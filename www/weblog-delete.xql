<?xml version="1.0"?>

<queryset>

    <fullquery name="delete_weblog">
          <querytext>
                delete from na_weblogs
                where  weblog_id = :weblog_id
                and    user_id = :user_id
                and    package_id = :package_id
          </querytext>
    </fullquery>

</queryset>
