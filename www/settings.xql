<?xml version="1.0"?>

<queryset>

    <fullquery name="select_aggregators">
          <querytext>
           select a.aggregator_id,
                  a.aggregator_name,
                  a.public_p,
                  u.default_aggregator
           from   na_aggregators a join
                  acs_objects o on (o.object_id = a.aggregator_id) join
                  na_user_preferences u on (o.creation_user = u.user_id)
           where  a.package_id = :package_id
           and    u.user_id = :user_id
           order  by a.aggregator_name
          </querytext>
    </fullquery>

</queryset>
