module AsciiTracker
  class App

    Defaults = {
      outfile: nil,   # defaults to $stdout
      delimiter: ',', # defaults to german delimiter 
    }

    def initialize #(context)
      #@options = Defaults.merge(context.options)
      #context.set_default_values(report: "report.txt")
      @c = Controller.new
    end

    def scan args, _ = {}
      args.shift.split(/,/).each do |pattern|
        scan_file(pattern)
        #puts "scanning file: #{filename}"
        #AsciiTracker::Parser.parse(@c, IO.read(filename))
        #puts "records:\n#{records.join("\n")}"
        #puts "--> 2: #{@c.model}"
        #puts "--> 3: #{@c.model.records}"
      end
    end
 
    def scan_file pattern
      Dir[pattern].each do |filename| 
        puts "scanning file: #{filename}"
        AsciiTracker::Parser.parse(@c, IO.read(filename))
      end
    end

    def report(args, options = {})
      select_in_range(args)
      group(@c.model.projects)
    end

    # removes all projects groups which are not included in whitelist
    def include(args, options = {}) 
      whitelist = args.shift.split(/,/)
      @groups.select! {|project_id, _| whitelist.include?(project_id) }
    end

    # output a report in csv format
    def csv(options = {})
      outfile = open_outstream(options[:report], options)

      # column heads first
      outfile.puts('date;hh:mm;h;begin;end;project;desc')

      @groups.each do |project_id, group| 
        group.records.each do |rec| 
          # strip project descriptive name from description text
          proj, desc = rec.desc.split(/: /, 2)
          # a, b are begin and end in case record is actually a slot 
          a, b = rec.respond_to?(:t_start) ?  [rec.t_start, rec.t_end] : []

          # with --delimiter=<char> you can change this
          h = "%.2f"%rec.span
          (options[:delimiter] and h.sub!('.', options[:delimiter]))

          outfile.puts(
            [rec.date, HHMM.new(rec.span), h, a, b, proj, desc].join(';')
          )
        end
      end
    end

    def txt(options = {})
      outfile = open_outstream(options[:report], options)

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

    private

    # path == nil or '-' means stdout
    def open_outstream(path = '-', options = {})
      if(path and path != '-')
        File.open(path, (options[:append] ? "a+" : "w"))
      else
        $stdout
      end
    end

    def weekdays_in_range(first_day, last_day)
      range = (first_day...last_day)
      #(t..(t+7)).select { |e|  [0,6].include? e.wday  }.map { |e| e.to_s 
      puts "================#{range}"
      range.reject { |e| [0,6].include? e.wday }.size
    end

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

    def select_in_range args
      range, args_rest = AsciiTracker::Ranges.parse!(*args)
      args.replace(args_rest) # args manipulation must be also be returned 
      puts "selected date range: #{range.begin} #{range.end}"

      #select_in_range(range.begin, range.end)
      @selection = []
      @workdays = []
      @selection_range = [range.begin, range.end]
      day = range.begin
      while day < range.end
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

__END__
=begin
    def range(args, _ = {})
      a = Date.parse(args.shift)
      b = Date.parse(args.shift)
      puts "selected date range: #{a} #{b}"
      select_in_range(a, b)
    end

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
