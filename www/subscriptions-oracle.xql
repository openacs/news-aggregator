<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="delete_source">
      <querytext>
             begin
	     na_source.del(
                source_id => :delete_id
             );
             end;
      </querytext>
</fullquery>

</queryset>
