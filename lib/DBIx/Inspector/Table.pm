package DBIx::Inspector::Table;
use strict;
use warnings;
use utf8;
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/inspector/);
use DBIx::Inspector::Column;

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    bless {%args}, $class;
}

sub columns {
    my $self = shift;

    my $sth = $self->inspector->dbh->column_info( $self->inspector->catalog, $self->inspector->schema, $self->name, '%' );
    return
      map { DBIx::Inspector::Column->new( table => $self, %$_ ) }
      @{ $sth->fetchall_arrayref( +{} ) };
}

sub primary_key {
    my $self = shift;
    my $sth = $self->inspector->dbh->primary_key_info( $self->inspector->catalog, $self->inspector->schema, $self->name );
    return
      map { DBIx::Inspector::Column->new( table => $self, %$_ ) }
      @{ $sth->fetchall_arrayref( +{} ) };
}

sub name    { $_[0]->{TABLE_NAME} }
sub catalog { $_[0]->{TABLE_CAT} }
sub schema  { $_[0]->{TABLE_SCHEM} }
sub type    { $_[0]->{TABLE_TYPE} }

1;
