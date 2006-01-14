<?xml version="1.0"?>

<queryset>

<fullquery name="news_aggregator::apm::before_uninstantiate.select_instance_aggregators">
      <querytext>
	select a.aggregator_id 
          from acs_objects o, na_aggregators a 
         where a.aggregator_id = o.object_id
           and o.context_id = :package_id
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::apm::before_uninstantiate.select_unused_sources">
      <querytext>
         select s.source_id from na_sources s where source_id not in (
                 select distinct source_id from na_subscriptions 
        )
        </querytext>
    </fullquery>

</queryset>
