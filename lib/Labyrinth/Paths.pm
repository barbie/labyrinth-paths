package Labyrinth::Paths;

use warnings;
use strict;

our $VERSION = '0.01';

# -------------------------------------
# Library Modules

use IO::File;
use JSON::XS;
use Labyrinth;
use Labyrinth::Variables;

# -------------------------------------
# The Subs

=head1 FUNCTIONS

=head2 Constructor

=over 4

=item new()

Create a new path object.

=back

=cut

sub new {
    my ($class,$pathfile) = @_;

    # create an attributes hash
    my $atts = {
        pathfile => $pathfile || $settings{pathfile} || './pathfile.json'
    };

    # create the object
    bless $atts, $class;

    $atts->load;

    return $atts;
};

=head2 Methods

=head3 Handling Actions

=over 4

=item load( [$file] )

Load the given path file, which can be the default, or specified as a parameter.

=item parse()

Parse the current path and reset cgiparams and settings values as appropriate.

=back

=cut

sub load {
    my $self = shift;
    my $file = shift;

    if($file) {
        return  unless(-f $file);
        $self->{pathfile} = $file;
    } else {
        return  unless(-f $self->{pathfile});
    }

    my $fh = IO::File->new($self->{pathfile},'r') or return;
    local $/ = undef;
    my $json = <$fh>;
    $fh->close;

    eval {
        my $data = decode_json($json);
        $self->{data} = $data->{paths};
    };

    return;
}

sub parse {
    my $self = shift;
    my $path = $ENV{SCRIPT_URL} || $ENV{SCRIPT_NAME};

    for my $data (@{$self->{data}}) {
        if($path =~ /$data->{path}/) {
            my @vars = ($1,$2,$3,$4,$5,$6,$7,$8,$9);
            while($data->{variables} && @{$data->{variables} && @vars}) {
                my $name = shift $data->{variables};
                $cgiparams{$name} = shift @vars;
            }

            $cgiparams{$_} = $self->{cgiparams}{$_} for(keys %{$self->{cgiparams}});
            $settings{$_}  = $self->{settings}{$_}  for(keys %{$self->{settings}});

            return;
        }
    }
}

1;

__END__

=head1 SEE ALSO

L<Labyrinth>

=head1 AUTHOR

Barbie, <barbie@missbarbell.co.uk> for
Miss Barbell Productions, L<http://www.missbarbell.co.uk/>

=head1 COPYRIGHT & LICENSE

  Copyright (C) 2015 Barbie for Miss Barbell Productions
  All Rights Reserved.

  This distribution is free software; you can redistribute it and/or
  modify it under the Artistic License 2.0.

=cut
