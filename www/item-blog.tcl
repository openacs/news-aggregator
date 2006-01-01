ad_page_contract {
    Post this item to user's weblog through Blogger API.

    @author Simon Carstensen
    @creation-date 2003-07-08
    @cvs-id $Id$
} {
    item_id:integer
}

set page_title "Post this item to your weblog"
set context [list $page_title]

db_1row select_item {}

if { [exists_and_not_null content_encoded] } {
    set content $content_encoded
} else {
    set text_only [util_remove_html_tags $item_description]
    
    if {[exists_and_not_null item_title] && ![string equal -nocase $item_title $text_only] } {
        set content "<a href=\"$item_link\">$item_title</a>. $item_description"
    } else {
        set content $item_description
    }
}

set user_id [ad_conn user_id]
set weblog_options [news_aggregator::weblog::options \
                        -user_id $user_id]
set weblog_p [expr [llength $weblog_options] > 0]

ad_form -name blog_item -form {
    {item_id:integer(hidden)
        {value $item_id}
    }
    {content:text(hidden)
        {value $content}
    }
    {weblog_id:integer(select)
        {options $weblog_options}
        {label "Select weblog:"}
    }
} -on_submit {

    set user_id [ad_conn user_id]
    
    permission::require_permission \
        -object_id $weblog_id \
        -privilege read

    db_1row select_weblog ""

    if { [exists_and_not_null content_encoded] } {
        set text $content_encoded
    } else {
        set text $item_description
    }

    set post_url [news_aggregator::weblog::get_post_url \
                    -blog_type $blog_type \
                    -base_url $base_url \
                    -title $item_title \
                    -text $text \
                    -link $item_link]
                    
    ad_returnredirect $post_url
    ad_script_abort
}
