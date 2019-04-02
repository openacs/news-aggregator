ad_page_contract {
    Page to load a file or URL with OPML for import.

    @author Guan Yang (guan@unicast.org)
    @creation-date 2003-07-18
    @cvs-id $Id$
} {
    aggregator_id:naturalnum,notnull
    opml_id:naturalnum,optional
    {format "opml"}
}

set user_id [auth::require_login]
set page_title "OPML Import"

permission::require_permission \
    -object_id $aggregator_id \
    -party_id $user_id \
    -privilege write

ad_form -name opml -action opml-import-2 -form {
    {url:text,optional
	{label "URL"}
	{help_text "The URL of an OPML file in mySubscriptions format."}
	{html {size 50}}}
    {opml_file:file,optional
	{label "File"}
	{help_text "This feature is not currently implemented."}}
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
