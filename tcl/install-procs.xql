<?xml version="1.0"?>

<queryset>

<fullquery name="news_aggregator::install::feed.insert_feed">
      <querytext>
           insert into na_presubscribed_feeds (
                source_id,
                package_id
           ) values (
                :source_id,
                :package_id
           )
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::install::feed.feed_exists_p">
      <querytext>
                select 1 
                from na_presubscribed_feeds 
                where source_id = :source_id
        </querytext>
    </fullquery>

</queryset>
