<?xml version="1.0"?>

<queryset>

<fullquery name="news_aggregator::source::new.source">
      <querytext>
        select source_id
        from   na_sources 
        where  feed_url = :feed_url
        </querytext>
    </fullquery>

</queryset>
