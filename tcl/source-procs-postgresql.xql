<?xml version="1.0"?>

<queryset>

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

<partialquery name="news_aggregator::source::update_all.time_limit">
    <querytext>
        where  last_scanned < (now() - '00:48:00'::time)
</querytext>
</partialquery>

<fullquery name="news_aggregator::source::update_all.sources">
      <querytext>
        select source_id,
               feed_url,
               last_modified
        from   na_sources
        $time_limit
	order  by last_scanned asc
	$limit_sql
        </querytext>
    </fullquery>

<partialquery name="news_aggregator::source::update_all.sources_limit">
    <querytext>
	limit $limit
    </querytext>
</partialquery>


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
    
<fullquery name="news_aggregator::source::new.add_item_pub_date_now">
    <querytext>
        now()
    </querytext>
</fullquery>

<partialquery name="news_aggregator::source::new.add_item_pub_date">
    <querytext>
        :pub_date
    </querytext>
</partialquery>

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
                :content_encoded,
                :author,
                $pub_date_sql
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
