<?xml version="1.0"?>

<queryset>

    <fullquery name="sources">
        <querytext>
                    select title,
			   source_id,
			   feed_url,
			   link,
			   description,
			   updates,
                           to_char(last_scanned, 'YYYY-MM-DD HH24:MI:SS') as last_scanned
                    from   na_sources
                    where  owner_id = :user_id
                    order  by lower(title)
        </querytext>
    </fullquery>

</queryset>
