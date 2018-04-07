ad_library {
    Procs to manage aggregators.
    
    @author Simon Carstensen (simon@bcuni.net)
    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-09
}

namespace eval news_aggregator {}
namespace eval news_aggregator::weblog {}
namespace eval news_aggregator::weblog::impl {}

ad_proc -public news_aggregator::weblog::new {
    {-package_id ""}
    {-user_id ""}
    -blog_type:required
    -weblog_name:required
    -base_url:required
    {-ip ""}
} {
    Creates a new weblog and returns weblog_id.
    @author Simon Carstensen (simon@bcuni.net)
    @creation-date 2003-07-14
} {
    if { $package_id eq ""} {
        set package_id [ad_conn package_id]
    }
    if { $user_id eq ""} {
        set user_id [ad_conn user_id]
    }
    if { $ip eq ""} {
	set ip [ns_conn peeraddr]
    }

    set weblog_id [db_string new_weblog {}]

    return $weblog_id
}

ad_proc -public news_aggregator::weblog::edit {
    -weblog_id:required
    -blog_type:required
    -weblog_name:required
    -base_url:required
} {
    Edit weblog.
    
    @author Simon Carstensen (simon@bcuni.net)
    @creation-date 2003-07-14
} {
    db_dml edit_weblog {}
}

ad_proc -public news_aggregator::weblog::validate_base_url {
    -blog_type:required
    -base_url:required
} {
    Attempt to validate the specified base URL against the
    specified blog type.
    
    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-12-15
    
    @return 1 if the base URL successfully validates, or 0 if
        it does not appear to be valid, or if the blog type
        could not be found.
} {
    return [news_aggregator::weblog::impl::${blog_type}_validate_url \
                    -base_url $base_url]
}

ad_proc -private news_aggregator::weblog::impl::movabletype_validate_url {
    -base_url:required
} {
    Validates a Movable Type base URL.
} {
    set valid_p 1
    
    if { ![util_url_valid_p $base_url] } {
        # Not a valid URL at all
        return 0
    }
    
    # MT base urls will start with http or https
    if { ![regexp {^https?://} $base_url] } {
        return 0
    }
    
    # At some point we expect to see "app?" or "mt.cgi?"
    # Is this too strict?
    if { ![regexp {/app\?__mode=[a-z]+&blog_id=(\d+)} $base_url match blog_id] &&
         ![regexp {/mt.cgi\?__mode=[a-z]+&blog_id=(\d+)} $base_url match blog_id] } {
        return 0
    }
        
    return 1
}

ad_proc -private news_aggregator::weblog::impl::movabletype_get_post_url {
    -base_url:required
    -title:required
    -link:required
    -text:required
} {
    Returns the post URL for a Movable Type weblog. Will barf bigtime
    if the URL is not valid.
    
    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-12-15
} {
    if { ![news_aggregator::weblog::impl::movabletype_validate_url \
                    -base_url $base_url] } {
        return ""
    }
    
    if { [regexp {^(.+/app\?)__mode=[a-z]+&blog_id=(\d+)} $base_url match first_part blog_id] ||
         [regexp {^(.+/mt.cgi\?)__mode=[a-z]+&blog_id=(\d+)} $base_url match first_part blog_id] } {
        # do nothing
    }
    
    set post_url $first_part
    append post_url [export_vars -url [list \
            [list "is_bm" 1] \
            [list "bm_show" "trackback,category,allow_comments,allow_pings,convert_breaks,excerpt,text_more#,keywords"] \
            [list "__mode" "view"] \
            [list "_type" "entry"] \
            [list "blog_id" $blog_id] \
            [list "link_title" $title] \
            [list "link_href" $link] \
            [list "text" $text]]]

    
    return $post_url
}

ad_proc -public news_aggregator::weblog::get_post_url {
    -blog_type:required
    -base_url:required
    -title:required
    -link:required
    -text:required
} {
    Attempt to return an URL which will bring the user to a page
    where he can post a weblog entry. If we don't succeed, throw
    an error.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-12-15
} {
    return [news_aggregator::weblog::impl::${blog_type}_get_post_url \
    				-base_url $base_url \
    				-title $title \
				-link $link \
				-text $text]
}

ad_proc -public news_aggregator::weblog::options {
    -user_id:required
} {
    Returns options (value label pairs) for building the weblog HTML select box.

    @author Simon Carstensen
} {
    return [db_list_of_lists select_weblog_options {}]
}

ad_proc -public news_aggregator::weblog::blog_type_options {} {
    Returns options (value label pairs) for building the blog type HTML select box.

    @author Simon Carstensen
} {
    return  {
        {"Select Blog Type"    {}}
        {"Blogger"        blogger}  
        {"Manila"         manila} 
        {"Movable Type"    movabletype}
        {"Radio Userland" radio}
        {"TypePad" typepad}
    }
}

