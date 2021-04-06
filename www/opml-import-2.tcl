ad_page_contract {
    The -2 page for OPML import.
    
    @author Guan Yang (guan@unicast.org)
    @cvs-id $Id$
    @creation-date 2003-08-14
} {
    aggregator_id:naturalnum,notnull
    url:notnull
} -validate {
    url_is_valid -requires { url:notnull } {
	if { ![util_url_valid_p $url] } {
	    ad_complain "The URL you have entered is not valid."
	}
    }
}

set opml_url $url

set user_id [auth::require_login]
permission::require_permission \
    -object_id $aggregator_id \
    -party_id $user_id \
    -privilege write

set page_title "OPML Import"
set context [list $page_title]

if { [catch {
    set f [util::http::get -url $url]
    if { [dict get $f status] ne "200" } {
        error "Could not fetch document via HTTP."
    }

    array set opml [news_aggregator::opml::parse -xml [dict get $f page]]

    if { $opml(status) eq "failure" } {
	error "OPML parse error: $opml(errmsg)"
    }

    set sources $opml(elements)
    if { [llength $sources] == 0 } {
	error "OPML file did not contain any valid sources"
    }

    list::create \
	-name opml_feeds \
	-multirow opml_feeds \
	-key url \
	-row_pretty_plural "sources" \
	-bulk_actions {
	    Subscribe opml-import-3
	} -elements {
	    title {
		label "Name"
		display_template {
		    <a href="@opml_feeds.html_url@"
		    target="_blank"
		    title="Visit the source's home page">@opml_feeds.title@</a>
		}
	    }
	}

    multirow create opml_feeds title html_url url
    foreach source $sources {
	array set s $source
	multirow append opml_feeds $s(title) $s(html_url) $s(url)
    }
    
} errmsg] } {
    ad_return_complaint 1 "OPML import error: $errmsg"
    ad_script_abort
}
