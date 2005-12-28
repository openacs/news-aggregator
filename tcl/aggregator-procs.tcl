ad_library {
    Procs to manage aggregators.
    
    @author Simon Carstensen (simon@bcuni.net)
    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-06-28
}

namespace eval news_aggregator {}
namespace eval news_aggregator::aggregator {}

ad_proc -public news_aggregator::aggregator::aggregator_info {
    {-aggregator_id:required}
} {
    Returns a Tcl array-list with some aggregator information:
    aggregator_name, aggregator_description and public_p.
    
    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-11-10
    @returns Tcl array-list with the information, or empty
             string on error.
} {
    if { ![db_0or1row aggregator_info ""] } {
        return ""
    }
    
    set info(aggregator_name) $aggregator_name
    set info(aggregator_description) $aggregator_description
    set info(public_p) $public_p
    
    return [array get info]
}

ad_proc -public news_aggregator::aggregator::as_xml {
    {-aggregator_id:required}
    {-package_id:required}
    {-stylesheet}
    {-stylesheet_type}
} {
    Generate an XML document of the contents of the aggregator as they
    would be displayed in a public aggregator. The format is specific
    to the news aggregator. It is intended to be processed with an XSLT
    stylesheet -- that is why we don't return the raw XML string.
    
    @param stylesheet An URI for a stylesheet that will be inserted
                      into the document as the xml-stylesheet processing
                      instruction.
    @param stylesheet_type MIME type for the stylesheet.
    
    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-10
    @returns tDOM document node
} {
    set items_query [news_aggregator::aggregator::items_sql \
        -aggregator_id $aggregator_id \
        -package_id $package_id \
        -purge_p 0]
    
    dom setResultEncoding "utf-8"
    set doc [dom createDocument "aggregator"]
    
    set doc_node [$doc documentElement]
    $doc_node setAttribute "version" "0.9"
    
    # Create the xml processing instruction
    set pi [$doc createProcessingInstruction "xml" {version="1.0"}]
    set root [$doc_node selectNode /]
    $root insertBefore $pi $doc_node
    
    # If applicable, create the xml-stylesheet processing instruction
    if { [info exists stylesheet] && [info exists stylesheet_type] } {
        set pi [$doc createProcessingInstruction "xml-stylesheet" "href=\"$stylesheet\" type=\"$stylesheet_type\""]
        $root insertBefore $pi $doc_node
    }
    
    # Create a generator comment
    set comment [$doc createComment " Generated by the [ad_system_name] news aggregator. [ad_url] "]
    $root insertBefore $comment $doc_node
    
    set head_node [$doc createElement head]
    $doc_node appendChild $head_node
    
    array set info [news_aggregator::aggregator::aggregator_info \
                                    -aggregator_id $aggregator_id]
                                    
    set header_fields [list \
                        [list aggregator_name name] \
                        [list aggregator_description description]]
    foreach header_field $header_fields {
        set node [$doc createElement [lindex $header_field 1]]
        set text_node [$doc createTextNode $info([lindex $header_field 0])]
        $node appendChild $text_node
        $head_node appendChild $node
    }
    
    set body_node [$doc createElement "body"]
    $doc_node appendChild $body_node
    
    set previous_source_id 0
    db_foreach items_sql $items_query {
        if { $source_id != $previous_source_id } {
            set source_node [$doc createElement source]
            $source_node setAttribute title         $title       \
                                      link          $link        \
                                      description   $description
            $body_node appendChild $source_node
        }
        
        set item_node [$doc createElement item]
        
        set title_node [$doc createElement title]
        set text_node [$doc createTextNode $item_title]
        $title_node appendChild $text_node
        $item_node appendChild $title_node
        
        set link_node [$doc createElement link]
        set text_node [$doc createTextNode $item_link]
        $link_node appendChild $text_node
        $item_node appendChild $link_node
        
        if { ![string equal $content_encoded ""] } {
            set content $content_encoded
        } else {
            set content $item_description
        }
        
        set content_node [$doc createElement content]
        set text_node [$doc createCDATASection $content]
        $content_node appendChild $text_node
        $item_node appendChild $content_node
        
        $source_node appendChild $item_node
        
        set previous_source_id $source_id
    }
    
    set xml [$doc asXML]
    $doc delete
    return $xml
}

ad_proc -private news_aggregator::aggregator::items_sql {
    {-aggregator_id:required}
    {-package_id:required}
    {-purge_p:required}
    {-limit_multiple 6}
} {
    Returns the SQL required to fetch items, including purges
    if purge_p is true.
} {
    if { $purge_p } {
        set items_purges [db_map items_purges]
    } else {
        set items_purges ""
    }
    
    set limit [ad_parameter -package_id $package_id "number_of_items_shown"]
    set sql_limit [expr $limit_multiple*$limit]
    
    set sql [db_map items]
    return $sql
}

ad_proc -public news_aggregator::aggregator::as_opml {
    {-aggregator_id:required}
} {
    Generate OPML of the subscriptions of the aggregator in
    mySubscriptions.opml format.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-10
    @returns A string containing the XML document.
} {
    dom setResultEncoding "utf-8"
    set doc [dom createDocument "opml"]

    set doc_node [$doc documentElement]
    $doc_node setAttribute "version" "1.1"

    # Create the xml processing instruction
    set pi [$doc createProcessingInstruction "xml" {version="1.0"}]
    set root [$doc_node selectNode /]
    $root insertBefore $pi $doc_node

    # Create a generator comment
    set comment [$doc createComment " generated by the [ad_system_name] news aggregator. [ad_url] "]
    $root insertBefore $comment $doc_node

    # Fetch the aggregator information
    if { ![db_0or1row maintainer ""] } {
    	return ""
    }

    # Create the header
    set head_node [$doc createElement head]
    $doc_node appendChild $head_node
    set headers [list \
    	[list title "mySubscriptions"] \
	[list dateCreated $creation_date] \
	[list dateModified $modified_date] \
	[list ownerName $person_name] \
	[list ownerEmail $email] \
	[list expansionState ""] \
	[list vertScrollState "1"] \
	[list windowTop 295] \
	[list windowLeft 319] \
	[list windowBottom 495] \
	[list windowRight 704]]
    foreach header $headers {
        set node [$doc createElement [lindex $header 0]]
	set text_node [$doc createTextNode [lindex $header 1]]
	$node appendChild $text_node
	$head_node appendChild $node
    }

    set body_node [$doc createElement "body"]
    $doc_node appendChild $body_node

    db_foreach subscriptions "" {
        set node [$doc createElement "outline"]
	$node setAttribute text $title
	$node setAttribute description $description
	$node setAttribute htmlUrl $link
	$node setAttribute language "unknown"
	$node setAttribute title $title
	$node setAttribute type "rss"
	$node setAttribute version "RSS"
	$node setAttribute xmlUrl $feed_url

	$body_node appendChild $node
    }

    return [$doc asXML]
}

ad_proc -private news_aggregator::aggregator::purge {
    {-aggregator_id:required}
    {-top:required}
    {-bottom:required}
} {
    Purge the aggregator.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-04
} {
    db_transaction {
        # Find out how many purges the aggregator has
        # and clear some if there are too many
        set purge_count [db_string count_purges ""]
        set max_purges [ad_parameter "max_purges"]
        if { $purge_count > $max_purges } {
            db_1row get_range ""
	    db_dml purge_all_purges ""

	    # The aggregator's bottom is set to the argument
	    # top because aggregator_bottom is actually the
	    # highest-numbered item to be displayed. Yes, it
	    # is confusing.
	    set aggregator_bottom $top
	    db_dml aggregator_purge ""

	    return
        }

        set purge_id [db_nextval na_purges_seq]
	db_dml insert_purge ""
    }
}

ad_proc -private news_aggregator::aggregator::set_user_default {
    {-user_id:required}
    {-package_id:required}
    {-aggregator_id:required}
} {
    Sets the user's default aggregator to aggregator_id.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-04
} {
    db_dml set_default ""
    if { ![db_resultrows] } {
    	db_dml create_pref ""
    }
}

ad_proc -private news_aggregator::aggregator::user_default {
    {-user_id:required}
    {-package_id:required}
} {
    Returns the user's default aggregator, or 0 if none exists.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-06-29
} {
    set aggregator_id [db_string select_user_default {} -default 0]
    if { $aggregator_id eq "" } {
	return 0
    } else {
	return $aggregator_id
    }
#     if { [string equal $aggregator_id "0"] } {
#         set aggregator_id [db_string lowest_aggregator ""]
# 	if { [exists_and_not_null aggregator_id] } {
# 	    news_aggregator::aggregator::set_user_default \
# 	  				-user_id $user_id \
# 					-aggregator_id $aggregator_id
# 	} else {
# 	    return 0
# 	}
#     }
#     return $aggregator_id
}

ad_proc -private news_aggregator::aggregator::instance_default {
    {-package_id:required}
} {
    Returns the instance's default aggregator, or 0 if none exists.

    @author Michael Steigman (michael@steigman.net)
    @creation-date 2005-12-25
} {
    set aggregator_id [db_string select_instance_default {} -default 0]
    if { $aggregator_id eq "" } {
	return 0
    } else {
	return $aggregator_id
    }
}

ad_proc -public news_aggregator::aggregator::edit {
    {-aggregator_id:required}
    {-aggregator_name:required}
    {-description:required}
    {-public_p:required}
} {
    Edit the aggregator's name or listing status.

    @author Guan Yang
    @creation-date 2003-06-29
} {
    db_dml edit_aggregator {}

    if { [db_resultrows] } {
        # Error
    	return 1
    } else {
        return 0
    }
}

ad_proc -public news_aggregator::aggregator::new {
    {-aggregator_name:required}
    {-description ""}
    {-package_id ""}
    {-public_p t}
    {-creation_user ""}
    {-creation_ip ""}
} {
    Create a new news aggregator.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-06-29
} {

    if { ![exists_and_not_null creation_user] } {
        set creation_user [ad_conn user_id]
    }

    if { ![exists_and_not_null creation_ip] } {
        set creation_ip [ad_conn peeraddr]
    }

    if { ![exists_and_not_null package_id] } {
        set package_id [ad_conn package_id]
    }

    return [db_exec_plsql new_aggregator {}]
}

ad_proc -public news_aggregator::aggregator::delete {
    {-aggregator_id:required}
} {
    Delete an aggregator.

    @author Simon Carstensen (simon@bcuni.net)
    @creation-date 2003-06-28
} {
    db_exec_plsql delete_aggregator {}
}

ad_proc -public news_aggregator::aggregator::load_preinstalled_subscriptions {
    -aggregator_id:required
    -package_id:required
} {

    db_foreach select_feeds {} {
     
        news_aggregator::subscription::new \
            -aggregator_id $aggregator_id \
            -source_id $source_id
    }
}

ad_proc -public news_aggregator::aggregator::options {
    -user_id:required
} {
    Returns options (value label pairs) for building the news aggregator HTML select box.

    @author Simon Carstensen
} {
    return [db_list_of_lists select_aggregator_options {}]
}
