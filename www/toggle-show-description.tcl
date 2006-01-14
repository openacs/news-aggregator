ad_page_contract {
    Toggle show_description_p

    @author Michael Steigman (michael@steigman.net)
    @creation-date 01-04-06
} {
    aggregator_id:integer
    source_id:integer
}

db_dml toggle_show_desc_p {
    update na_subscriptions
       set show_description_p = not show_description_p
     where aggregator_id = :aggregator_id
       and source_id = :source_id
}

ad_returnredirect subscriptions