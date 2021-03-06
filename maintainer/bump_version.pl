#!/usr/bin/perl

sub usage {
    print "Usage: bump_version.pl VERSION\n";
    exit(2);
}

$VERSION=$ARGV[0];
usage() unless defined $VERSION;
print "Bumping to version $VERSION.\n";

# Bump version in tcl files
while ($file = <pbc*.tcl>) {
    print "Working on $file.\n";
    open(IN, "<$file") || die "Can't open $file for reading!";
    open(OUT, ">$file.new") || die "Can't open $file.new for writing!";
    while (<IN>) {
	if (s/package (provide|require) pbc(tools|gui|_core) (.*)$/package $1 pbc$2 $VERSION/) {
	    print "  pbc$2 $3 -> $VERSION\n";
	}
	print OUT $_;
    }
    close(IN);
    close(OUT);
    print "  $file.new -> $file.\n";
    rename "$file.new", $file;
}

# Call pkg_mkIndex
print "Updating pkgIndex.tcl...\n";
system('tclsh maintainer/pkg_mkIndex.tcl');
open(OUT, ">>pkgIndex.tcl") || die "Can't open pkgIndex.tcl for writing!";
print OUT "package ifneeded pbc_core $VERSION [load [file join \$dir libpbc_core.so]]\n";
close(OUT);
print "Finished.\n";

# Bump version in doc/pbctools.tex
$file = "doc/pbctools.tex";

print "Working on $file.\n";
open(IN, "<$file") || die "Can't open $file for reading!";
open(OUT, ">$file.new") || die "Can't open $file.new for writing!";

# Replace version number in the first line
while (<IN>) {
    if (s/^\\date\{Version (.*)\}$/\\date\{Version $VERSION\}/) {
	print "  $1 -> $VERSION\n";
    }
    print OUT $_;
}

close(IN);
close(OUT);

print "  $file.new -> $file.\n";
rename "$file.new", $file;

# Bump version in src/pbc_core.c
$file = "src/pbc_core.c";

print "Working on $file.\n";
open(IN, "<$file") || die "Can't open $file for reading!";
open(OUT, ">$file.new") || die "Can't open $file.new for writing!";

# Replace version number.
while (<IN>) {
    if (s/^#define PBC_CORE_VERSION "(.*)"/#define PBC_CORE_VERSION "$VERSION"/) {
	print "  $1 -> $VERSION\n";
    }
    print OUT $_;
}

close(IN);
close(OUT);

print "  $file.new -> $file.\n";
rename "$file.new", $file;

# Bump version in Makefile
$file = "Makefile";

print "Working on $file.\n";
open(IN, "<$file") || die "Can't open $file for reading!";
open(OUT, ">$file.new") || die "Can't open $file.new for writing!";

# Replace version number.
while (<IN>) {
    if (s/^VMVERSION = (.*)/VMVERSION = $VERSION/) {
	print "  $1 -> $VERSION\n";
    }
    print OUT $_;
}

close(IN);
close(OUT);

print "  $file.new -> $file.\n";
rename "$file.new", $file;

# Now rebuild the docs
print "Now recreating the documentation...\n";
chdir "doc";
open(LOG, ">make.log") || die "Can't open make.log for writing!";
$res = `make`;
print LOG $res;
print "See make.log for make output.\n";

system("ls -l pbctools.html pbctools.pdf");

