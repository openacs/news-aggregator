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
} {
    @author Simon Carstensen

    Parse feed_url for link, title, and description. Then insert the source if it does not excist already.
} {

    set source_id [db_string source {} -default ""]

    if { [exists_and_not_null source_id] } {
        if { [exists_and_not_null aggregator_id] } {
            news_aggregator::subscription::new \
                -aggregator_id $aggregator_id \
                -source_id $source_id

            return $source_id
        }
        return 0
    }

    array set f [ad_httpget -url $feed_url -depth 4]

    if { ![string equal 200 $f(status)] || [catch { array set result [news_aggregator::parse -xml $f(page)] }] } {
        return 0
    }

    array set channel $result(channel)
    set title [string_truncate -len 500 -- $channel(title)]
    set link [string_truncate -len 500 -- $channel(link)]
    set description [string_truncate -len 500 -- $channel(description)]
    
    set source_id [db_nextval "acs_object_id_seq"]
    set creation_ip [ad_conn peeraddr]
    set last_modified $f(modified)
    
    db_exec_plsql add_source {}
    
    if { [exists_and_not_null aggregator_id] } {
        news_aggregator::subscription::new \
            -aggregator_id $aggregator_id \
            -source_id $source_id
    }

    set items $result(items)

    foreach array $items {
        array set item $array
        set title [string_truncate -len 500 -- $item(title)]
        set link [string_truncate -len 500 -- $item(link)]
        set guid [string_truncate -len 500 -- $item(guid)]
        set permalink_p $item(permalink_p)
        set description $item(description)
        set content_encoded $item(content_encoded)
    }

    return $source_id
}


ad_proc -public news_aggregator::source::get_identifier {
    {-guid:required}
    {-link:required}
    {-domain:required}
    {-description:required}
} {
    if { [exists_and_not_null guid] } {
        return guid
    } elseif { [exists_and_not_null link] && [news_aggregator::check_link \
                                                  -link $link \
                                                  -domain $domain] } {
        return link
    } elseif { [exists_and_not_null description]  } {
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
    ns_set put $headers "Referer" [ad_parameter "referer"]

    if { [catch { array set f [ad_httpget \
                                    -url $feed_url \
                                    -headers $headers] }] } {
        ns_log Debug "source::update: httpget failed"
        return
    }

    if { ![string equal 200 $f(status)] } {
	ns_log Debug "source::update: httpget didn't return 200 but $f(status)"
	return
    }

    if { [catch {
    		set parse_result [news_aggregator::parse \
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
        
        set guid [news_aggregator::source::generate_guid \
                        -link $item(link) \
                        -feed_url $feed_url \
                        -title $item(title) \
                        -description $item(description) \
                        -guid $item(guid)]
        
        if { [lsearch -exact $existing_guids $guid] == -1 } {
            set new_p 1
	    ns_log Debug "source::update: guid $guid marked as new"
        } else {
            set new_p 0
            set db_title [lindex $existing_items($guid) 0]
            set db_description [lindex $existing_items($guid) 1]

	    ns_log Debug "source::update: guid $guid marked as existing\ttitle = $db_title\tdescription = $db_description"
        }
        
        if { (!$new_p
          && (![string equal $db_title $title] ||
              ![string equal $db_description $description]))
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

#	    set title $item(title)
#	    set description $item(description)
#	    set content_encoded $item(content_encoded)
#	    set original_guid $item(guid)
#	    set permalink_p $item(permalink_p)
#	    set link $item(link)

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
    {-guid}
} {
    Generate a private GUID for an entry that is used only
    by news-aggregator.
} {
    if { ![exists_and_not_null guid] } {
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
                set limit [expr int($source_count/4)]
		if { $limit < 1 } {
		    set limit 1
		}
		set limit_sql [db_map sources_limit]
	    } else {
		set limit_sql ""
	    }
            set sources [db_list_of_lists sources ""]
            foreach source $sources {
                set source_id [lindex $source 0]
                set feed_url [lindex $source 1]
                set last_modified [lindex $source 2]
                
                news_aggregator::source::update \
                        -source_id $source_id \
                        -feed_url $feed_url \
                        -modified $last_modified
            }
        }
    }
}
