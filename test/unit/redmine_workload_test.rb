# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

class RedmineWorkloadTest < WorkloadTestCase

  test "should return working week days" do
    with_settings 'non_working_week_days' => ['1', '6', '7'] do
      assert_equal Set.new([2, 3, 4, 5]),
        RedmineWorkload.working_days
    end
  end


  test "open_issues_for_users returns empty list if no users given" do
    user = User.generate!
    issue = Issue.generate!(:assigned_to => user,
                             :status => IssueStatus.find(1) # New, not closed
                           )

    assert_equal [], RedmineWorkload.open_issues_for_users([])
  end

  test "open_issues_for_users returns only issues of interesting users" do
    user1 = User.generate!
    user2 = User.generate!

    issue1 = Issue.generate!(:assigned_to => user1,
                             :status => IssueStatus.find(1) # New, not closed
                            )

    issue2 = Issue.generate!(:assigned_to => user2,
                             :status => IssueStatus.find(1) # New, not closed
                            )

    assert_equal [issue2], RedmineWorkload.open_issues_for_users([user2])
  end

  test "open_issues_for_users returns only open issues" do
    user = User.generate!

    issue1 = Issue.generate!(:assigned_to => user,
                             :status => IssueStatus.find(1) # New, not closed
                            )

    issue2 = Issue.generate!(:assigned_to => user,
                             :status => IssueStatus.find(6) # Rejected, closed
                            )

    assert_equal [issue1], RedmineWorkload.open_issues_for_users([user])
  end

  test "users_allowed_to_display returns an empty array if the current user is anonymus." do
    User.current = User.anonymous

    assert_equal [], RedmineWorkload.users_allowed_to_display
  end

  test "users_allowed_to_display returns only the user himself if user has no role assigned." do
    User.current = User.generate!

    assert_equal [User.current].map(&:id).sort, RedmineWorkload.users_allowed_to_display.map(&:id).sort
  end

  test "users_allowed_to_display returns all users if the current user is a admin." do
    User.current = User.generate!
    # Make this user an admin (can't do it in the attributes?!?)
    User.current.admin = true

    assert_equal User.active.map(&:id).sort, RedmineWorkload.users_allowed_to_display.map(&:id).sort
  end

  test "users_allowed_to_display returns exactly project members if user has right to see workload of project members." do
    User.current = User.generate!
    project = Project.generate!

    projectManagerRole = Role.generate!(:name => 'Project manager',
                                        :permissions => [:view_project_workload])

    User.add_to_project(User.current, project, [projectManagerRole]);

    projectMember1 = User.generate!
    User.add_to_project(projectMember1, project)
    projectMember2 = User.generate!
    User.add_to_project(projectMember2, project)

    # Create some non-member
    User.generate!

    assert_equal [User.current, projectMember1, projectMember2].map(&:id).sort,
      RedmineWorkload.users_allowed_to_display.map(&:id).sort
  end
end

