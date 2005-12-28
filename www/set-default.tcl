ad_page_contract {
    Set default aggregator

    @creation-date 2005-12-27
} {
    aggregator_id:integer,notnull
    user_id:integer,notnull
}

news_aggregator::aggregator::set_user_default -user_id $user_id \
    -package_id [ad_conn package_id] -aggregator_id $aggregator_id
ad_returnredirect ./settings