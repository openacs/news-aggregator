<?xml version="1.0"?>

<queryset>

<fullquery name="na_update_sources.sources">
      <querytext>
        select source_id,
               owner_id,
               feed_url,
               last_modified
               from na_sources
        </querytext>
    </fullquery>

<fullquery name="na_update_source.update_item">
      <querytext>
        update na_items
        set link = :link,
            title = :title,
            description = :description,
            creation_date = now()
        where item_id = :item_id
        </querytext>
    </fullquery>

<fullquery name="na_add_source.source">
      <querytext>
        select 1 from na_sources where owner_id = :owner_id AND feed_url =:feed_url
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
        </querytext>
    </fullquery>

</queryset>
