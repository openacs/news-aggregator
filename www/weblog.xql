<?xml version="1.0"?>

<queryset>

    <fullquery name="weblog_select">
          <querytext>
                select weblog_id,
                       weblog_name,
			blog_type,
			base_url
                from   na_weblogs
                where  weblog_id = :weblog_id
          </querytext>
    </fullquery>

</queryset>
