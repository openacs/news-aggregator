<?xml version="1.0"?>

<queryset>

<fullquery name="news_aggregator::install::before_uninstantiate.select_instance_aggregators">
      <querytext>
	select a.aggregator_id 
          from acs_objects o, na_aggregators a 
         where a.aggregator_id = o.object_id
           and o.context_id = :package_id
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::install::before_uninstantiate.select_instance_sources">
      <querytext>
	select s.source_id
          from acs_objects o, na_sources s
         where s.source_id = o.object_id
           and o.context_id = :package_id
        </querytext>
    </fullquery>

</queryset>