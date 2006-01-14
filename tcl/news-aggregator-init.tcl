# update sources every 15 mins
ad_schedule_proc -thread t 900 news_aggregator::source::update_all
# delete old items every day
ad_schedule_proc -thread t 86400 news_aggregator::items_cleanup
# time interval for both scheduled procs should be site-wide parameter
