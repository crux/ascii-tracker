require 'spec_helper'

include AsciiTracker 

describe AsciiTracker::Ranges do

  it { should be_kind_of(Module) }

  context 'error handling' do
    it 'bails out on first param when not recogized' do
      expect { Ranges.parse!('XXX') }.to raise_error /range param format: 'XXX'/
      expect { Ranges.parse('XXX') }.to_not raise_error
    end
  end

  it 'parses to date param range args' do
    (w, _ = Ranges.parse('2012-01-01', '2013-01-01')).should be
    w.should be_kind_of(Range)
    w.begin.year.should eq(2012)
    w.begin.month.should eq(1)
    w.begin.day.should eq(1)

    w.end.year.should eq(2013)
    w.end.month.should eq(1)
    w.end.day.should eq(1)
  end

  it 'parses yesterday' do
    (w, _ = Ranges.parse!('yesterday')).should be
    w.should be_kind_of(Range)
    w.begin.should eq(Date.today - 1)
    w.end.should eq(Date.today)
  end

  context 'today' do
    let(:today) { Date.new(2013, 9, 13) }
    before { Date.stub(:today) { today } }

    it 'knows last monday' do
      Ranges.last_monday.should eq(Date.new(2013, 9, 9))
    end

    it 'parses last_year' do
      (w, _ = Ranges.parse('last-year')).should be
      w.should be_kind_of(Range)
      w.begin.year.should eq(2012)
      w.begin.month.should eq(1)
      w.begin.day.should eq(1)

      w.end.year.should eq(2013)
      w.end.month.should eq(1)
      w.end.day.should eq(1)
    end

    it 'knows last year' do
      (w = Ranges.last_year).should be_kind_of(Range)
      w.begin.year.should eq(2012)
      w.begin.month.should eq(1)
      w.begin.day.should eq(1)

      w.end.year.should eq(2013)
      w.end.month.should eq(1)
      w.end.day.should eq(1)
    end

    it 'parses this_year' do
      (w, _ = Ranges.parse('this-year')).should be
      w.should be_kind_of(Range)
      w.begin.year.should eq(2013)
      w.begin.month.should eq(1)
      w.begin.day.should eq(1)

      w.end.year.should eq(2014)
      w.end.month.should eq(1)
      w.end.day.should eq(1)
    end

    it 'knows this year, year to date' do
      (w = Ranges.this_year).should be_kind_of(Range)
      w.begin.year.should eq(2013)
      w.begin.month.should eq(1)
      w.begin.day.should eq(1)

      w.end.year.should eq(2014)
      w.end.month.should eq(1)
      w.end.day.should eq(1)
    end

    it 'parses last_week' do
      (w, _ = Ranges.parse('last_week')).should be
      w.should be_kind_of(Range)
      w.begin.year.should eq(2013)
      w.begin.month.should eq(9)
      w.begin.day.should eq(2)

      w.end.year.should eq(2013)
      w.end.month.should eq(9)
      w.end.day.should eq(9)
    end

    it 'knows last week' do
      (w = Ranges.last_week).should be_kind_of(Range)
      w.begin.year.should eq(2013)
      w.begin.month.should eq(9)
      w.begin.day.should eq(2)

      w.end.year.should eq(2013)
      w.end.month.should eq(9)
      w.end.day.should eq(9)
    end

    it 'knows this week' do
      (w = Ranges.this_week).should be_kind_of(Range)
      w.begin.year.should eq(2013)
      w.begin.month.should eq(9)
      w.begin.day.should eq(9)

      w.end.year.should eq(2013)
      w.end.month.should eq(9)
      w.end.day.should eq(16)
    end

    it 'knows last month' do
      (m = Ranges.last_month).should be_kind_of(Range)
      m.begin.year.should eq(2013)
      m.begin.month.should eq(8)
      m.begin.day.should eq(1)

      m.end.year.should eq(2013)
      m.end.month.should eq(9)
      m.end.day.should eq(1)
    end

    it 'knows this month' do
      (m = Ranges.this_month).should be_kind_of(Range)
      m.begin.year.should eq(2013)
      m.begin.month.should eq(9)
      m.begin.day.should eq(1)

      m.end.year.should eq(2013)
      m.end.month.should eq(10)
      m.end.day.should eq(1)
    end
  end
end

__END__
it 'checks for right order of first and last day' do
    expect { AsciiTracker::Range.new(Date.today, Date.today)}.to raise_error /not befor/
  end
