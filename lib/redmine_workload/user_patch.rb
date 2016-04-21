module RedmineWorkload
  module UserPatch
    def self.apply
      User.send :prepend, UserPatch unless User < UserPatch
    end

    def working_hours(date)
      pref.workload_hours date.cwday
    end

    def working_day?(date)
      !working_hours(date).zero?
    end
  end
end
