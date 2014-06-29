#!/usr/bin/env ruby

# muc  -  Meaningful Units of Code
# Talus Baddley
# 2014

require 'open3'

total_pts = ARGV.lazy.map { |infile|
    
    this_file = -50  # “...the compression mechanism has a constant overhead in the region of 50 bytes.”
    
    Open3.popen3("bzip2", "--compress", "--best", "--stdout", "--quiet", infile) do |bzin, bzout, bzerr, wait_thr|
        bzin.close
        bzout.binmode
        
        begin
            loop do
                this_file += bzout.readpartial(1024).bytesize
            end
        rescue EOFError => eofe
            # cool.
        end
        
        bzerr.close
        bzout.close
        
        if wait_thr.value.exitstatus != 0
            $stderr.puts "Big epic problem."
            exit
        end
        
    end
    
    [this_file, 0].max / 10.0
    
}.reduce( :+ )


puts "#{total_pts} muc for #{ARGV.count} file#{ARGV.count == 1 ? '' : 's'}"
