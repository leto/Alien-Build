use Test2::Bundle::Extended;
use Alien::Build::Plugin::Download::Negotiate;
use lib 't/lib';
use MyTest;
use Path::Tiny;
use Capture::Tiny qw( capture_merged );
use Alien::Build::Util qw( _dump );

subtest 'pick fetch' => sub {

  local %ENV = %ENV;

  subtest 'http' => sub {
  
    my $plugin = Alien::Build::Plugin::Download::Negotiate->new('http://mytest.test/');
    
    is($plugin->_pick_fetch, 'HTTPTiny');
    is($plugin->scheme, 'http');
  
  };
  
  subtest 'https' => sub {
  
    my $plugin = Alien::Build::Plugin::Download::Negotiate->new('https://mytest.test/');
    
    is($plugin->_pick_fetch, 'HTTPTiny');
    is($plugin->scheme, 'https');
  
  };
  
  subtest 'ftp direct' => sub {
  
    my $plugin = Alien::Build::Plugin::Download::Negotiate->new('ftp://mytest.test/');
    
    is($plugin->_pick_fetch, 'NetFTP');
    is($plugin->scheme, 'ftp');
    
  };
  
  subtest 'ftp direct proxy' => sub {
  
    $ENV{ftp_proxy} = 1;
  
    my $plugin = Alien::Build::Plugin::Download::Negotiate->new('ftp://mytest.test/');
    
    is($plugin->_pick_fetch, 'LWP');
    is($plugin->scheme, 'ftp');
    
  };
  
  subtest 'local file URI' => sub {
  
    $ENV{ftp_proxy} = 1;
  
    my $plugin = Alien::Build::Plugin::Download::Negotiate->new('file:///foo/bar/baz');
    
    is($plugin->_pick_fetch, 'Local');
    is($plugin->scheme, 'file');
    
  };
  
  subtest 'local file' => sub {
  
    $ENV{ftp_proxy} = 1;
  
    my $plugin = Alien::Build::Plugin::Download::Negotiate->new('/foo/bar/baz');
    
    is($plugin->_pick_fetch, 'Local');
    is($plugin->scheme, 'file');
    
  };

};

subtest 'get the version' => sub {

  my $build = alienfile q{
    use alienfile;
    probe sub { 'share' };
    plugin 'Download' => (
      url => 'corpus/dist',
      version => qr/([0-9\.]+)/,
      filter => qr/\.tar\.gz$/,
    );
  };
  
  note capture_merged {
    $build->download;
    ();
  };
  
  is($build->install_prop->{version}, '1.00');

};

done_testing;
