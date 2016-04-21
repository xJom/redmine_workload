module RedmineWorkload
  class NotEstimatedIssueWorkload < Workload

    def initialize(issue, current_user_workload)
      unless issue.workload_not_estimated?
        raise ArgumentError, "issue #{issue} has estimated hours and due date."
      end

      super current_user_workload.timespan

      self.each do |workload_day|
        date = workload_day.date

        # A day is active if it is on or after the start and on or before the
        # due date
        workload_day.active =
          (issue.start_date.nil? || issue.start_date <= date) &&
          (issue.due_date.nil? || issue.due_date >= date)
      end

    end

  end
end

