require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Slotter 
describe "Slotter::Record" do
  it "finds the class" do
    Slot.should_not == nil
  end

  describe "with 10:45 - 12:15" do
    before :each do 
      @rec = Slot.new :start=>"10:45", :end=>"12:15", :desc=>"foo bar"
    end

    it "should fit Records" do
      # span are always contained...
      @rec.covers?(Record.new(:span => 0.5)).should == true
      @rec.covers?(Record.new(:span => 1.5)).should == true
    end

    it "should not cover records with are to long" do
      @rec.covers?(Record.new(:span => "1:31")).should == false
      @rec.covers?(Record.new(:span => 5.0)).should == false
    end

    it "should calc slot covers" do
      @rec.covers?(Slot.new(:start=>"10:45", :end=>"12:15")).should == true
      @rec.covers?(Slot.new(:start=>"10:00", :end=>"12:15")).should == false
      @rec.covers?(Slot.new(:start=>"10:45", :end=>"13:00")).should == false
    end
  end
  
  it "should construct from start, end and desc options" do
    rec = Slot.new :start => "10:15", :end => "10:45", :desc => "foo bar"
    rec.desc.should == "foo bar"
    rec.t_start.should == (HHMM "10:15")
    rec.t_end.should == (HHMM "10:45")
    rec.span.should == 0.5
    rec.gross_length.should == 0.5
    rec.interrupts.length.should == 0
  end

  it "should support long overlaps around midnight" do
    rec = Slot.new :start => "14:00", :end => "02:00"
    rec.interrupts.length.should == 0
    rec.span.should == 12
  end

  it "should cover slots over midnight" do
    rec = Slot.new :start=>"23:00", :end=>"01:00", :desc=>"foo bar"
    rec.covers?(Record.new(:span => 1.0)).should == true
  end

  it "should support slots over midnight" do
    rec = Slot.new :start=>"23:00", :end=>"01:00", :desc=>"foo bar"
    rec.span.should == 2
    rec.interrupts.length.should == 0

    rec = Slot.new :start=>"20:00", :end=>"05:00", :desc=>"foo bar"
    rec.span.should == 9
    rec.interrupts.length.should == 0
  end

  describe "with base slot" do
    before :each do 
      @base = Slot.new :start => "5:00", :end => "6:00"
    end

    it "sould calc overlaps" do
      a = Slot.new :start => "4:00", :end => "4:30"
      @base.overlaps?(a).should == false

      a1 = Slot.new :start => "4:00", :end => "5:00"
      @base.overlaps?(a1).should == false

      b = Slot.new :start => "1:00", :end => "5:30"
      @base.overlaps?(b).should == true

      c = Slot.new :start => "1:00", :end => "7:00"
      @base.overlaps?(c).should == true

      d = Slot.new :start => "5:15", :end => "5:45"
      @base.overlaps?(d).should == true

      d1 = Slot.new :start => "5:00", :end => "5:45"
      @base.overlaps?(d1).should == true

      d2= Slot.new :start => "5:15", :end => "6:00"
      @base.overlaps?(d2).should == true

      e = Slot.new :start => "5:30", :end => "7:00"
      @base.overlaps?(e).should == true

      f = Slot.new :start => "7:00", :end => "9:00"
      @base.overlaps?(f).should == false

      f1 = Slot.new :start => "6:00", :end => "9:00"
      @base.overlaps?(f1).should == false
    end
  end

  describe "with base over around midnight" do
    before :each do 
      @base = Slot.new :start => "22:00", :end => "02:00"
    end

    it "should calc overlaps around midnight" do
      # before
      a = Slot.new :start => "20:00", :end => "21:59"
      @base.covers?(a).should == false
      @base.overlaps?(a).should == false
      # after
      a = Slot.new :start => "02:01", :end => "04:00"
      @base.covers?(a).should == false
      @base.overlaps?(a).should == false

      a = Slot.new :start => "23:00", :end => "23:10"
      puts " -- #{[@base.t_start, @base.t_end, a.t_start, a.t_end].join(', ')}"
      @base.covers?(a).should == true
      @base.overlaps?(a).should == true

      a = Slot.new :start => "23:00", :end => "01:00"
      puts " -- #{[@base.t_start, @base.t_end, a.t_start, a.t_end].join(', ')}"
      @base.covers?(a).should == true
      @base.overlaps?(a).should == true

      a = Slot.new :start => "01:00", :end => "01:10"
      puts " -- #{[@base.t_start, @base.t_end, a.t_start, a.t_end].join(', ')}"
      @base.overlaps?(a).should == true
      @base.covers?(a).should == true
    end
  end
end
__END__

class SlotTest < Test::Unit::TestCase

  include Slotter


  def test_overlaps_around_midnight
    puts "\n--> #{self}"

    base = Slot.new :start => "22:00", :end => "02:00"

    # before
    a = Slot.new :start => "20:00", :end => "21:59"
    assert ! base.covers?(a)
    assert ! base.overlaps?(a)
    # after
    a = Slot.new :start => "02:01", :end => "04:00"
    assert ! base.covers?(a)
    assert ! base.overlaps?(a)

    a = Slot.new :start => "23:00", :end => "23:10"
    puts " -- #{[base.t_start, base.t_end, a.t_start, a.t_end].join(', ')}"
    assert base.covers?(a)
    assert base.overlaps?(a)

    a = Slot.new :start => "23:00", :end => "01:00"
    puts " -- #{[base.t_start, base.t_end, a.t_start, a.t_end].join(', ')}"
    assert base.covers?(a)
    assert base.overlaps?(a)

    a = Slot.new :start => "01:00", :end => "01:10"
    puts " -- #{[base.t_start, base.t_end, a.t_start, a.t_end].join(', ')}"
    assert base.overlaps?(a)
    assert base.covers?(a)
  end

    def test_add_interrupt_slot_or_span
        puts "\n--> #{self}"
        rec = Slot.new :start=>"10:00", :end=>"12:30", :desc=>"foo bar"
        assert_equal 2.5, rec.span 
        assert_equal 0, rec.interrupts.length

        wasted_time = Record.new :span => 1, :desc => "one hour of wasted time"
        rec.add_interrupt wasted_time
        assert_equal 1, rec.interrupts.length
        assert_equal 1.5, rec.span 
        rec.add_interrupt wasted_time
        assert_equal 2, rec.interrupts.length
        assert_equal 0.5, rec.span 

        assert_raise(SlotterException) { rec.add_interrupt(wasted_time) }

        rec = Slot.new :start=>"10:00", :end=>"12:30", :desc=>"foo bar"
        slot = Slot.new :start=>"10:00", :end => "12:00", :desc => "intruppt"
        rec.add_interrupt(slot)
        assert_equal 0.5, rec.span 

        slot = Slot.new :start=>"12:30", :end => "13:00", :desc => "intruppt"
        assert_raise(SlotterException) { rec.add_interrupt(slot) }
        slot = Slot.new :start=>"09:30", :end => "11:00", :desc => "intruppt"
        assert_raise(SlotterException) { rec.add_interrupt(slot) }

        slot = Slot.new :start=>"12:00", :end => "12:15", :desc => "intruppt"
        rec.add_interrupt(slot)
        assert_equal 0.25, rec.span 
        slot = Slot.new :start=>"12:15", :end => "12:30", :desc => "intruppt"
        rec.add_interrupt(slot)
        assert_equal 0.0, rec.span 

        slot = Slot.new :start=>"12:15", :end => "12:30", :desc => "intruppt"
        assert_raise(SlotterException) { rec.add_interrupt(slot) }
    end
end

