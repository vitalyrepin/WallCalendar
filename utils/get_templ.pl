#!/usr/bin/perl

## Tiny utility script to work with templates. Launch it without arguments to see how "clever" it is.
##
## (C) Vitaly Repin, 2013.
## License: GPLv3

use strict;

use File::Spec;
use File::Basename;
use Getopt::Long;

# hash array with configuration
my %cfg;

$cfg{template} = "RuEnPhoto2014";

# Logs message to stderr
# Input parameter: message to log
sub _log($)
{
  print STDERR shift . "\n";
};

# Replacement to the die subroutine. Calls _log subroutine
sub log_die($)
{
  my $str = shift;

  _log  $str;
  die $str;
};

# Creates symlinks to the template in the working directory
# Param:
# 1: template name
sub gen_links($)
{
  my $tname = shift;
  my $dirname = File::Spec->catdir("../../templates/", $tname);
  my $fname;

  _log "Generating symlinks for the template $tname";

  opendir(DIR, $dirname) or log_die "can't opendir $dirname: $!";

  while (defined($fname = readdir(DIR))) {
    next if $fname =~ /^\.\.?$/;     # skip . and ..
    symlink(File::Spec->catfile($dirname, $fname), File::Spec->catfile(".", $fname)) or log_die "can't make symlink $fname : $!";
    _log "Added symlink to $fname";
  }
  closedir(DIR);
}

# Removes all the symlinks from the current directory
sub clean_links()
{
  my $fname;

  opendir(DIR, ".") or log_die "can't opendir .: $!";
  while (defined($fname = readdir(DIR))) {
    next if $fname =~ /^\.\.?$/;     # skip . and ..
    if(-l $fname) {
	_log "Unlinking symlink: '$fname'";
	 unlink $fname or log_die "Could not unlink $fname: $!";
    };
  }
  closedir(DIR);
}

# User's help
sub usage () {
  print "Usage: $0 <command>\n";
  print "<command> is one of:\n";
  print "  --link\t\t Create symlinks to point to the template files\n";
  print "  --unlink\t\t Unlink symlinks\n";
  print "  --sync\t\t Unlink symlinks and create them again (--unlink, --link)\n";
  print "  --help\t\t Get this text and exit\n"
};

## Main. Kind of :-)
my ($link, $unlink, $help, $sync);

GetOptions ("link" => \$link, "unlink" => \$unlink, "sync" => \$sync, "help" => \$help) or log_die("Error in command line arguments\n");

if($link) {
    gen_links($cfg{template});
} elsif($unlink) {
    clean_links();
} elsif($sync) {
    clean_links();
    gen_links($cfg{template});
} else {
    usage();
};
