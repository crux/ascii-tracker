require 'spec_helper'

include AsciiTracker 
describe "AsciiTracker::HHMM" do
  it "finds the class" do
    HHMM.should_not == nil
  end

  describe "HHMM calculus" do
    it "should calc differences" do
      dt = (HHMM '12:00') - (HHMM '10:00')
      dt.hours.should == 2.0
      dt.minutes.should == 0
    end

    it "should calc midnight overlaps" do
      hhmm = (HHMM('00:01') - HHMM('23:59'))
      hhmm.hours.should == 0
      hhmm.minutes.should == 2
    end

    it "should calc zero length slots" do
      hhmm = (HHMM('12:34') - HHMM('12:34'))
      hhmm.hours.should == 0
      hhmm.minutes.should == 0
    end
    
    it "should calc 24 hour slots" do
      hhmm = (HHMM('24:00') - HHMM('00:00'))
      hhmm.hours.should == 24
      hhmm.minutes.should == 0

      # 0/end - 24/start ist actually 0 minutes long! 
      hhmm = (HHMM('00:00') - HHMM('24:00'))
      hhmm.hours.should == 0
      hhmm.minutes.should == 0
    end

    it "should calc long overlaps" do
      hhmm = (HHMM('02:00') - HHMM('14:00'))
      hhmm.hours.should == 12
      hhmm.minutes.should == 0
      hhmm = (HHMM('02:00') - HHMM('10:00'))
      hhmm.hours.should == 16
      hhmm.minutes.should == 0
    end
  end

  describe "HHMM parsing" do
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
end
