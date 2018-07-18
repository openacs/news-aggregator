ad_page_contract {
    Export aggregator as OPML.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-10
} {
    {aggregator_id:naturalnum,notnull}
}

if {[catch {
    set opml [news_aggregator::aggregator::as_opml \
                  -aggregator_id $aggregator_id]
} errmsg]} {
    ad_return_error "OPML generation error" "OPML generation error: $errmsg"
    ad_script_abort
}

ns_return 200 application/xml $opml
ad_script_abort
