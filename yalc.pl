#!/usr/bin/perl

use HTML::Parser ();
use File::Find;
use Cwd;

$dirPath = $ARGV[0];

my $file;
my $currDir;
my $hashId;

 # Create parser objects
 $p = HTML::Parser->new( api_version => 3,
                         start_h => [\&getAnchors, "text, tagname, attr"],
                         marked_sections => 1,
                       );

$h = HTML::Parser->new( api_version => 3,
                         start_h => [\&findHashes, "text, tagname, attr"],
                         marked_sections => 1,
                       );

find(\&findFiles, $dirPath);

sub findFiles
{
    $file = $_;

    if ($file =~ m/$.htm/ || $file =~ m/$.html/)
    {
    	$currDir = getcwd();
    	$p->parse_file($file);
    }
}

sub getAnchors { 
	my ($text,$tagname, $attr) = @_;

	if ($tagname eq 'a') {
		my $href = $attr->{ href };
		my $filepath = $currDir . "/" . $href;

		if ($href !~ m/www/ && $href !~ m/http:/ && $href !~ m/https:/) # not an external link
		{
			if ($href =~ m/\#/) # a reference to somewhere
			{
				my $hashFile = substr($href, 0, index($href, "#"));
				$hashId = substr($href, index($href, "#") + 1); 
				$h->parse_file($file);
			}
			else 
			{
				unless (-e $filepath) {
	 				print $file . " is trying to incorrectly link to " . $href . " as $filepath : $text\n\n";
	 			} 
	 		}
	 	}
	}
}

sub findHashes {
	my ($text,$tagname, $attr) = @_;
	my $foundId = "0";

	if ($id ne "")
	{
		foreach $id ($attr->{ id })
		{
			if ($id eq $hashId)
			{
				$foundId = "1";
			}
		}

		if ($foundId ne "1")
		{
			print $file . " has an incorrect hash to $hashId\n"; 
		}	
	}
}
