<?xml version="1.0"?>

<queryset>

<fullquery name="aggregator_info">
<querytext>
	select aggregator_id
	from na_aggregators
	where aggregator_id = :aggregator_id
</querytext>
</fullquery>

<fullquery name="unsave_item">
<querytext>
	delete from na_saved_items
	where item_id = :item_id
	and aggregator_id = :aggregator_id
</querytext>
</fullquery>

</queryset>
