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
set package_id [ad_conn package_id]
set default_aggregator [news_aggregator::aggregator::user_default -user_id $user_id \
			    -package_id $package_id]

if { [string equal $delete_aggregator_id $default_aggregator] } {
    # We are deleting the user's default aggregator
    # Set user's oldest aggregator as new default
    set new_default_aggregator [db_string select_oldest_aggregator {} -default ""]
    if { [exists_and_not_null new_default_aggregator] } {
        news_aggregator::aggregator::set_user_default \
            -user_id $user_id \
	    -package_id $package_id \
            -aggregator_id $new_default_aggregator
    }
}

news_aggregator::aggregator::delete \
    -aggregator_id $delete_aggregator_id

ad_returnredirect ./settings
