<?xml version="1.0"?>

<queryset>

    <fullquery name="select_oldest_aggregator">
    	<querytext>
	    select aggregator_id
	    from   na_aggregators a,
                   acs_objects o
	    where  a.aggregator_id = o.object_id
            and    creation_user = :user_id
            and    aggregator_id != :delete_aggregator_id
            and    a.package_id = :package_id
            order  by creation_date
            limit  1
	</querytext>
    </fullquery>

</queryset>
