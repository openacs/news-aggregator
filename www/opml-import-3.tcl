ad_page_contract {
    Import the final OPML urls.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-08-23
    @cvs-id $Id$
} {
    aggregator_id:naturalnum,notnull
    url:multiple,notnull
}

set package_id [ad_conn package_id]
set user_id [ad_maybe_redirect_for_registration]
permission::require_permission \
    -object_id $aggregator_id \
    -party_id $user_id \
    -privilege write

catch {
    foreach feed_url $url {
	set source_id [news_aggregator::source::new \
			   -feed_url $feed_url \
			   -user_id $user_id \
			   -package_id $package_id \
			   -aggregator_id $aggregator_id]
			
	if { $source_id } {
	    news_aggregator::subscription::new \
		-aggregator_id $aggregator_id \
		-source_id $source_id
	}
    }
}

ad_returnredirect subscriptions