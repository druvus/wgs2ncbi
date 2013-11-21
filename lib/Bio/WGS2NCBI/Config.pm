package Bio::WGS2NCBI::Config;
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Bio::WGS2NCBI::Logger;

my $SINGLETON;

sub new {
    my $class = shift;
	if ( $SINGLETON ) {
		return $SINGLETON;
	}
	else {
		my %config = $class->read_ini($ENV{'WGS2NCBI'}) if $ENV{'WGS2NCBI'};
		GetOptions(
			'verbose+'    => \$Bio::WGS2NCBI::Logger::Verbosity,
			'dir=s'       => \$config{'dir'},
			'source=s'    => \$config{'source'},
			'prefix=s'    => \$config{'prefix'},
			'fasta=s'     => \$config{'fasta'},
			'gff3=s'      => \$config{'gff3'},
			'info=s'      => \$config{'info'},
			'authority=s' => \$config{'authority'},
			'limit=i'     => \$config{'limit'},
			'chunksize=i' => \$config{'chunksize'},
			'minlength=i' => \$config{'minlength'},
			'minintron=i' => \$config{'minintron'},
		);
		die "Need -fasta argument" if not $config{'fasta'} or not -e $config{'fasta'};
		die "Need -gff3 argument"  if not $config{'gff3'}  or not -e $config{'gff3'};
		$SINGLETON = \%config;
    	return bless $SINGLETON, $class;
    }
}

sub read_ini {
	my ( $self, $file ) = @_;
	my %result;
	if ( $file and -e $file ) {
		open my $fh, '<', $file or die $!;
		while(<$fh>) {
			chomp;
			s/#.*$//; # strip comments
			if ( /^(.+?)=(.+)$/ ) {
				my ( $key, $value ) = ( $1, $2 );
				$result{$key} = $value;
			}
			if ( /\[.*\]/ ) {
				WARN "ini-style headings are ignored: $_";
			}
		}
	}
	return %result;
}

sub prefix { shift->{'prefix'} || 'OPHA_' }

sub source { shift->{'source'} || 'maker' }

sub dir { shift->{'dir'} || 'submission' }

sub fasta { shift->{'fasta'} or die "Need FASTA file to operate on!" }

sub gff3 { shift->{'gff3'} or die "Need GFF3 file to operate on!" }

sub authority { shift->{'authority'} || 'gnl|NaturalisBC|' }

sub chunksize { shift->{'chunksize'} || 1 }

sub info { shift->{'info'} }

sub limit { shift->{'limit'} }

sub minlength { shift->{'minlength'} || 200 }

sub minintron { shift->{'minintron'} || 10 }

1;