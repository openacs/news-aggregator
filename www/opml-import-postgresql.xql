<?xml version="1.0" encoding="iso-8859-1"?>

<queryset>
    <rdbms>
        <type>postgresql</type>
        <version>7.1</version>
    </rdbms>
    
    <fullquery name="aggregator_source_urls">
        <querytext>
            select
                feed_url
            from
                na_sources f,
                na_subscriptions u
            where
                u.aggregator_id = :aggregator_id
            and u.source_id = f.source_id
        </querytext>
    </fullquery>
</queryset>    
