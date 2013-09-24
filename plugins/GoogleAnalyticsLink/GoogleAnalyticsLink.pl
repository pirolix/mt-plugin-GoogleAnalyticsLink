package MT::Plugin::Admin::OMV::GoogleAnalyticsLink;
# GoogleAnalyticsLink (C) 2013 Piroli YUKARINOMIYA (Open MagicVox.net)
# This program is distributed under the terms of the GNU Lesser General Public License, version 3.
# $Id$

use strict;
use warnings;
use MT 4;
use MT::Util;

use vars qw( $VENDOR $MYNAME $FULLNAME $VERSION );
$FULLNAME = join '::',
        (($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1]);
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = 'v0.11'. ($revision ? ".$revision" : '');

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
    # Basic descriptions
    id => $FULLNAME,
    key => $FULLNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    plugin_link => 'http://www.magicvox.net/archive/2013/09241517/', # Blog
    doc_link => "http://lab.magicvox.net/trac/mt-plugins/wiki/$MYNAME", # tracWiki
    description => <<'HTMLHEREDOC',
<__trans phrase="Add some useful links to investigate the pages with Google Analytics.">
HTMLHEREDOC
    l10n_class => "${FULLNAME}::L10N",

    # Configurations
    blog_config_template => "$VENDOR/$MYNAME/config.tmpl",
    settings => new MT::PluginSettings ([
        [ 'awp', { Default => undef, scope => 'blog' } ],
        [ 'index', { Default => undef, scope => 'blog' } ],
    ]),

    registry => {
        applications => {
            cms => {
                callbacks => {
                    "template_source.entry_table" => "${FULLNAME}::Callbacks::template_source_entry_table",
                    "template_source.edit_entry" => "${FULLNAME}::Callbacks::template_source_edit_entry",
                    "template_source.template_table" => "${FULLNAME}::Callbacks::template_source_template_table",
                    "template_source.edit_template" => "${FULLNAME}::Callbacks::template_source_edit_template",
                    "template_source.header" => "${FULLNAME}::Callbacks::template_source_header",
                },
            },
        },
    },
});
MT->add_plugin ($plugin);

###
sub init_registry {
    my $self = shift;

    6.0 <= MT->version_number
        and return;

    # Inject a sub menu
    my $title = MT->registry ('list_properties', 'entry', 'title');
    push @{$title->{sub_fields}}, {
        class => 'galink_class',
        label => 'Google Analytics',
        display => 'default',
    };

    # Modify the original method's output
    my $orig_html = $title->{html};
    $title->{html} = sub {
        my ($prop, $obj) = @_;
        my $out = $orig_html->(@_);

        if (my $awp = &instance->get_config_value('awp', 'blog:'. $obj->blog_id)) {
            (my $pagePath = $obj->permalink) =~ s!^https?://.+?/!/!;    # omit domain part
            if ($pagePath =~ m!/$!) {
                my $index = MT::Util::trim( &instance->get_config_value( 'index', 'blog:'. $obj->blog_id ) || '' );
                $pagePath .= $index;
            }
            $pagePath = MT::Util::encode_url($pagePath);

            my $static_uri = MT->static_path;
            my $old = quotemeta qq{<p class="excerpt description"};
            my $add = &instance->translate_templatized(<<"HTMLHEREDOC");
<span class="galink_class">
  <a href="https://www.google.com/analytics/web/?hl=ja&pli=1#report/content-pages/${awp}/%3Fexplorer-table.plotKeys%3D[]%26_r.drilldown%3Danalytics.pagePath%3A${pagePath}/">
    <img src="${static_uri}plugins/$VENDOR/$MYNAME/chart_s.png" alt="<__trans phrase="Investigate with Google Analytics">" /></a>
</span>
HTMLHEREDOC
            unless ($out =~ s/($old)/$add$1/) {
                $out =~ s/$/$add/;
            }
        }

        return $out;
    };
    MT->registry('list_properties', 'entry', 'title', $title);
}

sub instance { $plugin; }

1;