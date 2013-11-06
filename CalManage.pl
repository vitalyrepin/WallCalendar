#!/usr/bin/perl

## Tiny utility script to manage templates. Launch it without arguments to see how "clever" it is.
##
## (C) Vitaly Repin, 2013.
## License: GPLv3

use strict;

use File::Spec;
use File::Basename;
use File::Copy;
use Getopt::Long;

# hash array with configuration
my %cfg;

$cfg{"templdir"} = "templates";
$cfg{"caldir"}   = "calendars";

# Logs message to stderr
# Input parameter: message to log
sub _log($) {
    print STDERR shift . "\n";
}

# Replacement to the die subroutine. Calls _log subroutine
sub log_die($) {
    my $str = shift;

    _log $str;
    die $str;
}

# Generates symlinks for the given calendar pointing to the given template files
# Arg1: template name
# Arg2: calendar name
sub gen_links($ $) {
    my $templ = shift;
    my $cal   = shift;

    my $fname;

    _log "Generating symlinks for the calendar $cal from the template $templ";
    my $tdirname = File::Spec->catdir( $cfg{"templdir"}, $templ );
    my $cdirname = File::Spec->catdir( $cfg{"caldir"},   $cal );

    opendir( DIR, $tdirname )
      or log_die "can't opendir template dir $tdirname: $!";

    # If no ".gitignore" exists, we'll create it and add all the symlinks there
    my $gitignore = undef;
    my $gitignorename = File::Spec->catfile( $cdirname, ".gitignore" );
    if ( !-e $gitignorename ) {
        open( $gitignore, '>', $gitignorename )
          or log_die "can't open $gitignorename for writing!";
    }

    while ( defined( $fname = readdir(DIR) ) ) {
        next if $fname =~ /^\.\.?$/;    # skip . and ..
        next
          if ( $fname eq "License" )
          or ( $fname eq "README" )
          or ( $fname eq "GPL3.txt" );    # Skipping Licenses and Readme
        # Skipping customization files.
        next if ( $fname eq "customization.tex" ) or ( $fname eq "custom.mk" );

        symlink(
            File::Spec->catfile( "../../",  $tdirname, $fname ),
            File::Spec->catfile( $cdirname, $fname )
        ) or log_die "can't make symlink $fname : $!";
        print "Added symlink to $fname\n";

        if ( defined($gitignore) ) {
            print "Adding the file $fname to .gitignore\n";
            print $gitignore "$fname\n";
        }
    }
    closedir(DIR);
    if ( defined($gitignore) ) { close($gitignore); }
}

# Removes all the symlinks from the given directory
# Arg1: Directory to clean symlinks from
sub clean_links($) {
    my $dirname = shift;
    my $fname;

    opendir( DIR, $dirname ) or log_die "can't opendir .: $!";
    print "Cleaning the symbolic links from the directory $dirname\n";
    while ( defined( $fname = readdir(DIR) ) ) {
        next if $fname =~ /^\.\.?$/;    # skip . and ..
        my $ffname = File::Spec->catfile( $dirname, $fname );

        if ( -l $ffname ) {
            print "Unlinking symlink: '$ffname'\n";
            unlink $ffname or log_die "Could not unlink $ffname: $!";
        }
    }
    closedir(DIR);
}

# Returns the alphabetically sorted list of 1st layers-subdirs of the given directory.
# Arg1: Directory name
sub get_subdirs($) {
    my $parent = shift;
    my $fname;

    my @dirlist = ();
    opendir( DIR, $parent ) or log_die "can't opendir .: $!";
    while ( defined( $fname = readdir(DIR) ) ) {
        next if $fname =~ /^\.\.?$/;    # skip . and ..
        my $dirname = File::Spec->catdir( $parent, $fname );
        if ( -d $dirname ) {
            push( @dirlist, $fname );
        }
    }

    # Sort the list alphabetically
    return sort { $a cmp $b } @dirlist;
}

# Prints subdirs of the given directory (only of the 1st layer)
# Arg1: Direcory to show sibfolders for
sub show_subdirs($) {
    my $parent = shift;

    foreach ( get_subdirs($parent) ) { print "$_\n"; }
}

# Shows the templates defined
sub list_templs() {
    print "Defined templates:\n\n";
    show_subdirs( $cfg{"templdir"} );
}

# Shows the calendars defined
sub list_cals() {
    print "Defined calendars:\n\n";
    show_subdirs( $cfg{"caldir"} );
}

# Returns 1 if elements exists in the aaray. 0 otherwise
# Adapted from: http://docstore.mik.ua/orelly/perl/cookbook/ch04_13.htm
# Arg1: Element
# Arg2: Reference to an array
sub elem_exists($ $) {
    my $item = shift;
    my $arr  = shift;

    foreach (@$arr) {
        if ( $item eq $_ ) {
            return 1;
        }
    }
    return 0;
}

# Checks is the template exists
# Arg1: Template name
sub check_template_exists ($) {
    my $templ = shift;

    my @templs = get_subdirs( $cfg{"templdir"} );

    my $tst = elem_exists( $templ, \@templs );
    if ( $tst != 1 ) {
        print STDERR "Template $templ is not defined!\n";
        list_templs();
        die "Error processing the command";
    }
}

# Synchronizes calendar with a template
# Arg1: Calendar name
# Arg2: Template name
sub sync_cal($ $) {
    my $cal   = shift;
    my $templ = shift;

    my @cals = get_subdirs( $cfg{"caldir"} );

    # Check that name of the calendar and of the templates are correct
    my $tst = elem_exists( $cal, \@cals );
    if ( $tst != 1 ) {
        print STDERR "Calendar $cal is not defined!\n";
        list_cals();
        return;
    }
    check_template_exists($templ);

    # It's safe now to do synchronization
    clean_links( File::Spec->catdir( $cfg{"caldir"}, $cal ) );
    gen_links( $templ, $cal );
}

# Creates new calendar based on a template
# Arg1: Calendar name
# Arg2: Template name
sub new_cal($ $) {
    my $cal   = shift;
    my $templ = shift;

    # Making sure template exists
    check_template_exists($templ);

    # Making sure calendar does NOT exist
    my @cals = get_subdirs( $cfg{"caldir"} );
    my $tst = elem_exists( $cal, \@cals );
    if ( $tst != 0 ) {
        print STDERR "Calendar $cal is ALREADY defined! Remove it first!\n";
        list_cals();
        return;

    }

    # Now it's safe to create new calendar
    my $caldir = File::Spec->catdir( $cfg{"caldir"}, $cal );
    print "Creating new calendar directory: $caldir\n";
    mkdir $caldir or log_die "can't mkdir $caldir : $!";

    gen_links( $templ, $cal );

    # Copying the "special" files (customization part of the template)
    my @special_files = ( "customization.tex", "custom.mk" );
    foreach (@special_files) {
        my $dst = File::Spec->catfile( $caldir, $_ );
        my $src = File::Spec->catfile( $cfg{"templdir"}, $templ, $_ );

        if ( -e $src ) {
            print "Copy file $src to $dst\n";
            copy( $src, $dst ) or log_die "can't copy file: $!";
        }
        else {
            print STDERR "WARNING: Template does not contain the file $_!\n";
        }
    }
}

# User's help
sub usage () {
    print "Usage: $0 <command> [OPTIONS]\n";
    print "<command> is one of:\n";
    print "  --list-templs\t List defined templates\n";
    print "  --list-cals\t List defined calendars\n";
    print "  --sync-cal <CAL_NAME> <TEMPL_NAME>\t Sync calendar <CAL_NAME> with its template <TEMPL_NAME>\n";
    print "  --new-cal <CAL_NAME> <TEMPL_NANE>\t Make a new calendar <CAL_NAME> based on the template <TEMPL_NAME>\n";
    print "  --help\t Get this text and exit\n";
}

sub usage_die () {
    usage();
    die;
}

## Main. Kind of :-)
my ( $help, @sync, @newcal, $list_templs, $list_cals );

GetOptions(
    "list-templs"   => \$list_templs,
    "new-cal=s{2}"  => \@newcal,
    "list-cals"     => \$list_cals,
    "sync-cal=s{2}" => \@sync,
    "help"          => \$help
) or usage_die();

if ($list_templs) {
    list_templs();
}
elsif ($list_cals) {
    list_cals();
}
elsif (@sync) {
    sync_cal( @sync[0], @sync[1] );
}
elsif (@newcal) {
    new_cal( @newcal[0], @newcal[1] );
}
else {
    usage();
}
