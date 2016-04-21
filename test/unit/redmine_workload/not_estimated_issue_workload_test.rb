require File.expand_path('../../../test_helper', __FILE__)

module RedmineWorkload
  class NotEstimatedIssueWorkloadTest < WorkloadTestCase

    setup do
      @user = User.generate!
      @user.pref.workload_hours_1 = '4' # works just 4 hours on mondays

      @thursday = Date.new(2013, 5, 30)
      @friday = Date.new(2013, 5, 31)
      @sunday = Date.new(2013, 6, 2)
      @monday = Date.new(2013, 6, 3)
      @tuesday = Date.new(2013, 6, 4)
      @wednesday = Date.new(2013, 6, 5)

      @ts = Timespan.new @thursday..@wednesday
      @user_workload = UserWorkload.new @ts, @user, @sunday
    end

    test 'should build from issue with start date in future' do
      issue = Issue.generate!(
        assigned_to: @user,
        due_date: nil,
        start_date: @tuesday,
      )

      expected = {
        @thursday => {
          hours: 0.0,
          active: false,
        },
        @friday => {
          hours: 0.0,
          active: false,
        },
        # Saturday
        Date.new(2013, 6, 1) => {
          hours: 0.0,
          active: false,
        },
        @sunday => {
          hours: 0.0,
          active: false,
        },
        # Monday
        Date.new(2013, 6, 3) => {
          hours: 0.0,
          active: false,
        },
        @tuesday => {
          hours: 0,
          active: true
        },
        @wednesday => {
          hours: 0,
          active: true
        }
      }

      w = NotEstimatedIssueWorkload.new issue, @user_workload

      assert_workload expected, w
    end

    test 'should build from issue with start and due date' do
      issue = Issue.generate!(
        assigned_to: @user,
        due_date: @tuesday,
        start_date: @friday,
        done_ratio: 25
      )

      expected = {
        @thursday => {
          hours: 0.0,
          active: false,
        },
        @friday => {
          hours: 0.0,
          active: true,
        },
        # Saturday
        Date.new(2013, 6, 1) => {
          hours: 0.0,
          active: true,
        },
        @sunday => {
          hours: 0.0,
          active: true,
        },
        # Monday
        Date.new(2013, 6, 3) => {
          hours: 0.0,
          active: true,
        },
        @tuesday => {
          hours: 0,
          active: true
        },
        @wednesday => {
          hours: 0,
          active: false
        }
      }

      w = NotEstimatedIssueWorkload.new issue, @user_workload
      assert_workload expected, w
    end

    test 'should build from issue with start date in past' do
      issue = Issue.generate!(
        assigned_to: @user,
        due_date: nil,
        start_date: @friday,
        done_ratio: 25
      )

      expected = {
        @thursday => {
          hours: 0.0,
          active: false,
        },
        @friday => {
          hours: 0.0,
          active: true,
        },
        # Saturday
        Date.new(2013, 6, 1) => {
          hours: 0.0,
          active: true,
        },
        @sunday => {
          hours: 0.0,
          active: true,
        },
        # Monday
        Date.new(2013, 6, 3) => {
          hours: 0.0,
          active: true,
        },
        @tuesday => {
          hours: 0,
          active: true
        },
        @wednesday => {
          hours: 0,
          active: true
        }
      }

      w = NotEstimatedIssueWorkload.new issue, @user_workload
      assert_workload expected, w
    end

    test 'should not build from issue with estimate' do
      issue = Issue.generate!(
        assigned_to: @user,
        due_date: @tuesday,
        start_date: @friday,
        estimated_hours: 8,
        done_ratio: 25
      )
      assert_raise(ArgumentError){
        NotEstimatedIssueWorkload.new issue, @user_workload
      }
    end

  end
end




