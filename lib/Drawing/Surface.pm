package Graph::Drawing::Surface;
#
# Graph topology landscape
#
use strict;
use Carp;
use GD;  # XXX Ugh.  Refactoring, please.

use constant PI     => 2 * atan2 (1, 0);  # The number.
use constant FLARE  => 0.9 * PI;          # The angle of the arrowhead.
use constant SCALE  => 0.07;              # Scaling factor for vector magnitude.
use constant FACTOR => 10;                # "Registration mark" factor.

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

    # Make the picture a white-transparent, interlaced background.
    $self->{image}->transparent($self->{colors}{fill});
#    $self->{image}->interlaced('true');

    my $grid = $self->{colors}{grid};
    my ($half, $end) = ($self->{size} / 2, $self->{size} - 1);

    # Put a "flat" radius grade on the picture.
    $self->{image}->line($half, 1, $half, $half, $grid);

    # Put registration marks on the picture.
    for (my $i = FACTOR; $i < $half; $i += FACTOR) {
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

    $self->{image}->string(
        gdTinyFont,
        FACTOR / 2, FACTOR / 2,
        'Total: '. $self->{size},
        $self->{colors}{border}
    );
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

sub pic_output {
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

    my $len = sqrt (($dx * $dx) + ($dy * $dy));

    # Calculate the angle of the vector in radians.
    my $angle = atan2 ($dy, $dx);

    my $poly = GD::Polygon->new;

    $poly->addPt($head->x, $head->y);

#    for($angle + FLARE, $angle - FLARE) {  # "full arrow"
    for($angle + FLARE, $angle + PI) {  # "half arrow"
        my $unitx = cos ($_) * 2 * $tail->size;  #$len * SCALE;  # Use fixed or
        my $unity = sin ($_) * 2 * $tail->size;  #$len * SCALE;  # proportional scaling.

        $dx = $head->x + $unitx;
        $dy = $head->y + $unity;

        $poly->addPt($dx, $dy);
    }

    $self->image->filledPolygon($poly, $self->{colors}{vertex_fill});
}

1;

__END__

=head1 NAME

Graph::Drawing::Vertex - A vertex object used by the 
C<Graph::Drawing> module.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ABSTRACT

=head1 PUBLIC METHODS

=over 4

=item pic_output

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

C<Graph::Drawing>

C<Graph::Drawing::Vertex>

=head1 TO DO

Uhh...

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Gene Boggs

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut