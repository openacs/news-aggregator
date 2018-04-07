ad_page_contract {
  Move subscription from one aggregator to another.

  @author Simon Carstensen (simon@bcuni.net)
  @creation-date 2003-08-23
} {
    aggregator_id:integer
    {source_id:integer,multiple ""}
    {source_ids ""}
    {move_to:integer ""}
}

permission::require_permission \
    -object_id $aggregator_id \
    -privilege write

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]

if { $move_to ne "" } {

    foreach source_id $source_ids {
        news_aggregator::subscription::move \
            -source_id $source_id \
            -move_from $aggregator_id \
            -move_to $move_to
    }

    ad_returnredirect "${package_url}$move_to/subscriptions"
    ad_script_abort
}

set aggregator_count [db_string count_aggregators {}]

if {$aggregator_count eq "2"} {
    set move_to [db_string select_aggregator_id {}]

    foreach source $source_id {
        news_aggregator::subscription::move \
            -source_id $source \
            -move_from $aggregator_id \
            -move_to $move_to
    }

    ad_returnredirect "${package_url}$move_to/subscriptions"
    ad_script_abort
}

set page_title "Move subscription"
set context [list $page_title]

set package_id [ad_conn package_id]
set list_of_aggregators [db_list_of_lists select_aggregators {}]

ad_form -name move_subscription -form {
    {aggregator_id:integer(hidden)
        {value $aggregator_id}
    }
    {source_ids:integer(hidden)
        {value $source_id}
    }
    {move_to:integer(select)
        {label "Move to:"}
        {value $move_to}
        {options $list_of_aggregators}
    }
}
