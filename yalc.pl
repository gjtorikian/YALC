#!/usr/bin/perl

use HTML::Parser ();
use File::Find;
use Cwd;

$dirPath = $ARGV[0];
$caseCheck = $ARGV[1];

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

		# not an external link, or ignorable link (/,, #)
		if ($href !~ m/www/ && $href !~ m/http:/ && $href !~ m/https:/ && $href ne '/' && $href ne '' && $href ne '#') 
		{
			if ($href =~ m/\#/) # a reference to somewhere internal
			{
				my $hashFile = substr($href, 0, index($href, "#"));
				$hashId = substr($href, index($href, "#") + 1); 

				$filepath = $currDir . "/" . $hashFile;

				# check preceeding file first
				if ($caseCheck eq 'y')
				{
					casedFileCheck($hashFile, $file, $filepath);
				}
				else
				{
					uncasedFileCheck($hashFile);
	 			}

	 			# then validate hash
				$h->parse_file($file);
			}
			else 
			{
				if ($caseCheck eq 'y')
				{
					casedFileCheck($href, $file, $filepath);
				}
				else
				{
					uncasedFileCheck($filepath);
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

sub casedFileCheck
{
	my ($href, $file, $filepath) = @_;
					$found = 0;
					$lastSlashPos = rindex($href, "/");
					$refDirName = substr($href, 0, $lastSlashPos);
					$refFileName = substr($href, $lastSlashPos + 1);

					if ($refDirName eq '' || $lastSlashPos < 0)
					{
						$refDirName = "./";
					}

					opendir my($dh), $refDirName or die "Couldn't open dir '$refDirName' (href is $href, lastSlashPos is $lastSlashPos) : $!";
					my @refFiles = readdir $dh;
					closedir $dh;

					foreach $refFile (@refFiles)
					{
						if ($refFile eq $refFileName)
						{
							$found = 1;
						}
					}

					if ($found == 0 && $href ne '') 
					{
						print $file . " is trying to incorrectly link to " . $href . " as $filepath : $text\n\n";
					}	
}

sub uncasedFileCheck
{
	my ($filepath) = @_;

					unless (-e $filepath) {
		 				print $file . " is trying to incorrectly link to " . $href . " as $filepath : $text\n\n";
		 			} 
}
