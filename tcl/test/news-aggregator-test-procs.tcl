ad_library {

    News aggregator tests

}

aa_register_case -cats {
    smoke
    production_safe
} -procs {
    util::http::get
    feed_parser::parse_feed
    feed_parser::test::parse_feed
} source_feeds_ok {
    Check that all source feeds currently configured keep being valid
    and parseable
} {
    set feed_urls [db_list get_feeds {
        select feed_url from na_sources
    }]

    foreach feed_url $feed_urls {
        set get_failed_p [catch {
            set response [util::http::get -url $feed_url]
        } errmsg]
        aa_false "HTTP call to $feed_url succeeds." $get_failed_p
        if {$get_failed_p} {
            aa_error "Error was: $errmsg"
            continue
        }

        set status [dict get $response status]
        aa_equals "HTTP call to $feed_url answers 200" $status 200
        if { $status != 200 } {
            aa_error "Status was: $status"
            continue
        }

        set test [feed_parser::test::parse_feed -xml [dict get $response page]]
    }
}

aa_register_case -cats {
    smoke
} -procs {
    news_aggregator::source::update
} sources_update_ok {
    Check that updating news sources works. In particular expose what
    happens in case an existing news item is updated or deleted.
} {
    aa_run_with_teardown \
        -rollback \
        -test_code {

            # Just test 3 sources
            db_foreach get_sources {
                select source_id, feed_url
                from na_sources
                fetch first 3 rows only
            } {
                aa_log "Removing all news items"
                db_dml delete_items {delete from na_items where source_id = :source_id}

                aa_false "Fetching source ${feed_url} works" [catch {
                    news_aggregator::source::update -source_id $source_id \
                        -feed_url $feed_url -modified 1900-01-01
                }]

                set a_news_id [db_string get_news_item {
                    select max(item_id) from na_items
                    where source_id = :source_id
                } -default 0]
                if {$a_news_id == 0} {
                    aa_log "No news updated for this source"
                    continue
                }

                db_1row get_news_data {
                    select guid,
                           title as orig_title,
                           description as orig_description,
                           link as orig_link
                    from na_items
                    where item_id = :a_news_id
                }

                aa_log "Storing bogus data in a random news item"
                set bogus_data "AAAAA"
                db_dml update_news_data {
                    update na_items set
                    title = :bogus_data,
                    description = :bogus_data,
                    link = :bogus_data
                    where item_id = :a_news_id
                }

                aa_false "Updating source ${feed_url} works" [catch {
                    news_aggregator::source::update -source_id $source_id \
                        -feed_url $feed_url -modified 1900-01-01
                }]

                db_1row get_news_data {
                    select guid,
                           title,
                           description,
                           link
                    from na_items
                    where item_id = :a_news_id
                }

                foreach att {title description link} {
                    aa_equals "'$att' was updated correctly" [set orig_${att}] [set $att]
                }

                aa_log "Deleting item"
                db_dml delete_item {
                    delete from na_items
                    where item_id = :a_news_id
                }

                aa_false "Updating source ${feed_url} works" [catch {
                    news_aggregator::source::update -source_id $source_id \
                        -feed_url $feed_url -modified 1900-01-01
                }]

                aa_true "Deleted item was fetched again from source" [db_0or1row lookup {
                    select 1 from na_items where guid = :guid and source_id = :source_id
                }]
            }
        }
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
