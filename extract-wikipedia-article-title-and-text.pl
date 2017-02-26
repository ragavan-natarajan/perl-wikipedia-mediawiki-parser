#!/usr/bin/perl
BEGIN {$| = 1};

# ________________________________________________________________________________
#
# Important instructions
# ________________________________________________________________________________
#
# Install the following tools before you proceed:
# ===============================================
# sudo apt-get install cpanminus
# cpanm Tree::XPathEngine::Number
#
# Download the following file
# ===========================
# wget https://dumps.wikimedia.org/itwiki/latest/itwiki-latest-pages-articles.xml.bz2
# ________________________________________________________________________________
# This code extracts the article titles and contents of all the 
# non-disambiguation and non-redirect articles present in the 
# mediawiki dump file. It makes use of the CPAN module 
# MediaWiki::DumpFile::FastPages for this purpose. 

# The extracted article titles and contents are separated by tab
# and written to wikipedia_articles.txt. 

use strict;
use warnings;
no warnings 'utf8';

use lib "perl-lib/perl5/";
use MediaWiki::DumpFile::FastPages;
use Encode;

# Set UTF-8 to be the character set for STDOUT.
binmode STDOUT, ':utf8';

if (!@ARGV or scalar @ARGV != 2) {
	print "Arguments: <Knowledge-base path> <Mediawiki dump file>\n";
	exit(-1);
}

my $kb_path = $ARGV[0];
my $mediawiki_file = $ARGV[1];
my $pages = MediaWiki::DumpFile::FastPages->new($mediawiki_file);

my $output_file = "$kb_path/wikipedia_articles.txt";
print "Output will be written to : $output_file\n";

# Delete the output file if it already exists.
unlink $output_file;

open OUTPUT, ">>:encoding(UTF-8)", 
    $output_file
    or die "Could not open file: $!";

my $start_time = time();

print "Processing input file $mediawiki_file\n";

my $count=0;
while ( ( my $title, my $text ) = $pages->next ) {

    # For status reporting.
    $count++;
    if ($count % 1000 == 0) {
        printf "\r%d lines processed", $count;
    }

    $title = &trimstr($title);
    # If the article title is a disambiguation or a redirect title
    # on Wikipedia then do nothing.
    if ($title =~ m/[:(][^:(]*disambiguation/i) {
    } elsif ((substr $text,0,15) =~ /#\s*redirect/i) {
    } else {

        # Otherwise, get the article content and convert all the 
        # non-alpha-numeric content (including any blankspace or newline
        # characters) in it to whitespace and also get the article content in 
        # lower case.
        $text =~ s/[^[:alnum:]]+/ /g;
        $text = lc($text);
        print OUTPUT "$title\t$text\n";
    }
}

close OUTPUT;
printf "\r%d lines processed overall\n", $count;

# Report the execution time.
print "All tasks completed in ";
print &get_execution_time($start_time), "\n";


sub get_execution_time {
    use integer;
    my $start_time = shift;
    my $execution_time = time() - $start_time;
    my $message="";
    if ($execution_time < 60) {
        $message = "$execution_time seconds";
    } elsif ($execution_time >= 60 and $execution_time < 3600) {
        my $minutes = $execution_time / 60;
        my $seconds = $execution_time - ($minutes * 60);
        $message = "$minutes minutes and $seconds seconds";
    } else {
        my $hours = $execution_time / 3600;
        my $minutes = ($execution_time - ($hours * 3600))/60;
        my $seconds = $execution_time - (($hours * 3600) + ($minutes * 60));
        $message = "$hours hours $minutes minutes and $seconds seconds";
    }
    return "$message";
}
