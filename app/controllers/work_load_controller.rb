# -*- encoding : utf-8 -*-
class WorkLoadController < ApplicationController

  helper :gantt
  helper :issues
  helper :projects
  helper :queries
  helper :workload

  include QueriesHelper

  def show
    workloadParameters = params[:workload] || {}

    @first_day = sanitizeDateParameter(workloadParameters[:first_day],
                                       User.current.today - 10)
    @last_day  = sanitizeDateParameter(workloadParameters[:last_day],
                                       User.current.today + 50)
    @today     = sanitizeDateParameter(workloadParameters[:start_date],
                                       User.current.today)

    # if @today ("select as today") is before @first_day take @today as @first_day
    @first_day = [@today, @first_day].min

    # Make sure that last_day is at most 12 months after first_day to prevent
    # long running times
    @last_day = [(@first_day >> 12) - 1, @last_day].min
    @timespan = RedmineWorkload::Timespan.new @first_day..@last_day

    initalizeUsers(workloadParameters)

    issues = RedmineWorkload.open_issues_for_users(@usersToDisplay)
    @workloads_by_user =
      RedmineWorkload::UserWorkload.build_for_issues issues,
                                                     @timespan,
                                                     @today
  end


  private

  def initalizeUsers(workloadParameters)
    @groupsToDisplay = Group.order('lastname ASC').all

    group_ids = workloadParameters[:groups].kind_of?(Array) ? workloadParameters[:groups] : []
    group_ids.map!(&:to_i)

    # Find selected groups:
    @selectedGroups = Group.where(id: group_ids)

    # take users of groups
    @usersToDisplay = RedmineWorkload.users_of_groups(@selectedGroups)

    user_ids = workloadParameters[:users].kind_of?(Array) ? workloadParameters[:users] : []
    user_ids.map!(&:to_i)

    # Get list of users that are allowed to be displayed by this user
    @usersAllowedToDisplay = RedmineWorkload.users_allowed_to_display.to_a
    @usersAllowedToDisplay.sort_by!(&:name)
    user_ids &= @usersAllowedToDisplay.map(&:id)

    # Get list of users that should be displayed.
    @usersToDisplay += User.where(id: user_ids)

    @usersToDisplay.sort_by!(&:name)
  end


  def sanitizeDateParameter(parameter, default)

    if (parameter.respond_to?(:to_date)) then
      return parameter.to_date
    else
      return default
    end
  end
end
