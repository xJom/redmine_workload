module RedmineWorkload

  # Workload distribution for issues with an estimated time as well as start
  # and due date present, taking into account the current work load of the
  # user.
  class IssueWorkload < Workload

    def initialize(issue, current_user_workload)
      today = current_user_workload.today
      super [today, issue.start_date || current_user_workload.timespan.first].compact.min..issue.due_date

      user = issue.assigned_to

      # now we try to fit in the necessary work for this issue so the least
      # amount of overtime results.

      # estimated remaining hours, taking progress percentage into account
      remaining_issue_hours = issue.remaining_working_hours

      # time span left for working on the issue
      remaining_days =
        Timespan.new [today, issue.start_date].compact.max..issue.due_date
      number_of_remaining_working_days =
        remaining_days.real_distance_in_days(user)

      # hours user is scheduled to work in that time
      remaining_user_hours = remaining_days.working_hours_for user

      # percentage of user time this issue will occupy
      workload = remaining_issue_hours.to_f / remaining_user_hours

      self.each do |workload_day|
        date = workload_day.date
        if date <= issue.due_date &&
          (issue.start_date.nil? || issue.start_date <= date)

          workload_day.active = true
          if date >= today && @timespan.working_day?(date, user)
            workload_day.add workload
            number_of_remaining_working_days -= 1
          end
        end
        break if number_of_remaining_working_days == 0
      end

    end

  end
end


