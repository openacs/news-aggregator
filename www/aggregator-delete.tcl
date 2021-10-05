ad_page_contract {
    Delete an aggregator

    @author Simon Carstensen
} {
    delete_aggregator_id:integer
}

permission::require_permission \
    -object_id $delete_aggregator_id \
    -privilege write

set user_id [ad_conn user_id]
set default_aggregator [db_string find_default {
    select default_aggregator
    from   na_user_preferences
    where  user_id = :user_id
}]

if {$delete_aggregator_id eq $default_aggregator} {
    # We are deleting the user's default aggregator
    # Set user's oldest aggregator as new default
    set new_default_aggregator [db_string select_oldest_aggregator {
        select min(aggregator_id)
        from   na_aggregators a,
               acs_objects o
        where  a.aggregator_id = o.object_id
        and    creation_user = :user_id
        and    aggregator_id != :delete_aggregator_id
        order  by creation_date
    } -default ""]
    if { $new_default_aggregator ne "" } {
        news_aggregator::aggregator::set_user_default \
            -user_id $user_id \
            -aggregator_id $new_default_aggregator
    }
}

news_aggregator::aggregator::delete \
    -aggregator_id $delete_aggregator_id

ad_returnredirect [ad_conn package_url]settings
