# $Id: Drawing.pm,v 1.4 2004/09/30 02:00:03 gene Exp $

package Graph::Drawing;

our $VERSION = '0.0902_1';

1;

__END__

=head1 NAME

Graph::Drawing - OBSOLETE Graph drawing functionality

=head1 SYNOPSIS

  use Graph::Layout::Aesthetic;  # instead

=head1 DESCRIPTION

This module is now obsolete but used to be a base class for other
C<Graph::Drawing> subclasses.  Then C<Graph::Layout::Aesthetic>
silently appeared ..despite my request for development and better
ideas below.  Anyway...  I am happy that there is finally a decent
way to draw graphs on the CPAN now.

=head1 SEE ALSO

L<Graph::Layout::Aesthetic>

=head1 TO DO

Play with C<Graph::Layout::Aesthetic>.

B<OLD COMMENT:>
If you would like to contribute to this project, please contact me
and I will rejoice.

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Gene Boggs

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
