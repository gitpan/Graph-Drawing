package Graph::Drawing::Surface;
use vars qw($VERSION); $VERSION = '0.06';
use strict;
use Carp;
use GD;  # XXX Ugh.  Refactoring, please.

use constant PI        => 2 * atan2 (1, 0);  # The number.
use constant FLARE     => 0.9 * PI;          # The angle of the arrowhead.
use constant CIRCLE    => 'circular';
use constant RECTANGLE => 'rectangular';

sub _debug { print @_, "\n" if shift->{debug} }

sub new {  # {{{
    my $proto = shift;
    my $class = ref $proto || $proto;
    my %args = @_;
    my $self = {
        debug         => $args{debug}        || 0,
        size          => $args{size}         || 0,
        name          => $args{name}         || 'surface',
        type          => $args{type}         || 'GD',  # default
        format        => $args{format}       || 'png',
        image         => $args{image}        || undef,
        colors        => $args{colors}       || {},
        grade         => $args{grade}        || 10,
        layout        => $args{layout}       || 'blank',
        show_grid     => $args{show_grid}    || 0,
        grid_labels   => $args{grid_labels}  || 0,
        show_axes     => $args{show_axes}    || 0,
        show_arrows   => defined $args{show_arrows} ? $args{show_arrows} : 1,
        vertex_labels => defined $args{vertex_labels} ? $args{vertex_labels} : 1,
        colors        => {
            fill   => [ 255, 255, 255 ],  # white
            border => [   0,   0,   0 ],  # black
            grid   => [ 210, 210, 210 ],  # light gray
            label  => [   0,   0,   0 ],  # black
            axis   => [ 100, 100, 100 ],  # dark gray
            edge   => [ 100, 100, 100 ],  # dark gray
            arrow  => [ 128, 128, 128 ],  # medium gray
        },
    };
    bless $self, $class;
    $self->_init(%args);
    return $self;
}  # }}}

sub size { return shift->{size} }

sub _init {  # {{{
    my $self = shift;
$self->_debug('entering Surface::_init');

    my $image_provided = $self->{image} ? 1 : 0;

    # Allocate the goodness.
    $self->{image} = GD::Image->new($self->{size}, $self->{size})
        unless $image_provided;
$self->_debug('image: ' . ref $self->{image});

    $self->{colors}{fill}   = $self->{image}->colorAllocate(@{ $self->{colors}{fill} });
    $self->{colors}{border} = $self->{image}->colorAllocate(@{ $self->{colors}{border} });
    $self->{colors}{grid}   = $self->{image}->colorAllocate(@{ $self->{colors}{grid} });
    $self->{colors}{label}  = $self->{image}->colorAllocate(@{ $self->{colors}{label} });
    $self->{colors}{axis}   = $self->{image}->colorAllocate(@{ $self->{colors}{axis} });
    $self->{colors}{edge}   = $self->{image}->colorAllocate(@{ $self->{colors}{edge} });
    $self->{colors}{arrow}  = $self->{image}->colorAllocate(@{ $self->{colors}{arrow} });

    # Make the picture a white-transparent background.
    $self->{image}->transparent($self->{colors}{fill})
        unless $image_provided;

    my ($half, $end) = ($self->{size} / 2, $self->{size} - 1);

    if ($self->{layout} eq CIRCLE) {
        if ($self->{show_axes}) {
            $self->{image}->line(
                $half, 1, $half, $half, $self->{colors}{axis}
            );  # r
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
                    $self->{colors}{grid}
                );

                if ($self->{grid_labels}) {
                    $self->{image}->string(
                        gdTinyFont,
                        $half + 1, $i,
                        $i, $self->{colors}{label}
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
#                    $self->{size}, $self->{size},
#                    $self->{colors}{grid}
#                );
#
#                if ($self->{grid_labels}) {
#                    $self->{image}->string(
#                        gdTinyFont,
#                        $half + 1, $i,
#                        $i, $self->{colors}{label}
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

        # Fill the corners with the grid color.
        $self->{image}->fill( 0,    0,    $self->{colors}{grid} );
        $self->{image}->fill( 0,    $end, $self->{colors}{grid} );
        $self->{image}->fill( $end, 0,    $self->{colors}{grid} );
        $self->{image}->fill( $end, $end, $self->{colors}{grid} );
    }
    elsif ($self->{layout} eq RECTANGLE) {
        if ($self->{show_axes}) {
            $self->{image}->line(
                1, $half,
                $self->{size}, $half,
                $self->{colors}{axis}
            );  # x
            $self->{image}->line(
                $half, 1,
                $half, $self->{size},
                $self->{colors}{axis}
            );  # y
        }

        if ($self->{show_grid}) {
            for (my $i = $self->{grade}; $i < $self->{size}; $i += $self->{grade}) {
                $self->{image}->line(
                    0, $i,
                    $self->{size}, $i,
                    $self->{colors}{grid}
                );  # x
                $self->{image}->line(
                    $i, 0,
                    $i, $self->{size},
                    $self->{colors}{grid}
                );  # y

                # XXX Oh man, do these ever suck.
                # stringUp is the wrong orientation, and I need to
                # implement a border edge big enough to accommodate
                # the labels if they are to be at the edges.
                if ($self->{grid_labels}) {
                    $self->{image}->stringUp(
                        gdTinyFont,
                        $i, $half + 1,
                        $i, $self->{colors}{label}
                    );  # x
                    $self->{image}->string(
                        gdTinyFont,
                        $half + 1, $i,
                        $i, $self->{colors}{label}
                    );  # y
                }
            }
        }

        # Add a frame around the picture.
        $self->{image}->rectangle(
            0, 0,
            $self->{size} - 1, $self->{size} - 1,
            $self->{colors}{border}
        );
    }

$self->_debug('exiting Surface::_init');
}  # }}}

sub write_image {  # {{{
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
}  # }}}

sub draw_vertex {  # {{{
    my ($self, $vertex) = @_;
$self->_debug(
    sprintf "%s (%d): [%.2f, %.2f] size: %.2f",
        $vertex->name, $vertex->weight,
        $vertex->x, $vertex->y, $vertex->size
);

    # Allocate the colors if they haven't been, already.
    $vertex->{colors}{fill} = $self->{image}->colorAllocate(@{ $vertex->{colors}{fill} })
        if ref $vertex->{colors}{fill} eq 'ARRAY';
    $vertex->{colors}{border} = $self->{image}->colorAllocate(@{ $vertex->{colors}{border} })
        if ref $vertex->{colors}{border} eq 'ARRAY';
    $vertex->{colors}{label} = $self->{image}->colorAllocate(@{ $vertex->{colors}{label} })
        if ref $vertex->{colors}{label} eq 'ARRAY';

    # circle border
    $self->{image}->arc(
        $vertex->x, $vertex->y,
        $vertex->size, $vertex->size,
        0, 360,
        $vertex->{colors}{border}
    );
    # circle fill
    $self->{image}->fillToBorder(
        $vertex->x, $vertex->y,
        $vertex->{colors}{border},
        $vertex->{colors}{fill}
    );
    # label
    if ($vertex->{show_label}) {
        $self->{image}->string(
            gdTinyFont,
            $vertex->x + $vertex->size,
            $vertex->y + $vertex->size / 2,
            $vertex->name .':'. $vertex->weight,
            $vertex->{colors}{label}
        );
    }
}  # }}}

sub draw_edge {  # {{{
    my ($self, $vertex1, $vertex2) = @_;

    $self->draw_arrowhead($vertex1, $vertex2)
        if $self->{show_arrows};

    # Allocate the edge color if it hasn't been, already.
    $self->{colors}{edge} = $self->{image}->colorAllocate(@{ $self->{colors}{edge} })
        if ref $self->{colors}{edge} eq 'ARRAY';

    $self->{image}->line(
        $vertex1->x, $vertex1->y,
        $vertex2->x, $vertex2->y,
        $self->{colors}{edge}
    );
}  # }}}

sub draw_arrowhead {  # {{{
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

    # Allocate the arrow color if it hasn't been, already.
    $self->{colors}{arrow} = $self->{image}->colorAllocate(@{ $self->{colors}{arrow} })
        if ref $self->{colors}{arrow} eq 'ARRAY';

    $self->{image}->filledPolygon($poly, $self->{colors}{arrow});
}  # }}}

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

=item size $PIXELS

The size of the (square) surface, in pixels.

If this is not set in the object construction, and there is a dataset,
half the graph max weight will be used, otherwise zero (no visible 
image) is set as the default.

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

=item vertex_labels 0 | 1

Show vertex labels.  Defaults to 1.

=back

=item size

Return the C<size> attribute.

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
