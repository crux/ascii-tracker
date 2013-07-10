module AsciiTracker
  class Slot < Record

    attr_reader :t_start, :t_end

    def to_s; "#{date} #{t_start}-#{t_end}  #{desc}" end

    # supports Record values keys plus:
    # :start and :end
    # for interval definition
    def initialize values = {}
      values = Defaults.merge(values)
      @t_start = HHMM.new(values[:start])
      @t_end = HHMM.new(values[:end])

      @duration = (@t_end - @t_start)
      super values.merge(:span => @duration.to_f)

      @interrupts = []
    end

    # returns copy only, not suited to add/delelte interrupts 
    def interrupts; @interrupts.clone end

    # gross length is full slot length without interruptions being subtracted
    def gross_length
      @duration.to_f
    end

    #          [-----]                 -+
    #          [----------------]       |
    #                [---]              | <-- overlaping
    #             [------]              |  
    #                [------]           |
    #                [----------]      -+
    #
    # self:       [---------]
    #
    #      [---]                       -+
    #         [---]                     | <-- not overlaping
    #                       [----]      |
    #                         [-----]  -+
    # 
    def _24(a,b)
      [a.to_f, b < a ? b.to_f + 24 : b.to_f]
    end

    def overlaps? slr
      return false unless slr.respond_to?(:t_end)
      a, b = _24(t_start, t_end)
      c, d = _24(slr.t_start, slr.t_end)
      #puts "..a, b, c, d: #{a}, #{b} -> #{c}, #{d}"
      if d < a
        #puts "..upgrade: #{a}, #{b} -> #{c}, #{d}"
        c = c + 24; d = d + 24
      end
      #puts "..a, b, c, d: #{a}, #{b} -> #{c}, #{d} | #{c < b && a < d}"
      c < b && a < d
      #!slr.nil? && !(slr.t_end <= t_start || t_end <= slr.t_start)
      #not(slr.t_end <= t_start || t_end <= slr.t_start)
    end

    # checks for a pure technical fit which does not take into account the
    # already existing interruptions!
    def covers? slot_or_span
      slr = slot_or_span # shortcut for shorter lines below
      begin
        a, b = _24(t_start, t_end)
        c, d = _24(slr.t_start, slr.t_end)
        if d < a
          #puts "..upgrade: #{a}, #{b} -> #{c}, #{d}"
          c = c + 24; d = d + 24
        end
        a <= c && d <= b
      rescue NoMethodError # not a slot?
        slr.kind_of?(Record) and slr.span <= gross_length
      end
    end

    def add_interrupt slot_or_span
      slr = slot_or_span # shortcut
      unless covers? slr
        raise Exception, "interrupt not covered! #{slr}"
      end

      unless slr.span <= span
        raise Exception, "'#{self}' overload(#{span}): #{slr}"
      end
      #raise Exception, "overload: #{slr}" unless slr.span <= span

      # new interrupts may not overlap with existing ones!
      if slr.respond_to?(:t_start) 
        #raise Exception, "overlap: #{slr}" if @interrupts.any? do |i| 
        #    slr.overlaps? i
        #end
        if @interrupts.any? { |rec| slr.overlaps? rec }
          raise Exception, "overlap: #{slr}"
        end
      end

      @interrupts.push(slr)

      # subtract interrupts from span time
      #dt_lost = @interrupts.inject(0.0) { |sum, rec| sum + rec.span }
      dt_lost = @interrupts.inject(0.0) { |sum, rec| sum + (rec.gross_length rescue rec.span) }
      @span = gross_length - dt_lost
    end
  end
end
