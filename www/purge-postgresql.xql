<?xml version="1.0"?>

<queryset>

<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="aggregator_info">
	<querytext>
		select public_p from na_aggregators
		where aggregator_id = :aggregator_id
	</querytext>
</fullquery>

</queryset>
