require 'spec_helper'

include AsciiTracker
describe AsciiTracker::Parser do
  let(:c) { double(:controller) }

  it 'parses an emtpy txt' do
    expect(Parser.parse(c, '')).to be(c)
  end

  it 'parses some txt' do
    c.should_receive(:new_project_re).with('project', /name: /i)
    expect(Parser.parse(c, <<-EOT)).to be(c)
@project name: 
    EOT
  end

  it 'parses a crossfit record' do

    c.should_receive(:new_day).with(Date.parse('2008-07-10'))
    c.should_receive(:new_slot).
        with(HHMM(11, 35), HHMM(13, 40), "crossfit: new warm-up, ")
    c.should_receive(:new_txt).
        with('|a backsquat 123.5, benchpress 76, 76/4, 75')
    c.should_receive(:new_txt).
        with('|b AMRAP6, 5 FrontSquat 50%1RM, 5 PushUps, 5 T2B')
    c.should_receive(:new_txt).
        with('|6 rounds @ 60kg, (5 T2B, rest high knee)')

    expect(Parser.parse(c, <<-EOT)).to be(c)
2008-07-10 11:35-13:40  crossfit: new warm-up, 
                            |a backsquat 123.5, benchpress 76, 76/4, 75
                            |b AMRAP6, 5 FrontSquat 50%1RM, 5 PushUps, 5 T2B
                                |6 rounds @ 60kg, (5 T2B, rest high knee)
      EOT
  end

  it 'parses brackets in txt lines' do

    c.should_receive(:new_day).with(Date.parse('2001-02-03'))
    c.should_receive(:new_slot).with(HHMM(9, 0), HHMM(17, 0), "work: day")
    c.should_receive(:new_txt).with('a) some stuff')
    c.should_receive(:new_txt).with('b) other stuff')

    expect(Parser.parse(c, <<-EOT)).to be(c)
2001-02-03  9:00-17:00  work: day
                          a) some stuff
                          b) other stuff
      EOT
  end
end
__END__
      assert_equal 5, c.model.records.size
      assert_equal 3, c.model.projects.size
      assert_not_nil ee = c.model.records.first
      assert_equal "expoeasy: yui data tables for visitors", ee.desc
      assert_equal 4, ee.interrupts.size

      assert_equal 10.00, ee.gross_length
      assert_equal 3.25, ee.span
    end
  end
end

