<?xml version="1.0"?>

<queryset>

    <fullquery name="select_aggregators">
          <querytext>
           select a.aggregator_name,
                  a.aggregator_id
           from   na_aggregators a join
                  acs_objects o on (o.object_id = a.aggregator_id) join
                  na_user_preferences u on (o.creation_user = u.user_id)
           where  a.package_id = :package_id
           and    u.user_id = :user_id
           and    a.aggregator_id != :aggregator_id
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
