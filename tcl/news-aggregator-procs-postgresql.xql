<?xml version="1.0"?>

<queryset>

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

</queryset>
