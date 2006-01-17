ad_library {
    Test cases for the news aggregator package

    @author Michael Steigman (michael@steigman.net)
    @creation-date 2006-01-17
    @cvs-id $Id$

}

aa_register_case \
    -cats {smoke api} \
    -procs {
	news_aggregator::aggregator::new
	news_aggregator::aggregator::delete
	news_aggregator::aggregator::aggregator_info
    } \
    aggregator_api_test \
    {
        A simple test that adds, retrieves, and deletes an aggregator.
    } {
        aa_run_with_teardown \
            -rollback \
            -test_code  {
                set name [ad_generate_random_string]
		set pkg_id [db_string pkg_id "select package_id from apm_packages limit 1"]
                set aggregator_id [news_aggregator::aggregator::new -aggregator_name $name -package_id $pkg_id]
                aa_true "Aggregator creation succeeded" [exists_and_not_null aggregator_id]
                
		set ag_info [news_aggregator::aggregator::aggregator_info -aggregator_id $new_id]
                aa_true "Aggregator contains correct title" [string equal $ag_info(aggregator_name) $name]
                
		news_aggregator::aggregator::delete -aggregator_id $new_id
                
                set get_again [catch {
		    set ag_info [news_aggregator::aggregator::aggregator_info -aggregator_id $new_id]
		}]
                aa_false "After deleting an aggregator, retrieving it fails" [expr $get_again == 0]
            }
    }

aa_register_case \
    -cats {smoke api} \
    -procs {
	news_aggregator::source::new
	news_aggregator::source::delete
    } \
    source_api_test \
    {
        A simple test that adds and deletes an RSS feed (OpenACS News).
    } {
        aa_run_with_teardown \
            -rollback \
            -test_code  {
                set source_info [news_aggregator::aggregator::new \
				-feed_url http://openacs.org/news/rss/rss.xml -array 1]
		set source_id $source_info(source_id)
                aa_true "Source add succeeded" [exists_and_not_null source_id]
                
		news_aggregator::source::delete -source_id $source_id
            }
    }
