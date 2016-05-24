module RedmineWorkload

  # Workload for a timespan.
  #
  # Maintains a list of days and hours worked.
  class Workload

    attr_reader :timespan

    def initialize(timespan, user_workload = nil)
      @timespan = if Timespan === timespan
        timespan
      else
        Timespan.new timespan
      end
      @days = Hash.new do |hsh, date|
        wld = WorkloadDay.new(date)
        wld.user_workload = user_workload
        hsh[date] = wld
      end
    end

    def empty?
      @days.values.inject(0.0){|sum, wld| sum += wld.hours} == 0.0
    end

    def [](date)
      @days[date] if in_range?(date)
    end

    # currently recorded workload for date
    def workload(date)
      self[date].workload if in_range?(date)
    end

    def each(&block)
      @timespan.each do |date|
        yield self[date]
      end
    end

    def add(workload_day_or_date, hours = 0.0)
      case workload_day_or_date
      when Workload
        workload_day_or_date.each{ |w_day| add w_day if in_range?(w_day.date) }
      when WorkloadDay
        if existing = self[workload_day_or_date.date]
          existing.add workload_day_or_date
        else
          raise ArgumentError, "invalid date: #{workload_day_or_date.date}"
        end
      when Date
        if existing = self[workload_day_or_date]
          if holiday? workload_day_or_date
            raise ArgumentError, "cannot add hours on holiday: #{workload_day_or_date}"
          else
            existing.add hours
          end
        else
          raise ArgumentError, "invalid date: #{workload_day_or_date}"
        end
      else
        raise ArgumentError,
          "cannot add #{workload_day_or_date.class.name} to workload"
      end
    end

    def holiday?(date)
      @timespan.holiday? date
    end

    private

    def in_range?(date)
      @timespan.include?(date)
    end

  end

end
