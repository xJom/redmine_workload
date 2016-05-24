# -*- encoding : utf-8 -*-
# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class WorkloadTestCase < ActiveSupport::TestCase

  fixtures :trackers, :projects, :projects_trackers, :members, :member_roles,
           :users, :issue_statuses, :enumerations, :roles, :enabled_modules

  def with_plugin_settings(settings = {}, &block)
    with_settings(
      {
        'plugin_redmine_workload' => {
          'threshold_lowload_min' => 0.1,
          'threshold_normalload_min' => 7.0,
          'threshold_highload_min' => 8.5,
        }.merge(settings)
      }, &block
    )
  end

  # Set Saturday, Sunday and Wednesday to be a holiday, all others to be a
  # working day.
  def with_wednesday_as_holiday(&block)
    with_settings('non_working_week_days' => ['3', '6', '7'], &block)
  end

  def assert_workload(expected, workload)
    expected.each do |date, r|
      assert wd = workload[date], "should have record for #{date}"
      assert_in_delta r[:workload], wd.workload, 1e-4, "wrong workload on #{date}"
      assert_equal r[:active], wd.active?, "wrong active flag on #{date}"
    end
  end

end
