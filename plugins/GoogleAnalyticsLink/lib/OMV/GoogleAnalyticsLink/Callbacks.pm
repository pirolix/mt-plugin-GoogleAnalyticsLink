package OMV::GoogleAnalyticsLink::Callbacks;
# $Id$

use strict;
use warnings;
use MT;
use MT::Util;

use vars qw( $VENDOR $MYNAME $FULLNAME );
$FULLNAME = join '::',
        (($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[0, 1]);

sub instance { MT->component($FULLNAME); }



### MT::App::CMS::template_source.entry_table for 5.0
sub template_source_entry_table {
    my ($cb, $app, $tmpl) = @_;

    my $blog_id = $app->param('blog_id') or return;
    my $awp = &instance->get_config_value('awp', 'blog:'. $blog_id) or return;
    my $index = MT::Util::encode_url( MT::Util::trim( &instance->get_config_value( 'index', 'blog:'. $blog_id ) || '' ));

    # Inject links to Google Analytics after the view link
    my $pin1 = quotemeta qq{<mt:if name="entry_permalink">};
    my $pin2 = quotemeta qq{</td>};
    my $add = &instance->translate_templatized(<<"MTMLHEREDOC");
<a href="https://www.google.com/analytics/web/?hl=ja&pli=1#report/content-pages/${awp}/%3Fexplorer-table.plotKeys%3D[]%26_r.drilldown%3Danalytics.pagePath%3A<mt:var name="entry_permalink" regex_replace="/^https?:\/\/.+?\//","/" escape="url"><mt:if name="entry_permalink" like="/\$">$index</mt:if>/">
  <img src="<mt:var name="static_uri">plugins/$VENDOR/$MYNAME/chart_s.png" alt="<__trans phrase="Investigate with Google Analytics">" /></a>
MTMLHEREDOC
    $$tmpl =~ s/($pin1.+?)($pin2)/$1$add$2/s;
}

### MT::App::CMS::template_source.edit_entry
sub template_source_edit_entry {
    my ($cb, $app, $tmpl) = @_;

    my $blog_id = $app->param('blog_id') or return;
    my $awp = &instance->get_config_value('awp', 'blog:'. $blog_id) or return;
    my $index = MT::Util::encode_url( MT::Util::trim( &instance->get_config_value( 'index', 'blog:'. $blog_id ) || '' ));

    # Add link to Google Analytics after the button for communication
    my $pin1 = quotemeta qq{<mt:if name="can_send_notifications">};
    my $pin2 = quotemeta qq{</mtapp:setting>};
    my $add = &instance->translate_templatized(<<"MTMLHEREDOC");
<a href="https://www.google.com/analytics/web/?hl=ja&pli=1#report/content-pages/${awp}/%3Fexplorer-table.plotKeys%3D[]%26_r.drilldown%3Danalytics.pagePath%3A<mt:var name="entry_permalink" regex_replace="/^https?:\/\/.+?\//","/" escape="url"><mt:if name="entry_permalink" like="/\$">$index</mt:if>/">
  <img src="<mt:var name="static_uri">plugins/$VENDOR/$MYNAME/chart_m.png" alt="<__trans phrase="Investigate with Google Analytics">" /></a>
MTMLHEREDOC
    $$tmpl =~ s/($pin1.+?)($pin2)/$1$add$2/s;
}

### MT::App::CMS::template_source.template_table
sub template_source_template_table {
    my ($cb, $app, $tmpl) = @_;

    my $blog_id = $app->param('blog_id') or return;
    my $awp = &instance->get_config_value('awp', 'blog:'. $blog_id) or return;
    my $index = MT::Util::encode_url( MT::Util::trim( &instance->get_config_value( 'index', 'blog:'. $blog_id ) || '' ));

    # Inject links to Google Analytics after the view link
    my $pin = quotemeta qq{<img src="<mt:var name="static_uri">images/status_icons/view.gif" alt="<__trans phrase="View Published Template">" width="13" height="9" /></a>};
    my $add = &instance->translate_templatized(<<"MTMLHEREDOC");
<a href="https://www.google.com/analytics/web/?hl=ja&pli=1#report/content-pages/${awp}/%3Fexplorer-table.plotKeys%3D[]%26_r.drilldown%3Danalytics.pagePath%3A<mt:var name="published_url" regex_replace="/^https?:\/\/.+?\//","/" escape="url"><mt:if name="published_url" like="/\$">$index</mt:if>/">
  <img src="<mt:var name="static_uri">plugins/$VENDOR/$MYNAME/chart_s.png" alt="<__trans phrase="Investigate with Google Analytics">" /></a>
MTMLHEREDOC
    $$tmpl =~ s/($pin)/$1$add/s;
}

### MT::App::CMS::template_source.edit_template
sub template_source_edit_template {
    my ($cb, $app, $tmpl) = @_;

    my $blog_id = $app->param('blog_id') or return;
    my $awp = &instance->get_config_value('awp', 'blog:'. $blog_id) or return;
    my $index = MT::Util::encode_url( MT::Util::trim( &instance->get_config_value( 'index', 'blog:'. $blog_id ) || '' ));

    # Add item to Google Analytics in the shortcut widget
    my $pin1 = quotemeta qq{<mt:if name="published_url">};
    my $pin2 = quotemeta qq{</mt:if>};
    my $add = &instance->translate_templatized(<<"MTMLHEREDOC");
<li><a href="https://www.google.com/analytics/web/?hl=ja&pli=1#report/content-pages/${awp}/%3Fexplorer-table.plotKeys%3D[]%26_r.drilldown%3Danalytics.pagePath%3A<mt:var name="published_url" regex_replace="/^https?:\/\/.+?\//","/" escape="url"><mt:if name="published_url" like="/\$">$index</mt:if>/" class="icon-left icon-related">
  <img src="<mt:var name="static_uri">plugins/$VENDOR/$MYNAME/chart_s.png" alt="<__trans phrase="Investigate with Google Analytics">" />
  <__trans phrase="Investigate with Google Analytics"></a></li>
MTMLHEREDOC
    $$tmpl =~ s/($pin1.+?)($pin2)/$1$add$2/s;
}

### MT::App::CMS::template_source.header
sub template_source_header {
    my ($cb, $app, $tmpl) = @_;

    my $blog_id = $app->param('blog_id') or return;
    my $awp = &instance->get_config_value('awp', 'blog:'. $blog_id) or return;

    # Add button to Google Analytics on the header menu
    my $pin1 = quotemeta qq{<span><__trans phrase="View [_1]" params="<mt:var name="scope_type" capitalize="1">"></span></a>};
    my $pin2 = quotemeta qq{</li>};
    my $add = &instance->translate_templatized(<<"MTMLHEREDOC");
<li id="view-site" class="nav-link">
  <a href="https://www.google.com/analytics/web/?hl=ja&pli=1#report/content-pages/${awp}/"
      style="background-image:url(<mt:var name="static_uri">plugins/$VENDOR/$MYNAME/chart_m.png);"
      title="<__trans phrase="Investigate with Google Analytics">">
    <span><__trans phrase="Investigate with Google Analytics"></span></a></li>
MTMLHEREDOC
    $$tmpl =~ s/($pin1.*?$pin2)/$1$add/s;
}

1;