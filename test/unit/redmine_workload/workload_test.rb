require File.expand_path('../../../test_helper', __FILE__)

module RedmineWorkload
  class WorkloadTest < WorkloadTestCase

    setup do
      @monday = Date.new(2016, 4, 25)
      @tuesday = Date.new(2016, 4, 26)
      @sunday = Date.new(2016, 5, 1)
      @next_monday = Date.new(2016, 5, 2)

      @ts = Timespan.new @monday..@sunday
    end

    test 'should only get data for days in range' do
      w = Workload.new @ts
      assert d = w[@monday]
      assert_equal @monday, d.date
      assert d = w[@tuesday]
      assert_equal @tuesday, d.date
      assert_nil w[@next_monday]
    end

    test 'should get work hours for day' do
      w = Workload.new @ts
      assert_equal 0.0, w.workload(@monday)
      assert_equal 0.0, w.workload(@tuesday)
      assert_equal 0.0, w.workload(@sunday)
      assert_nil w.workload(@next_monday)

      w.add @monday, 2
      w.add WorkloadDay.new(@tuesday, 1.5)
      assert_equal 2.0, w.workload(@monday)
      assert_equal 1.5, w.workload(@tuesday)

      w.add @monday, 0.2
      assert_equal(2.2, w.workload(@monday))
    end

    test 'should add workload day with active flag' do
      w = Workload.new @ts
      wd = WorkloadDay.new @tuesday
      wd.active = true
      assert wd.active?
      assert !w[@tuesday].active?
      w.add wd
      assert w[@tuesday].active?
    end

    test 'should not allow add on holidays' do
      w = Workload.new @ts
      assert_raise(ArgumentError){ w.add @sunday, 2 }
    end

    test 'should not allow add outside of range' do
      w = Workload.new @ts
      assert_raise(ArgumentError){ w.add @next_monday, 2 }
    end

    test 'should add workload' do
      w1 = Workload.new @ts
      w1.add @monday, 2
      w2 = Workload.new @ts
      w2.add @monday, 2
      w2.add @tuesday, 3

      assert_equal 2.0, w1.workload(@monday)
      assert_equal 0.0, w1.workload(@tuesday)

      w1.add w2
      assert_equal 4.0, w1.workload(@monday)
      assert_equal 3.0, w2.workload(@tuesday)
      assert w1[@tuesday].active?
    end

  end
end

