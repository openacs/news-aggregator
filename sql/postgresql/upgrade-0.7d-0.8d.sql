--
-- News Aggregator upgrade script from 0.7d to 0.8d
--
-- @author Guan Yang (guan@unicast.org)
-- @creation-date 2004-06-01
-- @cvs-id $Id$
--

alter table na_subscriptions add source_title varchar(100);
alter table na_subscriptions add show_description_p boolean;
update na_subscriptions set show_description_p = true;
alter table na_subscriptions alter column show_description_p set default true;
alter table na_subscriptions alter column show_description_p set not null;

alter table na_items add author varchar(100);
alter table na_items add comment_page varchar(200);
alter table na_items add pub_date timestamptz;
