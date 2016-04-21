require 'redmine_workload/hooks'

module RedmineWorkload
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

  # Returns all issues that fulfill the following conditions:
  #  * They are open
  #  * The project they belong to is active
  def self.open_issues_for_users(users)
    user_ids = users.map(&:id)

    issue = Issue.arel_table
    project = Project.arel_table
    issue_status = IssueStatus.arel_table

    # Fetch all issues that ...
    issues = Issue.joins(:project).
                   joins(:status).
                   joins(:assigned_to).
                        where(issue[:assigned_to_id].in(user_ids)).      # Are assigned to one of the interesting users
                        where(project[:status].eq(1)).                  # Do not belong to an inactive project
                        where(issue_status[:is_closed].eq(false))       # Is open

    #  Filter out all issues that have children; They do not *directly* add to
    # the workload
    return issues.select { |x| x.leaf? }
  end

  # Returns the list of all users the current user may display.
  def self.users_allowed_to_display

    return [] if User.current.anonymous?
    return User.active if User.current.admin?

    result = [User.current]

    # Get all projects where the current user has the :view_project_workload
    # permission
    projects = Project.allowed_to(:view_project_workload)

    projects.each do |project|
      result += project.members.map(&:user)
    end

    return result.uniq
  end

  def self.users_of_groups(groups)
    groups.map do |grp|
      grp.users(&:users)
    end.tap do |result|
      result.flatten!
      result << User.current
      result.uniq!
    end
  end
end

