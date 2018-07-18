ad_page_contract {
    The News Aggregator index page.

    @author Simon Carstensen simon@bcuni.net
    @creation-date 28-06-2003
} {
    aggregator_id:integer,optional
    {purge_p:boolean,optional false}
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set per_user_aggregators_p [parameter::get -package_id $package_id -parameter PerUserAggregatorsP -default 0]
set enable_purge_p [parameter::get -package_id $package_id -parameter EnablePurgeP -default 1]
set multiple_aggregators_p [parameter::get -package_id $package_id -parameter MultipleAggregatorsP -default 1]
set allow_aggregator_edit_p [parameter::get -package_id $package_id -parameter AllowAggregatorEditP -default 1]


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

        set user_name [person::name -person_id $user_id]
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

    ad_returnredirect $aggregator_id
    ad_script_abort
}

if { $aggregator_id == 0 } {
    # May this user create her own aggregator?
    set write_p [permission::permission_p \
                     -object_id $package_id \
                     -privilege write]
    if { $write_p } {
        ad_returnredirect "settings"
        ad_script_abort
    }
    ad_returnredirect "public-aggregators"
    ad_script_abort
}

set write_p [permission::permission_p \
                 -object_id $aggregator_id \
                 -privilege write]

set info [news_aggregator::aggregator::aggregator_info \
              -aggregator_id $aggregator_id]
set aggregator_name        [dict get $info aggregator_name]
set aggregator_description [dict get $info aggregator_description]
set public_p               [dict get $info public_p]

#if { $public_p == "f" } {
#    permission::require_permission \
#        -object_id $aggregator_id \
#        -privilege write
#}
set page_title $aggregator_name
set context [list $page_title]

set package_url [ad_conn package_url]
set url "$package_url$aggregator_id/"
set graphics_url "${package_url}graphics/"
set return_url [ad_conn url]
set aggregator_url [export_vars -base aggregator { return_url aggregator_id }]

set create_url "${package_url}/aggregator"

# We only handle purges if the aggregator is not public
if { $enable_purge_p || !$public_p || $purge_p } {
    set purges [db_list_of_lists purges {
        select top, bottom
	  from na_purges
	 where aggregator_id = :aggregator_id
 	order by top desc, bottom desc
    }]
    set saved_items [db_list saved_items {
        select item_id
        from na_saved_items
        where aggregator_id = :aggregator_id
    }]
} else {
    set purges [list]
    set saved_items [list]
}

if { $enable_purge_p || !$public_p || $purge_p } {
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


set limit [parameter::get -parameter "number_of_items_shown"]

set top 0
set bottom 1073741824

set counter 0

db_multirow -extend {
    content
    diff
    source_url
    save_url
    unsave_url
    item_blog_url
    item_guid_link
    pub_date
} items items $items_query {
    if { $enable_purge_p } {
        # Top is the first item
        if { $item_id > $top } {
            set top $item_id
        }

        set purged_p 0
        # Handle purged items
        foreach purge $purges {
            if { $item_id <= [lindex $purge 0]
                 && $item_id >= [lindex $purge 1]
                 && $item_id ni $saved_items
             }  {
                set purged_p 1
            }
        }
        if { $purged_p } {
            continue
        }
    }

    if { [info exists content_encoded] && $content_encoded ne "" } {
        if { [info exists item_title] && $item_title ne "" } {
            set content "<a href=\"$item_link\">$item_title</a>. $content_encoded"
        } else {
            set content $content_encoded
        }
    } else {
        set text_only [util_remove_html_tags $item_description]

        if { [info exists item_title] && $item_title ne "" } {
            set content "<a href=\"$item_link\">$item_title</a>.                    <span class=\"item_author\">$item_author</span>
$item_description"
        } else {
            set content $item_description
        }
    }

    set item_guid_link [expr {$item_permalink_p ? $item_original_guid : $item_link}]

    set diff [news_aggregator::last_scanned \
                  -diff [expr {([clock seconds] - [clock scan $last_scanned]) / 60}]]
    set source_url [export_vars -base source {source_id}]

    set localtime [clock scan [lc_time_utc_to_local $item_pub_date] -gmt 1]
    set utctime [clock scan $item_pub_date -gmt 1]
    if { $utctime > [clock scan "1 week ago"] } {
        set pub_date [clock format $localtime -format "%a %H:%M"]
    } else {
        set pub_date [clock format $localtime -format "%m-%d %H:%M"]
    }

    if {$write_p} {
        if {$item_id ni $saved_items} {
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

set purge [expr {$enable_purge_p
                 && $top >= $bottom
                 && !$public_p
                 && $write_p}]
if {$purge} {
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
}

set purge_off_url ${return_url}/?purge_p=f
set purge_on_url ${return_url}/?purge_p=t

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
