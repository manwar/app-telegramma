package App::TeleGramma::Config;

use Mojo::Base -base;
use File::Spec::Functions qw/catdir/;
use Config::INI::Writer 0.025;
use Config::INI::Reader 0.025;

has config => sub { {} };

sub path_base    { catdir($ENV{HOME}, '.telegramma') }
sub path_config  { catdir(shift->path_base, 'telegramma.ini') }
sub path_plugins { catdir(shift->path_base, 'plugins') }
sub path_logs    { catdir(shift->path_base, 'logs') }

sub read {
  my $self = shift;
  $self->config( Config::INI::Reader->read_file( $self->path_config ) );
}

sub write {
  my $self = shift;
  Config::INI::Writer->write_file($self->config, $self->path_config);
}

sub default_config {
  [
    'general' => [ bot_token => 'please change me, see: https://telegram.me/BotFather' ],
    'plugins' => [],
  ],
}

sub create_if_necessary {
  my $self = shift;

  foreach my $path (
    $self->path_base,
    $self->path_plugins,
    catdir($self->path_plugins, 'App'),
    catdir($self->path_plugins, 'App/TeleGramma'),
    catdir($self->path_plugins, 'App/TeleGramma/Plugin'),
    $self->path_logs ) {

    if (! -e $path) {
      mkdir $path, 0700 || die "cannot create $path: $!\n";
    }
    elsif (! -d $path) {
      die "$path is not a directory?\n";
    }
  }

  my $config_path = $self->path_config;
  if (! -e $config_path) {
    $self->create_default_config;
    return 1;
  }

  return 0;
}

sub create_default_config {
  my $self = shift;
  my $path = $self->path_config;

  Config::INI::Writer->write_file($self->default_config, $path);
  chmod 0600, $path;
}

sub config_created_message {
  my $self = shift;
  my $path = $self->path_config;

  return <<EOF
Your new config has been created in $path

Please edit it now and update the Telegram Bot token, then
re-run $0.
EOF
}



1;