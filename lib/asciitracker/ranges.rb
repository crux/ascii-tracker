module AsciiTracker::Ranges

  def parse txt
    self.send(txt.sub('-', '_')) rescue nil
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
