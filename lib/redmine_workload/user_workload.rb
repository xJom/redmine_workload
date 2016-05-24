module RedmineWorkload

  class UserWorkload < Workload

    attr_reader :project_workloads, :invisible_issue_workload,
                :today, :user,
                :project_overdues, :overdue_hours, :overdue_number

    def self.build_for_issues(issues, timespan, today)
      {}.tap do |result|
        issues.each do |issue|
          if assignee = issue.assigned_to
            wl = (result[assignee.id] ||= new(timespan, assignee, today))
            wl.add_issue issue
          end
        end
      end
    end

    def initialize(timespan, user, today = timespan.first)
      # second argument is used in the @days hash default proc, see
      # Workload#initialize
      super timespan, self

      @overdue_number = 0
      @overdue_hours = 0.0
      @project_overdues = Hash.new{|h,k| h[k] = {overdue_hours: 0.0,
                                                 overdue_number: 0} }

      @user = user
      @today = today
      @invisible_issue_workload = Workload.new timespan, self
      @project_workloads = Hash.new{|h,k| h[k] = Hash.new{|h, k| h[k] = Workload.new timespan, self } }
    end

    def working_hours(date)
      holiday?(date) ? 0.0 : @user.working_hours(date)
    end

    def working_hours_in_range(timespan = @timespan)
      timespan.working_hours_for(@user)
    end

    # next non-holiday on or after @today
    def next_work_day
      @timespan.first_work_day_from(@today, @user)
    end

    # issues with earlier due dates should be added first
    def add_issue(issue)
      raise ArgumentError unless issue.assigned_to == @user

      if issue.overdue?
        if hours = issue.remaining_working_hours
          @overdue_number += 1
          @overdue_hours += hours
          @project_overdues[issue.project][:overdue_number] += 1
          @project_overdues[issue.project][:overdue_hours] += hours
        end
      elsif issue_workload = build_issue_workload(issue)
        self.add issue_workload
        if issue.visible?
          @project_workloads[issue.project][:summary].add issue_workload
          @project_workloads[issue.project][issue].add issue_workload
        else
          @invisible_issue_workload.add issue_workload
        end
      end
    end

    def holiday?(date)
      @timespan.holiday? date, @user
    end

    private

    def build_issue_workload(issue)
      return nil unless issue.assigned_to.present?

      if issue.workload_not_estimated?
        NotEstimatedIssueWorkload.new issue, self

      elsif issue.workload_overdue?(@today)
        OverdueIssueWorkload.new issue, self

      else
        IssueWorkload.new issue, self
      end
    end

  end
end
