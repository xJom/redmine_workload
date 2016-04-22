# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

class WorkloadTimespanTest < WorkloadTestCase

  test "working_days works if start and end day are equal and no holiday." do

    date = Date.new(2005, 12, 30)      # A friday
    assert_equal [date],
      RedmineWorkload::Timespan.new(date..date).working_days
  end

  test "working_days works if start and end day are equal and a holiday." do

    # Set friday to be a holiday.
    with_settings 'non_working_week_days' => ['5', '6', '7'] do

      date = Date.new(2005, 12, 30)      # A friday
      assert_equal [],
        RedmineWorkload::Timespan.new(date..date).working_days
    end
  end

  test "working_days_in_timespan works if start day before end day." do

    startDate = Date.new(2005, 12, 30) # A friday
    endDate = Date.new(2005, 12, 28)   # A wednesday
    assert_equal [],
      RedmineWorkload::Timespan.new(startDate..endDate).working_days
  end

  test "working_days_in_timespan works if both days follow each other and are holidays." do

    # Set wednesday and thursday to be a holiday.
    with_settings 'non_working_week_days' => ['3', '4', '6', '7'] do

      startDate = Date.new(2005, 12, 28) # A wednesday
      endDate = Date.new(2005, 12, 29)     # A thursday
      assert_equal [],
        RedmineWorkload::Timespan.new(startDate..endDate).working_days
    end
  end

  test "working_days_in_timespan works if only weekends and mondays are holidays and startday is thursday, endday is tuesday." do

    with_settings 'non_working_week_days' => ['1', '6', '7'] do

      startDate = Date.new(2005, 12, 29) # A thursday
      endDate = Date.new(2006, 1, 3)     # A tuesday

      expected = [
        startDate,
        Date::new(2005, 12, 30),
        endDate
      ]

      assert_equal expected,
        RedmineWorkload::Timespan.new(startDate..endDate).working_days
    end
  end

  test "getMonthsBetween returns [] if last day after first day" do
    firstDay = Date.new(2012, 3, 29)
    lastDay = Date.new(2012, 3, 28)

    assert_equal [], RedmineWorkload::Timespan.new(firstDay..lastDay).months.map{|hsh| hsh[:first_day].month}
  end

  test "getMonthsBetween returns [3] if both days in march 2012 and equal" do
    firstDay = Date.new(2012, 3, 27)
    lastDay = Date.new(2012, 3, 27)

    assert_equal [3], RedmineWorkload::Timespan.new(firstDay..lastDay).months.map{|hsh| hsh[:first_day].month}
  end

  test "getMonthsBetween returns [3] if both days in march 2012 and different" do
    firstDay = Date.new(2012, 3, 27)
    lastDay = Date.new(2012, 3, 28)

    assert_equal [3], RedmineWorkload::Timespan.new(firstDay..lastDay).months.map{|hsh| hsh[:first_day].month}
  end

  test "getMonthsBetween returns [3, 4, 5] if first day in march and last day in may" do
    firstDay = Date.new(2012, 3, 31)
    lastDay = Date.new(2012, 5, 1)

    assert_equal [3, 4, 5], RedmineWorkload::Timespan.new(firstDay..lastDay).months.map{|hsh| hsh[:first_day].month}
  end

  test "getMonthsBetween returns correct result timespan overlaps year boundary" do
    firstDay = Date.new(2011, 3, 3)
    lastDay = Date.new(2012, 5, 1)

    assert_equal (3..12).to_a.concat((1..5).to_a), RedmineWorkload::Timespan.new(firstDay..lastDay).months.map{|hsh| hsh[:first_day].month}
  end
end

