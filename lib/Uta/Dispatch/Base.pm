package Uta::Dispatch::Base;
use Exporter;

@ISA = (Exporter);
@EXPORT = qw/decode/;

#------------------------------------------------------------------------
# decoder
# * return : decoded input stream
#------------------------------------------------------------------------
sub decode {
  my $r = shift;
  my $request = Apache2::Request->new($r);
  my %req;
  
  for my $key($request->param) {
    my @ret = $request->param($key);
    $req{$key} = scalar @ret > 1 ? [@ret] : Encode::decode('utf-8', $ret[0]);
    $req{$key} =~ s/&/&amp;/g;
    $req{$key} =~ s/</&lt;/g;
    $req{$key} =~ s/>/&gt;/g;
    $req{$key} =~ s/"/&quot;/g;
    $req{$key} =~ s/'/&#39;/g;
    $req{$key} =~ s/\\//g;
  }
  
  $req{controller} = 'main' unless (defined $req{controller} && $req{controller});
  $req{action}     = 'top'  unless (defined $req{action} && $req{action});
  $req{cookie}     = $request->jar;
  
  die('Cheat code "ctrl" was discovered!', $req{controller}) if (ref $req{controller} eq 'ARRAY');
  die('Cheat code "action" was discovered!', $req{action})   if (ref $req{action} eq 'ARRAY');
  
  return \%req;
}

1;
