package Logger;

sub info {
  my ($msg) = @_;
  print("[INFO] >> $msg\n")
}

sub warn {
  my ($msg) = @_;
  print("[WARN] >> $msg\n")
}

sub error {
  my ($msg) = @_;
  print("[ERROR] >> $msg\n")
}

sub throw_and_abort {
  my ($msg) = @_;
  error($msg);
  exit 1;
}
1;
