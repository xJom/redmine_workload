module RedmineWorkload
  class Timespan
    def initialize(date_range)
      raise ArgumentError unless Range === date_range && Date === date_range.first
      @date_range = date_range
    end

    def first
      @date_range.first
    end

    def working_day?(day, user = nil)
      work_week.include?(day.cwday) and
        user.nil? || user.working_hours(day) > 0
    end

    def holiday?(day, user = nil)
      !working_day?(day, user)
    end

    def include?(date)
      @date_range.include? date
    end

    def working_days(user = nil)
      (@working_days ||= {})[user] ||=
        @date_range.select{|day| working_day? day, user}
    end

    # sum of hours the given user is scheduled to work in range
    def working_hours_for(user)
      working_days(user).inject(0){|sum, date| sum += user.working_hours(date)}
    end

    def real_distance_in_days(user = nil)
      working_days(user).size
    end

    def each(&block)
      @date_range.each(&block)
    end

    def any?
      @date_range.any?
    end

    def first_work_day_from(date, user = nil)
      working_days(user).detect{|d| d >= date}
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
      @work_week ||= RedmineWorkload.working_days
    end
  end
end

