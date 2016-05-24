require File.expand_path('../../../test_helper', __FILE__)

module RedmineWorkload
  class UserWorkloadTest < WorkloadTestCase

    setup do
      @user = User.generate!
      @user.pref.workload_hours_1 = '4' # monday

      today = Date.today
      # base line is the next monday
      @monday = today + 8 - today.cwday
      @tuesday = @monday + 1
      @sunday = @monday + 6
      @next_monday = @monday + 7

      @ts = Timespan.new @monday..@sunday
    end


    test 'should build from issue that exceeds time span' do
      today = @monday
      issue = Issue.generate!(
        assigned_to: @user,
        start_date: @tuesday,
        due_date: @next_monday,
        estimated_hours: 43.2,
        done_ratio: 0
      )

      expected = {
        @monday => {
          workload: 0.0,
          active: false,
        },
        @tuesday => {
          workload: 1.2,
          active: true,
        },
        @tuesday+1 => {
          workload: 1.2,
          active: true,
        },
        @tuesday+2 => {
          workload: 1.2,
          active: true,
        },
        @tuesday+3 => {
          workload: 1.2,
          active: true,
        },
        # saturday
        @tuesday+4 => {
          workload: 0.0,
          active: true,
        },
        @sunday => {
          workload: 0.0,
          active: true,
        },
        # remaining hours on next_monday, which is out of
        # current_user_workload range
      }

      w = UserWorkload.new @ts, @user, today
      w.add_issue issue

      assert_workload expected, w
    end


    test 'should work for issue within time span' do
      friday = @monday - 3
      sunday = @monday - 1
      wednesday = @tuesday + 1
      issue = Issue.generate!(
        assigned_to: @user,
        start_date: friday,
        due_date: wednesday,
        estimated_hours: 6.0,
        done_ratio: 0
      )

      expected = {
        friday-1 => {
          workload: 0,
          active: false
        },
        friday => {
          workload: 0.0,
          active: true,
        },
        friday + 1 => {
          workload: 0.0,
          active: true,
        },
        sunday => {
          workload: 0.0,
          active: true,
        },
        @monday => {
          workload: 0.5,
          active: true,
        },
        @tuesday => {
          workload: 0.5,
          active: true,
        },
        wednesday => {
          workload: 0,
          active: false,
        },
      }

      with_wednesday_as_holiday do

        w = UserWorkload.new (friday-1..wednesday), @user, sunday
        w.add_issue issue

        assert_workload expected, w
      end
    end

    test 'should get working hours for day' do
      w = UserWorkload.new @ts, @user
      assert_equal 4.0, w.working_hours(@monday)
      assert_equal 8.0, w.working_hours(@tuesday)
      assert_equal 0.0, w.working_hours(@sunday)
      # next_monday is out of range but still the workload should return the
      # default value for this user and weekday
      assert_equal 4.0, w.working_hours(@next_monday)
    end

    test 'should compute working hours for timespan' do
      w = UserWorkload.new @ts, @user
      assert_equal 12, w.working_hours_in_range(Timespan.new(@monday..@tuesday))
      assert_equal 36, w.working_hours_in_range(Timespan.new(@tuesday..@next_monday))
    end

    test 'should not allow add on holidays' do
      @user.pref.workload_hours_2 = '0' # make tuesday a holiday for this user
      w = UserWorkload.new @ts, @user
      assert_raise(ArgumentError){ w.add @sunday, 1 }
      assert_raise(ArgumentError){ w.add @tuesday, 0.1 }
    end

  end
end


