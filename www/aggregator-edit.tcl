ad_page_contract {
    Include to create a new aggregator.

    @author Simon Carstensen
    @cvs-id $Id$
} {
    aggregator_id:integer,notnull
    {return_url ""}
}

set page_title "Edit Aggregator Info"
array set ag_info [news_aggregator::aggregator::aggregator_info -aggregator_id $aggregator_id]
set context [list [list "." "$ag_info(aggregator_name)"] "$page_title"]

