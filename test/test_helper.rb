# -*- encoding : utf-8 -*-
# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class WorkloadTestCase < ActiveSupport::TestCase

  def with_plugin_settings(settings = {}, &block)
    with_settings(
      {
        'plugin_redmine_workload' => {
          'general_workday_monday' => 'checked',
          'general_workday_tuesday' => 'checked',
          'general_workday_wednesday' => 'checked',
          'general_workday_thursday' => 'checked',
          'general_workday_friday' => 'checked',
          'general_workday_saturday' => '',
          'general_workday_sunday' => '',
          'threshold_lowload_min' => 0.1,
          'threshold_normalload_min' => 7.0,
          'threshold_highload_min' => 8.5,
        }.merge(settings)
      }, &block
    )
  end

end
