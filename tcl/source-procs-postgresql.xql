<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="news_aggregator::source::update.update_source_no_new">
    <querytext>
        update na_sources
	set last_scanned = now(),
	    title = :title,
	    link = :link,
	    description = :description
	where source_id = :source_id
    </querytext>
</fullquery>

<fullquery name="news_aggregator::source::update_all.source_count">
    <querytext>
        select count(*)
        from na_sources
    </querytext>
</fullquery>

<fullquery name="news_aggregator::source::update_all.sources">
      <querytext>
        select source_id,
               feed_url,
               last_modified
        from   na_sources
        where  last_scanned < (now() - '00:48:00'::time)
	order  by last_scanned asc
        limit  $limit
        </querytext>
    </fullquery>


<fullquery name="news_aggregator::source::update.items">
    <querytext>
        select  guid, original_guid, i.title, i.description
        from    na_items i join
                na_sources s on (i.source_id = s.source_id)
        where   s.feed_url = :feed_url
        and     guid in ($guids)   
	order by i.item_id asc
    </querytext>
</fullquery>

<fullquery name="news_aggregator::source::new.add_source">
        <querytext>
            select na_source__new (
                :source_id,
                :feed_url,
		        :link,
                :title,
                :description,
		        :last_modified,
                '1',
                :package_id,
                :user_id,
                :creation_ip
            )
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::source::new.add_item">
      <querytext>
        select na_item__new (
                :source_id,
                :link,
                :guid,
        boolean :permalink_p,
                :title,
                :description,
                :content_encoded
        );
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::source::update.update_source">
      <querytext>
        update na_sources
        set    link = :link,
               title = :title,
               description = :description,
 	       updates = (updates + 1),
	       last_scanned = now(),
	       last_modified = now(),
	       last_modified_stamp = now()
        where  source_id = :source_id
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::source::update.add_item">
      <querytext>
        select na_item__new (
                :source_id,
                :link,
                :guid,
                :original_guid,
        boolean :permalink_p,
                :title,
                :description,
                :content_encoded
        );
        </querytext>
    </fullquery>

    <fullquery name="news_aggregator::source::delete.delete_source">
          <querytext>
            select na_source__delete(
                    :source_id
            );
    
          </querytext>
    </fullquery>

</queryset>
