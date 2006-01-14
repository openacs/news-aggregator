<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="sources">
        <querytext>
                    select s.title,
			   s.source_id,
			   s.feed_url,
			   s.link,
			   s.description,
			   s.updates,
                           su.aggregator_id,
                           su.show_description_p,
                           to_char(s.last_scanned, 'YYYY-MM-DD HH24:MI') as last_scanned,
                           to_char(s.last_modified_stamp, 'YYYY-MM-DD HH24:MI') as last_modified
                    from   na_sources s join (
                           na_subscriptions su  join
                           na_aggregators a on (a.aggregator_id = su.aggregator_id))
                           on  (s.source_id = su.source_id)
                    where  
                    	a.package_id = :package_id
                    and    a.aggregator_id = :aggregator_id
                    [ad_decode source "" "" [template::list::orderby_clause -orderby -name sources]]
        </querytext>
    </fullquery>

    <fullquery name="delete_source">
        <querytext>
                select na_source__delete(
                        :delete_id
                );

        </querytext>
    </fullquery>

</queryset>
