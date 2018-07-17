ad_library {
    Procs to manage sources.

    @author Simon Carstensen (simon@bcuni.net)
    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-06-28
}

namespace eval news_aggregator {}
namespace eval news_aggregator::source {}

ad_proc -public news_aggregator::source::new {
    -feed_url:required
    -user_id:required
    -package_id:required
    {-aggregator_id ""}
    -array:boolean
} {
    @author Simon Carstensen

    Parse feed_url for link, title, and description. Then insert the
    source if it does not exist already. Subscribe the specified
    aggregator to the source.

    @param array Return more into in array get or dict format
} {
    # aggregator_id is de-facto mandatory, but cannot be made required
    # atm, as this proc's contract was not defined in this way
    # originally.
    if { $aggregator_id eq "" } {
        ns_log Debug "news_aggregator::source::new: No aggregator provided, returning 0"
        return 0
    }

    if {[db_0or1row source {
        select source_id,
               title as channel_title
          from na_sources
         where feed_url = :feed_url
    }]} {
        ns_log Debug "news_aggregator::source::new: Source exists"
    } else {
        ns_log Debug "news_aggregator::source::new: Creating new source"
        set response [util::http::get -url $feed_url -max_depth 4]
        set status [dict get $response status]
        set page   [dict get $response page]

        if { $status != 200 ||
             [catch { set result [feed_parser::parse_feed -xml $page] }] } {
            ns_log Debug "news_aggregator::source::new: Couldn't httpget, status = $status"
            return 0
        }
        ns_log Debug "news_aggregator::source::new: HTTP GET successful, [string length $page] bytes"

        set channel [dict get $result channel]
        set channel_title [string_truncate -len 500 -- [dict get $channel title]]
        set link          [string_truncate -len 500 -- [dict get $channel link]]
        set description   [string_truncate -len 500 -- [dict get $channel description]]

        set creation_ip [ad_conn peeraddr]
        set last_modified [dict get $response modified]

        set source_id [db_exec_plsql add_source {}]

        update -source_id $source_id -feed_url $feed_url -modified ""
    }

    ns_log Debug "news_aggregator::source::new: Creating new subscription"
    news_aggregator::subscription::new \
        -aggregator_id $aggregator_id \
        -source_id $source_id

    if { $array_p } {
        ns_log Debug "news_aggregator::source::new: New subscription created, returning array"
        return [list source_id $source_id \
                     title     $channel_title]
    } else {
        ns_log Debug "news_aggregator::source::new: New subscription created, returning source_id"
        return $source_id
    }
}


ad_proc -public news_aggregator::source::get_identifier {
    {-guid:required}
    {-link:required}
    {-domain:required}
    {-description:required}
} {
    if { $guid ne "" } {
        return guid
    } elseif { $link ne ""
            && [news_aggregator::check_link \
                -link $link \
                -domain $domain] } {
        return link
    } elseif { $description ne "" } {
        return description
    }
}

ad_proc -public news_aggregator::source::update {
    {-source_id:required}
    {-feed_url:required}
    {-modified:required}
} {
    Parse source and then update the source if it has changed.

    @author Simon Carstensen
    @author Guan Yang (guan@unicast.org)
} {
    ns_log Debug "source::update: updating $feed_url (source_id=$source_id)"

    set headers [ns_set create]
    ns_set put $headers "If-Modified-Since" $modified
    ns_set put $headers "Referer" [parameter::get -parameter "referer"]

    if { [catch { array set f [ad_httpget \
                                    -url $feed_url \
                                    -headers $headers] }] } {
        ns_log Debug "source::update: httpget failed"
        return
    }

    if { "200" ne $f(status) } {
        ns_log Debug "source::update: httpget didn't return 200 but $f(status)"
        return
    }

    if { [catch {
        set parse_result [feed_parser::parse_feed \
            -xml $f(page)]
        array set result $parse_result
    } err] } {
        ns_log Debug "source::update: parse failed, error = $err"
        return
    }

    array set channel $result(channel)
    set items $result(items)

    set no_items 0
    set updated_p 0
    set guid_list [list]

    if { [llength $items] == 0 } {
        # No items
        return
    }

    # First we assemble a list of arrays of:
    #       feed_url, guid
    # Then we fetch the guids that we want to deal with
    # Finally, we insert those.
    foreach array $items {
        array set item $array
        set guid [news_aggregator::source::generate_guid \
                        -link $item(link) \
                        -feed_url $feed_url \
                        -title $item(title) \
                        -description $item(description) \
                        -guid $item(guid)]

        lappend guid_list "'$guid'"
    }

    set guids [join $guid_list ", "]
    set existing_guids [list]

    db_foreach items "" {
        lappend existing_guids $guid
        set existing_items($guid) [list $title $description]
        ns_log Debug "source::update: existing guid $guid\n\ttitle = $title"
    }

    ns_log Debug "source::update: existing_guids = $existing_guids"

    foreach array $items {
        array set item $array

        set title [string_truncate -len 500 -- $item(title)]
        set link [string_truncate -len 500 -- $item(link)]
        set original_guid [string_truncate -len 500 -- $item(guid)]
        set permalink_p $item(permalink_p)
        set content_encoded $item(content_encoded)
        set description $item(description)
        set author $item(author)
        set pub_date $item(pub_date)

        set guid [news_aggregator::source::generate_guid \
                        -link $item(link) \
                        -feed_url $feed_url \
                        -title $item(title) \
                        -description $item(description) \
                        -guid $item(guid)]

        if {$guid ni $existing_guids} {
            set new_p 1
            ns_log Debug "source::update: guid $guid marked as new"
        } else {
            set new_p 0
            lassign $existing_items($guid) db_title db_description

            ns_log Debug "source::update: guid $guid marked as existing\ttitle = $db_title\tdescription = $db_description"
        }

        if { (!$new_p
          && ($db_title ne $title ||
              $db_description ne $description ))
                        ||
                    $new_p } {
            set updated_p 1
            ns_log Debug "source::update: guid $guid marked as existing but updated; title=!$title! description=!$description!"
            if { [info exists db_title] && [info exists db_description] } {
                ns_log Debug "source::update:\tdb_title=!$db_title! db_description=!$db_description!"
                ns_log Debug "source::update:\tfirst_equal=[string equal $db_title $title] second_equal=[string equal $db_description $description] new_p=$new_p item_title=[string length $title] chars db_title=[string length $db_title] chars"
            } elseif { $new_p } {
                ns_log Debug "source::update: guid $guid is new and will be inserted; title=$title description=$description"
            }

            # set title $item(title)
            # set description $item(description)
            # set content_encoded $item(content_encoded)
            # set original_guid $item(guid)
            # set permalink_p $item(permalink_p)
            # set link $item(link)

            # pub_date_sql
            if { $pub_date eq "" } {
                set pub_date_sql "now()"
            } else {
                # message pub_date
                set pub_date [clock format $pub_date -format "%Y-%m-%d %T UTC"]
                set pub_date_sql ":pub_date"
            }

            db_exec_plsql add_item {}
            incr no_items
        } else {
            ns_log Debug "source::update: guid $guid marked as existing and not updated"
        }
    }

    set link $channel(link)
    set title $channel(title)
    set description $channel(description)
    if { $updated_p } {
        db_dml update_source ""
    } else {
        db_dml update_source_no_new ""
    }
}

ad_proc -private news_aggregator::source::generate_guid {
    {-link:required}
    {-feed_url:required}
    {-title:required}
    {-description:required}
    {-guid ""}
} {
    Generate a private GUID for an entry that is used only
    by news-aggregator.
} {
    if { $guid eq "" } {
        set message [list $title $link $description]
        set guid [ns_sha1 $message]
    }

    return "$guid@$feed_url"
}

ad_proc -public news_aggregator::source::delete {
    {-source_id:required}
} {
    db_exec_plsql delete_source {}
}

ad_proc -public news_aggregator::source::update_all {
    -all_sources:boolean
} {
    @author Simon Carstensen (simon@bcuni.net)
    @author Guan Yang (guan@unicast.org)

    Update sources by a one hour interval.

    @param all_sources Update every source. Normally this proc
    will only update the 25% of the existing sources.
} {
    ns_log Notice "Updating news aggregator sources"

    ds_comment "test"
    db_transaction {
        set source_count [db_string source_count ""]
        if { $source_count >= 1 } {
            if { !$all_sources_p } {
                set limit [expr {int($source_count/4)}]
                if { $limit < 1 } {
                    set limit 1
                }
                set limit_sql [db_map sources_limit]
            } else {
                set limit_sql ""
            }

            if { !$all_sources_p } {
                set time_limit [db_map time_limit]
            } else {
                set time_limit {}
            }

            set sources [db_list_of_lists sources ""]
            foreach source $sources {
                lassign $source source_id feed_url last_modified

                news_aggregator::source::update \
                        -source_id $source_id \
                        -feed_url $feed_url \
                        -modified $last_modified
            }
        }
    }
}
