package Dotty;
use strict;
use warnings;

use File::Basename;
use File::Path qw(make_path);
use Cwd 'abs_path';
use Data::Dumper;
use Exporter 'import';

use lib ".";
use Utils;
use Logger;

our @EXPORT = qw(
  $parsed_config_ref
  check_if_initialized
  initialize
  sync
);

our $parsed_config_ref = Utils::parse_config();

sub get_dotfiles_root_dir {
  my $dotty_location = Consts::DEFAULT_LOCATION;
  my $config_location = Utils::get_dict_value($parsed_config_ref, ["general", "location"]);
  if ($config_location) {
    $dotty_location = $config_location;
  }
  return $dotty_location;
}

sub get_dotfiles_config_location {
  my $dotty_location = get_dotfiles_root_dir();
  my $full_file_location = $dotty_location . "/" . Consts::DOTTY_CONF;

  return $full_file_location;
}

sub get_dotfiles_config {
  my $config_location = get_dotfiles_config_location();
  my $cofnig_ref = Utils::parse_yaml_file($config_location);
  return $cofnig_ref;
}

sub check_if_initialized {
  if (-e get_dotfiles_config_location()) {
    return 1;
  }

  return 0;
}

sub throw_if_initialized {
  if (check_if_initialized()) {
    Utils::throw_error("Your dotfiles location configuration is already initialized at " . get_dotfiles_config_location());
  }
}

sub throw_if_not_initialized {
  if (!check_if_initialized()) {
    Utils::throw_error("You need to initialize dotfiles location first using init; see --help");
  }
}

sub initialize {
  throw_if_initialized();
  my ($location) = @_;
  my $absolute_location = $location ? abs_path($location) : abs_path(Consts::DEFAULT_LOCATION);
  
  unless (-d $absolute_location) {
    mkdir $absolute_location or Utils::throw_error("Failed to create Dotty directory at $absolute_location");
  }

  if (abs_path($absolute_location) ne abs_path(Consts::DEFAULT_LOCATION)) {
    Utils::add_dict_value($parsed_config_ref, ['general', 'location'], $absolute_location);
    Utils::dump_yaml_to_file(Consts::CONFIG_LOCATION, $parsed_config_ref);
  }
 
  my $dotty_config_file = sprintf("%s/%s", $absolute_location, Consts::DOTTY_CONF);
  open(my $fh, '>', $dotty_config_file) or Utils::throw_error("Failed to create main dotty file at $location");
  print $fh "# write your dotfiles binding here!\n";

  close($fh);
}

sub handle_link_entry {
  my ($entry, $entry_config_ref, $is_forced) = @_;
  my $desired_path = Utils::get_dict_value($entry_config_ref, ['path']);
  my $force_mode = Utils::get_dict_value($entry_config_ref, ['force']);
  my $root = get_dotfiles_root_dir();
  my $entry_path = $root . "/" . $entry;

  if (!-e $entry_path) {
    Logger::info("entry $entry does not exist - skipping");
    return;
  }

  if (!$desired_path) {
    $desired_path = Utils::get_relative_path($entry);
  }

  if (-e $desired_path && !($force_mode || $is_forced)) {
    Logger::info("destination at $desired_path exists - skipping");
    return;
  }

  my $target_dir = dirname($desired_path);
  make_path($target_dir) unless -d $target_dir;
  
  if (-e $desired_path) {
    print("I EXIST $desired_path");
    Utils::delete_by_path($desired_path);
  }
  
  my $symlink_result = symlink($entry_path, $desired_path);
  if (!$symlink_result) {
    Logger::error("failed to create a symlink for $entry");
    return;
  }
}

sub sync {
  my ($is_forced) = @_;
  my $dotfiles_config = get_dotfiles_config();

  my $links_ref = Utils::get_dict_value($dotfiles_config, ["links"]);
  for my $entry (keys(%$links_ref)) {
    my $entry_config_ref = Utils::get_dict_value($links_ref, [$entry]);
    handle_link_entry($entry, $entry_config_ref, $is_forced);
  }
}

1;
