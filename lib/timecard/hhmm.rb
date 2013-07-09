module Timecard

  class HHMM < Struct.new :hours, :minutes

    include Comparable
    def <=>(other)
      a = (hours <=> other.hours)
      a == 0 ? (minutes <=> other.minutes) : a
    end

    #def -(other); self.to_f - other.to_f end
    #def +(other); self.to_f + other.to_f end
    def -(other)
      m = to_minutes - other.to_minutes
      (m += 24 * 60) if m < 0
      HHMM.new *(m.divmod 60)
    end

    def to_a; [hours, minutes] end
    def to_s; "%02d:%02d" % [hours, minutes] end
    def to_f; (minutes.to_f/60) + hours end
    def to_minutes; (60*hours) + minutes end

    # "12:30", "1:15" or "00:45" for hours and minutes
    #   or
    # "1.5" for fractions of an hour notation
    def self.parse txt
      if (m = txt.match(/^(\d?\d):(\d\d)/))
        HHMM.new m[1].to_i, m[2].to_i
      else 
        minutes = ((Float(txt) * 60) + 0.5).to_i
        HHMM.new(minutes / 60, minutes % 60)
      end
    end

    # five ways to express 1 hour and 30 minutes:
    #   1 arg:  ["1:30"], ["1.5"] or [1.5]
    #           or a HHMM object to be cloned from
    #   2 args: [1, 30], ["1", "30"], 
    def initialize *args
      if 2 == args.length # [1, 30] or ["1", "30"]
        super *(args.map{ |e| Integer(e) })
      else
        hhmm = args.first
        hhmm = HHMM.parse(hhmm.to_s) unless hhmm.kind_of? HHMM 
        self.hours, self.minutes = hhmm.hours, hhmm.minutes
      end
    end
  end

  def HHMM *args; HHMM.new(*args); end

  module Helper
    def hhmm(*args)
      HHMM.new(*args)
    end
  end
end
