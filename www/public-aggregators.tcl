ad_page_contract {
    Public Aggregators.

    @author Ola Hansson
    @creation-date 2004-05-16
} {
}

set page_title "Public News Feed Aggregators"
set context [list $page_title]

set package_id [ad_conn package_id]
set package_url [ad_conn package_url]

#set return_url [ad_conn url]
#set aggregator_link [export_vars -base "${package_url}aggregator" {return_url}]

template::list::create \
    -name "aggregators" \
    -multirow "aggregators" \
    -key aggregator_id \
    -row_pretty_plural "aggregators" \
    -elements {
        aggregator_name {
            label "Name"
            display_template {
                <a href="@aggregators.url@@aggregators.aggregator_id@/" title="View this aggregator"
                >@aggregators.aggregator_name@</a>
            }
            link_url_eval {}
            link_html { title "" }
        }
    }

db_multirow -extend { 
    url 
} aggregators select_aggregators {} {

    set url $package_url
}
