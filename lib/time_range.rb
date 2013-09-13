class WrongTimeRangeError < Exception; end

WRONG_ARG = "is not time"

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
    self.begin <= time && self.end >= time
  end

  def fully_include?(time_rage)
    self.include?(time_rage.begin) && self.include?(time_rage.end)
  end

  def subtract(*ranges)
    ranges = ranges.flatten
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
    TimeRange.new(date.beginning_of_day, date.end_of_day)
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
      return union([first, union(tranges[1..-1])].flatten).flatten unless first.intersects?(second)
      return union([ union(first, second), union(tranges[2..-1])].flatten).flatten
    end
  end
end