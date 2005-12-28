ad_page_contract {
    Settings.

    @author Simon Carstensen
    @creation-date 2003-07-01
} {
    aggregator_id:integer,optional
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set instance_name [apm_instance_name_from_id $package_id]
set page_title "$instance_name Settings"
set default_aggregator_id [news_aggregator::aggregator::user_default -user_id $user_id -package_id $package_id]

# Check to make sure the aggregator exists (user may have deleted and redirected)
if { [exists_and_not_null aggregator_id] && [db_string aggregator_exists {} -default 0] } {
    array set ag_info [news_aggregator::aggregator::aggregator_info -aggregator_id $aggregator_id]    
    set context [list [list "." $ag_info(aggregator_name)] "$page_title"]
} else {
    set context [list $page_title]
}

set return_url settings
set aggregator_link [export_vars -base "${package_url}aggregator-add" {return_url}]

template::list::create \
    -name "aggregators" \
    -multirow "aggregators" \
    -key aggregator_id \
    -no_data "There are no aggregators in the system yet." \
    -row_pretty_plural "aggregators" \
    -elements {
        edit {
            label {}
            display_template {
                <if @aggregators.write_p@><a href="@aggregators.edit_url@" title="Edit this aggregator"
                ><img src="@aggregators.url@graphics/edit.gif" height="16" width="16" 
                alt="Edit this aggregator" border="0"></a></if>
            }
        }            
        aggregator_name {
            label "Aggregator Name"
            display_template {
                <a href="@aggregators.url@@aggregators.aggregator_id@/" title="View this aggregator"
                >@aggregators.aggregator_name@</a>
            }
            link_url_eval {}
            link_html { title "" }
        }
        public_p {
            label "Public?"
        }
        default_p {
            display_template {
                <if @aggregators.default_p@>default</if><else><a href="@aggregators.set_default_url@">set as default</a></else>
            }
        }
        delete {
            label {}
            display_template {
                <if @aggregators.write_p@><a href="@aggregators.delete_url@" onclick="@aggregators.delete_onclick@" title="Delete this aggregator"
                ><img src="@aggregators.url@graphics/delete.gif" height="16" width="16" 
                alt="Delete this aggregator" border="0"></a></if>
            }
        }
    }

db_multirow -extend { 
    url 
    edit_url 
    delete_url 
    delete_onclick 
    default_p
    set_default_url
} aggregators select_aggregators {} {
    if { [string equal $public_p t] } {
        set public_p "Yes"
    } else {
        set public_p "No"
    }

    set url $package_url
    set edit_url "${url}${aggregator_id}/manage?tab=general"
    set delete_url [export_vars -base aggregator-delete {{delete_aggregator_id $aggregator_id}}]
    set delete_onclick "return confirm('Are you sure you want to delete this news aggregator?');"

    if { [string equal $aggregator_id $default_aggregator_id] } {
        set default_p 1
    } else {
        set default_p 0
	set set_default_url [export_vars -base set-default {user_id aggregator_id}]
    }
}

template::list::create \
    -name "weblogs" \
    -multirow "weblogs" \
    -key weblog_id \
    -no_data "No weblogs have been added yet." \
    -row_pretty_plural "weblogs" \
    -elements {
        edit {
            label {}
            display_template {
                <a href="@weblogs.edit_url@" title="Edit this weblog"
                ><img src="@weblogs.url@graphics/edit.gif" height="16" width="16" 
                alt="Edit this weblog" border="0"></a>
            }
        }            
        weblog_name {
            label "Name"
        }
        delete {
            label {}
            display_template {
                <a href="@weblogs.delete_url@" onclick="@weblogs.delete_onclick@" title="Delete this weblog"
                ><img src="@weblogs.url@graphics/delete.gif" height="16" width="16" 
                alt="Delete this weblog" border="0"></a>
            }
        }
    }

db_multirow -extend { url edit_url delete_url delete_onclick } weblogs select_weblogs {
    select weblog_id,
           weblog_name
    from   na_weblogs
    where  user_id = :user_id
    order  by server
} {
    set url $package_url
    set edit_url [export_vars -base "${url}weblog" {weblog_id}]
    set delete_url [export_vars -base weblog-delete {weblog_id}]
    set delete_onclick "return confirm('Are you sure you want to delete this weblog?');"
}
