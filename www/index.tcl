#packages/news-aggregator/index.tcl
ad_page_contract {
    The News Aggregator index page.

    @author Simon Carstensen simon@bcuni.net
    @creation-date Jan 2004
} {
    item_id:integer,notnull,optional,multiple
} -properties {
    context_bar:onevalue  
}

ad_maybe_redirect_for_registration

set user_id [ad_conn user_id]

set context_bar [ad_context_bar]

if { ![empty_string_p [ad_parameter "blogger_url"]] } {
    set blogger_url "/[ad_parameter "blogger_url"]/entry-edit"
}

ad_form -name items -form {
    {delete_submit:text(submit) {label "Delete" } }
} -on_submit {
    if {[exists_and_not_null item_id]} {
	foreach delete_id $item_id {
	    db_dml delete_item { *SQL* }
	}
    }

    ad_returnredirect "."
    ad_script_abort
}

set limit [ad_parameter "number_of_items_shown"]

db_multirow -extend { content diff update_url } items items { *SQL* } {

    set text_only [util_remove_html_tags $item_description]

    if {[exists_and_not_null item_title] && ![string equal -nocase $item_title $text_only] } {
        set content "<a href=\"$item_link\">$item_title</a>. $item_description"
    } else {
        set content $item_description
    }

    set diff [na_last_scanned [expr [expr [clock seconds] - [clock scan $last_scanned]] / 60]]

    set update_url "source-update?[export_vars { user_id source_id feed_url last_scanned}]"
}

ad_return_template
