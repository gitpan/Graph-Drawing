package Graph::Drawing::Surface;
use vars qw($VERSION); $VERSION = '0.02';
use strict;
use Carp;

use GD;  # XXX Ugh.  Refactoring, please.

use constant PI    => 2 * atan2 (1, 0);  # The number.
use constant FLARE => 0.9 * PI;          # The angle of the arrowhead.

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my %args = @_;
    my $self = {
        size   => $args{size},
        name   => $args{name},
        format => $args{format},
        image  => $args{image}  || undef,
        colors => $args{colors} || {},
        grade  => $args{grade}  || 10,
    };
    bless $self, $class;
    $self->_init(%args);
    return $self;
}

sub _init {
    my $self = shift;

    # Allocate the goodness.
    $self->image(
        GD::Image->new($self->{size}, $self->{size})
    );

    # Argh! GD appears to require that you allocate white first.
    $self->colors->{fill}          = $self->image->colorAllocate( 255, 255, 255 );  #white
    $self->colors->{grid}          = $self->image->colorAllocate( 210, 210, 210 );  #light grey
    $self->colors->{vertex_fill}   = $self->image->colorAllocate( 100, 100, 100 );  #dark grey
    $self->colors->{vertex_border} = $self->image->colorAllocate(   0,   0, 255 );  #blue
    $self->colors->{border}        = $self->image->colorAllocate(   0,   0,   0 );  #black

    # Make the picture a white-transparent background.
    $self->{image}->transparent($self->{colors}{fill});
#    $self->{image}->interlaced('true');

    my $grid = $self->{colors}{grid};
    my ($half, $end) = ($self->{size} / 2, $self->{size} - 1);

    # Put a "flat" radius grade on the picture.
    $self->{image}->line($half, 1, $half, $half, $grid);

    # Put registration marks on the picture.
    for (my $i = $self->{grade}; $i < $half; $i += $self->{grade}) {
        $self->{image}->arc(
            $half,  $half,
            2 * $i, 2 * $i,
            0,      360,
            $grid
        );
    
        $self->{image}->string(
            gdTinyFont,
            $half + 1, $i,
            $i, $self->{colors}{vertex_fill}
        );
    }

    # Put a frame around the picture.
    $self->{image}->arc(
        $half, $half,
        $end,  $end,
        0,     360,
        $self->{colors}{border}
    );

    # Fill the corners.
    $self->{image}->fill( 0,    0,    $grid );
    $self->{image}->fill( 0,    $end, $grid );
    $self->{image}->fill( $end, 0,    $grid );
    $self->{image}->fill( $end, $end, $grid );

# XXX Why do we need this, anymore?
#    $self->{image}->string(
#        gdTinyFont,
#        $self->{grade} / 2, $self->{grade} / 2,
#        'Total: '. $self->{size},
#        $self->{colors}{border}
#    );
}

sub image {
    my $self = shift;
    $self->{image} = shift if @_;
    return $self->{image};
}

sub colors {
    my $self = shift;
    $self->{colors} = shift if @_;
    return $self->{colors};
}

sub size {
    my $self = shift;
    $self->{size} = shift if @_;
    return $self->{size};
}

sub draw {
    my $self = shift;

    my $filename = "$self->{name}.$self->{format}";

    # Make sure we are writing to a binary stream first!
    binmode STDOUT;

    open F, ">$filename"
        or croak "Can't open $filename - $!\n";
    binmode F;
    print F $self->{image}->png if $self->{format} eq 'png';
    print F $self->{image}->gif if $self->{format} eq 'gif';
    close F;

    return $filename;
}

sub draw_vertex {
    my ($self, $vertex) = @_;

    warn sprintf "%s (%d): [%.2f, %.2f]\n",
        $vertex->name, $vertex->weight, $vertex->x, $vertex->y;

    $self->{image}->arc(
        $vertex->x, $vertex->y,
        $vertex->size, $vertex->size,
        0, 360,
        $self->{colors}{vertex_border}
    );

    $self->{image}->fillToBorder(
        $vertex->x, $vertex->y,
        $self->{colors}{vertex_border},
        $self->{colors}{vertex_fill}
    );

    $self->{image}->string(
        gdTinyFont,
        ($vertex->x + $vertex->size),
        ($vertex->y + $vertex->size / 2),
        $vertex->name .':'. $vertex->weight,
        $self->{colors}{border}
    );
}

sub draw_edge {
    my ($self, $vertex1, $vertex2) = @_;

    $self->image->line(
        $vertex1->x, $vertex1->y,
        $vertex2->x, $vertex2->y,
        $self->{colors}{vertex_fill}
    );

    $self->draw_arrowhead($vertex1, $vertex2); 
}

sub draw_arrowhead {
    my ($self, $tail, $head) = @_;

    # Calculate the size and distance of the vector.
    my $dx = $head->x - $tail->x;
    my $dy = $head->y - $tail->y;

    my $dist = sqrt (($dx * $dx) + ($dy * $dy));

    # Calculate the angle of the vector in radians.
    my $angle = atan2 ($dy, $dx);

    my $poly = GD::Polygon->new;

    $poly->addPt($head->x, $head->y);

#    for($angle + FLARE, $angle - FLARE) {  # "full arrow"
    for($angle + FLARE, $angle + PI) {  # "half arrow"
        my $unitx = cos ($_) * 2 * $tail->size;  # proportional scaling
        my $unity = sin ($_) * 2 * $tail->size;

        $dx = $head->x + $unitx;
        $dy = $head->y + $unity;

        $poly->addPt($dx, $dy);
    }

    $self->image->filledPolygon($poly, $self->{colors}{vertex_fill});
}

1;

__END__

=head1 NAME

Graph::Drawing::Surface - 2D Graph topology landscape

=head1 SYNOPSIS

This module is called automatically by the parent and does not need 
to be called directly.

=head1 DESCRIPTION

This module is a two dimensional graph topology landscape used by the
parent to plot vertices, edges, axes and labels.

A number of attributes can be specified in the arguments provided in 
the call to the C<new> method, to control the format and dimensions 
of the surface.  Please see the documentation in the parent module,
(C<Graph::Drawing>) for a description of these options.

=head1 ABSTRACT

2D Graph topology landscape used by the C<Graph::Drawing> module.

=head1 PUBLIC METHODS

=over 4

=item draw

Print the (binary) contents of the object's image attribute to a file,
who's name and format are defined by the concatination of the name 
and format attributes.

=back

=head1 PRIVATE METHODS

new
image
colors
draw_vertex
draw_edge
draw_arrowhead

=head1 SEE ALSO

L<Graph::Drawing>

L<Graph::Drawing::Base>

L<Graph::Drawing::Vertex>

=head1 TO DO

Uhh...

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Gene Boggs

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
