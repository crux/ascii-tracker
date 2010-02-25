require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Slotter 
describe "Slotter::HHMM" do
  it "finds the class" do
    HHMM.should_not == nil
  end

  it "should parse '1:30'" do
    hhmm = (HHMM '1:30')
    hhmm.to_a.should == [1, 30]
    hhmm.to_s.should == "01:30"
    hhmm.to_f.should == 1.5
  end

  it "should parse '1.5'" do
    hhmm = (HHMM '1.5')
    hhmm.to_a.should == [1, 30]
    hhmm.to_s.should == "01:30"
    hhmm.to_f.should == 1.5
  end

  it "should parse 1.5" do
    hhmm = (HHMM 1.5)
    hhmm.to_a.should == [1, 30]
    hhmm.to_s.should == "01:30"
    hhmm.to_f.should == 1.5
  end

  it "should parse (1, 30)" do
    hhmm = (HHMM 1, 30)
    hhmm.to_a.should == [1, 30]
    hhmm.to_s.should == "01:30"
    hhmm.to_f.should == 1.5
  end

  it "should parse ('1', '30')" do
    hhmm = (HHMM '1', '30')
    hhmm.to_a.should == [1, 30]
    hhmm.to_s.should == "01:30"
    hhmm.to_f.should == 1.5
  end
end
