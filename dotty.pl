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
}
