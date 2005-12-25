<?xml version="1.0"?>

<queryset>

<fullquery name="saved_items">
	<querytext>
		select item_id
		from na_saved_items
		where aggregator_id = :aggregator_id
	</querytext>
</fullquery>

<fullquery name="aggregator_info">
	<querytext>
          select aggregator_name, 
                 description as aggregator_description, 
                 public_p
          from   na_aggregators
          where  aggregator_id = :aggregator_id
	</querytext>
</fullquery>

<fullquery name="purges">
    <querytext>
        select
		top, bottom
	from
		na_purges
	where
		aggregator_id = :aggregator_id
 	order by top desc, bottom desc
    </querytext>
</fullquery>

</queryset>
