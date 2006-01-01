ad_page_contract {
    Create a new aggregator.

    @author Simon Carstensen
    @cvs-id $Id$
} {
    aggregator_id:integer,notnull,optional
    {return_url ""}
}

set page_title "Add an aggregator"
set context [list $page_title]
