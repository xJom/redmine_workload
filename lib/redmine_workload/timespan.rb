module RedmineWorkload
  class Timespan
    def initialize(date_range)
      @date_range = date_range
    end

    def working_day?(day)
      working_days.include? day
    end

    def holiday?(day)
      !working_day?(day)
    end

    def working_days
      @working_days ||= @date_range.select{|day| work_week.include? day.cwday}
    end

    def real_distance_in_days
      working_days.size
    end

    def each(&block)
      @date_range.each(&block)
    end

    def any?
      @date_range.any?
    end

    def first_work_day_from(date)
      working_days.detect{|d| d >= date}
    end

    # Returns an array with one entry for each month in the given time span.
    # Each entry is a hash with two keys: :first_day and :last_day, having the
    # first resp. last day of that month from the time span as value.
    def months
      @months ||= begin
        # Abort if the given time span is empty.
        return [] unless any?

        first_of_mon = @date_range.first
        last = @date_range.last

        last_of_mon = ->(date){ [date.end_of_month, last].min}

        [].tap do |result|
          while first_of_mon <= @date_range.last do
            result << {
              first_day: first_of_mon,
              last_day: last_of_mon.call(first_of_mon)
            }
            first_of_mon = first_of_mon.beginning_of_month.next_month
          end
        end
      end
    end

    private

    def work_week
      @work_week ||= DateTools.working_days
    end
  end
end
