<?xml version="1.0"?>

<queryset>

    <fullquery name="select_aggregator">
          <querytext>
                select aggregator_id,
                       aggregator_name,
                       description,
                       public_p
                from   na_aggregators
                where  aggregator_id = :aggregator_id
          </querytext>
    </fullquery>

</queryset>
