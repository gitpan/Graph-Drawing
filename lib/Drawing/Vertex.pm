package Graph::Drawing::Vertex;
use strict;
use vars qw($VERSION); $VERSION = '0.01.1';
use Carp;

sub new {
    my $class = shift;
    my $proto = ref ($class) || $class;

    my %args = @_;

    my $self = {
        name   => $args{name}   || '',
        size   => $args{size}   || 0,
        weight => $args{weight} || 0,
        graph  => $args{graph}  || undef,
    };

    bless $self, $class;

    $self->_init(%args) if $args{graph};

    return $self;
}

sub _init {
    my $self = shift;
    ($self->{x}, $self->{y}, $self->{z}) =
        $self->{graph}->get_coordinate($self);
}

sub name {
    my $self = shift;
    $self->{name} = shift if @_;
    return $self->{name};
}

sub x {
    my $self = shift;
    $self->{x} = shift if @_;
    return $self->{x};
}

sub y {
    my $self = shift;
    $self->{y} = shift if @_;
    return $self->{y};
}

sub z {
    my $self = shift;
    $self->{z} = shift if @_;
    return $self->{z};
}

sub size {
    my $self = shift;
    $self->{size} = shift if @_;
    return $self->{size};
}

sub weight {
    my $self = shift;
    return $self->{graph}->vertex_weight($self->{name});
}

1;

__END__

=head1 NAME

Graph::Drawing::Vertex - A vertex object

=head1 SYNOPSIS

This module is called automatically by the parent and does not need 
to be called directly.

=head1 DESCRIPTION

This module represents a vertex object, that is used by the
parent in plotting.

=head1 ABSTRACT

A vertex object used by the C<Graph::Drawing> module.

=head1 PUBLIC METHODS

None that need to be called explicitly.

=head1 PRIVATE METHODS

new
x
y
z
name
size
weight

=head1 SEE ALSO

C<Graph::Drawing>

C<Graph::Drawing::Surface>

=head1 TO DO

Uhh...

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Gene Boggs

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
