ad_page_contract {
	Effect a purge.

	@author Guan Yang (guan@unicast.org)
	@creation-date 2003-07-07
} {
	aggregator_id:naturalnum,notnull
	purge_top:naturalnum,notnull
	purge_bottom:naturalnum,notnull
}

set user_id [ad_maybe_redirect_for_registration]

db_1row aggregator_info ""

permission::require_permission \
	-party_id $user_id \
	-object_id $aggregator_id \
	-privilege write

if { $public_p == "f" } {
    # Only purge if the aggregator is not public
    news_aggregator::aggregator::purge \
	-aggregator_id $aggregator_id \
	-top $purge_top \
	-bottom $purge_bottom
}

ad_returnredirect "[ad_conn package_url]$aggregator_id"
