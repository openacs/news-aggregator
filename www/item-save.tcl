ad_page_contract {
    Save an item.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-07
} {
    item_id:naturalnum,notnull
    aggregator_id:naturalnum,notnull
}

set user_id [ad_maybe_redirect_for_registration]

db_1row aggregator_info ""

permission::require_permission \
	-party_id $user_id \
	-object_id $aggregator_id \
	-privilege write

catch { db_dml save_item "" } errmsg

ad_returnredirect "[ad_conn package_url]$aggregator_id/\#$item_id"
