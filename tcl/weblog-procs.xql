<?xml version="1.0"?>

<queryset>

<fullquery name="news_aggregator::weblog::options.select_weblog_options">
      <querytext>
        select weblog_name,
               weblog_id
        from   na_weblogs
        where  user_id = :user_id
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::weblog::new.new_weblog">
      <querytext>
	select na_weblog__new (
		null,
		:package_id,
		:blog_type,
		:weblog_name,
		:base_url,
		:user_id,
		:ip
	)
      </querytext>
    </fullquery>

<fullquery name="news_aggregator::weblog::edit.edit_weblog">
      <querytext>
        update na_weblogs set blog_type = :blog_type,
                              base_url = :base_url,
			      weblog_name = :weblog_name
        where weblog_id = :weblog_id
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::weblog::new_post.weblog_info">
      <querytext>
        select weblog_name,
		blog_type,
		base_url
        from   na_weblogs
        where  weblog_id = :weblog_id
        </querytext>
    </fullquery>


</queryset>
