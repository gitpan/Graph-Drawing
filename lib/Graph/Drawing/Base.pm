package Graph::Drawing::Base;
use vars qw($VERSION); $VERSION = '0.07.1';
use strict;
use Carp;
use base qw(Graph::Weighted);

use Graph::Drawing::Surface;
use Graph::Drawing::Vertex;

# Not to be called directly.  Inherit from a subclass like 
# G::D::Random.
sub new {
    my $class = shift;
    my $proto = ref $class || $class;
    my $self  = Graph::Weighted->new(@_);
    bless $self, $class;
    $self->_init(@_);
    return $self;
}

sub _init {  # {{{
    my ($self, %args) = @_;
$self->_debug('entering Drawing::_init');

    # Set the surface width to twice the graph's maximum weight if 
    # a dataset is not specified.
    $args{surface_size} = 2 * $self->max_weight
        if !$args{surface_size} && $self->data && keys %{ $self->data };

    # Get a new surface object.
    $self->{surface} = $self->surface(%args);

    # Add a new vertex to the drawing for each of the graph vertices.
$self->_debug('add new vertices');
    $self->vertex(
        debug      => $args{debug},
        name       => $_,
        show_label => $args{vertex_labels},
        size       => $args{vertex_size},
    ) for $self->vertices;

    # Plot the vertices and edges.
$self->_debug('plot the vertices and edges');
    for my $v ($self->vertices) {
        $self->{surface}->draw_vertex($self->vertex($v));
        $self->{surface}->draw_edge($self->vertex($v), $self->vertex($_))
            for $self->successors($v);
    }

$self->_debug('exiting Drawing::_init');
}  # }}}

sub surface {
    my $self = shift;
    if (@_) {
        my %args = @_;

        # If we are given a surface_size key, turn it into 'size'.
        if ($args{surface_size}) {
            $args{size} = $args{surface_size};
            delete $args{surface_size};
        }
        return Graph::Drawing::Surface->new(%args);
    }
    else {
        return $self->{surface};
    }
}

sub vertex {
    my $self = shift;
    my $v;

    if (@_ > 1) {
        my %args = @_;

        $v = Graph::Drawing::Vertex->new(%args, graph => $self);

        # Make the object an attribute of the graph vertex.
        $self->set_attribute('obj', $args{name}, $v);
    }
    else {
        $v = shift;
        $v = $self->get_attribute('obj', $v);
    }

    return $v;
}

1;

__END__

=head1 NAME

Graph::Drawing::Base - Base class for graph drawing functionality

=head1 SYNOPSIS

  use Graph::Drawing::Random;

  $g = Graph::Drawing::Random->new(%args);

  $g->surface->write_image;

=head1 DESCRIPTION

This module is a base class from which the C<Graph::Drawing> 
subclasses derive common functionality.

This module is a subclass of C<Graph::Weighted>, which in turn is a
subclass of C<Graph::Directed>.  Thus, every appropriate method 
available in those modules, is also available to a C<Graph::Drawing>
object.

Please see the C<Graph::Drawing> subclass C<SYNOPSIS> sections for 
complete usage descriptions.

Also see the distribution eg/ directory for working examples.

=head1 PUBLIC METHODS

=over 4

=item surface [%ARGUMENTS]

Return a surface object.

If the method is passed a list of arguments a new 
C<Graph::Drawing::Surface> object is created.  If no arguments are 
given, the object's surface is returned.

The list of arguments for a new surface object are detailed in the 
C<Graph::Drawing::Surface> documentation.

Note that if one of the arguments is named C<surface_size>, it will 
be renamed to C<size>.

=item vertex $NAME | %ARGUMENTS

Return a vertex object.

If the method is passed a list of arguments a new 
C<Graph::Drawing::Vertex> object is created.  If only one argument is 
given, the existing vertex with that name is returned.

The list of arguments for a new vertex object are detailed in the 
C<Graph::Drawing::Vertex> documentation.

=back

=head1 PRIVATE METHODS

=over 4

=item _debug

This method is inherited from the parent class, C<Graph::Weighted>
and like all the other methods there, can be called directly, on a
C<Graph::Drawing> object.

=back

=head1 SEE ALSO

L<Graph::Base>

L<Graph::Weighted>

L<Graph::Drawing>

L<Graph::Drawing::Surface>

L<Graph::Drawing::Vertex>

L<Graph::Drawing::Random>

=head1 TO DO

A little less than everything.

If you would like to contribute to this project, please contact me
and I will rejoice.

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Gene Boggs

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
