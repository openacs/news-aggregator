<?xml version="1.0"?>

<queryset>

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


<fullquery name="news_aggregator::source::update_all.source_count">
    <querytext>
        select count(*)
        from na_sources
    </querytext>
</fullquery>

<fullquery name="news_aggregator::source::new.source">
      <querytext>
        select source_id
        from   na_sources 
        where  feed_url = :feed_url
        </querytext>
    </fullquery>

</queryset>
