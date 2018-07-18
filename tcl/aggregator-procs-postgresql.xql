<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="news_aggregator::aggregator::items_sql.items">
      <querytext>
	select s.source_id,
               s.link,
               s.description,
               s.title,
               to_char(i.creation_date, 'YYYY-MM-DD HH24:MI:SS') as last_scanned,
               to_char(i.creation_date, 'YYYY-MM-DD HH24') as sort_date,
	       s.feed_url,
	       i.item_id,
               i.title as item_title,
               i.link as item_link,
               i.description as item_description,
               i.content_encoded,
               i.guid as item_guid,
               i.original_guid as item_original_guid,
               i.permalink_p as item_permalink_p,
               i.author as item_author,
               to_char(i.pub_date at time zone 'UTC', 'YYYY-MM-DD HH24:MI:SS') as item_pub_date,
               s.last_modified
        from   (
                   na_aggregators a join
                   na_subscriptions su on (a.aggregator_id = su.aggregator_id)
               ) join
               na_items i on (su.source_id = i.source_id)
               join na_sources s on (i.source_id = s.source_id)
	where  a.package_id = :package_id
        and    a.aggregator_id = :aggregator_id
            $items_purges
	order  by i.item_id desc
	limit  $sql_limit
</querytext>
</fullquery>

<partialquery name="news_aggregator::aggregator::items_sql.items_purges">
    <querytext>
	and    ((i.item_id > coalesce(a.aggregator_bottom, 0)) or
		(i.item_id in (select item_id from na_saved_items
			       where aggregator_id = :aggregator_id)))
    </querytext>
</partialquery>

    <fullquery name="news_aggregator::aggregator::as_opml.maintainer">
    <querytext>
      select
      		email,
		person__name(party_id) as person_name,
		to_char(o.creation_date, 'Dy, DD Mon YYYY HH24:MI:SS TZ') as creation_date,
		to_char(o.creation_date, 'Dy, DD Mon YYYY HH24:MI:SS TZ') as modified_date
      from
      		na_aggregators a,
		parties p,
		acs_objects o
      where
               a.aggregator_id = o.object_id and a.maintainer_id = p.party_id
	       and a.aggregator_id = :aggregator_id
	       </querytext>
	       </fullquery>
    
    <fullquery name="news_aggregator::aggregator::as_opml.subscriptions">
        <querytext>
	  select
	  	feed_url,
		link,
		title,
		description
	  from
	  	na_sources s,
		na_subscriptions su
	  where
	  	s.source_id = su.source_id
		and su.aggregator_id = :aggregator_id
	  order by lower(title)
	</querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::purge.count_purges">
        <querytext>
		select count(purge_id)
		from na_purges
		where aggregator_id = :aggregator_id
	</querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::purge.get_range">
    	<querytext>
		select max(top) as max_top, min(bottom) as min_bottom,
			nextval('na_purges_seq') as purge_id
		from na_purges
		where aggregator_id = :aggregator_id
	</querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::purge.aggregator_purge">
    	<querytext>
		update na_aggregators
		set aggregator_bottom = :aggregator_bottom
		where aggregator_id = :aggregator_id
	</querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::purge.purge_all_purges">
        <querytext>
		delete from na_purges
		where aggregator_id = :aggregator_id
	</querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::purge.insert_purge">
        <querytext>
		insert into na_purges
			(purge_id, top, bottom, aggregator_id, purge_date)
		values
			(:purge_id, :top, :bottom, :aggregator_id, now())
	</querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::set_user_default.create_pref">
    	<querytext>
		insert into na_user_preferences
			(user_id, default_aggregator)
		values
			(:user_id, :aggregator_id)
	</querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::set_user_default.set_default">
    	<querytext>
		update na_user_preferences
		set default_aggregator = :aggregator_id
		where user_id = :user_id
	</querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::user_default.find_default">
    	<querytext>
	    select
	        default_aggregator
	    from
	    	na_user_preferences
	    where
	    	user_id = :user_id
	</querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::user_default.lowest_aggregator">
          <querytext>
                select min(object_id) as aggregator_id
                from   acs_objects
                where  object_type = 'na_aggregator'
                and    creation_user = :user_id
          </querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::delete.delete_aggregator">
          <querytext>
                select na_aggregator__delete (
                        :aggregator_id
                );

          </querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::new.new_aggregator">
	  <querytext>
		select na_aggregator__new (
			null,
			:aggregator_name,
                        :description,
			:package_id,
			:public_p,
			:creation_user,
			:creation_ip
		)
	  </querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::edit.edit_aggregator">
    	 <querytext>
		update na_aggregators
		set
			aggregator_name = :aggregator_name,
                        description = :description,
			public_p = :public_p
		where
			aggregator_id = :aggregator_id
	 </querytext>
    </fullquery>

</queryset>
