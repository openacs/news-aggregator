<?xml version="1.0"?>

<queryset>

    <fullquery name="find_default">
    	<querytext>
	    select default_aggregator
	    from   na_user_preferences
	    where  user_id = :user_id
	</querytext>
    </fullquery>

    <fullquery name="select_oldest_aggregator">
    	<querytext>
	    select min(aggregator_id)
	    from   na_aggregators a,
                   acs_objects o
	    where  a.aggregator_id = o.object_id
            and    creation_user = :user_id
            and    aggregator_id != :delete_aggregator_id
            order  by creation_date
	</querytext>
    </fullquery>

</queryset>
