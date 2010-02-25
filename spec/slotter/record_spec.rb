require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Slotter 
describe "Slotter::Record" do
  it "finds the class" do
    Record.should_not == nil
  end

  it "should calc days from hours and minutes" do
    Record.hours_to_dhm(0.25).should ==  [0,  0, 15]
    Record.hours_to_dhm(1).should ==     [0,  1,  0]
    Record.hours_to_dhm(24).should ==    [3,  0,  0]
    Record.hours_to_dhm(35.25).should == [4,  3, 15]
  end

  it "should init with fixnum span" do
    rec = Record.new :span => 1, :desc => "foo bar"
    rec.span.should == 1.0
    rec.desc.should == "foo bar"
  end

  it "should init with string duration span" do
    rec = Record.new :span => "2.75", :desc => "bar foo"
    rec.span.should == 2.75
    rec.desc.should == "bar foo"
  end

  it "should init with without description text" do
    rec = Record.new :span => "00:30"
    rec.span.should == 0.5
    rec.desc.should == nil
  end
end
