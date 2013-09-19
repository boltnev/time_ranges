
WRONG_ARG = "is not time"
# the TimeRange 
# 
# helps in Issues with time time ranges,
# such as intersecton of time ranges,
# union of time ranges, etc.
# 
# == Examples
#   require "time_range"
#
#   range = TimeRange.new(Time.now - 1000, Time.now + 1000)
#   # => 2013-09-13 23:32:16 +0400..2013-09-14 00:05:36 +0400
#   today = TimeRange.for_date(Date.today)
#   # =>  2013-09-13 00:00:00 +0400..2013-09-13 23:59:59 +0400
#
# Check time presence in time range
#   range.include?(Time.now)
#   # => true
#   range.include?(Date.today)
#   # => true
# 
# Check time range presense in another time_range
#   range2 = TimeRange.new(Time.now - 10, Time.now + 10)
#   # => 2013-09-13 23:50:31 +0400..2013-09-13 23:50:51 +0400
# 
#   range.fully_include?(range2)
#   # => true
#
# Check time ranges intersects each other:
#   range.intersects?(range2)
#   # => true
#
# Intersect time ranges
#   range.intersection(range2)
#   # => 2013-09-13 23:50:31 +0400..2013-09-13 23:50:51 +0400 # i.e equal range2
#
# Union time ranges 
#   range3 = TimeRange.new(Time.now + 10000, Time.now + 20000)
#   TimeRange.union(range, range2, range3)
#   # => [2013-09-13 23:32:16 +0400..2013-09-14 00:05:36 +0400, 
#   #     2013-09-14 02:41:17 +0400..2013-09-14 05:27:57 +0400]
#
# Subtract time ranges from one time range
#   TimeRange.for_date(Date.today).subtract(TimeRange.new(Time.now + 900, Time.now + 1200),    
#                                           TimeRange.new(Time.now + 300, Time.now + 600))
#   # => [2013-09-14 00:00:00 +0400..2013-09-14 00:55:51 +0400, 
#   #     2013-09-14 01:00:51 +0400..2013-09-14 01:05:51 +0400, 
#   #     2013-09-14 01:10:51 +0400..2013-09-14 23:59:59 +0400]
class TimeRange < Range

  alias_method :orig_init, :initialize
  def initialize(rbegin, rend)
    raise WrongTimeRangeError, WRONG_ARG unless (rbegin.is_a?(Time) && rend.is_a?(Time))
    rbegin, rend = rend, rbegin if rbegin > rend
    orig_init(rbegin, rend)
  end

  def intersects?(range)
    (self.begin >= range.begin &&  self.begin <= range.end) || (self.end >= range.begin &&  self.end <= range.end) ||
      (range.begin >= self.begin &&  range.begin  <= self.end) || (range.end >= self.begin &&  range.end <= self.end)
  end

  def intersection(range)
    TimeRange.intersection(self, range)
  end

  def include?(time)
    if time.is_a?(Time)
      self.begin <= time && self.end >= time
    elsif time.is_a?(Date)
      self.begin.to_date <= time && self.end.to_date >= time
    else
      raise WrongTimeRangeError, WRONG_ARG 
    end
  end

  def fully_include?(time_rage)
    self.include?(time_rage.begin) && self.include?(time_rage.end)
  end

  def subtract(*ranges)
    ranges = ranges.flatten.sort{|a, b| a.begin <=> b.begin}
    return self if ranges.empty?
    result = []
    ranges.each do |range|
      subtraction = self.intersection(TimeRange.new(self.begin, range.begin) ) if range.eql?(ranges.first)
      result << subtraction if subtraction

      if range.eql?(ranges.last)
        subtraction = self.intersection(TimeRange.new(range.end, self.end ) )
        result << subtraction if subtraction
      else
        subtraction = self.intersection(TimeRange.new(range.end, ranges[ranges.index(range) + 1].begin ))
        result << subtraction if subtraction
      end
    end
    TimeRange.union(result)
  end

  def self.for_date(date)
    TimeRange.new(date.to_time, (date + 1).to_time - 1)
  end

  def self.intersection(*tranges)
    return tranges if tranges.is_a?(TimeRange)
    tranges = tranges.flatten.sort!{|a,b| a.begin <=> b.begin}
    return tranges.first if (tranges.count == 1)
    first, second = tranges[0], tranges[1]
    if(tranges.count == 2)
      return nil unless first.intersects?(second)
      tbegin = [first.begin, second.begin].max
      tend =   [first.end, second.end].min
      return TimeRange.new(tbegin, tend)
    elsif tranges.count > 2
      return intersection([intersection(first, second), tranges[2..-1] ].flatten) if first.intersects?(second)
    end
  end

  def self.union(*tranges)
    return tranges if tranges.is_a?(TimeRange) && tranges.begin != tranges.end
    tranges = tranges.flatten.sort{|a,b| a.begin <=> b.begin}.select{|trange| trange.begin != trange.end}
    return tranges.first if (tranges.count == 1)
    first, second = tranges[0], tranges[1]
    if(tranges.count == 2)
      return [first, second] unless first.intersects?(second)
      tbegin = [first.begin, second.begin].min
      tend =   [first.end, second.end].max
      return TimeRange.new(tbegin, tend)
    elsif tranges.count > 2
      return [ first, union(tranges[1..-1])].flatten unless first.intersects?(second)
      result = union([ union(first, second), tranges[2..-1]])
      return result.is_a?(Array) ? result.flatten : result
    end
  end
end
