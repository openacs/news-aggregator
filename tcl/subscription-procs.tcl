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
    Creates a new subscription to a source in an aggregator. If one
    already exists this proc would just skipt the new creation.
} {
    if {![db_string subscription_exists_p {
        select exists (select 1 from na_subscriptions
                       where aggregator_id = :aggregator_id
                         and source_id = :source_id)
    }]} {
        db_dml insert_subscription {
            insert into na_subscriptions (
                aggregator_id,
                source_id,
                creation_date
            ) values (
                :aggregator_id,
                :source_id,
                current_timestamp
            )
        }
    }
}

ad_proc -public news_aggregator::subscription::delete {
    {-source_id:required}
    {-aggregator_id:required}
} {
    Delete a subscription to a source in an aggregator.
} {
    db_dml delete_subscription {
        delete from na_subscriptions
        where source_id = :source_id
          and aggregator_id = :aggregator_id
    }
}

ad_proc -public news_aggregator::subscription::move {
    {-source_id:required}
    {-move_from:required}
    {-move_to:required}
} {
    Move subscription to another aggregator

    @author Simon Carstensen
    @creation-date 2003-08-23
} {
    db_dml move_subscription {
        update na_subscriptions set
           aggregator_id = :move_to
        where source_id = :source_id
          and aggregator_id = :move_from
    }
}

ad_proc -public news_aggregator::subscription::copy {
    {-source_id:required}
    {-copy_to:required}
} {
    Copy subscription to another aggregator

    @author Simon Carstensen
    @creation-date 2003-08-23
} {
    news_aggregator::subscription::new \
        -aggregator_id $copy_to \
        -source_id $source_id
}
