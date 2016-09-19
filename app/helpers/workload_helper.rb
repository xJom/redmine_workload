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

  def get_option_tags_for_userselection(usersToShow, selectedUsers)

    result = '';

    usersToShow.each do |user|
      selected = selectedUsers.include?(user) ? 'selected="selected"' : ''

      result += "<option value=\"#{h(user.id)}\" #{selected}>#{h(user.name)}</option>"
    end

    return result.html_safe
  end

  def get_option_tags_for_groupselection(groupsToShow, selectedGroups)

    result = '';

    groupsToShow.each do |group|

      selected = selectedGroups.include?(group) ? 'selected="selected"' : ''

     result += "<option value=\"#{h(group.id)}\" #{selected}>#{h(group.lastname)}</option>"

    end


    return result.html_safe
  end
end
