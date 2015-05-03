#!/usr/bin/env ruby

# muc  -  Meaningful Units of Code
# Talus Baddley
# 2014-2015

# Version 2: Switched to ARGF for auto-concat'ing;
#            added much suaveness to input checking.

require 'open3'
argv_count = ARGV.count


def total_pts catfiles
    sizeof_file = -50  # “...the compression mechanism has a constant overhead in the region of 50 bytes.”
    file_contents = catfiles.each_line.lazy.map {|ligne| ligne.gsub /\s/, '' }
    
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
    
end
    


points = if ARGF.filename == '-' && (STDIN.tty? || STDIN.closed?)
    STDERR.puts ""
    STDERR.puts "Usage: muc.rb <infile> [<infile-2> ...]"
    STDERR.puts "    or: cat <stuff> | muc.rb"
    STDERR.puts ""
    
    0
    
else
    total_pts ARGF
    
end

puts argv_count == 0 ?
    "#{points} muc for stdin" :
    "#{points} muc for #{argv_count} file#{argv_count == 1 ? '' : 's'}"
    
