<?xml version="1.0"?>

<queryset>

<fullquery name="news_aggregator::aggregator::load_preinstalled_subscriptions.select_feeds">
      <querytext>
        select source_id 
        from   na_presubscribed_feeds 
        where  package_id = :package_id
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::aggregator::load_preinstalled_subscriptions.select_source_id">
      <querytext>
        select source_id
        from   na_presubscribed_feeds
        where  package_id = :package_id
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::aggregator::options.select_aggregator_options">
      <querytext>
        select a.aggregator_name,
               a.aggregator_id
        from   na_aggregators a join
               acs_objects o on (a.aggregator_id = o.object_id)
        where  o.creation_user = :user_id
        </querytext>
    </fullquery>

</queryset>
