ad_page_contract {
    Create new weblog.

    @author Simon Carstensen
} {
    weblog_id:integer,optional
}

set page_title "New Weblog"
set context [list $page_title]

set blog_type_options [news_aggregator::weblog::blog_type_options]

ad_form -name weblog -select_query_name select_weblog -form {
    {weblog_id:integer(hidden),key}
    {blog_type:text(select)
        {label "Blog Type"}
        {options $blog_type_options}
    }
    {weblog_name:text
        {label "Name"}
	{html {size 40}}
    }
    {base_url:text
	{label "Base URL"}
	{html {size 40}}
    }
} -validate {
    {base_url
        {[util_url_valid_p $base_url]}
        "The base URL must be a valid URL for your weblog tool."
    }
} -edit_data {
    news_aggregator::weblog::edit \
        -weblog_id $weblog_id \
        -blog_type $blog_type \
	-base_url $base_url \
	-weblog_name $weblog_name
    
    ad_returnredirect settings
    ad_script_abort
} -new_data {
    set ip [ns_conn peeraddr]

    set new_weblog_id [news_aggregator::weblog::new \
                           -blog_type $blog_type \
                           -weblog_name $weblog_name \
			   -base_url $base_url \
			   -ip $ip]
    
    ad_returnredirect settings
    ad_script_abort
} -select_query_name weblog_select

