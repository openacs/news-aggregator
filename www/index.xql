<?xml version="1.0"?>

<queryset>

<fullquery name="delete_item">
      <querytext>
        update na_items set deleted_p = '1' where item_id = :delete_id
      </querytext>
</fullquery>

</queryset>
