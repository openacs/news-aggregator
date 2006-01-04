<?xml version="1.0"?>

<queryset>

    <fullquery name="count_aggregators">
          <querytext>
            select acs_permission__permission_p(aggregator_id,:user_id,'write') as write_p
            from   na_aggregators
          </querytext>
    </fullquery>

    <fullquery name="select_name">
          <querytext>
            select a.aggregator_name 
            from   na_aggregators a, 
                   acs_objects o 
            where  o.object_id = a.aggregator_id
            and    a.aggregator_id != :aggregator_id 
            and    o.creation_user = :user_id
          </querytext>
    </fullquery>

    <fullquery name="select_other_feeds">
          <querytext>
            select s.title, s.source_id 
              from na_sources s 
             where source_id not in (select source_id 
                                       from na_subscriptions 
                                      where aggregator_id = :aggregator_id)
          </querytext>
    </fullquery>

</queryset>
