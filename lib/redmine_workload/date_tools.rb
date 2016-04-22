# -*- encoding : utf-8 -*-
class RedmineWorkload::DateTools

  WEEK = (1..7).to_a

  # array of all non working weekdays as day numbers. retrieved from global
  # config (Administration / Issues / Non-working days)
  def self.non_working_week_days
    Setting.non_working_week_days.map(&:to_i)
  end

  # Returns a Set of all regular working weekdays.
  # 1 is monday, 7 is sunday (same as in Date::cwday)
  def self.getWorkingDays()
    (WEEK - non_working_week_days).to_set
  end

  @@getWorkingDaysInTimespanCache = Hash::new

  def self.getWorkingDaysInTimespan(timeSpan, noCache = false)
    raise ArgumentError unless timeSpan.kind_of?(Range)

    return @@getWorkingDaysInTimespanCache[timeSpan] unless @@getWorkingDaysInTimespanCache[timeSpan].nil? || noCache

    workingDays = self::getWorkingDays()

    result = Set::new

    timeSpan.each do |day|
      if workingDays.include?(day.cwday) then
        result.add(day)
      end
    end

    @@getWorkingDaysInTimespanCache[timeSpan] = result

    return result
  end

  def self.getRealDistanceInDays(timeSpan)
    raise ArgumentError unless timeSpan.kind_of?(Range)

    return self::getWorkingDaysInTimespan(timeSpan).size
  end
end
