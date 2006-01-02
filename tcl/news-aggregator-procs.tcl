ad_library {
    Procs used by the News Aggregator application.
    
    @author Simon Carstensen (simon@bcuni.net)
    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-06-28
    @cvs-id $Id$
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

    Returns the number of days, hours and minutes since the feed was last updated.

    @author Simon Carstensen    
} {
    set days [expr $diff / 1440]
    if { $diff < 120 && $diff > 60 } {
        set to_return "1 hour and "
    } elseif { $diff >= 60 && $days == 0 } {
        set to_return "[expr $diff / 60] hours and "
    } else {
	switch $days {
	    "0" {
		set to_return ""
	    }
	    "1" {
		set to_return "1 day, "
	    }
	    default {
		set to_return "$days days, "
	    }
	}
	if { [expr $diff % 1440] < 60 && $days == 0 } {
	    append to_return ""
	} elseif { [expr $diff % 1440] < 60 } {
	    append to_return "and "
	} elseif { [expr $diff % 1440] < 120 } {
	    append to_return "1 hour and "
	} else {
	    append to_return "[expr [expr $diff % 1440]  / 60] hours and "
	}
    }

    set mins [expr $diff % 60]
    if {[string equal 1 $mins]} {
        append to_return "1 minute ago"
    } else {
        append to_return "$mins minutes ago"
    }
    return $to_return
}

