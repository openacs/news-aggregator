<?xml version="1.0"?>

<queryset>

    <fullquery name="count_aggregators">
          <querytext>
            select count(*) 
            from   na_aggregators a,
                   acs_objects o
            where  a.aggregator_id = o.object_id
            and    o.creation_user = :user_id
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

</queryset>
