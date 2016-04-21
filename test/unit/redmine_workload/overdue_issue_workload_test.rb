require File.expand_path('../../../test_helper', __FILE__)

module RedmineWorkload
  class OverdueIssueWorkloadTest < WorkloadTestCase

    setup do
      @user = User.generate!
      @user.pref.workload_hours_1 = '4' # works just 4 hours on mondays

      @thursday = Date.new(2013, 5, 30)
      @friday = Date.new(2013, 5, 31)
      @sunday = Date.new(2013, 6, 2)
      @tuesday = Date.new(2013, 6, 4)
      @wednesday = Date.new(2013, 6, 5)

      @ts = Timespan.new @thursday..@wednesday
      @user_workload = UserWorkload.new @ts, @user, @sunday
    end

    test 'should build from issue with due date before today' do
      issue = Issue.generate!(
        assigned_to: @user,
        due_date: @friday,
        start_date: @friday,
        estimated_hours: 8,
        done_ratio: 25
      )

      expected = {
        @thursday => {
          workload: 0.0,
          active: false,
        },
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
          workload: 1.5, # 4 hours planned, 6 hours to work. For overdue issues all remaining hours are put on the next working day, regardless of the users existing load or working hours.
          active: true,
        },
        @tuesday => {
          workload: 0,
          active: false
        },
        @wednesday => {
          workload: 0,
          active: false
        }
      }

      w = OverdueIssueWorkload.new issue, @user_workload
      assert_workload expected, w
    end

    test 'should not build from issue with due date today or in future' do
      issue = Issue.generate!(
        assigned_to: @user,
        due_date: @sunday,
        start_date: @friday,
        estimated_hours: 8,
        done_ratio: 25
      )
      assert_raise(ArgumentError){
        OverdueIssueWorkload.new issue, @user_workload
      }

      issue = Issue.generate!(
        assigned_to: @user,
        due_date: @wednesday,
        start_date: @friday,
        estimated_hours: 8,
        done_ratio: 25
      )
      assert_raise(ArgumentError){
        OverdueIssueWorkload.new issue, @user_workload
      }
    end

  end
end


