package Utils;
use YAML::XS qw(LoadFile DumpFile);
use File::Path qw(remove_tree);

use lib "./";
use Consts;
use Logger;

sub throw_error {
  my ($error_msg) = @_;
  print("$error_msg\n");
  exit 1;
}

sub get_relative_path {
  my ($path) = @_;
  return "$ENV{HOME}/$path";
}

sub delete_by_path {
  my ($path) = @_;

  unless (-e $path) {
    return;
  }

  if (-f $path) {
    unlink $path or Logger::error("could not delete file at $path");
  } elsif (-d $path) {
    remove_tree($path, {error => \my $err}) or Logger::error("could not delete directory: $path");
  } 

}

sub get_dict_value {
  my ($hash_ref, $keys_ref) = @_;
  my $current = $hash_ref;
  
  foreach my $key (@$keys_ref) {
    if (ref($current) eq "HASH" && exists($current->{$key})) {
      $current = $current->{$key};
    } else {
      return '';
    }
  }
  return $current;
}

sub add_dict_value {
  my ($hash_ref, $keys_ref, $value) = @_;

  die "First argument must be a hash reference." unless ref($hash_ref) eq 'HASH';

  my $current = $hash_ref;
  my $last_key = pop @$keys_ref;

  foreach my $key (@$keys_ref) {
    $current->{$key} //= {};
    $current = $current->{$key};
  }

  $current->{$last_key} = $value;
}

sub dump_yaml_to_file {
  my ($file_path, $data_ref) = @_;
  eval {
    DumpFile($file_path, $data_ref);
  };

  if ($@) {
    throw_error("Failed to save data to $file_path");
  }
}

sub parse_yaml_file {
  my ($file_path) = @_;
  my $data_ref;

  eval {
    $data_ref = LoadFile($file_path);
  };

  if ($@) {
    throw_error("Failed to parse file at $file_path");
  }
  return $data_ref;
}

sub parse_config {
  my $config_file = Consts::CONFIG_LOCATION;
  if (!-e $config_file) {
    return {};
  }
  $parsed_config_ref = LoadFile($config_file);
  return $parsed_config_ref;
}

1;
