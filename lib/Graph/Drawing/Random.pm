package Graph::Drawing::Random;
use strict;
use vars qw($VERSION); $VERSION = '0.02';
use Carp;
use base qw(Graph::Drawing);

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

#    warn sprintf "%s: w=%d, m=%d, a=%.2f => [%.2f, %.2f]\n",
#        $v, $weight, $max, $angle, $x, $y;

$self->_debug('exit get_coordinate');
    return $x + $max, $y + $max, $z + $max;
}

1;
__END__

=head1 NAME

Graph::Drawing::Random - Polar grid constrained, random distribution 
graph drawing 

=head1 SYNOPSIS

  use Graph::Drawing::Random;

  my $g = Graph::Drawing::Random->new(
  #    debug => 1,
      type         => 'GD',
      format       => 'png',
      surface_name => 'foo',
  #    surface_size => 300,
      vertex_size  => 6,
      data => {
          john   => { paul => 30, },
          paul   => { john => 30, george => 20, ringo => 10, },
          george => { john => 10, paul   => 10, ringo => 10, },
          ringo  => {},
      }
  );

  $g->surface->pic_output;

=head1 DESCRIPTION

This entire distribution is currently under heavy development.
Nearly every method, argument and bit of documentation currently have 
restrictions, caveats and deficiencies that will change as 
development progresses.

Please see the C<Graph::Drawing> documentation for a description of 
the available methods and their arguments.

=head1 ABSTRACT

Polar grid constrained, random distribution graph drawing.

=head1 PUBLIC METHODS

None.

=head1 PRIVATE METHODS

=over 4

=item get_coordinate

Return the vertex coordinate.

This method is used automatically for the vertex plotting that is 
done in the parent module.

=back

=head1 SEE ALSO

L<Graph::Drawing>

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
