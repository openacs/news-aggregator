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
            	 link => :link,
             	 title => :title,
		 description => :description,
		 => sysdate,
		 => '0'
             );
             end
        </querytext>
    </fullquery>

<fullquery name="na_add_source.add_item">
      <querytext>
	     begin
             :1 := na_source.new (
                 source_id => :source_id,
            	 link => :link,
             	 title => :title,
		 description => :description,
		 => sysdate,
		 => '0'
             );
             end
        </querytext>
    </fullquery>

<fullquery name="na_cleanup_items.deleted_items">
      <querytext>
        delete from na_items where creation_date + 60 < sysdate
        </querytext>
    </fullquery>

</queryset>
