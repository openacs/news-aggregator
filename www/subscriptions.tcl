#packages/news-aggregator/subscriptions.tcl

ad_page_contract {
  The News Aggregator subscription page.

  @author Simon Carstensen (simon@bcuni.net)
  @creation-date Jan 2003
} {
    source_id:integer,notnull,optional,multiple
    {feed_url ""}
} -properties {
    context_bar:onevalue
}

ad_maybe_redirect_for_registration

permission::require_permission \
    -object_id [ad_conn package_id] \
    -privilege write

set user_id [ad_conn user_id]

set context_bar [ad_context_bar "Add Subscription"]

set package_id [ad_conn package_id]

ad_form -name add_subscription -form {

    new_source_id:key

    {feed_url:text(text) {value "http://"} {label "URL:"} {html { size 55 }}}
    {add_submit:text(submit) {label "Add"}}
} -validate {
    {feed_url
	{[exists_and_not_null feed_url] && ![string equal "http://" $feed_url]} "You must specify a URL."
    }
} -new_data {
    na_add_source $feed_url $user_id $package_id :key
    ad_returnredirect "subscriptions"
    ad_script_abort
}

db_multirow sources sources { *SQL* }

ad_form -name delete_subscription -form {

    {delete_submit:text(submit) {label "Unsubscribe" } }
} -on_submit {
    if {[exists_and_not_null source_id]} {
	foreach delete_id $source_id {
	    db_exec_plsql delete_source { *SQL* }
	}
    }

    ad_returnredirect "subscriptions"
    ad_script_abort
}

ad_return_template
