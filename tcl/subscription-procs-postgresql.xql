<?xml version="1.0"?>

<queryset>

    <fullquery name="news_aggregator::subscription::copy.copy_subscription">
          <querytext>
            insert into na_subscriptions (
                aggregator_id,
                source_id,
                creation_date
            ) values (
                :copy_to,
                :source_id,
                now()
            )
          </querytext>
    </fullquery>

    <fullquery name="news_aggregator::subscription::new.insert_subscription">
          <querytext>
            insert into na_subscriptions (
                aggregator_id,
                source_id,
                creation_date
            ) values (
                :aggregator_id,
                :source_id,
                now()
            )
          </querytext>
    </fullquery>
</queryset>
