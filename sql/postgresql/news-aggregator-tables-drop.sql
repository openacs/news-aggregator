-- Drop non-procedural data model of the News Aggregator application.
--
-- @author Simon Carstensen (simon@bcuni.net)
-- @creation-date 2003-06-27

drop table na_weblogs;
select acs_object_type__drop_type('na_weblog', true);

drop table na_presubscribed_feeds;
drop sequence na_presubscribed_feeds_seq;

drop table na_user_preferences;

drop table na_purges;
drop sequence na_purges_seq;

--drop na_item table
drop table na_saved_items;
drop index na_items_guid_idx;
drop index na_items_source_id_idx;
drop table na_items;
drop sequence na_items_item_id_seq;


--drop na_source table  and objects
drop table na_sources;

delete
from acs_objects
where object_type = 'na_source';

select acs_object_type__drop_type(
          'na_source',
	  	  't'
       );


--drop na_subscriptions table
drop index na_subscriptions_aid_idx;
drop table na_subscriptions;



-- drop na_aggregators table and objects
drop table na_aggregators;

delete
from acs_objects
where object_type = 'na_aggregator';

select acs_object_type__drop_type(
          'na_aggregator',
	  	  't'
       );
