ad_page_contract {
    Delete a weblog.

    @author Simon Carstensen (simon@bcuni.net)
    @creation-date 2003-07-16
} {
    weblog_id:integer
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

db_dml delete_weblog {}

ad_returnredirect settings
ad_script_abort
