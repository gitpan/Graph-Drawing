package Graph::Drawing;
# This is the distribution version:
use vars qw($VERSION); $VERSION = '0.3';
use base qw(Graph::Drawing::Base);
use Graph::Drawing::Surface;
use Graph::Drawing::Vertex;
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

  # ...

=head1 DESCRIPTION

This module is a base class from which the C<Graph::Drawing> 
subclasses derive common functionality.

This module is a subclass of C<Graph::Weighted>, which in turn is a
subclass of C<Graph::Directed>.  Thus, every appropriate method 
available in those modules, is also available to a C<Graph::Drawing>
object.

Please see the <Graph::Drawing::Base> module for basic method 
descriptions, and the individual C<Graph::Drawing> subclass 
C<SYNOPSIS> sections for usage descriptions.

Please see the distribution eg/ directory for a working, if only 
feeble, example.

=head1 ABSTRACT

Graph drawing functionality.

=head1 SEE ALSO

L<Graph::Base>

L<Graph::Weighted>

L<Graph::Drawing::Base>

L<Graph::Drawing::Surface>

L<Graph::Drawing::Vertex>

L<Graph::Drawing::Random>

=head1 TO DO

A little less than everything.

If you would like to contribute to this project, please contact me
and I will rejoice.

=head1 DISCLAIMER

This entire distribution is currently under heavy development.

Nearly every method, argument and bit of documentation currently have 
(possible annoying) restrictions, caveats and deficiencies, that will 
change as development progresses.

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Gene Boggs

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
