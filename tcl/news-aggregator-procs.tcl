ad_library {
     Procs used by the News Aggregator application.

     @author Simon Carstensen (simon@bcuni.net)
     @author Guan Yang (guan@unicast.org)
     @creation-date 2003-06-28
}


namespace eval news_aggregator {}


ad_proc -public news_aggregator::check_link {
    {-domain:required}
    {-link:required}
} {
    @author Simon Carstensen
} {
    regexp {(https?://[^/]+)+} $domain domain
    regexp {(https?://[^/]+)+} $link link
    return [string equal $link $domain]
}


ad_proc -public news_aggregator::last_scanned {
    {-diff:required}
} {

    Returns the number of hours and minutes since the feed was last updated.

    @author Simon Carstensen    
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

ad_proc -private news_aggregator::dom_set_child_text {
    {-node:required}
    {-child:required}
} {
    If node contains a child node named child,
    the variable child is set to the text of that node
    in the caller's stack frame.

    @author Guan Yang
    @creation-date 2003-07-03
} {
    if { [$node hasChildNodes] } {
        set child_nodes [$node selectNodes "*\[local-name()='$child'\]"]
        if { [llength $child_nodes] == 1 } {
            set child_node [lindex $child_nodes 0]
            upvar $child var
            set var [$child_node text]
        }
    }
}

ad_proc -private news_aggregator::channel_parse {
    {-channel_node:required}
} {
    Takes a tDOM node which is supposed to represent an RSS
    channel, and returns a list with the RSS/RDF elements
    of that node. This proc should later be extended to
    support Dublin Core elements and other funk.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-03
} {
    set properties [list title link description language copyright lastBuildDate docs generator managingEditor webMaster]

    foreach property $properties {
        set $property ""
	    news_aggregator::dom_set_child_text -node $channel_node -child $property
        set channel($property) [set $property]
    }
    
    set channel_name [$channel_node nodeName]
    
    # Do weird Atom-like stuff
    if { [string equal $channel_name "feed"] } {
        # link
        if { [string equal $link ""] } {
            # Link is in a href
            set link_node [$channel_node selectNodes {*[local-name()='link' and @rel = 'alternate' and @type = 'text/html']/@href}]
            if { [llength $link_node] == 1 } {
                set link_node [lindex $link_node 0]
                set channel(link) [lindex $link_node 1]
            }
        }
        
        # author
        set author_node [$channel_node selectNodes {*[local-name()='author']}]
        if { [llength $author_node] == 1 } {
            set author_node [lindex $author_node 0]
            news_aggregator::dom_set_child_text -node $author_node -child name
            news_aggregator::dom_set_child_text -node $author_node -child email
            if { [info exists email] && [info exists name] } {
                set channel(managingEditor) "$email ($name)"
            }
        }
        
        # tagline
        news_aggregator::dom_set_child_text -node $channel_node -child tagline
        if { [info exists tagline] } {
            set channel(tagline) $tagline
        }
    }

    return [array get channel]
}

ad_proc -private news_aggregator::items_fetch {
    {-doc_node:required}
} {
    Takes a tDOM document node which is supposed to be some
    form of RSS. Returns a list with the item nodes. Returns
    an empty list if none could be found.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-03
} {
    set items [$doc_node selectNodes {//*[local-name()='item' or local-name()='entry']}]
    return $items
}

ad_proc -private news_aggregator::item_parse {
    {-item_node:required}
} {
    Takes a tDOM node which is supposed to represent an RSS item,
    and returns a list with the RSS/RDF elements of that node.

    @author Simon Carstensen
    @author Guan Yang (guan@unicast.org)
} {
    set title ""
    set link ""
    set guid ""
    set permalink_p false
    set description ""
    set content_encoded ""

    news_aggregator::dom_set_child_text -node $item_node -child title
    news_aggregator::dom_set_child_text -node $item_node -child link
    news_aggregator::dom_set_child_text -node $item_node -child guid
    news_aggregator::dom_set_child_text -node $item_node -child description
    
    set maybe_atom_p 0
    
    # Try to handle Atom link
    if { [string equal $link ""] } {
        set link_attr [$item_node selectNodes {*[local-name()='link']/@href}]
        if { [llength $link_attr] == 1 } {
            set link [lindex [lindex $link_attr 0] 1]
            set maybe_atom_p 1
        }
    }

    set encoded_nodes [$item_node selectNodes {*[local-name()='encoded' and namespace-uri()='http://purl.org/rss/1.0/modules/content/']}]
    if { [llength $encoded_nodes] == 1 } {
        set encoded_node [lindex $encoded_nodes 0]
	    set content_encoded [$encoded_node text]
    }

    if { [llength [$item_node selectNodes "*\[local-name()='guid'\]"]] } {
        # If guid exists, we assume that it's a permalink
        set permalink_p true
    }

    # Retrieve isPermaLink attribute
    set isPermaLink_nodes [$item_node selectNodes "*\[local-name()='guid'\]/@isPermaLink"]
    if { [llength isPermaLink_nodes] == 1} {
        set isPermaLink_node [lindex $isPermaLink_nodes 0]
    	set isPermaLink [lindex $isPermaLink_node 1]
	if { [string equal $isPermaLink false] } {
	    set permalink_p false
	}
    }

    if { [empty_string_p $link] } {
        if { [exists_and_not_null guid] } {
            set link $guid
            set permalink_p true
        } elseif { [empty_string_p $guid] && ![string equal $link $guid] } {
            set permalink_p true
        }
    }
    
    # Try to handle Atom guid
    if { [empty_string_p $guid] && $maybe_atom_p } {
        news_aggregator::dom_set_child_text -node $item_node -child id
        if { [info exists id] } {
            # We don't really know if it's an URL
            set guid $id
            if { [util_url_valid_p $id] } {
                set permalink_p true
            } else {
                set permalink_p false
            }
        }
    }
    
    # For Atom, description is summary, content is content_encoded
    if { $maybe_atom_p } {
        news_aggregator::dom_set_child_text -node $item_node -child summary
        if { [info exists summary] } {
            set description $summary
        }
        
        news_aggregator::dom_set_child_text -node $item_node -child content
        if { [info exists content] } {
            set content_encoded $content
        }
    }

    #remove unsafe html
    set description [news_aggregator::remove_unsafe_html -html $description]

    return [list title $title link $link guid $guid permalink_p $permalink_p description $description content_encoded $content_encoded]
}

ad_proc -private news_aggregator::external_entity {
    base_uri
    system_identifier
    public_identifier
} {
    A callback for tDOM to resolve external entities.

    @author Guan Yang
    @creation-date 2003-07-03
} {
    return [list string "" ""]
}

ad_proc -public news_aggregator::sort_result {
    {-result:required}
} {
    @author Simon Carstensen
} {
    set sorted [list]
    for {set i 0} {$i < [llength $result]} {incr i} {
	lappend sorted [lindex $result end-$i]
    }
    return $sorted
}

ad_proc -public news_aggregator::parse {
    {-xml:required}
} {
    The workhorse of news-aggregator: A Very Ugly RSS Parser.
    Now also supports Atom and weird formats in between. 

    @author Simon Carstensen
    @author Guan Yang (guan@unicast.org)
} {
    if { [catch {
    	# Pre-process the doc and remove any processing instruction
	regsub {^<\?xml [^\?]+\?>} $xml {<?xml version="1.0"?>} xml
	set doc [dom parse $xml]
        set doc_node [$doc documentElement]
        set node_name [$doc_node nodeName]

	# feed is the doc-node name for Atom feeds
        if { [lsearch {rdf RDF rdf:RDF rss feed} $node_name] == -1 } {
	    ns_log Debug "news_aggregator::parse: doc node name is not rdf, RDF, rdf:RDF or rss"
            set rss_p 0
        } else {
            set rss_p 1
        }
    } errmsg] } {
	ns_log Debug "news_aggregator::parse: error in initial itdom parse, errmsg = $errmsg"
        set rss_p 0
    }

    if { !$rss_p } {
        # not valid xml, let's try autodiscovery
	ns_log Debug "news_aggregator::parse: not  valid xml, we'll try autodiscovery"
        
        set doc [dom parse -html $xml]
        set doc_node [$doc documentElement]

        set link_nodes [$doc_node selectNodes {/html/head/link[@rel='alternate' and @title='RSS' and @type='application/rss+xml']/@href}]
      
	$doc delete

        if { [llength $link_nodes] == 1} {
            set link_node [lindex $link_nodes 0]
            set feed_url [lindex $link_node 1]
            array set f [ad_httpget -url $feed_url]
            return [news_aggregator::parse -xml $f(page)]
        }
        return 0
    }

    if { [catch {
	set doc_name [$doc_node nodeName]
	
	if { [string equal $doc_name "feed"] } {
	    # It's an Atom feed
	    set channel [news_aggregator::channel_parse \
	                   -channel_node $doc_node]
    } else {
        # It looks RSS/RDF'fy
	    set channel [news_aggregator::channel_parse \
			-channel_node [$doc_node getElementsByTagName channel]]
    }    
        
    set item_nodes [news_aggregator::items_fetch -doc_node $doc_node]
	set item_nodes [news_aggregator::sort_result -result $item_nodes]
	set items [list]
  
        foreach item_node $item_nodes {
            lappend items [news_aggregator::item_parse -item_node $item_node]
        }

	$doc delete
    } err] } {
        return 0
    } else {
        return [list channel "$channel" items "$items"]
    }
}

ad_proc -public news_aggregator::remove_unsafe_html { 
    -html:required
} {
    Make sure we are consuming RSS safely by removing unsafe tags.

    See http://diveintomark.org/archives/2003/06/12/how_to_consume_rss_safely.html.

    @author Simon Carstensen
    @creation-date 2003-07-06
} {

    set unsafe_tags {
        script
        embed
        object
        frameset
        frame
        iframe
        meta
        link
        style
    }

    foreach tag $unsafe_tags {
        regsub -all "(<$tag\[^>\]*>(\[^<\]*</$tag>)?)+"  $html {} html
    }

    return $html
}
