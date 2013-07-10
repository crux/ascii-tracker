require 'timecard/rdparser'

module Timecard

  Parser = RDParser.new do

    def parse model, txt
      @model = model
      super(txt)
      @model
    end

    def push_line line
      line.each do |rec|
        puts "--> #{rec.join("|")}"
        @model.send "new_#{rec.shift}", *rec
      end
    end

    token(/\s+/)
    token(/\d\d\d\d-\d\d-\d\d/)     { |txt| puts "2:#{txt}"; Date.parse(txt) }
    token(/([012]?\d):([0-5]\d)/)   { |txt| HHMM.new(txt) }
    token(/\d\d?(.\d\d?)?/)            { |m| m.to_f }
    token(/-/)                      { |m| m }
    #token(/[:;#]?.*/)               { |txt| txt }
    token(/@\S+/)                   { |txt| txt }
    token(/[:;#]?.*/)               { |txt| txt.sub /^[:;#]\s*/, '' }
    #token(/.+/)                     { |m| m }

    start :records do
      match(:records, :line)   { |lol, line|   push_line(line) }
      match(:line)             { |line|        push_line(line) }
    end

    #date          slot
    #date                      span
    #              slot
    #                          span
    #                                   desc

    rule :line do
      match(:project_re)  { |a|   [[:project_re, *a]] }
      match(:day, :slot)  { |a,b| [[:day, *a], [:slot, *b]] }
      match(:day, :span)  { |a,b| [[:day, *a], [:span, *b]] }
      match(:slot)        { |a|   [[:slot, *a]] }
      match(:span)        { |a|   [[:span, *a]] }
      match(:desc)        { |txt| [[:txt, txt]] } #@m.append_txt(txt) }
    end

    rule :project_re do
      #match('/', /[^\/]+/, '/', String) { |_, id, _, re| [id, re] }
      #match(/\/[^\/]+\/.+/) { |_, id, _, re| [id, re] }
      #match(/\/[^\/]+\/.+/) { |x| [x] }
      match(/@.+/, String) do |project_id, re|
        [project_id[1..-1], Regexp.new(re, Regexp::IGNORECASE)]
      end
    end

    rule :day do
      match(Date)   # { |date| puts "1:#{date}"; date }
    end

    rule :slot do
      match(:hhmm,'-',:hhmm, :desc) { |t1, _, t2, desc| [t1, t2, desc] }
      match(:hhmm,'-',:hhmm) { |t1, _, t2| [t1, t2, nil] }
    end

    rule :span do
      #match(:hhmm, :desc) { |hhmm, desc| @m.new_span(hhmm.to_f, desc) }
      #match(:hhmm)        { |hhmm| @m.new_span(hhmm.to_f) }
      match(:hhmm, :desc) { |hhmm, desc| [hhmm.to_f, desc] }
      match(:hhmm)        { |hhmm, desc| [hhmm.to_f, nil] }
    end

    rule :hhmm do
      match(Float)    { |x| HHMM.new(x) }
      match(HHMM)     { |x| x }
    end

    rule :desc do
      match(String)       { |txt| txt }
      # strip optional marker
      # match(String)       { |txt| txt.sub /^[:;#]\s*/, ''  }
    end
  end
end
