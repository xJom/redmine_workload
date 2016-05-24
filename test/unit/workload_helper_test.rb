# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

class WorkloadHelperTest < WorkloadTestCase
  include WorkloadHelper

  test 'should compute css class for day' do
    monday = Date.new(2016, 4, 25)
    sunday = Date.new(2016, 5, 1)
    u = User.generate!
    wl = RedmineWorkload::UserWorkload.new monday..sunday, u, monday
    wld = RedmineWorkload::WorkloadDay.new monday, 0.25
    wl.add wld
    wld.user_workload = wl
    assert_equal 'hours workingday active today low', workload_day_class(wld)
  end

  test "load_class_for returns \"none\" for workloads below threshold for low workload" do
    with_load_settings 1, 50.0, 70.0 do
      assert_equal "none", load_class_for(0.005)
    end
  end

  test "load_class_for returns \"low\" for workloads between thresholds for low and normal workload" do
    with_load_settings 1, 50, 70 do
      assert_equal "low", load_class_for(0.3)
    end
  end

  test "load_class_for returns \"normal\" for workloads between thresholds for normal and high workload" do
    with_load_settings 1, 20, 70 do
      assert_equal "normal", load_class_for(0.3)

    end
  end

  test "load_class_for returns \"high\" for workloads above threshold for high workload" do
    with_load_settings 1, 20, 90 do
      assert_equal "high", load_class_for(1)
    end
  end

  def with_load_settings(low, normal, high, &block)
    with_plugin_settings(
      {
        'threshold_lowload_min' => low,
        'threshold_normalload_min' => normal,
        'threshold_highload_min' => high,
      }, &block
    )
  end
end
