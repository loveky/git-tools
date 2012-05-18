#!/usr/bin/perl

# Wrote by loveky <ylzcylx@gmail.com> <http://loveky.me>
#
# This script is used to find large files in your repo
#
# Usage: find_large_file.pl -size MAX_SIZE_ALLOWED -repo PATH/TO/YOUR/REPO

use warnings;
use strict;
use Getopt::Long;
use File::Basename;

my $GIT_DIR;
my $max_size_allowed = 0;
my $repo = '';

GetOptions( "size=i"  => \$max_size_allowed,
            "repo=s"  => \$repo);

if (not $max_size_allowed) {
    print "Missing parameter \"-size SIZE\", script will list the files whose size is larger than the max size you specified here\n";
    exit 1;
}

if (not $repo) {
    print "Missing parameter \"-size /path/to/your/repo\", you have to tell me which repo are you checking for large files\n";
    exit 1;
}

chdir $repo;

my $is_in_git_dir   = `git rev-parse --is-inside-git-dir`;
my $is_in_work_tree = `git rev-parse --is-inside-work-tree`;

if ( $is_in_git_dir eq "false" && $is_in_work_tree eq "false") {
    print "The repo path you provides ($repo) is not a valid git repo, please verify!\n";
    exit 1;
}
else {
    $GIT_DIR = `git rev-parse --git-dir`;
    chomp $GIT_DIR;
}

# First, process pack file
my @pack_list = glob("$GIT_DIR/objects/pack/pack-*.pack");

foreach my $pack_file (@pack_list) {
    my @blob_list = `git verify-pack -v $pack_file | grep blob | cut -f1 -d\' \'`;
    foreach my $blob (@blob_list) {
        chomp $blob;
        my $blob_size = `git cat-file -s $blob`;
        chomp $blob_size;
        next if $blob_size < $max_size_allowed;

        my $filename = `for rev in \$(git rev-list --all); do git ls-tree -r \$rev | grep $blob; done |uniq | awk '{print \$4}'`;
        chomp $filename;
        print "$blob \t $blob_size \t $filename \n";
    }
}

# Then, process the loose object
my @loose_object_dir_list = glob("$GIT_DIR/objects/[0-9a-fA-f][0-9a-fA-F]");
foreach my $loose_object_dir (@loose_object_dir_list) {
    my $object_prefix = basename($loose_object_dir);
    my @object_list = glob("$loose_object_dir/*");
    foreach my $object (@object_list) {
        my $object_suffix = basename $object;
        my $object_sha1 = $object_prefix . $object_suffix;
        my $result = `git cat-file -t $object_sha1`;
        chomp $result;
        next if $result !~ /blob/i;
        my $blob_size = `git cat-file -s $object_sha1`;
        chomp $blob_size;
        next if $blob_size < $max_size_allowed;

        my $filename = `for rev in \$(git rev-list --all); do git ls-tree -r \$rev | grep $object_sha1; done |uniq | awk '{print \$4}'`;
        chomp $filename;
        print "$object_sha1 \t $blob_size \t $filename \n";
    }
}
