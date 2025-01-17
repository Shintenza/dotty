use strict;
use warnings;
use Getopt::Long;

use lib './lib/';
use Utils;
use Consts;
use Dotty;

my $main_option = shift @ARGV;

if (!$main_option) {
  Utils::throw_error("Invalid usage; check --help");
}

if ($main_option eq "init") {
  my $cusotm_location = "";

  GetOptions(
    'path=s' => \$cusotm_location,
  );

  initialize($cusotm_location);
} elsif ($main_option eq "sync") {
  my $force_enabled = 0;
  GetOptions(
    'force' => \$force_enabled,
  );
  sync($force_enabled);
} elsif ($main_option eq "add") {
  my $location;
  my $replace;
  my $file = shift @ARGV;
  Logger::throw_and_abort("missing file/directory") unless $file;

  GetOptions(
    'path=s' => \$location,
    'replace' => \$replace,
  );
  add($file, $location, $replace);
} elsif ($main_option eq "remove") {
  my $clean_removal;
  my $destination = shift @ARGV;

  GetOptions(
    'clean' => \$clean_removal,
  );

  remove($destination, $clean_removal);
} else {
  Utils::print_help();
}
