package Graph::Drawing;
use strict;
use vars qw($VERSION); $VERSION = '0.01.2';
use Carp;
use base qw(Graph::Weighted);

use Graph::Drawing::Surface;
use Graph::Drawing::Vertex;

# Not to be called directly.  Inherit from a subclass like 
# G::D::Random, or something.
sub new {
    my $class = shift;
    my $proto = ref $class || $class;
    my $self  = Graph::Weighted->new(@_);
    bless $self, $class;
    $self->_init(@_);
    return $self;
}

sub _init {
    my ($self, %args) = @_;

    # Set the surface width to twice the graph's maximum weight.
    $args{surface_size} ||= 2 * $self->max_weight;

    $self->{surface} = $self->new_surface(%args)
        if $args{surface_name} && $args{surface_size};

    # Add a new vertex to the drawing for each of the graph vertices.
    $self->new_vertex(name => $_, size => $args{vertex_size})
        for $self->vertices;

    # Plot the vertices and edges.
    for my $v ($self->vertices) {
        $self->{surface}->draw_vertex($self->vertex($v));
        $self->{surface}->draw_edge($self->vertex($v), $self->vertex($_))
            for $self->successors($v);
    }
}

sub new_surface {
    my ($self, %args) = @_;
    return Graph::Drawing::Surface->new(
        type   => $args{type},
        name   => $args{surface_name},
        format => $args{format},
        size   => $args{surface_size},
    );
}

sub surface {
    return shift->{surface};
}

sub new_vertex {
    my ($self, %args) = @_;

    my $v = Graph::Drawing::Vertex->new(
        name  => $args{name},
        size  => $args{size},
        graph => $self,
    );

    # Make the object an attribute of the graph vertex.
    $self->set_attribute('obj', $args{name}, $v);

    return $v;
}

sub vertex {
    my ($self, $vertex) = @_;
    return $self->get_attribute('obj', $vertex);
}

1;

__END__

=head1 NAME

Graph::Drawing - Graph drawing functionality

=head1 SYNOPSIS

  #use Graph::Drawing::ForceDirected;       # Not implemented.
  #use Graph::Drawing::SimulatedAnnealing;  # Not implemented.
  #use Graph::Drawing::Magnetic;            # Not implemented.
  #use Graph::Drawing::Heirarchical;        # Not implemented.
  #use Graph::Drawing::Orthogonal;          # Not implemented.

  use Graph::Drawing::Random;

  # See the individual module documentation!

=head1 DESCRIPTION

This module is a base class from which the C<Graph::Drawing> 
subclasses derive common functionality.

This module is a subclass of C<Graph::Weighted>, which in turn is a
subclass of C<Graph::Directed>.  Thus, every appropriate method 
available in those modules, is also available to a C<Graph::Drawing>
object.

Please see the C<Graph::Drawing::*> subclass C<SYNOPSIS> sections for 
usage descriptions.

Please see the distribution eg/ directory for a working, if only 
feeble, example.

* This entire distribution is currently under heavy development.
Nearly every method, argument and bit of documentation currently have 
restrictions, caveats and deficiencies that will change as 
development progresses.

=head1 ABSTRACT

Graph drawing functionality.

=head1 PUBLIC METHODS

=over 4

=item new_surface %ARGUMENTS

Create and return a new surface object.

=over 4

=item name $STRING

The file name (without the extension like "png") to use when saving 
the image.  That is, this attribute is prepended to the C<format>
attributeto make the image filename.

=item format $STRING

The graphic file format to save as.  Currently, this is only C<PNG>.

This object attribute is appened (automatically) to the C<name> 
attribute, as the "file extension", to make the image filename.

=item type $MODULE

Specify the graphics module to use.  Currently, this is only C<GD>.
(C<Imager> is next!)

=item size $WIDTH

The size of the (square) surface, in pixels.

=back

=item surface

Accessor to the surface object.

=item new_vertex %ARGUMENTS

Create and return a new vertex object.

=over 4

=item name $IDENTIFIER

The name to use to identify the vertex.  Currently, this must be
unique among the rest of the vertices.

=item size $DIAMETER

The size of the vertex diameter.

=back

=item vertex $NAME

Return the C<Graph::Drawing::Vertex> object, given the vertex name.

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
