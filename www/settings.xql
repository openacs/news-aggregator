<?xml version="1.0"?>

<queryset>

    <fullquery name="select_aggregators">
          <querytext>
          select a.aggregator_id,
                 a.aggregator_name,
                 a.public_p,
                 acs_permission__permission_p(a.aggregator_id,:user_id,'write') as write_p
           from  na_aggregators a
           where a.package_id = :package_id
             and acs_permission__permission_p(a.aggregator_id,:user_id,'read')
           order by a.aggregator_name;
          </querytext>
    </fullquery>

    <fullquery name="aggregator_exists">
          <querytext>
          select 1
           from  na_aggregators a
           where aggregator_id = :aggregator_id
          </querytext>
    </fullquery>

</queryset>
