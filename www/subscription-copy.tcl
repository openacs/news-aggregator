ad_page_contract {
  Copy subscription from one aggregator to another.

  @author Simon Carstensen (simon@bcuni.net)
  @creation-date 2003-08-23
} {
    aggregator_id:integer
    {source_id:integer,multiple ""}
    {source_ids ""}
    {copy_to:integer ""}
}

permission::require_permission \
    -object_id $aggregator_id \
    -privilege write

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]

if { [exists_and_not_null copy_to] } {

    foreach source_id $source_ids {
        news_aggregator::subscription::copy \
            -source_id $source_id \
            -copy_to $copy_to
    }

    ad_returnredirect "${package_url}$copy_to/subscriptions"
    ad_script_abort
}

set aggregator_count [db_string count_aggregators {}]

if { [string equal $aggregator_count "2"] } {
    set copy_to [db_string select_aggregator_id {}]

    foreach source $source_id {
        news_aggregator::subscription::copy \
            -source_id $source \
            -copy_from $aggregator_id \
            -copy_to $copy_to
    }

    ad_returnredirect "${package_url}$copy_to/subscriptions"
    ad_script_abort
}

set page_title "Copy subscription"
set context [list $page_title]

set package_id [ad_conn package_id]
set list_of_aggregators [db_list_of_lists select_aggregators {}]

ad_form -name copy_subscription -form {
    {aggregator_id:integer(hidden)
        {value $aggregator_id}
    }
    {source_ids:integer(hidden)
        {value $source_id}
    }
    {copy_to:integer(select)
        {label "Copy to:"}
        {value $copy_to}
        {options $list_of_aggregators}
    }
}
