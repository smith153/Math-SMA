package Math::SMA;
use Scalar::Util qw(looks_like_number);
use Moo;
use namespace::autoclean;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

has size => (
	is =>'ro',
	isa => sub { die "$_[0] is not an integer!" unless(looks_like_number($_[0]) && $_[0] >= 1)},
	required => '1',
);

has last_avg => (
	is =>'ro',
	isa => sub { die "$_[0] is not a number!" unless looks_like_number $_[0]},
	writer => '_set_last_avg',
);

has precision => (
	is => 'rw',
	isa => sub { die "$_[0] is not a number!" unless looks_like_number $_[0]},
	default => 2,
);

has values => (
	is => 'ro',
	isa => sub { die "$_[0] is not an array ref!" unless ref($_[0]) eq 'ARRAY'},
	default => sub { [] },
);



sub sma
{
	my ($self, $current) = @_;
	my $last = $self->last_avg();
	my $values = $self->values();
	my $size = $self->size();
	my $prec = $self->precision();
	my $obsolete;
	my $avg;

	return sprintf("%.${prec}f",$last) unless defined $current;
	die "sma() works on numbers only!" unless looks_like_number $current;

	push(@{$values}, $current);

	#return simple avg if not enough periods
	if(@{$values} <= $size){
		$self->_set_last_avg($self->_raw_average());
		return sprintf("%.${prec}f", $self->last_avg());
	}

	while( @{$values} >  $size) {
		$obsolete = shift(@{$values});
	}

	$avg = $last - ($obsolete/$size) + ($current/$size);
	$self->_set_last_avg($avg);

	return sprintf("%.${prec}f", $avg);
}


sub _raw_average
{
	my $self = shift();
	my $size = @{$self->values()} || 1;
	my $total = 0;
	foreach (@{$self->values}){
		$total += $_;
	}
	return $total / $size;
}



1;


