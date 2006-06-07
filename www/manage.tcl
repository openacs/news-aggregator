ad_page_contract {
    Manage an aggregator

    @author Michael Steigman (michael@steigman.net)
    @creation-date 12-27-2005
} {
    { aggregator_id:integer,optional "0" }
    { tab:optional "general" }
}

array set ag_info [news_aggregator::aggregator::aggregator_info -aggregator_id $aggregator_id]
set instance_name [apm_instance_name_from_id [ad_conn package_id]]

set context [list [list "." "$ag_info(aggregator_name)"]]
if { $tab eq "permissions" } {
    set page_title "Manage Permissions for $ag_info(aggregator_name)"
    lappend context { Manage Permissions }
} else {
    set page_title ""
}
