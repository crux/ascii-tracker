module AsciiTracker
  class Record

    attr_reader :date, :span, :desc

    def to_s; "#{date}       #{HHMM.new(span)}  #{desc}" end

    Defaults = { :date => Date.today, :span => 0.0, :desc => nil }

    # span may be any valid HHMM format 
    # value keys: :date, :span, and :desc
    def initialize values = {} #date, span, desc = nil
      values = Defaults.merge(values)
      @date = values[:date]
      @span = HHMM.new(values[:span]).to_f
      @desc = values[:desc]
    end

    # 35.25 -> [1, 11, 15]
    def self.hours_to_dhm(hours)
      d = hours.to_i / 8
      h = (hours - 8*d).to_i
      m = ((60 * (hours - 8*d - h)) + 0.5).to_i
      [d, h, m]
    end
  end
end
