module Slotter
  class Model

    attr_reader :records, :projects 

    def initialize 
      @records = [ ]
      @by_date = { }
      @projects = Hash.new { |hash, project_id| hash[project_id] = [] }
    end

    def by_date(date)
      (@by_date[date] ||= [])
    end

    def add_record rec, date = Date.today
      @records.push(rec)
      (@by_date[date] ||= []).push(rec)
      rec
    end

    def find_overlaps rec, date = Date.today
      by_date(date).find_all { |a| a.overlaps?(rec) rescue false }
    end

    def find_best_cover rec, date = Date.today
      by_date(date).inject(nil) do |best, test| 
        if test.respond_to?(:covers?) # spans never cover
          if test.covers?(rec) && (best.nil? || (best.covers? test))
            best = test 
          end
        end
        best
      end
    end
  end
end
