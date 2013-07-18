module AsciiTracker::Ranges

  # parses one or two parameters from the args vector:
  #
  # 1. symbolic name, like 'this-week', 'last-month', etc.
  # 2. Two date string of the form 2012-12-01 like:
  #     2012-01-01 2013-01-01   -> returns range for this year.
  #   
  # NOTE! the args vector is changed! depending on the one two arg version
  #
  def parse!(*args)
    first = args.shift
    range = if first.match /20[0-9]{2}-[01]\d-[0-3]\d/
              Range.new(Date.parse(first), Date.parse(args.shift))
            else
              begin
                self.send(first.sub('-', '_'))
              rescue => e
                raise "unknown first date range param format: '#{first}'"
              end
            end
    [range, args]
  end

  def parse(*args)
    parse!(*args) rescue nil
  end

  def this_year
    Range.new(
      Date.new(Date.today.year,  1,  1),
      Date.new(Date.today.year, 12, 31) + 1
    )
  end
  def last_year
    Range.new(
      Date.new(Date.today.year - 1,  1,  1),
      Date.new(Date.today.year - 1, 12, 31) + 1
    )
  end

  def this_month
    Range.new(
      Date.new(Date.today.year, Date.today.mon, 1),
      Date.new(Date.today.year, Date.today.mon, -1) + 1
    )
  end
  def last_month
    t = Date.today << 1
    Range.new(Date.new(t.year, t.mon, 1), Date.new(t.year, t.mon, -1) + 1)
  end

  def last_monday
    monday = Date.today
    monday -= (monday.cwday - 1)
  end

  def this_week
    monday = last_monday
    sunday = monday + 6
    Range.new(
      Date.new(monday.year, monday.mon, monday.mday),
      Date.new(sunday.year, sunday.mon, sunday.mday) + 1
    )
  end
  def last_week
    monday = last_monday - 7
    sunday = monday + 6
    Range.new(
      Date.new(monday.year, monday.mon, monday.mday),
      Date.new(sunday.year, sunday.mon, sunday.mday) + 1
    )
  end

  extend(self)
end
