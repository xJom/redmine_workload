# -*- encoding : utf-8 -*-
# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class WorkloadTestCase < ActiveSupport::TestCase

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

end
