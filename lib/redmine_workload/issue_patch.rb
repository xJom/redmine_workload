module RedmineWorkload
  module IssuePatch
    def self.apply
      Issue.send :prepend, IssuePatch unless Issue < IssuePatch
    end

    def remaining_working_hours
      return 0.0 if estimated_hours.blank?
      return 0.0 if children.any?
      return estimated_hours*((100.0 - done_ratio)/100.0)
    end

    # true if the issue is considered overdue for workload computations
    def workload_overdue?(today)
      due_date.present? &&
        due_date < today &&
        remaining_working_hours > 0
    end

    def workload_not_estimated?
      due_date.nil? || estimated_hours.to_i.zero?
    end

  end
end
