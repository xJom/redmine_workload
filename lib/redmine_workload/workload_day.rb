module RedmineWorkload
  class WorkloadDay

    attr_reader :workload, :date
    attr_writer :active, :user_workload

    def initialize(date, workload = 0.0)
      @date  = date
      @workload = Float(workload)
      @active = @workload > 0.0
    end

    def today?
      @user_workload.today == @date if @user_workload
    end

    def holiday?
      @user_workload.holiday? @date if @user_workload
    end

    def user
      @user_workload.user if @user_workload
    end

    def hours
      workload * @user_workload.working_hours(@date) if @user_workload
    end

    def active?
      !!@active
    end

    def add(other)
      case other
      when WorkloadDay
        if other.date != @date
          raise ArgumentError, "cannot add workload from #{other.date} to #{@date}"
        end
        @workload += other.workload
        @active |= other.active?
      when Numeric
        @workload += other
        @active |= (@workload > 0.0)
      end
      self
    end

  end
end
