<?xml version="1.0"?>

<queryset>

    <fullquery name="select_aggregators">
          <querytext>
           select a.aggregator_name as move_to_name,
                  a.aggregator_id as move_to_id, 
                  acs_permission__permission_p(a.aggregator_id,:user_id,'write') as write_p
           from   na_aggregators a
           where  a.package_id = :package_id
           and not exists (select 1
                             from na_subscriptions s
                            where a.aggregator_id = s.aggregator_id
                              and source_id in ($sources))
           order  by aggregator_name
          </querytext>
    </fullquery>

    <fullquery name="count_aggregators">
          <querytext>
            select count(*) 
            from   na_aggregators a,
                   acs_objects o
            where  a.aggregator_id = o.object_id
            and    o.creation_user = :user_id
          </querytext>
    </fullquery>

    <fullquery name="select_aggregator_id">
          <querytext>
           select a.aggregator_id
           from   na_aggregators a join
                  acs_objects o on (o.object_id = a.aggregator_id) join
                  na_user_preferences u on (o.creation_user = u.user_id)
           where  a.package_id = :package_id
           and    u.user_id = :user_id
           and    a.aggregator_id != :aggregator_id
           order  by o.creation_date
          </querytext>
    </fullquery>

</queryset>
