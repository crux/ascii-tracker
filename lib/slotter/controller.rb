module Slotter 
  class Controller
    attr_reader :model

    def initialize 
      @model = Model.new
    end

    # match(:day, :slot)  { |a,b| [[:day, *a], [:slot, *b]] }
    # match(:day, :span)  { |a,b| [[:day, *a], [:span, *b]] }
    def new_day date
      @day = date
      @rec = @slot = nil
    end

    # match(:slot)        { |a|   [[:slot, *a]] }
    def new_slot start, stop, desc = nil
      #slot = Slot.new :date=>@day, :start=> start, :end=>stop, :desc=>desc
      @rec = @slot = Slot.new(
        :start => start, :end =>stop, :desc =>desc, :date => @day.dup
      )

      # updates parant records when this slot is an interruption
      overlaps = @model.find_overlaps(@slot, @day)
      puts "new slot(#{@slot}), overlaps: #{overlaps}"
      unless overlaps.empty?
        # parents are covers which are a subset of overlaps
        if parent = @model.find_best_cover(@slot, @day)
          parent.add_interrupt(@slot)
        else
          raise SlotterException, <<-EOM
          #{@slot}
overlaps with:
          #{overlaps.first} ...
                    EOM
        end
      end

      # add record to model after interrupt calculation to save self
      # interruption checks
      @model.add_record(@slot, @day)
    end

    # match(:span)        { |a|   [[:span, *a]] }
    def new_span span, desc = nil
      @rec = Record.new :span=>span, :desc=>desc, :date => @day.dup
      @slot.add_interrupt(@rec) if @slot
      @model.add_record(@rec, @day)
    end

    # match(:desc)        { |txt| [[:txt, txt]] } #@m.append_txt(txt) }
    def new_txt txt = nil
      @rec.desc << " #{txt}"
    end

    # match(/@.+/, String) { |project_id, re| [project_id[1..-1], Regexp.new(re)] }
    def new_project_re project_id, re
      puts "project expression: #{project_id}, #{re}"
      @model.projects[project_id].push(re)
    end
  end
end
