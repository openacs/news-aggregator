<?xml version="1.0"?>

<queryset>

    <fullquery name="source_info">
          <querytext>
                select title,
                       link,
                       description,
                       last_scanned
                from   na_sources
                where  source_id = :source_id
          </querytext>
    </fullquery>

</queryset>
