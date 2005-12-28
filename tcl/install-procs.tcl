ad_library {
    Procedures for initializing service contracts etc. for the
    news aggregator. Should only be executed once upon installation.
    
    @creation-date 2003-07-04
    @author Simon Carstensen (simon@bcuni.net)
    @author Guan Yang (guan@unicast.org)
}

namespace eval news_aggregator::install {}


###############
#
# Install procs
#
###############

ad_proc -private news_aggregator::install::feed {
    -package_id:required
    -source_id:required
} {
    if { ![db_0or1row feed_exists_p {}] } {
        db_dml insert_feed {}
    }
}

ad_proc -private news_aggregator::install::after_install {
    -package_id:required
} {
    News Aggregator package install proc
} {    
    set user_id [ad_conn user_id]

    set feeds {
        http://www.bbc.co.uk/syndication/feeds/news/ukfs_news/front_page/rss091.xml
        http://boingboing.net/rss.xml
        http://caterina.net/index.rdf
        http://www.csmonitor.com/rss/top.rss
        http://weblog.siliconvalley.com/column/dangillmor/index.xml
        http://www.dictionary.com/wordoftheday/wotd.rss
        http://partners.userland.com/nytRss/nytHomepage.xml
        http://www.theregister.co.uk/tonys/slashdot.rdf
        http://www.wired.com/news_drop/netcenter/netcenter.rdf
    }

    foreach feed_url $feeds {
        set source_id [news_aggregator::source::new \
                           -feed_url $feed_url \
                           -user_id $user_id \
                           -package_id $package_id]

        news_aggregator::install::feed \
            -package_id $package_id \
            -source_id $source_id
    }
}
