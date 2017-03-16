# -*- encoding : utf-8 -*-
require 'redmine'

require_dependency 'redmine_workload'

require_dependency 'redmine_workload'

Rails.configuration.to_prepare do
  RedmineWorkload::IssuePatch.apply
  RedmineWorkload::UserPatch.apply
  RedmineWorkload::UserPreferencePatch.apply
end

Redmine::Plugin.register :redmine_workload do
  name 'Redmine workload plugin'
  author 'Jost Baron'
  description 'This is a plugin for Redmine, originally developed by Rafael Calleja. It ' +
              'displays the estimated number of hours users have to work to finish ' +
              'all their assigned issus on time.'
  version '1.0.4c'
  url 'https://github.com/JostBaron/redmine_workload'
  author_url 'http://netzkönig.de/'

  menu :top_menu, :WorkLoad, { :controller => 'work_load', :action => 'show' }, :caption => :workload_title,
    :after => :crm_top_menu,
    :if =>  Proc.new { User.current.logged? }

  menu :admin_menu, :workload, {:controller => 'settings', :action => 'plugin', :id => "redmine_workload"}, :caption => :workload_title

  settings :partial => 'settings/workload_settings',
           :default => {
              'threshold_lowload_min'     => 1,
              'threshold_normalload_min'  => 80,
              'threshold_highload_min'    => 101
           }

  permission :view_project_workload, :work_load => :show

end

class RedmineToolbarHookListener < Redmine::Hook::ViewListener
   def view_layouts_base_html_head(context)
		 javascript_include_tag('slides', :plugin => :redmine_workload ) +
     stylesheet_link_tag('style', :plugin => :redmine_workload )
   end
end
