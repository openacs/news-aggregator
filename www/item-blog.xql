<?xml version="1.0"?>

<queryset>

    <fullquery name="select_item">
          <querytext>
                select i.title as item_title,
                       i.description as item_description,
                       i.content_encoded,
                       i.link as item_link,
                       s.title,
                       s.link,
                       to_char(s.last_scanned, 'YYYY-MM-DD; HH24:MI:SS') as last_scanned
                from   na_items i join
                       na_sources s on (i.source_id = s.source_id)
                where  item_id = :item_id
          </querytext>
    </fullquery>
    
    <fullquery name="select_weblog">
        <querytext>
            select
                blog_type,
                base_url
            from
                na_weblogs
            where
                weblog_id = :weblog_id
        </querytext>
    </fullquery>

</queryset>
