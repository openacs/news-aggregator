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

<fullquery name="na_update_source.update_source">
      <querytext>
        update na_sources
        set link = :link,
            title = :title,
            description = :description,
 	    updates = (updates + 1),
	    last_scanned = sysdate,
	    last_modified = :last_modified
        where source_id = :source_id
        </querytext>
    </fullquery>

</queryset>
