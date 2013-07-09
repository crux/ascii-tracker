require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Timecard 
describe "Timecard::Model" do
  it "finds the class" do
    Model.should_not == nil
  end

  describe "with a model" do
    before :each do
      @model = Model.new
    end

    it "should be initially empty" do
      @model.by_date(Date.today).should == []
    end

    it "should add slot records" do
      @model.add_record(Slot.new :start=>"10:45", :end=>"12:15")
      (records = @model.by_date(Date.today)).should_not == []
      records.first.span.should == 1.5
    end

    it "should find best cascaded cover" do
      @model.add_record Slot.new(:start=>"10:00", :end=>"20:00")
      @model.add_record Slot.new(:start=>"11:00", :end=>"19:00")
      @model.add_record Slot.new(:start=>"12:00", :end=>"17:00")
      slot = Slot.new(:start=>"16:00", :end=>"17:00")
      (cover = @model.find_best_cover slot).should_not == nil
      cover.t_start.to_s.should == "12:00"
      cover.t_end.to_s.should == "17:00"

      slot = Slot.new(:start=>"11:10", :end=>"11:20")
      (cover = @model.find_best_cover slot).should_not == nil
      cover.t_start.to_s.should == "11:00"
      cover.t_end.to_s.should == "19:00"
    end
    
    it "should find best cover" do
      @model.add_record Slot.new(:start=>"10:00", :end=>"15:00")
      @model.add_record Slot.new(:start=>"15:00", :end=>"20:00")
      slot = Slot.new(:start=>"16:00", :end=>"17:00")
      (overlaps = @model.find_overlaps slot).size.should == 1
      overlap = overlaps.first
      overlap.t_start.to_s.should == "15:00"
      overlap.t_end.to_s.should == "20:00"
    end
    
    it "should find overlaps" do
      @model.add_record Slot.new(:start=>"10:00", :end=>"20:00")
      slot = Slot.new(:start=>"11:00", :end=>"13:00")
      (overlaps = @model.find_overlaps slot).size.should == 1
      overlap = overlaps.first
      overlap.t_start.to_s.should == "10:00"
      overlap.t_end.to_s.should == "20:00"
    end
    
    it "should add non overlapping slot records" do
      @model.add_record(Slot.new :start=>"10:00", :end=>"11:00")
      @model.add_record(Slot.new :start=>"11:00", :end=>"13:00")
      (records = @model.by_date(Date.today)).should_not == []
      records.first.span.should == 1
      records.last.span.should == 2
    end
    
   #   @rec.covers?(Slot.new(:start=>"10:45", :end=>"12:15")).should == true
   #   @rec.covers?(Slot.new(:start=>"10:00", :end=>"12:15")).should == false
   #   @rec.covers?(Slot.new(:start=>"10:45", :end=>"13:00")).should == false
  end
end

