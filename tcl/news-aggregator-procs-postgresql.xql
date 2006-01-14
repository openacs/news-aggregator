<?xml version="1.0"?>

<queryset>

<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="na_add_source.add_source">
        <querytext>
            select na_source__new (
                :source_id,
		:package_id,
                :owner_id,
		:feed_url,
		:link,
                :title,
                :description,
		'0',
                now(),
		:last_modified,
		'na_source',
                :owner_id,
                :creation_ip
                )
        </querytext>
    </fullquery>

<fullquery name="na_add_source.add_item">
      <querytext>
        select na_item__new (
                :source_id,
                :link,
                :title,
                :description,
                now(),
		'0'
        );
        </querytext>
    </fullquery>

<fullquery name="na_update_source.add_item">
      <querytext>
        select na_item__new (
                :source_id,
                :link,
                :title,
                :description,
                now(),
		'0'
        );
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::items_cleanup.vacuum">
      <querytext>
	delete
	from na_items
	where item_id not in (select item_id
			      from na_saved_items)
	and item_id < (select min(aggregator_bottom)
		       from na_aggregators)
	and creation_date < current_timestamp - '180 days' :: interval
--        delete from na_items where date + interval '2 month' < now()
        </querytext>
    </fullquery>

<fullquery name="na_update_source.update_source">
      <querytext>
        update na_sources
        set link = :link,
            title = :title,
            description = :description,
 	    updates = (updates + 1),
	    last_scanned = now(),
	    last_modified = :last_modified
        where source_id = :source_id
        </querytext>
    </fullquery>

    <fullquery name="na_update_source.item">
      <querytext>
        select deleted_p, item_id, i.title as item_title, i.description as item_description
        from na_sources s, na_items i 
        where owner_id = :owner_id 
        and s.source_id = i.source_id
	and i.$identifier = :$identifier
	and feed_url = :feed_url
	order by item_id
        limit 1
      </querytext>
    </fullquery>

</queryset>
