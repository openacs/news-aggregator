<?xml version="1.0"?>

<queryset>


    <fullquery name="news_aggregator::subscription::new.subscription_exists_p">
          <querytext>
            select 1
            from   na_subscriptions
            where  aggregator_id =:aggregator_id
            and    source_id = :source_id
          </querytext>
    </fullquery>

    <fullquery name="news_aggregator::subscription::delete.delete_subscription">
          <querytext>
            delete from na_subscriptions
                where source_id = :source_id
                and   aggregator_id =:aggregator_id
          </querytext>
    </fullquery>

    <fullquery name="news_aggregator::subscription::delete.source_use_count">
          <querytext>
           select count(*) from na_subscriptions
            where source_id = :source_id
          </querytext>
    </fullquery>

    <fullquery name="news_aggregator::subscription::move.move_subscription">
          <querytext>
            update na_subscriptions
            set    aggregator_id = :move_to
            where  source_id = :source_id
            and    aggregator_id = :move_from
          </querytext>
    </fullquery>

</queryset>
