module WorkloadHelper
  def workload_day_class(workload_day)
    'hours'.tap do |klass|
      if workload_day.holiday?
        klass << ' holiday'
      else
        klass << ' workingday'
      end
      if workload_day.active?
        klass << ' active'
      else
        klass << ' not-active'
      end
      klass << ' today' if workload_day.today?
      klass << ' ' + load_class_for(workload_day.workload)
    end
  end

  def format_workload_hours(hours)
     (hours.abs < 0.01) ? '' : sprintf("%.1f", hours)
  end

  # Returns the "load class" for a given amount of working hours on a single
  # day.
  def load_class_for(workload)
    config = Setting['plugin_redmine_workload']
    workload = Float(workload) * 100

    if workload < config['threshold_lowload_min'].to_f
      return "none"
    elsif workload < config['threshold_normalload_min'].to_f
      return "low"
    elsif workload < config['threshold_highload_min'].to_f
      return "normal"
    else
      return "high"
    end
  end

end
