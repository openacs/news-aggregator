<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

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

<fullquery name="na_cleanup_items.deleted_items">
      <querytext>
        delete from na_items where date + interval '2 month' < now()
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

</queryset>
