ad_library {
    Procs to manage subscriptions.
    
    @author Simon Carstensen (simon@bcuni.net)
    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-06-28
}

namespace eval news_aggregator {}
namespace eval news_aggregator::subscription {}

ad_proc -public news_aggregator::subscription::new {
    {-aggregator_id:required}
    {-source_id:required}
} {
    if { ![db_string subscription_exists_p {} -default "0"] } {
        db_dml insert_subscription {}
    }
}

ad_proc -public news_aggregator::subscription::delete {
    {-source_id:required}
    {-aggregator_id:required}
} {
    db_dml delete_subscription {}
    if { [db_string source_use_count {}] eq "0" } {
	news_aggregator::source::delete -source_id $source_id
    }
}

ad_proc -public news_aggregator::subscription::move {
    {-source_id:required}
    {-move_from:required}
    {-move_to:required}
} {
    Move subscription to another aggregator

    @author Simon Carstensen
    @creation_date 2003-08-23
} {
    db_dml move_subscription {}
}

ad_proc -public news_aggregator::subscription::copy {
    {-source_id:required}
    {-copy_to:required}
} {
    Copy subscription to another aggregator

    @author Simon Carstensen
    @creation_date 2003-08-23
} {
    db_dml copy_subscription {}
}
