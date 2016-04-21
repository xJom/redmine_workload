# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

class PatchedIssueTest < WorkloadTestCase

  fixtures :trackers, :projects, :projects_trackers, :users,
           :issue_statuses, :enumerations, :enabled_modules


  test "remaining_working_hours works for issue without children." do
    issue = Issue.generate!(:estimated_hours => 13.2)
    assert_in_delta 13.2, issue.remaining_working_hours, 1e-4
  end

  test "remaining_working_hours works for issue with children." do
    parent = Issue.generate!(:estimated_hours => 3.6)
    child1 = Issue.generate!(:estimated_hours => 5.0, :parent_issue_id => parent.id, :done_ratio => 90)
    child2 = Issue.generate!(:estimated_hours => 9.0, :parent_issue_id => parent.id)

    # Force parent to reload so the data from the children is incorporated.
    parent.reload

    assert_in_delta 0.0, parent.remaining_working_hours, 1e-4
    assert_in_delta 0.5, child1.remaining_working_hours, 1e-4
    assert_in_delta 9.0, child2.remaining_working_hours, 1e-4
  end

  test "remaining_working_hours works for issue with grandchildren." do
    parent = Issue.generate!(:estimated_hours => 4.5)
    child = Issue.generate!(:estimated_hours => 5.0, :parent_issue_id => parent.id)
    grandchild = Issue.generate!(:estimated_hours => 9.0, :parent_issue_id => child.id, :done_ratio => 40)

    # Force parent and child to reload so the data from the children is
    # incorporated.
    parent.reload
    child.reload

    assert_in_delta 0.0, parent.remaining_working_hours, 1e-4
    assert_in_delta 0.0, child.remaining_working_hours, 1e-4
    assert_in_delta 5.4, grandchild.remaining_working_hours, 1e-4
  end

end

