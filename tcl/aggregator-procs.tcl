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
    @return Tcl array-list with the information, or empty
             string on error.
} {
    if { ![db_0or1row aggregator_info {
        select aggregator_name,
               description as aggregator_description,
               public_p
        from   na_aggregators
        where  aggregator_id = :aggregator_id
    } -column_array info] } {
        return ""
    }

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
    @return tDOM document node
} {
    set items_query [news_aggregator::aggregator::items_sql \
        -aggregator_id $aggregator_id \
        -package_id $package_id \
        -purge_p 0]

    set doc [dom createDocument "aggregator"]

    set doc_node [$doc documentElement]
    $doc_node setAttribute "version" "0.9"
    set root [$doc_node selectNode /]

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

    set info [news_aggregator::aggregator::aggregator_info \
                  -aggregator_id $aggregator_id]

    set header_fields {
        {aggregator_name name}
        {aggregator_description description}
    }
    foreach header_field $header_fields {
        set node [$doc createElement [lindex $header_field 1]]
        set text_node [$doc createTextNode [dict get $info [lindex $header_field 0]]]
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

        if { $content_encoded ne "" } {
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

    # apisano 2018-07-18: at least on tDOM 0.8.3, adding the xml
    # processing instruction via the API returns an error. Newer tDOM
    # versions allow one to specify a flag saying whether we want this to
    # be included when doing asXML, but we cannot assume one will use
    # the latest tDOM and therefore, in order to behave like the
    # original author wanted, we append the declaration manually.
    set xml {<?xml version="1.0"?>}
    append xml \n [$doc asXML]
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
        set items_purges {
            and    ((i.item_id > coalesce(a.aggregator_bottom, 0)) or
                    (i.item_id in (select item_id from na_saved_items
                                   where aggregator_id = :aggregator_id)))
        }
    } else {
        set items_purges ""
    }

    set limit [parameter::get -package_id $package_id -parameter "number_of_items_shown"]
    set sql_limit [expr {$limit_multiple*$limit}]

    set sql [subst -nocommands {
	select s.source_id,
               s.link,
               s.description,
               s.title,
               to_char(i.creation_date, 'YYYY-MM-DD HH24:MI:SS') as last_scanned,
               to_char(i.creation_date, 'YYYY-MM-DD HH24') as sort_date,
	       s.feed_url,
	       i.item_id,
               i.title as item_title,
               i.link as item_link,
               i.description as item_description,
               i.content_encoded,
               i.guid as item_guid,
               i.original_guid as item_original_guid,
               i.permalink_p as item_permalink_p,
               i.author as item_author,
               to_char(i.pub_date at time zone 'UTC', 'YYYY-MM-DD HH24:MI:SS') as item_pub_date,
               s.last_modified
        from   (
                   na_aggregators a join
                   na_subscriptions su on (a.aggregator_id = su.aggregator_id)
               ) join
               na_items i on (su.source_id = i.source_id)
               join na_sources s on (i.source_id = s.source_id)
	where  a.package_id = :package_id
        and    a.aggregator_id = :aggregator_id
            $items_purges
	order  by i.item_id desc
	fetch first $sql_limit rows only
    }]
    return $sql
}

ad_proc -public news_aggregator::aggregator::as_opml {
    {-aggregator_id:required}
} {
    Generate OPML of the subscriptions of the aggregator in
    mySubscriptions.opml format.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-10
    @return A string containing the XML document.
} {
    set doc [dom createDocument "opml"]

    set doc_node [$doc documentElement]
    $doc_node setAttribute "version" "1.1"

    # Create the xml processing instruction
    set root [$doc_node selectNode /]

    # Create a generator comment
    set comment [$doc createComment " Generated by the [ad_system_name] news aggregator. [ad_url] "]
    $root insertBefore $comment $doc_node

    # Fetch the aggregator information
    if { ![db_0or1row maintainer {
        select to_char(o.creation_date, 'Dy, DD Mon YYYY HH24:MI:SS TZ') as creation_date,
               a.maintainer_id
        from acs_objects o, na_aggregators a
        where o.object_id = a.aggregator_id
          and a.aggregator_id = :aggregator_id
    }] } {
        return
    }

    set email [party::email -party_id $maintainer_id]
    set person_name [person::name -person_id $maintainer_id]
    set modified_date $creation_date

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

    db_foreach subscriptions {
	  select
	  	feed_url,
		link,
		title,
		description
	  from
	  	na_sources s,
		na_subscriptions su
	  where
	  	s.source_id = su.source_id
		and su.aggregator_id = :aggregator_id
	  order by lower(title)
    } {
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

    # apisano 2018-07-18: at least on tDOM 0.8.3, adding the xml
    # processing instruction via the API returns an error. Newer tDOM
    # versions allow one to specify a flag saying whether we want this to
    # be included when doing asXML, but we cannot assume one will use
    # the latest tDOM and therefore, in order to behave like the
    # original author wanted, we append the declaration manually.
    set xml {<?xml version="1.0"?>}
    append xml \n [$doc asXML]
    return $xml
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
        set purge_count [db_string count_purges {
            select count(purge_id) from na_purges
            where aggregator_id = :aggregator_id
        }]
        set max_purges [parameter::get -parameter "max_purges"]
        if { $purge_count > $max_purges } {
            db_dml purge_all_purges {
                delete from na_purges
                where aggregator_id = :aggregator_id
            }

            # The aggregator's bottom is set to the argument
            # top because aggregator_bottom is actually the
            # highest-numbered item to be displayed. Yes, it
            # is confusing.
            set aggregator_bottom $top
            db_dml aggregator_purge {
                update na_aggregators
                set aggregator_bottom = :aggregator_bottom
                where aggregator_id = :aggregator_id
            }
            return
        }

        set purge_id [db_nextval na_purges_seq]
        db_dml insert_purge {
            insert into na_purges
                    (purge_id, top, bottom, aggregator_id, purge_date)
            values
                    (:purge_id, :top, :bottom, :aggregator_id, current_timestamp)
        }
    }
}

ad_proc -private news_aggregator::aggregator::set_user_default {
    {-user_id:required}
    {-aggregator_id:required}
} {
    Sets the user's default aggregator to aggregator_id.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-04
} {
    db_dml set_default {
        update na_user_preferences set
        default_aggregator = :aggregator_id
        where user_id = :user_id
    }
    if { ![db_resultrows] } {
        db_dml create_pref {
            insert into na_user_preferences
            (user_id, default_aggregator)
            values
            (:user_id, :aggregator_id)
        }
    }
}

ad_proc -private news_aggregator::aggregator::user_default {
    {-user_id:required}
} {
    Returns the user's default aggregator, or 0 if none exists.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-06-29
} {
    set aggregator_id [db_string find_default {
        select coalesce(default_aggregator, 0)
        from na_user_preferences
        where user_id = :user_id
    } -default 0]

    if {$aggregator_id == 0} {
        set aggregator_id [db_string lowest_aggregator {
            select coalesce(min(object_id), 0)
            from   acs_objects
            where  object_type = 'na_aggregator'
            and    creation_user = :user_id
        } -default 0]
        if { $aggregator_id != 0 } {
            news_aggregator::aggregator::set_user_default \
                -user_id       $user_id \
                -aggregator_id $aggregator_id
        }
    }

    return $aggregator_id
}

ad_proc -public news_aggregator::aggregator::edit {
    {-aggregator_id:required}
    {-aggregator_name:required}
    {-description:required}
    {-public_p:required}
} {
    Edit the aggregator's name or listing status.

    @return boolean value telling whether a row was updated
    @author Guan Yang
    @creation-date 2003-06-29
} {
    db_dml edit_aggregator {
        update na_aggregators set
            aggregator_name = :aggregator_name,
            description     = :description,
            public_p        = :public_p
        where aggregator_id = :aggregator_id
    }
    return [expr {[db_resultrows] > 0}]
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

    if { $creation_user eq "" } {
        set creation_user [ad_conn user_id]
    }

    if { $creation_ip eq "" } {
        set creation_ip [ad_conn peeraddr]
    }

    if { $package_id eq "" } {
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
    Subscribe aggregator to every pre-subscribed feed for the
    specified package.
} {
    foreach source_id [db_list select_feeds {
       select source_id
         from na_presubscribed_feeds
        where package_id = :package_id
    }] {
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
    return [db_list_of_lists select_aggregator_options {
        select a.aggregator_name,
               a.aggregator_id
        from   na_aggregators a join
               acs_objects o on (a.aggregator_id = o.object_id)
        where  o.creation_user = :user_id
    }]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
