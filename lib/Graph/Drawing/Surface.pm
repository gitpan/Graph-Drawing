package Graph::Drawing::Surface;
use vars qw($VERSION); $VERSION = '0.05';
use strict;
use Carp;

use GD;  # XXX Ugh.  Refactoring, please.

use constant PI    => 2 * atan2 (1, 0);  # The number.
use constant FLARE => 0.9 * PI;          # The angle of the arrowhead.
use constant CIRCLE    => 'circular';
use constant RECTANGLE => 'rectangular';

sub _debug {
    print @_, "\n" if shift->{debug};
}

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my %args = @_;
    my $self = {
        debug        => $args{debug}       || 0,
        surface_size => $args{surface_size},
        name         => $args{name},
        format       => $args{format},
        image        => $args{image}       || undef,
        colors       => $args{colors}      || {},
        grade        => $args{grade}       || 10,
        layout       => $args{layout}      || 'blank',
        show_grid    => $args{show_grid}   || 0,
        grid_labels  => $args{grid_labels} || 0,
        show_axes    => $args{show_axes}   || 0,
        show_arrows  => defined $args{show_arrows} ? $args{show_arrows} : 1,
    };
    bless $self, $class;
    $self->_init(%args);
    return $self;
}

sub size { return shift->{surface_size} }

sub _init {  # {{{
    my $self = shift;
$self->_debug('entering Surface::_init');

    my $image_provided = $self->{image} ? 1 : 0;

    # Allocate the goodness.
    $self->{image} = GD::Image->new(
        $self->{surface_size}, $self->{surface_size}
    ) unless $image_provided;
$self->_debug('image: ' . ref ($self->{image}));

    # Argh! GD appears to require that you allocate white first.
    $self->{colors}{fill}          = $self->{image}->colorAllocate( 255, 255, 255 );  #white
    $self->{colors}{grid}          = $self->{image}->colorAllocate( 210, 210, 210 );  #light grey
    $self->{colors}{vertex_fill}   = $self->{image}->colorAllocate( 100, 100, 100 );  #dark grey
    $self->{colors}{vertex_border} = $self->{image}->colorAllocate(   0,   0, 255 );  #blue
    $self->{colors}{border}        = $self->{image}->colorAllocate(   0,   0,   0 );  #black

    # Make the picture a white-transparent background.
    $self->{image}->transparent($self->{colors}{fill})
        unless $image_provided;

    my $grid = $self->{colors}{grid};
    my ($half, $end) = (
        $self->{surface_size} / 2, $self->{surface_size} - 1
    );

    if ($self->{layout} eq CIRCLE) {
        if ($self->{show_axes}) {
            $self->{image}->line($half, 1, $half, $half, $grid);  # r
        }

        if ($self->{show_grid}) {
            for (my $i = $self->{grade};
                 $i < $half;
                 $i += $self->{grade}
            ) {
                # concentric
                $self->{image}->arc(
                    $half,  $half,
                    2 * $i, 2 * $i,
                    0,      360,
                    $grid
                );

                if ($self->{grid_labels}) {
                    $self->{image}->string(
                        gdTinyFont,
                        $half + 1, $i,
                        $i, $self->{colors}{vertex_fill}
                    );
                }
            }

# XXX Radial grid is not happening yet...
#            for (my $i = $self->{grade}; $i < 360; $i += $self->{grade}) {
#                # radial
#                my $x = cos $i;
#                my $y = sin $i;
#                $self->{image}->line(
#                    $x, $y,
#                    $self->{surface_size}, $self->{surface_size},
#                    $grid
#                );
#
#                if ($self->{grid_labels}) {
#                    $self->{image}->string(
#                        gdTinyFont,
#                        $half + 1, $i,
#                        $i, $self->{colors}{vertex_fill}
#                    );
#                }
#            }
        }

        # Add a frame around the picture.
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
    }
    elsif ($self->{layout} eq RECTANGLE) {
        if ($self->{show_axes}) {
            $self->{image}->line(
                1, $half,
                $self->{surface_size}, $half,
                $grid
            );  # x
            $self->{image}->line(
                $half, 1,
                $half, $self->{surface_size},
                $grid
            );  # y
        }

        if ($self->{show_grid}) {
            for (my $i = $self->{grade}; $i < $self->{surface_size}; $i += $self->{grade}) {
                $self->{image}->line(
                    0, $i,
                    $self->{surface_size}, $i,
                    $grid
                );  # x
                $self->{image}->line(
                    $i, 0,
                    $i, $self->{surface_size},
                    $grid
                );  # y

                # XXX Oh man, do these ever suck.
                # stringUp is the wrong orientation, and I need to
                # implement a border edge big enough to accommodate
                # the labels if they are to be at the edges.
                if ($self->{grid_labels}) {
                    $self->{image}->stringUp(
                        gdTinyFont,
                        $i, $half + 1,
                        $i, $self->{colors}{vertex_fill}
                    );  # x
                    $self->{image}->string(
                        gdTinyFont,
                        $half + 1, $i,
                        $i, $self->{colors}{vertex_fill}
                    );  # y
                }
            }
        }

        # Add a frame around the picture.
        $self->{image}->rectangle(
            0, 0,
            $self->{surface_size} - 1, $self->{surface_size} - 1,
            $self->{colors}{border}
        );
    }

$self->_debug('exiting Surface::_init');
}  # }}}

sub write_image {
    my ($self, $filename) = @_;

    $filename = "$self->{name}.$self->{format}"
        if !$filename && $self->{name} && $self->{format};
    croak 'Surface image filename not defined' unless $filename;

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

$self->_debug(
    sprintf "%s (%d): [%.2f, %.2f] size: %.2f",
        $vertex->name, $vertex->weight,
        $vertex->x, $vertex->y, $vertex->size
);

    # circle border
    $self->{image}->arc(
        $vertex->x, $vertex->y,
        $vertex->size, $vertex->size,
        0, 360,
        $self->{colors}{vertex_border}
    );
    # circle fill
    $self->{image}->fillToBorder(
        $vertex->x, $vertex->y,
        $self->{colors}{vertex_border},
        $self->{colors}{vertex_fill}
    );
    # label
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

    $self->{image}->line(
        $vertex1->x, $vertex1->y,
        $vertex2->x, $vertex2->y,
        $self->{colors}{vertex_fill}
    );

    $self->draw_arrowhead($vertex1, $vertex2)
        if $self->{show_arrows};
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

    $self->{image}->filledPolygon($poly, $self->{colors}{vertex_fill});
}

1;

__END__

=head1 NAME

Graph::Drawing::Surface - 2D graph topology landscape

=head1 SYNOPSIS

This module does not need to be invoked explicitly, but rather, is 
called automatically by the parent.

Please see the C<Graph::Drawing> subclass C<SYNOPSIS> section 
documentation for usage.

=head1 DESCRIPTION

This module is a two dimensional graph topology landscape used by the
parent to plot vertices, edges, axes and labels.

=head1 ABSTRACT

2D graph topology landscape.

=head1 PUBLIC METHODS

=over 4

=item new %ARGUMENTS

Create and return a new surface object.

=over 4

=item image $OBJECT

An existing image object (currently a C<GD::Image> object only), on 
which to draw the graph, may be provided.

Please see the eg/image program, for an example of this in action.

=item name $STRING

The file name (without the extension like ".png") to use when saving 
the image.  This attribute is prepended to the C<format> attribute to 
make the image filename.

This object attribute is not required, and can be set manually with the 
C<Graph::Drawing::Surface::write_image> method.

=item format 'png' | 'gif' | ...

The graphic file format to use when saving and is dependent upon the
support with which your graphic module (as specified the C<type> 
attribute) is compiled.

This object attribute is appended (automatically) to the C<name> 
attribute, as the "file extension", to make the image filename, if
the C<name> attribute is provided.

=item type $MODULE

Specify the graphics module to use.  Currently, this is only C<GD>.
(C<Imager> is next!)

=item surface_size $PIXELS

The size of the (square) surface, in pixels.

=item grade $PIXELS

The gradation interval.

=item layout ['circular' | 'rectangular']

The type of graph layout to use.  Defaults to 'blank'.

=item show_grid 0 | 1

Show the grid, or not.  Defaults to 0.

=item grid_labels 0 | 1

Show the grid labels or not.  Defaults to 0.

* This functionality is pretty lame, right now.  Labels are currently 
drawn in the middle of the chart, instead of on the outer edges.

=item show_axes 0 | 1

Show the chart axes.  Defaults to 0.

=item show_arrows 0 | 1

Show edge arrows.  Defaults to 1.

=back

=item size

Return the C<surface_size> attribute.

=item write_image [$STRING]

Print the (binary) contents of the object's image attribute to a file,
who's name, if not provided as an argument, is defined by the 
concatination of the object's name and format attributes.

=back

=head1 PRIVATE METHODS

=over 4

=item _debug @STUFF

Print the contents of the argument array with a newline appended.

=item draw_vertex $VERTEX

=item draw_edge $VERTEX1, $VERTEX2

=item draw_arrowhead $HEAD, $TAIL

=back

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
