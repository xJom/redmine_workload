require File.expand_path('../../../test_helper', __FILE__)

module RedmineWorkload
  class WorkloadDayTest < WorkloadTestCase

    setup do
      @monday = Date.new(2016, 4, 25)
      @tuesday = Date.new(2016, 4, 26)
    end

    test 'should initialize with date and 0 workload' do
      d = WorkloadDay.new @monday
      assert_equal 0.0, d.workload
      assert_equal @monday, d.date
      assert !d.active?
    end

    test 'should add percentage from another workload' do
      d1 = WorkloadDay.new @monday, 0.2
      d2 = WorkloadDay.new @monday, 0.5
      d1.add d2
      assert_equal 0.7, d1.workload
      assert_equal 0.5, d2.workload
    end

    test 'should add workload directly' do
      d1 = WorkloadDay.new @monday, 0.1
      d1.add 1.2
      assert_equal 1.3, d1.workload
    end

    test 'should compute hours' do
      u = User.generate!
      u.pref.workload_hours_1 = '4'
      d1 = WorkloadDay.new @monday, 0.5
      wl = UserWorkload.new @monday..@tuesday, u, @monday
      d1.user_workload = wl
      assert_equal 2.0, d1.hours

    end

    test 'should refuse to add workload from a different day' do
      d1 = WorkloadDay.new @monday, 0.1
      d2 = WorkloadDay.new @tuesday, 0.3
      assert_raise(ArgumentError){ d1.add d2 }
      assert_raise(ArgumentError){ d2.add d1 }
    end

    test 'add should turn active flag on but not off again' do
      d1 = WorkloadDay.new @monday
      assert !d1.active?
      d2 = WorkloadDay.new @monday, 1
      assert d2.active?
      d3 = WorkloadDay.new @monday
      assert !d1.active?

      d1.add d2
      assert d1.active?
      d1.add d3
      assert d1.active?
    end

  end
end
