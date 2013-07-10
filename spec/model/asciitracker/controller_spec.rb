require 'spec_helper'

include AsciiTracker 
describe "AsciiTracker::Controller" do
  it "finds the class" do
    Controller.should_not == nil
  end

  describe "with a controller" do
    before :each do
      @c = Controller.new
    end
  end
end

__END__

    it "should have a #new_slot method" do
      @c.new_day Date.today
      slot = @c.new_slot(HHMM("10:00"), HHMM("12:00"), "foo bar")
      @c.new_span  "1.75", "some task"
      @c.new_txt   "some additional text"
    end

class ControllerTest < Test::Unit::TestCase

    include Timecard
   
    def test_expoeasy
      puts "\n--> #{self}"
      c = Controller.new
      Parser.parse c, <<-EOT
@expoeasy expoeasy: 
@wallcms wallcms:
@private private:
2008-07-10   18:15-04:15     expoeasy: yui data tables for visitors
                    0:15     wallcms: commit reviews
                    0:30     private: family & food
             20:15-22:15     private: halma
             23:45-03:45     private: @jussie's weeding
      EOT
      assert_equal 5, c.model.records.size
      assert_equal 3, c.model.projects.size
      assert_not_nil ee = c.model.records.first
      assert_equal "expoeasy: yui data tables for visitors", ee.desc
      assert_equal 4, ee.interrupts.size

      assert_equal 10.00, ee.gross_length
      assert_equal 3.25, ee.span
    end

    def test_day_spans
        puts "\n--> #{self}"
        c = Controller.new
        c.new_day   Date.today
        c.new_span  0, "ueberstundenabbau"
        assert_equal 1, c.model.records.length
        rec = c.model.records.first
        assert_equal 0, rec.span
        assert_equal Date.today, rec.date
    end

    def test_slot_span_slot
        puts "\n--> #{self}"
        c = Controller.new
        c.new_day   Date.today
        c.new_slot(HHMM("10:00"), HHMM("14:00"), "slot 1")
        c.new_span  2.5, "span"
        c.new_slot(HHMM("14:00"), HHMM("16:00"), "slot 2")
        assert_equal 3, c.model.records.length
        assert_equal [1.5,2.5,2], c.model.records.map { |e| e.span }
    end

    def test_interrupted_slot
        puts "\n--> #{self}"
        c = Controller.new
        c.new_day   Date.today
        c.new_slot  HHMM("10:00"), HHMM("14:00"), "office works"
        c.new_span  "0:15", "annoyance" 
        c.new_slot  HHMM("10:15"), HHMM("10:30"), "another annoyance"
        assert_equal 3, c.model.records.length
        assert_equal 3.5, c.model.records.first.span

        telco = c.new_slot(HHMM("10:30"), HHMM("11:30"), "sysadm")
        assert_equal 4, c.model.records.length
        assert_equal 2.5, c.model.records.first.span

        c.new_span  0.25, "telco" # interrupt the sysadm task only!
        assert_equal 5, c.model.records.length
        assert_equal 2.5, c.model.records.first.span

        assert_raise(TimecardException) do 
            c.new_slot  HHMM("09:15"), HHMM("10:15"), "overlap"
        end
        assert_raise(TimecardException) do 
            c.new_slot  HHMM("10:00"), HHMM("11:00"), "overlap"
        end
        assert_raise(TimecardException) do 
            c.new_slot  HHMM("11:00"), HHMM("12:00"), "overlap"
        end
        assert_raise(TimecardException) do 
            c.new_slot  HHMM("13:55"), HHMM("14:05"), "overlap"
        end

        assert_equal 5, c.model.by_date(Date.today).length
        #records = c.model.by_date[Date.today]
        #assert_equal 4, records.length
    end

    def test_disjunct_slots
        puts "\n--> #{self}"
        c = Controller.new
        c.new_day   Date.today
        c.new_slot(HHMM("10:00"), HHMM("11:00"), "foo bar")
        c.new_slot(HHMM("11:00"), HHMM("13:00"), "foo bar")
        c.new_slot(HHMM("13:00"), HHMM("16:00"), "foo bar")
        assert_equal 3, c.model.records.length
        assert_equal [1,2,3], c.model.records.map { |e| e.span }
    end

    def test_new_record_api
        puts "\n--> #{self}"
        c = Controller.new
        c.new_day   Date.today
        slot = c.new_slot(HHMM("10:00"), HHMM("12:00"), "foo bar")
        c.new_span  "1.75", "some task"
        c.new_txt   "some additional text"
    end
end

