ad_library {
    Some random procs to parse (not generate) OPML.
    
    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-17
}

namespace eval news_aggregator::opml {}

ad_proc -public news_aggregator::opml::parse {
    {-xml:required}
} {
    Parse the OPML and return a wonderful special data structure.
    This is Guan's Ultra Liberal OPML Parser (GULOP).
        
    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-17
} {
    if { [catch {
        set doc [dom parse $xml]
        
        set doc_node [$doc documentElement]
        if { ![string equal [$doc_node nodeName] "opml"] } {
            error "Document element is not opml"
        }
        
        set opml(status) "success"
        
        set head_nodes [$doc_node selectNodes {/opml/*[local-name()='head']}]
        if { [llength $head_nodes] != 1 } {
            error "There is not exactly one head element"
        }
        set head_node [lindex $head_nodes 0]
        set title_texts [$head_node selectNodes {*[local-name()='title']/text()}]
        if { [llength $title_texts] != 1 } {
            error "There is not exactly one title element in head: $title_texts"
        }
        set title_text [[lindex $title_texts 0] nodeValue]
        if { ![string equal $title_text "mySubscriptions"] } {
            error "OPML title is not 'mySubscriptions'. This does not appear to be an OPML file in mySubscriptions format."
        }
        
        set body_nodes [$doc_node selectNodes {/opml/*[local-name()='body']}]
        if { [llength $body_nodes] == 0 } {
            # No body node
            error "Document element has no body child"
        }
        # If there is more than one body child, we take the first one
        set body_node [lindex $body_nodes 0]
        
        set elements [list]
        
        foreach node [$body_node getElementsByTagName "outline"] {
            set title [$node getAttribute title ""]
            set url [$node getAttribute xmlUrl ""]
            set html_url [$node getAttribute htmlUrl ""]
            
            if { ![string equal $title ""] && ![string equal url ""] &&
                 ![string equal $html_url ""] &&
                 [util_url_valid_p $url] } {
                set feed(title) $title
                set feed(url) $url
                set feed(html_url) $html_url
                lappend elements [array get feed]
            }
        }
        
        set opml(elements) $elements
    } errmsg] } {
        set error(status) "failure"
        set error(errmsg) $errmsg
        
        return [array get error]
    }
    
    return [array get opml]
}
