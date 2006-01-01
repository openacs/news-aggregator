<?xml version="1.0"?>

<queryset>

    <fullquery name="select_item">
          <querytext>
                select i.title as item_title,
                       i.description as item_description,
                       i.content_encoded,
                       i.link as item_link,
                       s.title,
                       s.link
                from   na_items i join
                       na_sources s on (i.source_id = s.source_id)
                where  item_id = :item_id
          </querytext>
    </fullquery>
    
    <fullquery name="select_weblog">
        <querytext>
            select blog_type,
                   base_url
              from na_weblogs
             where weblog_id = :weblog_id
             union 
            select 'larsblogger'as blog_type,
                   site_node__url(s.node_id) || 'entry-edit' as base_url
              from site_nodes s, apm_packages p 
             where s.object_id = p.package_id 
               and p.package_id = :weblog_id
        </querytext>
    </fullquery>

</queryset>
