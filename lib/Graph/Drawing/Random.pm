package Graph::Drawing::Random;
use vars qw($VERSION); $VERSION = '0.05';
use strict;
use Carp;
use base qw(Graph::Drawing::Base);

sub get_coordinate {
    my ($self, $vertex) = @_;
$self->_debug("entering get_coordinate with $vertex");
    croak "Can't compute the coordinate of an undefined vertex."
        unless $vertex;

    my $max    = $self->surface->size / 2;
    my $weight = $max - $vertex->weight;
    my $angle  = rand 360;

    # Apply the polar transformation. 
    my $x = $weight * cos $angle;
    my $y = $weight * sin $angle;
    my $z = 0;

#    warn sprintf "%s: w=%d, m=%d, a=%.2f => [%.2f, %.2f, %.2f]\n",
#        $v, $weight, $max, $angle, $x, $y, $z;

$self->_debug('exit get_coordinate');
    return $x + $max, $y + $max, $z + $max;
}

1;
__END__

=head1 NAME

Graph::Drawing::Random - Concentric ring constrained, random angle, 
polar coordinate graph drawing.

=head1 SYNOPSIS

  use Graph::Drawing::Random;

  my $g = Graph::Drawing::Random->new(
      type          => 'GD',
      format        => 'png',
      name          => 'The_Beatles',
      surface_size  => 300,  # half the max weight if not specified.
      grade         => 20,
      layout        => 'circular',
      show_grid     => 1,
      grid_labels   => 1,
      show_axes     => 1,
      show_arrows   => 1,
      vertex_labels => 1,
      vertex_size   => 6,
      data => {
          john   => { paul => 30, },
          paul   => { john => 30, george => 20, ringo => 10, },
          george => { john => 10, paul   => 10, ringo => 10, },
          ringo  => {},
          gene   => {},
      }
  );

  # Recolor and then redraw a vertex and edge.
  my $paul = $g->vertex('paul');
  $g->surface->{colors}{edge}  = [ 0, 100, 0 ];
  $g->surface->{colors}{arrow} = [ 0, 200, 0 ];
  $g->surface->draw_edge($paul, $g->vertex('george'));
  $paul->{colors}{border} = [ 255,   0, 0 ];
  $paul->{colors}{fill}   = [ 255, 255, 0 ];
  $g->surface->draw_vertex($paul);

  # Show 'em what they've won, Don pardo!
  $g->surface->write_image;

=head1 DESCRIPTION

Draw a concentric ring constrained, random angle, polar coordinate 
graph.

=head1 ABSTRACT

Concentric ring constrained, random angle, polar coordinate graph 
drawing.

=head1 PUBLIC METHODS

=over 4

=item new %ARGUMENTS

The arguments that must be provided are described in the 
C<Graph::Drawing::Surface> and C<Graph::Drawing::Vertex> documentation.

=back

=head1 PRIVATE METHODS

=over 4

=item get_coordinate $NAME

Compute and return the coordinate of a C<Graph::Drawing::Vertex> 
object.

This method is used automatically for the vertex plotting that is 
done in the parent module.

This method takes a C<Graph::Drawing::Vertex> object as an argument.

=back

=head1 SEE ALSO

L<Graph::Drawing>

L<Graph::Drawing::Base>

L<Graph::Drawing::Vertex>

L<Graph::Drawing::Surface>

=head1 TO DO

Make this module more flexible to justify such a generic namespace.

If you would like to contribute to this project, please contact me
and I will rejoice.

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Gene Boggs

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
