module AsciiTracker
  class App

    Defaults = {
      outfile: nil, # defaults to $stdout
    }

    def initialize #(context)
      #@options = Defaults.merge(context.options)
      #context.set_default_values(report: "report.txt")
      @c = Controller.new
    end

    def scan args, _ = {}
      filename = args.shift
      puts "scanning file: #{filename}"
      AsciiTracker::Parser.parse(@c, IO.read(filename))
      #puts "records:\n#{records.join("\n")}"
      #puts "--> 2: #{@c.model}"
      #puts "--> 3: #{@c.model.records}"
    end

    def render_txt(options = {})
      group(@c.model.projects)

      outfile = if options[:report] and options[:report] != '-'
                  File.open(options[:report], (options[:append] ? "a+" : "w"))
                else
                  $stdout # nil or '-' means stdout
                end

      workcount = weekdays_in_range(*@selection_range) \
        - (sickcount = @sickdays.size) \
        - (holicount = @holidays.size) \
        - (freecount = @freedays.size)

      netto = total = @selection.inject(0.0) { |sum, rec| sum + rec.span }

      %w{ishapes pause ueberstunden holidays feiertag}.each do |tag|
        netto -= (pause = @groups[tag].total rescue 0)
      end
      #pause = @groups["pause"].total rescue 0
      #netto -= pause
      #abbau = @groups["ueberstundenabbau"].total rescue 0
      #netto -= abbau
      #netto -= @groups["holidays"].total rescue 0
      #netto -= @groups["feiertag"].total rescue 0

      outfile.puts(<<-EOT % [netto, total])
reporting period: #{@selection_range.join(" until ")}
#{@selection.size} records in #{@groups.size} groups
#{@workdays.size} days booked(#{workcount} working(weekdays), #{sickcount} sickdays, #{holicount} holidays, #{@freedays.size} freeday)
            ---
%.2f netto working hours in total(%.2f brutto)
            ---
freedays: #{@freedays.map {|rec| rec.date.strftime("%e.%b")}.join(", ") }
holidays: #{@holidays.map {|rec| rec.date.strftime("%e.%b")}.join(", ") }
sickdays: #{@sickdays.map {|rec| rec.date.strftime("%e.%b")}.join(", ") }
            ---
      EOT

      @groups.each do |project_id, group| 
        #puts ">>>> #{project_id}:\n#{records.join("\n")}"
        #total = group.records.inject(0.0) { |sum, rec| sum + rec.span }
        #h1 = "#{group.total} hours #{group.project_id}"
        if options[:brief]
          p = [group.total, group.project_id]
          outfile.puts("%6.2f hours #{group.project_id}" % p)
          next
        end

        headline = group_head(group, workcount)
        outfile.puts <<-EOT

#{headline}
#{'-' * headline.size}
        EOT
        group.records.each do |rec| 
          #report.puts ("%5.2f" % rec.span) << "\t#{rec}"
          outfile.puts(("%s(%5.2f)" % [HHMM.new(rec.span), rec.span]) << "\t#{rec}")
        end
      end

      outfile.puts <<-TXT
<<< end of reporting period: #{@selection_range.join(" until ")}
      TXT
    end

    def range(args, _ = {})
      a = Date.parse(args.shift)
      b = Date.parse(args.shift)
      puts "selected date range: #{a} #{b}"
      select_in_range(a, b)
    end

    private

    def weekdays_in_range(first_day, last_day)
      range = (first_day...last_day)
      #(t..(t+7)).select { |e|  [0,6].include? e.wday  }.map { |e| e.to_s 
      puts "================#{range}"
      range.reject { |e| [0,6].include? e.wday }.size
    end
=begin
    def before(context)
      a = Date.parse(context.argv.shift)
      select_in_range(Date.today - (365*10), a)
      context.forward(self)
    end

    def after(context)
      a = Date.parse(context.argv.shift)
      select_in_range(a, Date.today+1)
      context.forward(self)
    end

    def today(context)
      a = Date.today
      select_in_range(a, a+1)
      context.forward(self)
    end
=end

    def group(projects)
      @groups = group_by_project(projects)
      @groups.each do |project_id, records| 
        @groups[project_id] = {
          project_id: project_id, 
          records: records,
          total: records.inject(0.0) { |sum, rec| sum + rec.span }
        }
      end

      # XXX: this only works when assuming full days
      @holidays = @groups["holidays"].records rescue []
      @freedays = @groups["feiertag"].records rescue []
      @sickdays = @groups["sickdays"].records rescue []
      @abbau = @groups["ueberstundenabbau"].records rescue []
    end

    def select_in_range first_day, last_day
      @selection = []
      @workdays = []
      @selection_range = [first_day, last_day]
      day = first_day
      while day < last_day
        dayrecs = @c.model.by_date(day)
        @selection.push(*dayrecs)
        @workdays.push(day) unless dayrecs.empty?
        day += 1
      end
      puts "#{@selection.size} records in range"
    end

    def group_head group, work_days
      per_day  = "%.3f" % [group.total / work_days]
      days = group.total.to_i / 8
      h = group.total - (days * 8)
      thours = "%.2f" % group.total
      hours = "%.2f" % h
      d,h,m = Record.hours_to_dhm(group.total)
      "#{thours} hours | #{d}d #{h}h #{m}m | #{per_day} hours/day: #{group.project_id}"
    end

    # grouping records by projects
    def group_by_project projects

      groups = {} 
      groups[:unaccounted] = @selection.dup

      projects.each do |project_id, project_matchers|
        group = (groups[project_id] ||= [])
        project_matchers.each do |re| 
          matching_records, rest = groups[:unaccounted].partition do |rec| 
            re.match(rec.desc) 
          end
          group.push(*matching_records)
          groups[:unaccounted] = rest
        end
      end
      groups.delete_if { |k,v| v.nil? or v.empty? }
      groups
    end

  end
end

