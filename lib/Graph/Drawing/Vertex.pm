package Graph::Drawing::Vertex;
use vars qw($VERSION); $VERSION = '0.03';
use strict;
use Carp;

sub _debug { print @_, "\n" if shift->{debug} }

sub new {  # {{{
    my $class = shift;
    my $proto = ref ($class) || $class;
    my %args = @_;
    my $self = {
        debug      => $args{debug}  || 0,
        name       => $args{name}   || '',
        size       => $args{size}   || 0,
        weight     => $args{weight} || 0,
        graph      => $args{graph}  || undef,
        show_label => defined $args{show_label} ? $args{show_label} : 1,
        colors     => {
            fill   => [ 100, 100, 100 ],  # dark gray
            border => [   0,   0, 255 ],  # blue
            label  => [   0,   0,   0 ],  # black
        },
    };
    bless $self, $class;
    $self->_init(%args) if $args{graph};
    return $self;
}  # }}}

sub _init {
    my $self = shift;
$self->_debug('entering Vertex::_init');
    # This goofy looking method call with $self as an argument is a
    # "hook" into the derived subclass of the graph class.
    ($self->{x}, $self->{y}, $self->{z}) =
        $self->{graph}->get_coordinate($self);
$self->_debug('exiting Vertex::_init');
}

sub name {
    my $self = shift;
    $self->{name} = shift if @_;
    return $self->{name};
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

1;

__END__

=head1 NAME

Graph::Drawing::Vertex - A vertex object

=head1 SYNOPSIS

The methods in this module are called automatically by the parent and 
do not need to be called explicitly.

=head1 DESCRIPTION

This module represents a vertex object that is used by other 
C<Graph::Drawing> modules.

=head1 ABSTRACT

A vertex object.

=head1 PUBLIC METHODS

=over 4

=item new %ARGUMENTS

This method is called automatically by the C<Graph::Drawing::Base> 
module, and does not need to be called explicitly.

These attributes (except for C<name>) are set with the same value, for 
all vertices, in the C<Graph::Drawing::Surface::_init> routine.  If 
desired, any attribute can be set, after the surface object creation, 
of course.

=over 4

=item name $STRING

The name to use to identify the vertex.  Currently, this must be
unique among the rest of the vertices.

This object attribute is set automatically, based on the keys of the
data attribute.  It should not be set explicitly.

=item show_label 0 | 1

Display the name and weight beside the plotted vertex.  Defaults to 1.

=item size $PIXELS

The size of the vertex diameter, in pixels.

=back

=item x, y, z [$NUMBER]

Set/get accessor to the vertex coordinates.

=item name [$STRING]

Set/get accessor to the vertex's C<name> attribute.

=item size [$PIXELS]

Set/get accessor to the vertex's C<size> attribute.

=item weight

Accessor to return the vertex's C<weight> attribute (that is retrieved
with the C<Graph::Weighted::vertex_weight> method).

=back

=head1 PRIVATE METHODS

=over 4

=item _debug @STUFF

Print the contents of the argument array with a newline appended.

=back

=head1 SEE ALSO

C<Graph::Drawing>

C<Graph::Drawing::Base>

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
