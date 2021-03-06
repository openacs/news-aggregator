ad_page_contract {
    Create a new aggregator.

    @author Simon Carstensen
} {
    aggregator_id:integer,notnull,optional
    {return_url ""}
}

set package_id [ad_conn package_id]

if { ![parameter::get -package_id $package_id -parameter PerUserAggregatorsP -default 0] } {
    # May this user create her own aggregator?
    permission::require_permission \
        -object_id $package_id \
        -privilege write
}

set page_title "Create aggregator"
set context [list $page_title]

set user_id [auth::require_login]

ad_form -name aggregator -select_query_name select_aggregator -form {
    {aggregator_id:integer(hidden),key}
    {aggregator_name:text
        {label "Name"}
    }
    {description:text(textarea),optional
        {label "Description"}
        {html {cols 60 rows 10}}
    }
    {public_p:text(radio)
        {label "Public?"}
        {options {{"Yes" t} {"No" f}}}
        {help_text "A public aggregator is intended to be used by a group of people and will not have a Purge button. Instead, the most recent 100 items will be displayed."}
    }
    {return_url:text(hidden)
        {value $return_url}
    }
} -edit_data {
    news_aggregator::aggregator::edit \
        -aggregator_id $aggregator_id \
        -aggregator_name $aggregator_name \
        -description $description \
        -public_p $public_p

    if { $return_url ne "" } {
        ad_returnredirect $return_url
    } else {
        ad_returnredirect settings
    }
    ad_script_abort

} -new_data {
    set new_aggregator_id [news_aggregator::aggregator::new \
                               -aggregator_name $aggregator_name \
                               -description $description \
                               -public_p $public_p]

    if { $return_url ne "" } {
        ad_returnredirect $return_url
    } else {
        ad_returnredirect "[ad_conn package_url]$new_aggregator_id"
    }
    ad_script_abort
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
