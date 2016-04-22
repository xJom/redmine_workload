# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

class WorkloadDateToolsTest < WorkloadTestCase

  test "should return working week days" do
    with_settings 'non_working_week_days' => ['1', '6', '7'] do
      assert_equal Set.new([2, 3, 4, 5]),
        RedmineWorkload::DateTools.working_days
    end
  end

end
