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


ad_proc -deprecated -public news_aggregator::source::get_identifier {
    {-guid:required}
    {-link:required}
    {-domain:required}
    {-description:required}
} {
    Deprecated: this proc has no usage in current uptsream codebase.
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

    if { [catch {
        set response [util::http::get \
                          -url $feed_url \
                          -headers $headers]
    }] } {
        ns_log Debug "source::update: HTTP GET failed"
        return
    }

    set status [dict get $response status]

    if { $status != 200 } {
        ns_log Debug "source::update: httpget didn't return 200 but $status"
        return
    }

    if { [catch {
        set result [feed_parser::parse_feed -xml [dict get $response page]]
    } err] } {
        ns_log warning "source::update: parse failed, error = $err"
        return
    }

    set items [dict get $result items]

    if { [llength $items] == 0 } {
        # No items
        return
    }

    # First we assemble a list of arrays of:
    #       feed_url, guid
    # Then we fetch the guids that we want to deal with
    # Finally, we insert those.
    set guids [list]
    foreach item $items {
        lappend guids [news_aggregator::source::generate_guid \
                           -link        [dict get $item link] \
                           -feed_url    $feed_url \
                           -title       [dict get $item title] \
                           -description [dict get $item description] \
                           -guid        [dict get $item guid]]
    }

    set existing_items [dict create]
    set guids '[join $guids "', '"]'
    db_foreach items [subst {
        select  guid, i.title, i.description
        from    na_items i join
                na_sources s on (i.source_id = s.source_id)
        where   s.feed_url = :feed_url
        and     guid in ($guids)
    }] {
        dict set existing_items $guid [list $title $description]
        ns_log Debug "source::update: existing guid $guid\n\ttitle = $title"
    }

    ns_log Debug "source::update: existing_guids = [dict keys $existing_items]"

    set no_items 0
    set updated_p false
    foreach item $items {
        set title [string_truncate -len 500 -- [dict get $item title]]
        set link [string_truncate -len 500 -- [dict get $item link]]
        set original_guid [string_truncate -len 500 -- [dict get $item guid]]
        set permalink_p [dict get $item permalink_p]
        set content_encoded [dict get $item content_encoded]
        set description [dict get $item description]
        set author [dict get $item author]
        set pub_date [dict get $item pub_date]

        set guid [news_aggregator::source::generate_guid \
                      -link [dict get $item link] \
                      -feed_url $feed_url \
                      -title [dict get $item title] \
                      -description [dict get $item description] \
                      -guid [dict get $item guid]]

        set new_p [expr {![dict exists $existing_items $guid]}]
        if {$new_p} {
            ns_log Debug "source::update: guid $guid marked as new"
        } else {
            lassign [dict get $existing_items $guid] db_title db_description
            ns_log Debug "source::update: guid $guid marked as existing\ttitle = $db_title\tdescription = $db_description"
        }

        if { $new_p || $db_title ne $title || $db_description ne $description } {
            set updated_p true
            ns_log Debug "source::update: guid $guid marked as existing but updated; title=!$title! description=!$description!"
            if { !$new_p } {
                ns_log Debug "source::update:\tdb_title=!$db_title! db_description=!$db_description!"
                ns_log Debug "source::update:\tfirst_equal=[string equal $db_title $title] second_equal=[string equal $db_description $description] new_p=$new_p item_title=[string length $title] chars db_title=[string length $db_title] chars"
            } else {
                ns_log Debug "source::update: guid $guid is new and will be inserted; title=$title description=$description"
            }

            if { $pub_date ne "" } {
                set pub_date [clock format $pub_date -format "%Y-%m-%d %T UTC"]
            }

            db_exec_plsql add_item {}
            incr no_items
        } else {
            ns_log Debug "source::update: guid $guid marked as existing and not updated"
        }
    }

    set channel [dict get $result channel]
    set link        [dict get $channel link]
    set title       [dict get $channel title]
    set description [dict get $channel description]

    if { $updated_p } {
        db_dml update_source {
            update na_sources set
                link = :link,
                title = :title,
                description = :description,
                updates = (updates + 1),
                last_scanned = current_timestamp,
                last_modified = current_timestamp,
                last_modified_stamp = current_timestamp
            where source_id = :source_id
        }
    } else {
        db_dml update_source_no_new {
            update na_sources set
                last_scanned = current_timestamp,
	        title = :title,
	        link = :link,
	        description = :description
	     where source_id = :source_id
        }
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
    Delete a news source.
} {
    db_exec_plsql delete_source {}
}

ad_proc -public news_aggregator::source::update_all {
    -all_sources:boolean
} {
    @author Simon Carstensen (simon@bcuni.net)
    @author Guan Yang (guan@unicast.org)

    Update sources.

    @param all_sources Update every source. Normally this proc will
                       only update the 25% of the existing sources and
                       limit to those that were scanned earlier than
                       '48' minutes ago
} {
    ns_log Notice "Updating news aggregator sources"

    db_transaction {
        set source_count [db_string source_count {
            select count(*) from na_sources
        }]
        if { $source_count >= 1 } {
            if { !$all_sources_p } {
                set limit [expr {max(1, int($source_count/4))}]
                set limit_sql [db_map sources_limit]
            } else {
                set limit_sql ""
            }

            foreach source [db_list_of_lists sources [subst {
                select source_id,
                       feed_url,
                       last_modified
                 from na_sources
                where :all_sources_p or
                      last_scanned < (current_timestamp - interval '48 minutes')
             order by last_scanned asc
                $limit_sql
            }]] {
                lassign $source source_id feed_url last_modified
                news_aggregator::source::update \
                        -source_id $source_id \
                        -feed_url $feed_url \
                        -modified $last_modified
            }
        }
    }
}
