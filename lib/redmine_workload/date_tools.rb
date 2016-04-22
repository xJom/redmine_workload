# -*- encoding : utf-8 -*-
module RedmineWorkload
  module DateTools

    WEEK = (1..7).to_a

    # array of all non working weekdays as day numbers. retrieved from global
    # config (Administration / Issues / Non-working days)
    def self.non_working_week_days
      Setting.non_working_week_days.map(&:to_i)
    end

    # Returns a Set of all regular working weekdays.
    # 1 is monday, 7 is sunday (same as in Date#cwday)
    def self.working_days
      (WEEK - non_working_week_days).to_set
    end

  end
end

