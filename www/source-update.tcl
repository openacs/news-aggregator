#packages/news-aggregator/index.tcl
ad_page_contract {
    Update a source.

    @author Simon Carstensen simon@bcuni.net
    @creation-date May 2004
} {
    user_id
    source_id
    feed_url
    last_scanned
}

na_update_source $user_id $source_id $feed_url $last_scanned

ad_returnredirect "."
ad_script_abort
