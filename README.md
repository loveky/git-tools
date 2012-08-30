### This repo contains scripts that may make your git life easier ###
_______________

#### find_it_in_history.rb ####
Given a file, the path of the file in the repo and a path to local repo. Check in which commit the given file was first introduced in
Usage:

	find_it_in_history.rb --file <file> --repo <path/to/repo> --path_in_repo <file/path/in/repo>

#### find_large_file.pl ####
This script is used to find large files in your repo
Usage:

	find_large_file.pl -size MAX_SIZE_ALLOWED -repo PATH/TO/YOUR/REPO

#### parse_index_file ####
This script will parse the given index file and output all entries in it.
Usage:

	parse_index_file --file path/to/index/file