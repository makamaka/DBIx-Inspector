package DBIx::Inspector;
use strict;
use warnings;
use 5.008001;
our $VERSION = '0.01';
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/dbh catalog schema driver/);
use Carp ();
use DBIx::Inspector::Table;
use DBIx::Inspector::Iterator;
use DBIx::Inspector::ForeignKey;

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    my $dbh = $args{dbh};
    Carp::croak("missing mandatory parameter: dbh") unless $dbh;
    my $driver = $dbh->{Driver}->{Name};

    # default schema name for Pg is 'public'
    if (not exists $args{schema}) {
        if ($driver eq 'Pg') {
            $args{schema} = 'public';
        }
    }
    return bless {driver => $driver, catalog => undef, %args}, $class;
}

sub tables {
    my ($self, $table) = @_;

    my $sth = $self->{dbh}->table_info( $self->catalog, $self->schema, $table, my $type='TABLE' );

    my $iter = DBIx::Inspector::Iterator->new(
        callback => sub { DBIx::Inspector::Table->new(inspector => $self, %{$_[0]}) },
        sth =>$sth,
    );
    return wantarray ? $iter->all : $iter;
}

sub table {
    my ($self, $table) = @_;
    Carp::croak("missing mandatory parameter: table") unless defined $table;
    return $self->tables($table)->next;
}

1;
__END__

=encoding utf8

=head1 NAME

DBIx::Inspector -

=head1 SYNOPSIS

  use DBIx::Inspector;

=head1 DESCRIPTION

DBIx::Inspector is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
