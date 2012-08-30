#!/usr/bin/ruby

# Author: loveky <ylzcylx#gmail.com>
# Blog  : http://loveky2012.blogspot.com

# This script will parse the given index file and output all entries in it.
# run 'parse_index_file.rb -h' for help message

$: << File.dirname(__FILE__) 
require 'bindata'
require 'optparse'
require 'IndexEntry'

STANDARD_SIGNATURE  = 'DIRC'
entry_count         = 1

begin
    options = {}
    opts = OptionParser.new do |opts|
        opts.banner = "Parse the index file and show you what is there"
        opts.on('-f FILE ','--file FILE', 'Path to the index file') do |value|
            options[:file] = value
        end
    
        opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
        end
    
    end.parse!

    raise ArgumentError, "No index file given!" if options[:file] == nil

    File.open(options[:file], "rb") do |fd|
        SIGNATURE = fd.read(4)
        raise RuntimeError, "Not an index file!" if SIGNATURE != STANDARD_SIGNATURE
    
        VERSION         = fd.read(4).unpack("N")[0]
        ENTRIES_NUMBER  = fd.read(4).unpack("N")[0]
    
        puts "Index version : #{VERSION}"
        puts "Entries number: #{ENTRIES_NUMBER}"
    
        ENTRIES_NUMBER.times do
            entry = IndexEntry.read(fd)
            puts "Found file: " + entry.path 
            puts "  SHA1    : " + entry.sha1.unpack("H40").join
            puts "  stage   : #{entry.flags << 2 >> 14}"
            puts "  ctime   : " + Time.at(entry.ctime_s + entry.ctime_ns * 10**-9).strftime('%Y-%m-%d %H:%M:%S.%9N')
            puts "  mtime   : " + Time.at(entry.mtime_s + entry.mtime_ns * 10**-9).strftime('%Y-%m-%d %H:%M:%S.%9N')
            puts "  size    : #{entry.file_size}"
        
            if (fd.pos - 12) % 8 != 0
                fd.seek(8 - ((fd.pos - 12) % 8), IO::SEEK_CUR)
            end
        end
    end
rescue => ex
    puts "#{ex.class}: #{ex.message}"
end
