ad_library {
     Procs used by the News Aggregator module.
     @author Simon Carstensen (simon@bcuni.net)
     @creation-date January 2003
}

ad_proc -public util_httpget_full {
    url {headers ""} {timeout 30} {depth 0}
} {
    Just like ns_httpget, but first optional argument is an ns_set of
    headers to send during the fetch.
} {
    if {[incr depth] > 10} {
        return -code error "util_httpget:  Recursive redirection:  $url"
    }
    ns_log Debug "Getting {$url} {$headers} {$timeout} {$depth}"
    set http [ns_httpopen GET $url $headers $timeout]
    set rfd [lindex $http 0]
    close [lindex $http 1]
    set headers [lindex $http 2]
    set response [ns_set name $headers]
    set status [lindex $response 1]
    set last_modified [ns_set iget $headers last-modified]
    if {$status == 302} {
        set location [ns_set iget $headers location]
        if {$location != ""} {
            ns_set free $headers
            close $rfd
            return [util_httpget_full $location {} $timeout $depth]
        }
    } elseif { $status == 304 } {
        # The requested variant has not been modified since the time specified
        # A conditional get didn't return anything.
        ns_set free $headers
        close $rfd
        return [list "" $status]
    }
    set length [ns_set iget $headers content-length]
    if [string match "" $length] {set length -1}
    set err [catch {
        while 1 {
            set buf [_ns_http_read $timeout $rfd $length]
            append page $buf
            if [string match "" $buf] break
            if {$length > 0} {
                incr length -[string length $buf]
                if {$length <= 0} break
            }
        }
    } errMsg]
        ns_set free $headers
        close $rfd
        if $err {
            global errorInfo
            return -code error -errorinfo $errorInfo $errMsg
        }
        return [list $page $status $last_modified]
    }

ad_proc -public na_check_link {
    domain
    link
} {
    regexp {(https?://[^/]+)+} $domain domain
    regexp {(https?://[^/]+)+} $link link
    return [string equal $link $domain]
}

ad_proc -public na_last_scanned {
    diff
} {
    if {$diff < 120 && $diff > 60} {
        set to_return "1 hour and "
    } elseif {$diff >= 60} {
        set to_return "[expr $diff / 60] hours and "
    }
    set mins [expr $diff % 60]
    if {[string equal 1 $mins]} {
        append to_return "1 minute ago"
    } else {
        append to_return "$mins minutes ago"
    }
    return $to_return
}

ad_proc -public na_get_nodes {
    nodes
} {
    foreach node_id $nodes {
        switch -- [xml_node_get_name $node_id] {
            title {
                catch {set title [xml_node_get_content $node_id]}
            }
            "link" {
                catch {set link [xml_node_get_content $node_id]}
            }
            "guid" {
                catch {set guid [xml_node_get_content $node_id]}
            }
            "description" {
                catch {set description [xml_node_get_content $node_id]}
            }
        }
    }

    if { ![exists_and_not_null title] } {
        set title ""
    }
    if { ![exists_and_not_null link] } {
        if { [exists_and_not_null guid] } {
            set link $guid
        } else {
            set link ""
        }
    }
    if { ![exists_and_not_null description] } {
        set description ""
    }
        
    return [list $title $link $description]
}

ad_proc -public na_sort_result {
    result
} {
    set sorted [list]
    for {set i 0} {$i < [llength $result]} {incr i} {
        lappend sorted [lindex $result end-$i]
    }
    return $sorted
}

ad_proc -public na_get_elements {
     nodes
     match
 } {
     set matches [list]
     foreach node_id $nodes {
         if { [string equal $match [xml_node_get_name $node_id]] } {
             lappend matches $node_id
         } else {
             #set children [ns_xml node children $node_id]
             set children [xml_node_get_children $node_id]
             if { [llength $children] > 0 } {
                 set matches [concat $matches [na_get_elements $children $match]]
             }
         }
     }
     return $matches
}

ad_proc -public na_parse {
    xml
} {
    if { [catch {
        set doc_id [xml_parse -persist $xml]
        set nodes [xml_node_get_children [xml_doc_get_first_node $doc_id]]
        set channel [na_get_elements $nodes "channel"]
        set result [list [na_get_nodes [xml_node_get_children $channel]]]

        set items [na_get_elements $nodes "item"]
        set items_sorted [na_sort_result $items]
        foreach item $items_sorted {
            lappend result [na_get_nodes [xml_node_get_children $item]]
        }
        

    } err] } {
        ns_log Notice "Error parsing RSS feed: $err"
        return 0
    } else {
        return $result
    }
}

ad_proc -public na_add_source {
    feed_url
    owner_id
    package_id
    source_id
} {
    Parse $feed_url for host_url, title, and description. Then add the source.
} {
    if { ![catch {set f [util_httpget_full $feed_url]}] && [string equal 200 [lindex $f 1]] } {
        set result [na_parse [lindex $f 0]]
        if { ![string equal 0 $result] } {

            set channel [lindex $result 0]
            set title [string_truncate -len 245 -- [lindex $channel 0]]
            set link [string_truncate -len 245 -- [lindex $channel 1]]
            set description [string_truncate -len 245 -- [lindex $channel 2]]
            set source_id [db_nextval "acs_object_id_seq"]
            set creation_ip [ns_conn peeraddr]
            set last_modified [lindex $f 2]
        
            # check whether the source already exists
            if { ![db_0or1row source { *SQL* }] } {
                db_exec_plsql add_source { *SQL* }
                set items [lrange $result 1 end]
                foreach item $items {
                    set title [string_truncate -len 245 -- [lindex $item 0]]
                    set link [string_truncate -len 245  -- [lindex $item 1]]
                    set description [lindex $item 2]
                    db_exec_plsql add_item { *SQL* }
                }
            }
        }
    }
}

ad_proc -public na_update_source {
    owner_id
    source_id
    feed_url
    last_modified
} {
    Parse source and then update the source if it has changed.
} {
    set header [ns_set create]
    ns_set put $header "If-Modified-Since" $last_modified

    if { [catch { 
        set f [util_httpget_full $feed_url $header] }]
    } {
        return
    }
    # check the http status code
    if { [exists_and_not_null f] && [string equal 200 [lindex $f 1]] } {

        set result [na_parse [lindex $f 0]]
        set host [lindex [lindex $result 0] 1]
        set items [lrange $result 1 end]
        foreach item $items {
            set title [string_truncate -len 245 -- [lindex $item 0]]
            set link [string_truncate -len 245 -- [lindex $item 1]]
            set description [lindex $item 2]

            # check whether link and description have been set as we
            # need these to check against already added items
            # also we check whether link is an external or internal URL
            # if not, it might occur in other items, and we can't check against it
            if { [exists_and_not_null link] && [na_check_link $link $host] } {
                set identifier "link"
            } elseif { [exists_and_not_null description]  } {
                set identifier "description"
            } else {
                set identifier "none"
            }

            # check whether the item already exists
            # that it has at least a link or description
            # and that we're not handling a deleted item
            
            if { ![string equal "none" $identifier] } {
                if {![db_0or1row item { *SQL* }]} {
                    db_exec_plsql add_item { *SQL* }
                    set updated_p 1
                } elseif { [string equal f $deleted_p] && ((![string equal $title $item_title]) || (![string equal $description $item_description])) } {
                    db_dml update_item { *SQL* }
                    set updated_p 1
                }
            }
        }
        if { [exists_and_not_null updated_p] } {
            # one or more items were added/updated
            # let's update the rss metadata as well
            set channel [lindex $result 0]
            set last_modified [lindex $f 2]
            set title [string_truncate -len 245 -- [lindex $channel 0]]
            set link [string_truncate -len 245 -- [lindex $channel 1]]
            set description [string_truncate -len 245 -- [lindex $channel 2]]
            
            db_dml update_source { *SQL* }
        }
    }
}

ad_proc -public na_update_sources { } {
    Update sources by a one hour interval.
} {
    ns_log Debug "na_update_sources: updating news-aggregator sources"
    
    db_foreach sources {} {
        na_update_source $owner_id $source_id $feed_url $last_modified
    }

}

# schedule hourly updates
ad_schedule_proc 600 na_update_sources

ad_proc -public na_cleanup_items {} {
    Clean up the items that have been retrieved more than two months ago.
} {
    db_dml deleted_items { *SQL* }
}

# schedule daily cleanup of one-week-old deleted items
#ad_schedule_proc 86400 na_cleanup_items
