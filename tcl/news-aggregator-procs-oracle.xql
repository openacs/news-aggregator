<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="na_add_source.add_source">
        <querytext>
	     begin
             :1 := na_source.new (
                 source_id => :source_id,
            	 package_id => :package_id,
            	 feed_url => :feed_url,
            	 link => :link,
             	 title => :title,
		 description => :description,
		 creation_user => :owner_id,
            	 creation_ip => :creation_ip
             );
             end;
        </querytext>
    </fullquery>

<fullquery name="na_add_source.add_item">
      <querytext>
	     begin
             :1 := na_source.new (
                 source_id => :source_id,
            	 package_id => :package_id,
            	 feed_url => :feed_url,
            	 link => :link,
             	 title => :title,
		 description => :description,
		 creation_user => :owner_id,
            	 creation_ip => :creation_ip
             );
        </querytext>
    </fullquery>

<fullquery name="na_update_source.add_item">
      <querytext>
	     begin
             :1 := na_source.new (
                 source_id => :source_id,
            	 package_id => :package_id,
            	 feed_url => :feed_url,
            	 link => :link,
             	 title => :title,
		 description => :description,
		 creation_user => :owner_id,
            	 creation_ip => :creation_ip
             );
             end
        </querytext>
    </fullquery>

<fullquery name="na_cleanup_items.deleted_items">
      <querytext>
        delete from na_items where creation_date + 60 < sysdate
        </querytext>
    </fullquery>

<fullquery name="na_update_source.update_source">
      <querytext>
        update na_sources
        set link = :link,
            title = :title,
            description = :description,
 	    updates = (updates + 1),
	    last_scanned = sysdate,
	    last_modified = :last_modified
        where source_id = :source_id
        </querytext>
    </fullquery>

    <fullquery name="na_update_source.item">
      <querytext>
        select q.* from (
            select deleted_p, item_id, i.title as item_title, i.description as item_description
            from na_sources s, na_items i 
            where owner_id = :owner_id 
            and s.source_id = i.source_id
            and i.$identifier = :$identifier
            and feed_url = :feed_url
            order by item_id
        ) q where rownum = 1
      </querytext>
    </fullquery>


</queryset>
