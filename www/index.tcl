ad_page_contract {
    The News Aggregator index page.

    @author Simon Carstensen simon@bcuni.net
    @creation-date 28-06-2003
} {
    aggregator_id:integer,optional
    purge_p:boolean,optional
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set per_user_aggregators_p [parameter::get -package_id $package_id -parameter PerUserAggregatorsP -default 0]

if { ![info exists aggregator_id] } {
    # Check whether the user has an aggregator
    if { !$user_id } {
	if { !$per_user_aggregators_p } {
	    ad_returnredirect "public-aggregators"
	}
	ad_redirect_for_registration
	ad_script_abort
    }

    set aggregator_id [news_aggregator::aggregator::user_default -user_id $user_id]

    if { !$aggregator_id && $per_user_aggregators_p } {
        
        set user_name [db_string select_user_name {}]
        set aggregator_name "${user_name}'s News Aggregator"

	set aggregator_id [news_aggregator::aggregator::new \
				-aggregator_name $aggregator_name \
				-package_id $package_id \
				-public_p 0 \
				-creation_user $user_id \
				-creation_ip [ad_conn peeraddr]]

        #load preinstalled subscriptions into aggregator
        news_aggregator::aggregator::load_preinstalled_subscriptions \
            -aggregator_id $aggregator_id \
            -package_id $package_id
    }

    ad_returnredirect "$aggregator_id"
}

if { $aggregator_id == 0 } {
    # May this user create her own aggregator?
    set write_p [permission::permission_p \
		     -object_id $package_id \
		     -privilege write]
    if { $write_p } {
	ad_returnredirect "settings"
    }
    ad_returnredirect "public-aggregators"
}

set write_p [permission::permission_p \
                 -object_id $aggregator_id \
                 -privilege write]

db_1row aggregator_info {}

#if { $public_p == "f" } {
#    permission::require_permission \
#        -object_id $aggregator_id \
#        -privilege write]
#}

set page_title $aggregator_name
set context [list $page_title]

set package_url [ad_conn package_url]
set url "$package_url$aggregator_id/"
set graphics_url "${package_url}graphics/"
set return_url [ad_conn url]
set aggregator_url [export_vars -base aggregator { return_url aggregator_id }]

set create_url "${package_url}/aggregator"

set limit [ad_parameter "number_of_items_shown"]
set sql_limit [expr 7*$limit]

set top 0
set bottom 1073741824

set counter 0

if { [info exists purge_p] && $public_p == "f" && $purge_p == "f" } {
    set purge_p 0
} elseif { $public_p == "t" } {
    set purge_p 0
} else {
    set purge_p 1
}

# We only handle purges if the aggregator is not public
if { $purge_p } {
#    set items_purges [db_map items_purges]
    set purges [db_list_of_lists purges ""]
    set saved_items [db_list saved_items ""]
} else {
#    set items_purges ""
    set purges [list]
    set saved_items [list]
}

if { $purge_p } {
    set items_query [news_aggregator::aggregator::items_sql \
                    -aggregator_id $aggregator_id \
                    -package_id $package_id \
                    -purge_p $purge_p]
} else {
    set items_query [news_aggregator::aggregator::items_sql \
                    -aggregator_id $aggregator_id \
                    -package_id $package_id \
                    -purge_p $purge_p \
		    -limit_multiple 1]
}

db_multirow -extend { 
    content 
    diff
    source_url 
    save_url 
    unsave_url 
    item_blog_url 
    technorati_url
    item_guid_link
    pub_date
} items items $items_query {
    # Top is the first item
    if { $item_id > $top } {
    	set top $item_id
    }
    
    set purged_p 0
    # Handle purged items
    foreach purge $purges {
    	if { $item_id <= [lindex $purge 0] && $item_id >= [lindex $purge 1] &&
	     [lsearch $saved_items $item_id] == -1 } {
	    set purged_p 1
	}
    }
    if { $purged_p } {
        continue
    }

    if { [exists_and_not_null content_encoded] } {
	if { [exists_and_not_null item_title] } {
	    set content "<a href=\"$item_link\">$item_title</a>. $content_encoded"
	} else {
            set content $content_encoded
	}
    } else {
        set text_only [util_remove_html_tags $item_description]

        if { [exists_and_not_null item_title] } {
            set content "<a href=\"$item_link\">$item_title</a>. 		    <span class=\"item_author\">$item_author</span>
$item_description"
        } else {
            set content $item_description
        }
    }
    
    if { $item_permalink_p == "t" } {
        set item_guid_link $item_original_guid
    } else {
        set item_guid_link $item_link
    }

    set diff [news_aggregator::last_scanned -diff [expr [expr [clock seconds] - [clock scan $last_scanned]] / 60]]
    set source_url [export_vars -base source {source_id}]
    set technorati_url "http://www.technorati.com/cosmos/links.html?url=$link&sub=Get+Link+Cosmos"

    set localtime [clock scan [lc_time_utc_to_local $item_pub_date] -gmt 1]
    set utctime [clock scan $item_pub_date -gmt 1]
    if { $utctime > [clock scan "1 week ago"] } {
        set pub_date [clock format $localtime -format "%a %H:%M"]
    } else {
        set pub_date [clock format $localtime -format "%m-%d %H:%M"]
    }

    if { [string equal $write_p "1"] } {
	if { [lsearch $saved_items $item_id] == -1 } {
            set save_url [export_vars -base "${url}item-save" {item_id}]
	    set unsave_url ""
	} else {
	    set unsave_url [export_vars -base "${url}item-unsave" {item_id}]
	    set save_url ""
	}
        set item_blog_url [export_vars -base "${url}item-blog" {item_id}]
    }

    if { $item_id < $bottom } {
	set bottom $item_id
    }

    incr counter
    if { $counter > $limit } {
	break
    }
}

if { [exists_and_not_null top] && [exists_and_not_null bottom] &&
     $top >= $bottom && $public_p == "f" &&
     [permission::permission_p -party_id $user_id -object_id $aggregator_id -privilege write] } {
    
    ad_form -name purge -action "[ad_conn package_url]$aggregator_id/purge" -form {
        {purge_top:integer(hidden) 
            {value $top}
        }
        {purge_bottom:integer(hidden) 
            {value $bottom}
        }
        {purge_submit:text(submit) 
            {label "Purge this page of news"} 
            {html {accesskey "p"}}
        }
    }
    set purge 1
    
} else {
    set purge 0
}

set purge_off_url "[ad_conn package_url]$aggregator_id/?purge_p=f"
set purge_on_url "[ad_conn package_url]$aggregator_id"
