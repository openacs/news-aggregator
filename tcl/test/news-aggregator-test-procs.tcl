ad_library {

    News aggregator tests

}

aa_register_case -cats {
    smoke
} -procs {
    util::http::get
    feed_parser::parse_feed
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


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
