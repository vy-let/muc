#!/usr/bin/env ruby

# muc  -  Meaningful Units of Code
# Talus Baddley
# 2014

require 'open3'

total_pts = ARGV.lazy.map { |infile|
    
    sizeof_file = -50  # “...the compression mechanism has a constant overhead in the region of 50 bytes.”
    file_contents = open(infile, 'rb').each_line.lazy.map {|ligne| ligne.gsub /\s/, '' }
    
    Open3.popen3("bzip2", "--compress", "--best", "--quiet") do |bzin, bzout, bzerr, wait_thr|
        bzout.binmode
        pool = []
        
        pool << Thread.new do
            file_contents.each {|ligne| bzin.write ligne }
            bzin.close
        end
        
        pool << Thread.new do
            begin
                loop do
                    sizeof_file += bzout.readpartial(1024).bytesize
                end
            rescue EOFError => eofe
                # done.
            end
        end
        
        pool << Thread.new { bzerr.read }  # We don't care, for now.
        
        pool.each {|th| th.join }
        
        if wait_thr.value.exitstatus != 0
            $stderr.puts "Big epic problem."
            exit
        end
        
    end
    
    [sizeof_file, 0].max / 10.0
    
}.reduce( :+ )


puts "#{total_pts} muc for #{ARGV.count} file#{ARGV.count == 1 ? '' : 's'}"
