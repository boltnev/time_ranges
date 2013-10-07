require 'spec_helper'
require 'time_range'
require 'date'

DAY = 3600 * 24

describe :time_range do
  let(:time_range) { TimeRange.new(Time.now - 10, Time.now + 10) }

  context :responds_to do
    it '.begin' do
      time_range.should respond_to(:begin)
    end

    it '.end' do
      time_range.should respond_to(:end)
    end

    it '.intersection' do
      time_range.should respond_to(:subtract)
    end

    it '.intersects?' do
      time_range.should respond_to(:intersects?)
    end

    it '.include?' do
      time_range.should respond_to(:include?)
    end

    it '.fully_include?' do
      time_range.should respond_to(:fully_include?)
    end

    it 'self.union' do
      TimeRange.should respond_to(:union)
    end

    it 'self.intersection' do
      TimeRange.should respond_to(:intersection)
    end

    it 'self.for_date' do
      TimeRange.should respond_to(:for_date)
    end

  end

  context :time_ranges_interaction do
    let(:time1){ Time.now - 1 * DAY }
    let(:time2){ Time.now + 1 * DAY }
    let(:time3){ Time.now }
    let(:time4){ Time.now + 2 * DAY }
    let(:time5){ Time.now + 5 * DAY }
    let(:time6){ Time.now + 7 * DAY }

    let(:time_range1) { TimeRange.new(time1, time2) }
    let(:time_range2) { TimeRange.new(time3, time4) }
    let(:time_range3) { TimeRange.new(time1, time3) }
    let(:time_range4) { TimeRange.new(time2, time4) }
    let(:time_range5) { TimeRange.new(time5, time6) }
    
    it '.intersects?' do
      time_range1.intersects?(time_range2).should be_true
      time_range2.intersects?(time_range1).should be_true
      time_range3.intersects?(time_range4).should be_false
      time_range4.intersects?(time_range3).should be_false
    end

    # Delegate method
    it '.intersection' do
      time_range1.intersection(time_range2).should eq time_range2.intersection(time_range1)
    end

    it '.include?' do
      time_range1.include?(Time.now).should be_true
      time_range4.include?(Time.now).should be_false
      time_range1.include?(Date.today).should be_true      
      time_range4.include?(Date.today).should be_false
    end

    it '.fully_include?' do
      time_range1.fully_include?(time_range2).should be_false
      time_range1.fully_include?(TimeRange.new(time3 - 5, time3 + 5)).should be_true
    end

    it '.subtract' do
      subtraction =  TimeRange.new(time1, time6).subtract(time_range2)
      subtraction.should eq [TimeRange.new(time1, time3), TimeRange.new(time4, time6)]
      subtraction =  TimeRange.new(time1, time6).subtract(time_range2, time_range5)
      subtraction.should eq [TimeRange.new(time1, time3), TimeRange.new(time4, time5)]
    end

    it '.subtract more complex' do
      range = TimeRange.for_date(Date.today)
      time1 = Time.now
      time2 = Time.now + 100
      time3 = Time.now + 200
      time4 = Time.now + 300
      range2 = TimeRange.new(time1, time2)   
      range3 = TimeRange.new(time3, time4)

      range.subtract(range2, range3).count.should eq 3   
      range.subtract(TimeRange.new(Time.now + 400, Time.now + 500 ),
                     TimeRange.new(Time.now + 300, Time.now + 350)).count.should eq 3
    end

    it '.substract with empty array' do
      subtraction =  TimeRange.new(time1, time6).subtract([])
      subtraction.should eq TimeRange.new(time1, time6)
    end

    it '.length' do
      time_range1.length.round(2).should eq (2 * 24 * 3600) 
    end

    context :class_methods do
      it 'self.for_date' do
        TimeRange.for_date(Date.today).should eq TimeRange.new(Date.today.to_time, Date.today.to_time + DAY - 1) # end_of day
      end
      
      it '.sum_length' do
        TimeRange.sum_length([time_range1, time_range2]).round(2).should eq (2 * 2 * 24 * 3600) 
      end

      context :intersection  do
        it '.intersection' do
          trange = TimeRange.intersection(time_range1, time_range2)
          trange.should eq TimeRange.new(time3, time2)
        end

        it '.union' do
          trange = TimeRange.union(time_range1, time_range2)
          trange.should eq TimeRange.new(time1, time4)
        end
      end

      context :without_intersection do
        it '.intersection' do
          trange = TimeRange.intersection(time_range3, time_range4)
          trange.should be_nil
        end

        it '.union' do
          trange = TimeRange.union(time_range3, time_range4)
          trange.should eq [time_range3, time_range4]
        end
      end
      
      context(:multiple_union) do

        it '.union' do
          trange = TimeRange.union(time_range1, time_range2, time_range3, time_range4, time_range5)
          trange.should eq [TimeRange.new(time1, time4), time_range5]
        end

        it '.intersection' do
          trange = TimeRange.intersection(time_range1, time_range2, time_range3, time_range4, time_range5)
          trange.should be_nil
          trange = TimeRange.intersection(time_range1, time_range2, time_range3)
          trange.should eq TimeRange.new(time3, time3)
        end

      end
    end
  end

  context :wrong_args do
    it 'raises an error on wrong initialization argument' do
      expect{TimeRange.new(10, 20)}.to raise_error #(WrongTimeRangeError)
    end
  end
end
