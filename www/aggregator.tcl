ad_page_contract {
    Include to create a new aggregator.

    @author Simon Carstensen
    @cvs-id $Id$
} {
    aggregator_id:integer,notnull,optional
    {return_url ""}
}

set package_id [ad_conn package_id]
set user_id [auth::require_login]

if { ![parameter::get -package_id $package_id -parameter PerUserAggregatorsP -default 0] } {
    # May this user create her own aggregator?
    permission::require_permission \
	-object_id $package_id \
	-privilege write
}

ad_form -name aggregator -action aggregator -select_query_name select_aggregator -form {
    {aggregator_id:integer(hidden),key}
    {aggregator_name:text
        {label "\#news-aggregator.Name\#"}
        {html {size 50}}
    }
    {description:text(textarea),optional
        {label "\#news-aggregator.Description\#"}
        {html {cols 60 rows 10}}
    }
    {public_p:text(radio)
        {label "\#news-aggregator.Public\#"}
        {options {{"[_ news-aggregator.Yes]" t} {"[_ news-aggregator.No]" f}}}
	{help_text "[_ news-aggregator.Help_Msg_aggregator]"}
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
    
    if { [exists_and_not_null return_url] } {
        ad_returnredirect $return_url
    } else {
	ad_returnredirect "[ad_conn package_url]$aggregator_id"
    }
    ad_script_abort

} -new_data {
    set new_aggregator_id [news_aggregator::aggregator::new \
                               -aggregator_name $aggregator_name \
                               -description $description \
                               -public_p $public_p]
    
    if { [exists_and_not_null return_url] } {
        ad_returnredirect $return_url
    } else {
        ad_returnredirect "[ad_conn package_url]$new_aggregator_id"
    }
    ad_script_abort
}
