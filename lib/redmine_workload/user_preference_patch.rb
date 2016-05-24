module RedmineWorkload
  module UserPreferencePatch

    def self.apply
      unless UserPreference < UserPreferencePatch
        UserPreference.send :prepend, UserPreferencePatch
      end
    end

    def self.prepended(base)
      base.class_eval do
        1.upto(7) do |d|
          attr = "workload_hours_#{d}".to_sym
          define_method :"#{attr}=" do |h|
            self[attr] = h
          end
          define_method attr do
            self[attr].blank? ? 8 : self[attr]
          end
        end
      end
    end

    def workload_hours(day)
      send(:"workload_hours_#{day}").to_f
    end

  end
end
