ad_page_contract {
    Settings.

    @author Simon Carstensen
    @creation-date 2003-07-01
} {
    aggregator_id:integer,optional
}

set page_title "Your Settings"
set context [list $page_title]

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]

set aggregator_options [news_aggregator::aggregator::options -user_id $user_id]
set default_aggregator_id [news_aggregator::aggregator::user_default -user_id $user_id]

ad_form -name aggregators -form {
    {default_aggregator_id:integer(select)
        {options $aggregator_options}
        {value $default_aggregator_id}
    }
    {submit:text(submit)
        {label "Go"}
    }
} -on_submit {
    news_aggregator::aggregator::set_user_default \
        -user_id $user_id \
        -aggregator_id $default_aggregator_id

    ad_returnredirect settings
    ad_script_abort   
}

set return_url settings
set aggregator_link [export_vars -base "${package_url}aggregator" {return_url}]

template::list::create \
    -name "aggregators" \
    -multirow "aggregators" \
    -key aggregator_id \
    -row_pretty_plural "aggregators" \
    -elements {
        edit {
            label {}
            display_template {
                <a href="@aggregators.edit_url@" title="Edit this aggregator"
                ><img src="@aggregators.url@graphics/edit.gif" height="16" width="16" 
                alt="Edit this aggregator" border="0"></a>
            }
        }            
        aggregator_name {
            label "Name"
            display_template {
                <a href="@aggregators.url@@aggregators.aggregator_id@/" title="View this aggregator"
                >@aggregators.aggregator_name@</a>
                <if @aggregators.default_p;literal@ true>
                (default)
                </if>        
            }
            link_url_eval {}
            link_html { title "" }
        }
        public_p {
            label "Public?"
        }
        delete {
            label {}
            display_template {
                <a href="@aggregators.delete_url@" onclick="@aggregators.delete_onclick@" title="Delete this aggregator"
                ><img src="@aggregators.url@graphics/delete.gif" height="16" width="16" 
                alt="Delete this aggregator" border="0"></a>
            }
        }
    }

db_multirow -extend { 
    url 
    edit_url 
    delete_url 
    delete_onclick 
    default_p
} aggregators select_aggregators {} {
    if {$public_p == "t"} {
        set public_p "Yes"
    } else {
        set public_p "No"
    }

    set url $package_url
    set edit_url [export_vars -base "${url}aggregator" {aggregator_id}]
    set delete_url [export_vars -base aggregator-delete {{delete_aggregator_id $aggregator_id}}]
    set delete_onclick "return confirm('Are you sure you want to delete this news aggregator?');"

    if {$aggregator_id eq $default_aggregator} {
        set default_p 1
    } else {
        set default_p 0
    }
}

template::list::create \
    -name "weblogs" \
    -multirow "weblogs" \
    -key weblog_id \
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
