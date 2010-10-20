require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Slotter 
describe "Slotter::Model" do
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

    it "should add non overlapping slot records" do
      @model.add_record(Slot.new :start=>"10:45", :end=>"12:15")
      (records = @model.by_date(Date.today)).should_not == []
      records.size.should == 1
      slot = records.first
      slot.span.should == 1.5
    end
    
   #   @rec.covers?(Slot.new(:start=>"10:45", :end=>"12:15")).should == true
   #   @rec.covers?(Slot.new(:start=>"10:00", :end=>"12:15")).should == false
   #   @rec.covers?(Slot.new(:start=>"10:45", :end=>"13:00")).should == false
  end
end

