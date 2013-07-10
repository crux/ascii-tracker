#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'pp'
require 'ostruct'
require 'applix'
require 'asciitracker'

# example cmdline:
#
#   $ ./slotter.rb --report=2013-02-01--2013-03-01.txt \
#       scan ~/.timecard \
#       range 2013-02-01 2013-03-01 \
#       group report
#
Applix.main(ARGV, debug: false) do

  class Context 
    attr_reader :argv, :values
    def initialize argv, config
      @argv = argv
      @values = OpenStruct.new(config)
    end

    def set_default_values defaults 
      @values = OpenStruct.new(defaults.merge(@values.marshal_dump))
    end

    def forward(target)
      begin
        (op = @argv.shift) && target.send(op, self)
      rescue ArgumentError => e
        target.send(op)
      end
    end
  end

  prolog do |argv, config|
    @context = Context.new(argv, config)
    @app = AsciiTracker::App.new(@context)
  end

  handle(:any) do |*args, opts|
    @context.forward(@app)
  end
end