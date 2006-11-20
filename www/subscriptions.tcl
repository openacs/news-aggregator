ad_page_contract {
  The News Aggregator subscription page.

  @author Simon Carstensen (simon@bcuni.net)
  @creation-date Jan 2003
} {
    aggregator_id:integer
    {new_source_id:integer,optional ""}
    {source_id:integer,multiple ""}
    {feed_url ""}
    {orderby ""}
}

permission::require_permission \
    -object_id $aggregator_id \
    -privilege write

set page_title "[_ news-aggregator.Manage_Subscriptions]"
array set ag_info [news_aggregator::aggregator::aggregator_info -aggregator_id $aggregator_id]
set context [list [list "." "$ag_info(aggregator_name)"] "$page_title"]

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]

set opml_url "${package_url}opml/$aggregator_id/mySubscriptions.opml"

# This is done in case we want to implement some user interface
# stuff in the future where it might be useful.
if { [empty_string_p $feed_url] } {
    set feed_url_val ""
} else {
    set feed_url_val $feed_url
}
    
    #ad_returnredirect "[ad_conn package_url]opml/$aggregator_id/mySubscriptions.opml"
    #ad_script_abort

if { [exists_and_not_null source_id] } {
    set delete_count 0
    foreach delete_id $source_id {
        news_aggregator::subscription::delete \
            -source_id $delete_id \
            -aggregator_id $aggregator_id
	incr delete_count
    }
    if { $delete_count > 1 } {
	set message "[_ news-aggregator.You_have_been_unsubscribed_from]"
    } else {
	set message "[_ news-aggregator.You_have_been_unsubscribed]"
    }
    ad_returnredirect -message $message subscriptions
    ad_script_abort
}

# find aggregators user has write privs on
set aggregator_count 0
db_foreach count_aggregators {} {
    if { $write_p eq "t" } { incr aggregator_count }	
}

set bulk_actions {
    #news-aggregator.Unsubscribe# subscriptions #news-aggregator.Unsubscribe#
}

if { $aggregator_count > 1 } {
    # user has write privs on more than 1 aggregator, let's present our fancy move and copy features
    if { $aggregator_count > 2 } {
        set title "another aggregator"
    } else {
        set title [db_string select_name {}]
    }
    lappend bulk_actions \
        \#news-aggregator.Copy\# Copy subscription-copy "\#news-aggregator.Copy_Selected\#" \
        \#news-aggregator.Move\# subscription-move "\#news-aggregator.Move_Selected\#"

}

list::create \
    -name sources \
    -multirow sources \
    -key source_id \
    -row_pretty_plural "subscriptions" \
    -actions {
       "\#news-aggregator.Export_Subscriptions\#" "opml" "\#news-aggregator.Export_your_subscriptions_as_an_OPML_file\#"
    } -bulk_actions $bulk_actions -elements {
        title {
            label "\#news-aggregator.Name\#"
            link_url_eval $link
        }
        last_scanned {
            label "\#news-aggregator.Last_Scan\#"
        }
	last_modified {
	    label "\#news-aggregator.Last_Update\#"
	}
	show_description_p {
	    label "\#news-aggregator.Titles_Only\#"
	    display_template {
		<center><if @sources.show_description_p@ true>\#news-aggregator.No\#</if><else>\#news-aggregator.Yes\#</else> <a href="@sources.toggle_show_desc_url@" title="toggle" class="button">toggle</a></center>
	    }
	}
        feed_url {
            label "\#news-aggregator.Source\#"
            display_template {
                <a href="@sources.feed_url@" title="\#news-aggregator.View_the_XML\#"
                ><img src="@sources.xml_graphics_url@" height="14" width="36" 
                alt="\#news-aggregator.View_the_XML\#" border="0"></a>
            }
        }
    } -orderby {
        default_value title,asc
        title {
            label "Name"
            orderby_asc "lower(title) asc"
            orderby_desc "lower(title) desc"
        }
        last_scanned {
            label "Last Updated"
            orderby_desc "last_scanned desc"
            orderby_asc "last_scanned asc"
        }
	last_modified {
	    label "Last Update"
	    orderby_desc "last_modified_stamp desc"
	    orderby_asc "last_modified_stamp asc"
	}
        updates {
            label "Updates"
            orderby_asc "updates asc"
            orderby_desc "updates desc"
        }
    }

set package_url [ad_conn package_url]

db_multirow -extend { xml_graphics_url toggle_show_desc_url } sources sources {} {
    set xml_graphics_url "${package_url}graphics/xml.gif"
    set toggle_show_desc_url [export_vars -base toggle-show-description { aggregator_id source_id }]
}

set other_feeds [list [list "Select Feed" ""]]
db_foreach select_other_feeds {} {
    lappend other_feeds [list $title $source_id]
}

ad_form -name add_subscription -form {
    {subscription_id:integer(hidden),key}
    {aggregator_id:integer(hidden) {value $aggregator_id}}
    {feed_url:text(text),optional
        {value $feed_url_val} 
        {label "#news-aggregator.URL#"}
	{value "http://"}
        {html {size 55}}
    }
    {new_source_id:integer(select),optional
	{label "\#news-aggregator.Feed\#"}
	{options $other_feeds}
    }
    {add_submit:text(submit),optional
        {label "[_ news-aggregator.Add]"}
    }
} -validate {
    {feed_url
	{ ![string equal "http://" $feed_url] || ![string equal $new_source_id ""] } 
        { You must specify a URL or select a feed }
    }
} -new_data {
    if { [exists_and_not_null new_source_id] } {
	news_aggregator::subscription::new -aggregator_id $aggregator_id -source_id $new_source_id
	ad_returnredirect subscriptions
	ad_script_abort
    }
    set channel_array [news_aggregator::source::new \
                           -feed_url $feed_url \
                           -aggregator_id $aggregator_id \
                           -user_id $user_id \
			   -array]
    if { $channel_array eq "0" } {
        ad_returnredirect -message "The feed $feed_url has an error." subscriptions
        ad_script_abort
    }
    array set channel $channel_array
    set title $channel(title)
    ad_returnredirect -message "You have been subscribed to $title." subscriptions
    ad_script_abort
}
