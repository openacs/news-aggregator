<?xml version="1.0"?>

<queryset>

<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="aggregator_info">
<querytext>
	select aggregator_id
	from na_aggregators
	where aggregator_id = :aggregator_id
</querytext>
</fullquery>

<fullquery name="save_item">
<querytext>
	insert into na_saved_items (
		item_id,
		aggregator_id
	) values (
		:item_id,
		:aggregator_id
	)
</querytext>
</fullquery>

</queryset>
