ad_page_contract {
  The News Aggregator subscription page.

  @author Simon Carstensen (simon@bcuni.net)
  @creation-date Jan 2003
} {
    aggregator_id:integer
    new_source_id:integer,optional
    {source_id:integer,multiple ""}
    {feed_url ""}
    {orderby ""}
}

permission::require_permission \
    -object_id $aggregator_id \
    -privilege write

set page_title "Subscriptions"
set context [list $page_title]

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
    foreach delete_id $source_id {
        news_aggregator::subscription::delete \
            -source_id $delete_id \
            -aggregator_id $aggregator_id
    }
}

set aggregator_count [db_string count_aggregators {}]

set bulk_actions {
    Unsubscribe subscriptions Unsubscribe
}

if { $aggregator_count  > 1 } {
    # user has more than 1 aggregator, let's present our fancy move and copy features
    if { $aggregator_count > 2 } {
        set title "another aggregator"
    } else {
        set title [db_string select_name {}]
    }
    lappend bulk_actions \
        Copy subscription-copy "Copy selected subscriptions to $title" \
        Move subscription-move "Move selected subscriptions to $title"

}

list::create \
    -name sources \
    -multirow sources \
    -key source_id \
    -row_pretty_plural "subscriptions" \
    -actions {
       "Export Subscriptions" "opml" "Export your subscriptions as an OPML file"
       "Import Subscriptions" "opml-import" "Import your subscriptions from an OPML file"
    } -bulk_actions $bulk_actions -elements {
        title {
            label "Name"
            link_url_eval $link
        }
        last_scanned {
            label "Last Scan"
        }
	last_modified {
	    label "Last Update"
	}
        updates {
            label "Updates"
            html {align center}
        }
        feed_url {
            label "Source"
            display_template {
                <a href="@sources.feed_url@" title="View the XML 
                source for this subscriptions."
                ><img src="@sources.xml_graphics_url@" height="14" width="36" 
                alt="View the XML source for this subscription" border="0"></a>
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

db_multirow -extend {xml_graphics_url} sources sources {} {
    if { [exists_and_not_null new_source_id] && $source_id == $new_source_id } {
        set new_source_title $title
    }
    set xml_graphics_url "${package_url}graphics/xml.gif"
}

ad_form -name add_subscription -form {
    {subscription_id:integer(hidden),key}
    {feed_url:text(text) 
        {value $feed_url_val} 
        {label "URL:"} 
        {html {size 55}}
    }
    {add_submit:text(submit) 
        {label "Add"}
    }
} -validate {
    {feed_url
	{ [exists_and_not_null feed_url] && ![string equal "http://" $feed_url] } 
        { You must specify a URL }
    }
} -new_data {
    set new_source_id [news_aggregator::source::new \
                           -feed_url $feed_url \
                           -aggregator_id $aggregator_id \
                           -user_id $user_id \
                           -package_id $package_id]

 
    ad_returnredirect [export_vars -base subscriptions {new_source_id}]
    ad_script_abort
}
