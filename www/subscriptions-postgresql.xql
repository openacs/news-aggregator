<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="delete_source">
      <querytext>
        select na_source__delete(
                :delete_id
        );

      </querytext>
</fullquery>

</queryset>
