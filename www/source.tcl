ad_page_contract {
    View source.

    @author Simon Carstensen
} {
    source_id:integer
}

set write_p [permission::permission_p \
                 -object_id $source_id \
                 -privilege write]

db_1row source_info {}

set page_title $title
set context [list $page_title]
