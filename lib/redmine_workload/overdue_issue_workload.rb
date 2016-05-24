module RedmineWorkload
  # If issue is overdue and the remaining time may be estimated, all
  # remaining hours are put on first working day after today
  class OverdueIssueWorkload < Workload

    def initialize(issue, current_user_workload)
      today = current_user_workload.today

      unless issue.workload_overdue?(today)
        raise ArgumentError, "issue #{issue} is not overdue"
      end

      super current_user_workload.timespan

      self.each do |workload_day|
        date = workload_day.date

        # A day is active if it is after the issue start and before today
        workload_day.active =
          date <= today && (issue.start_date.nil? || issue.start_date <= date)
      end

      if first_work_day = current_user_workload.next_work_day
        baseline = current_user_workload.user.working_hours(first_work_day)
        workload = issue.remaining_working_hours / baseline.to_f
        self[first_work_day].add workload
      end
    end

  end
end
