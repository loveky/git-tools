#!/usr/bin/ruby

# Author: loveky <ylzcylx@gmail.com>
# Blog  : http://loveky2012.blogspot.com

#Usage: find_it_in_history.rb --file <file> --repo <path/to/repo> --path_in_repo <file/path/in/repo>

require 'digest/sha1'
require 'optparse'

found   = false
commit  = nil
options = {}
OptionParser.new do |opts|
    opts.banner = "Find the commit who first introduced the specified version of a file"
    opts.on('--file FILE', 'Which file to check') do |value|
        options[:file] = value
    end
    opts.on('--repo REPO', 'which repo to check') do |value|
        options[:repo] = value
    end
    opts.on('--path_in_repo PATH', 'the path of the file in repo') do |value|
        options[:path_in_repo] = value
    end
end.parse!

file_content = File.open(options[:file]) {|f| f.read}
file_sha1    = Digest::SHA1.hexdigest("blob #{file_content.length}\0" + file_content)

puts("#{options[:file]} => #{file_sha1}")

Dir.chdir(options[:repo])

IO.popen("git whatchanged --oneline -m -- #{options[:path_in_repo]}") do |git_whatchanged|
    git_whatchanged.each_line do |line|
        if line[0,1] == ':'
            new_blob = (/\.\.\. ([0-9a-fA-F]{7})\.\.\./.match(line))[1]
            
            if new_blob == file_sha1[0,7]
                puts "Found blob(#{file_sha1[0,7]}) in commit " + commit
                found = true
            elsif found == true
                exit 0
            end
        else
            commit = line[0,7]   
        end
    end
end
