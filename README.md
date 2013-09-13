# the TimeRange 
# 
# helps in Issues with time time ranges,
# such as intersecton of time ranges,
# union of time ranges, etc.
# Installation 
#
#   gem install 'time_range'
#
# Examples
#
#   require "time_range"
#
#   range = TimeRange.new(Time.now - 1000, Time.now + 1000)
#   # => 2013-09-13 23:32:16 +0400..2013-09-14 00:05:36 +0400
#   today = TimeRange.for_date(Date.today)
#   # =>  2013-09-13 00:00:00 +0400..2013-09-13 23:59:59 +0400
#
# Check time presence in time range
#
#   range.include?(Time.now)
#   # => true
# 
# Check time range presense in another time_range
#
#   range2 = TimeRange.new(Time.now - 10, Time.now + 10)
#   # => 2013-09-13 23:50:31 +0400..2013-09-13 23:50:51 +0400
# 
#   range.fully_include?(range2)
#   # => true
#
# Check time ranges intersects each other:
#
#   range.intersects?(range2)
#   # => true
#
# Intersect time ranges
#
#   range.intersection(range2)
#   # => 2013-09-13 23:50:31 +0400..2013-09-13 23:50:51 +0400 # i.e equal range2
#
# Union time ranges 
#
#   range3 = TimeRange.new(Time.now + 10000, Time.now + 20000)
#   TimeRange.union(range, range2, range3)
#   # => [2013-09-13 23:32:16 +0400..2013-09-14 00:05:36 +0400, 
#   #     2013-09-14 02:41:17 +0400..2013-09-14 05:27:57 +0400]
#
# Subtract time ranges from one time range
#
#   TimeRange.for_date(Date.today).subtract(TimeRange.new(Time.now + 900, Time.now + 1200),    
#                                           TimeRange.new(Time.now + 300, Time.now + 600))
#   # => [2013-09-14 00:00:00 +0400..2013-09-14 00:55:51 +0400, 
#   #     2013-09-14 01:00:51 +0400..2013-09-14 01:05:51 +0400, 
#   #     2013-09-14 01:10:51 +0400..2013-09-14 23:59:59 +0400]

