package MT::Plugin::AssetPathURLFilter;
use strict;
use warnings;
use utf8;

use base qw( MT::Plugin );

my $plugin = __PACKAGE__->new(
    {   name        => 'AssetPathURLFilter',
        version     => 0.01,
        author_name => 'Masahiro Iuchi',
        author_link => 'https://github.com/masiuchi',
        plugin_link =>
            'https://github.com/masiuchi/mt-plugin-asset-path-url-filter',
        description =>
            '<__trans phrase="Enable filtering assets by file path or URL.">',

        registry => {
            list_properties => {
                asset => {
                    file_path => {
                        base  => '__virtual.string',
                        label => 'File Path',
                        terms => sub { _terms( @_[ 0 .. 3 ], 'file_path' ) },
                    },
                    url => {
                        base  => '__virtual.string',
                        label => 'URL',
                        terms => sub { _terms( @_[ 0 .. 3 ], 'url' ) },
                    },
                },
            },
        },
    }
);
MT->add_plugin($plugin);

sub _terms {
    my $prop = shift;
    my ( $args, $db_terms, $db_args, $col ) = @_;
    my $option = $args->{option};
    my $query  = quotemeta $args->{string};

    require MT::Asset;
    my @assets = MT::Asset->load( $db_terms, $db_args ) or return;

    my @filtered_assets;
    if ( 'contains' eq $option ) {
        @filtered_assets = grep { $_->$col =~ m/$query/ } @assets;
    }
    elsif ( 'not_contains' eq $option ) {
        @filtered_assets = grep { $_->$col !~ m/$query/ } @assets;
    }
    elsif ( 'beginning' eq $option ) {
        @filtered_assets = grep { $_->$col =~ m/^$query/ } @assets;
    }
    elsif ( 'end' eq $option ) {
        @filtered_assets = grep { $_->$col =~ m/$query$/ } @assets;
    }

    if ( !@filtered_assets ) {
        return +{ id => \'IS NULL' };
    }

    my @ids = map { $_->id } @filtered_assets;
    return +{ id => \@ids };
}

1;
