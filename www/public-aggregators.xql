<?xml version="1.0"?>

<queryset>

    <fullquery name="select_aggregators">
          <querytext>
           select aggregator_id,
                  aggregator_name
           from   na_aggregators
           where  package_id = :package_id
           and    public_p = true
           order  by aggregator_name
          </querytext>
    </fullquery>

</queryset>
