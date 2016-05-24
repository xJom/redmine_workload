require File.expand_path('../../../test_helper', __FILE__)

module RedmineWorkload
  class IssueWorkloadTest < WorkloadTestCase

    setup do
      @user = User.generate!
      @user.pref.workload_hours_1 = '4' # works just 4 hours on mondays

      @friday = Date.new(2013, 5, 31)
      @sunday = Date.new(2013, 6, 2)
      @monday = Date.new(2013, 6, 3)
      @tuesday = Date.new(2013, 6, 4)
      @wednesday = Date.new(2013, 6, 5)
      @thursday = Date.new(2013, 6, 6)

      @ts = Timespan.new @friday..@wednesday
      @user_workload = UserWorkload.new @ts, @user, @sunday
    end

    test 'should not book on users free days' do
      @user.pref.workload_hours_1 = '0' # free mondays
      issue = Issue.generate!(
        assigned_to: @user,
        start_date: @friday,
        due_date: @tuesday,
        estimated_hours: 6.0,
        done_ratio: 0
      )

      expected = {
        @friday => {
          workload: 0.0,
          active: true,
        },
        # Saturday
        Date.new(2013, 6, 1) => {
          workload: 0.0,
          active: true,
        },
        @sunday => {
          workload: 0.0,
          active: true,
        },
        # Monday
        Date.new(2013, 6, 3) => {
          workload: 0.0,
          active: true,
        },
        @tuesday => {
          workload: 0.75,
          active: true,
        },
      }

      w = IssueWorkload.new issue, @user_workload
      assert_workload expected, w
    end

    test 'should build from issue that exceeds parent time window' do
      issue = Issue.generate!(
        assigned_to: @user,
        start_date: @monday,
        due_date: @thursday+1,
        estimated_hours: 43.2,
        done_ratio: 0
      )

      expected = {
        @sunday => {
          workload: 0.0,
          active: false,
        },
        @monday => {
          workload: 1.2,
          active: true,
        },
        @tuesday => {
          workload: 1.2,
          active: true,
        },
        @wednesday => {
          workload: 1.2,
          active: true,
        },
        # user_workload only goes to wednesday but the per issue time window
        # reaches until the due date
        @thursday => {
          workload: 1.2,
          active: true,
        },
        @thursday+1 => {
          workload: 1.2,
          active: true,
        },
      }

      w = IssueWorkload.new issue, @user_workload
      assert_workload expected, w
    end

    test 'should never book on sunday' do
      monday = Date.new(2016, 4, 25)
      tuesday = Date.new(2016, 4, 26)
      sunday = Date.new(2016, 5, 1)
      next_monday = Date.new(2016, 5, 2)

      ts = Timespan.new monday..sunday
      user_workload = UserWorkload.new ts, @user, sunday

      issue = Issue.generate!(
        assigned_to: @user,
        start_date: tuesday,
        due_date: next_monday,
        estimated_hours: 16.0,
        done_ratio: 0
      )

      expected = {
        tuesday => {
          workload: 0.0,
          active: true,
        },
        tuesday+1 => {
          workload: 0.0,
          active: true,
        },
        tuesday+2 => {
          workload: 0.0,
          active: true,
        },
        tuesday+3 => {
          workload: 0.0,
          active: true,
        },
        # saturday
        tuesday+4 => {
          workload: 0.0,
          active: true,
        },
        sunday => {
          workload: 0.0,
          active: true,
        },
        next_monday => {
          workload: 4.0, # 4 times four hours
          active: true,
        },
      }

      w = IssueWorkload.new issue, user_workload
      assert_workload expected, w
    end

    test 'should build from issue that fits in time window' do
      issue = Issue.generate!(
        assigned_to: @user,
        start_date: @friday,
        due_date: @tuesday,
        estimated_hours: 6.0,
        done_ratio: 0
      )

      expected = {
        @friday => {
          workload: 0.0,
          active: true,
        },
        # Saturday
        Date.new(2013, 6, 1) => {
          workload: 0.0,
          active: true,
        },
        @sunday => {
          workload: 0.0,
          active: true,
        },
        # Monday
        Date.new(2013, 6, 3) => {
          workload: 0.5,
          active: true,
        },
        @tuesday => {
          workload: 0.5,
          active: true,
        },
      }

      w = IssueWorkload.new issue, @user_workload

      # wednesday is past the issue's due date
      assert_nil w[@wednesday]

      assert_workload expected, w
    end

    test 'should build from issue without start date' do
      issue = Issue.generate!(
        assigned_to: @user,
        start_date: nil,
        due_date: @tuesday,
        estimated_hours: 6,
        done_ratio: 0
      )

      expected = {
        @friday => {
          workload: 0.0,
          active: true,
        },
        # Saturday
        Date.new(2013, 6, 1) => {
          workload: 0.0,
          active: true,
        },
        @sunday => {
          workload: 0.0,
          active: true,
        },
        # Monday
        Date.new(2013, 6, 3) => {
          workload: 0.5,
          active: true,
        },
        @tuesday => {
          workload: 0.5,
          active: true,
        },
      }

      w = IssueWorkload.new issue, @user_workload

      # wednesday is past the issue's due date
      assert_nil w[@wednesday]

      assert_workload expected, w
    end

  end
end

