<?xml version="1.0"?>

<queryset>

    <fullquery name="select_user_name">
          <querytext>
                select p.first_names || ' ' || p.last_name as user_name
                from   users u join
                       persons p on (u.user_id = p.person_id)
                where  u.user_id = :user_id
          </querytext>
    </fullquery>

</queryset>
