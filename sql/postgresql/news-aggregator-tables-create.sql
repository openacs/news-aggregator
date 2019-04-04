-- PostgreSQL tables for the News Aggregator package
--
-- @author Simon Carstensen (simon@bcuni.net)
-- @creation-date 2003-06-26


----------------
--
-- Aggregators
--
----------------

create table na_aggregators (
        aggregator_id		integer
				constraint na_aggregators_pk
				primary key
				constraint na_aggregators_aid_fk
				references acs_objects(object_id)
                                on delete cascade,
	aggregator_name		varchar(100)
				constraint na_aggregators_name_nn
				not null,
        description             text,
        package_id              integer
                                constraint na_aggregators_pid_fk
                                references apm_packages(package_id)
                                constraint na_aggregators_pid_nn
                                not null,
        maintainer_id           integer
                                constraint na_aggregators_mid_fk
                                references users(user_id)
                                constraint na_aggregators_mid_nn
                                not null,
	public_p		boolean default true,
        number_shown            integer
                                default '100',
        aggregator_bottom       integer
);


select acs_object_type__create_type (
    'na_aggregator',                  -- object_type
    'Aggregator',                     -- pretty_name
    'Aggregators',                    -- pretty_plural
    'acs_object',                     -- supertype
    'na_aggregators',                 -- table_name
    'aggregator_id',                  -- id_column
    null,                             -- package_name
    'f',                              -- abstract_p
    null,                             -- type_extension_table
    'na_aggregator.name'              -- name_method
);


----------------
--
-- Sources
--
----------------

create table na_sources (
       source_id                    integer
                                    constraint na_sources_pk
                                    primary key
                                    constraint na_sources_sid_fk
                                    references acs_objects(object_id)
                                    on delete cascade,
       feed_url                     varchar(500)
                                    constraint na_sources_fu_nn
                                    not null,
       link                         varchar(500),
       title                        varchar(500),
       description                  varchar(500),
       updates                      integer
				    default '0',
       last_scanned                 timestamptz
				    default current_timestamp,
       last_modified                varchar(100),
       last_modified_stamp          timestamptz,
       last_scan_ok_p		    boolean default true,
       stacktrace		    text,
       rss_source		    text,
       listed_p			    boolean default true
);


select acs_object_type__create_type (
    'na_source',                      -- object_type
    'Sources',                        -- pretty_name
    'Sources',                        -- pretty_plural
    'acs_object',                     -- supertype
    'na_sources',                     -- table_name
    'source_id',                      -- id_column
    null,                             -- package_name
    'f',                              -- abstract_p
    null,                             -- type_extension_table
    'na_source.name'                  -- name_method
);


----------------
--
-- Items
--
----------------

create sequence na_items_item_id_seq cache 1;
create table na_items (
       item_id                      integer
                                    default nextval('na_items_item_id_seq')
				    constraint na_items_pk
                                    primary key,
       source_id                    integer
                                    constraint na_items_sid_fk
                                    references na_sources(source_id)
                                    constraint na_items_sid_nn
                                    not null,
       link                         varchar(500),
       guid			    varchar(500),
       original_guid    varchar(500),
       permalink_p		    boolean 
                                    default true,
       title                        varchar(500),
       author                       varchar(100),
       comment_page                 varchar(200),
       description                  text,
       content_encoded              text,
       creation_date                timestamptz
				    default current_timestamp,
    pub_date                        timestamptz
);

create index na_items_guid_idx on na_items(guid);
create index na_items_source_id_idx on na_items(source_id);
ALTER TABLE na_items ADD CONSTRAINT na_items_unique_guid UNIQUE (guid,source_id);

create table na_saved_items (
       item_id			    integer
				    constraint na_saved_items_iid_fk
				    references na_items(item_id),
       aggregator_id		    integer
		                    constraint na_saved_items_aid_fk
				    references na_aggregators(aggregator_id),
       constraint na_saved_items_pk primary key(item_id, aggregator_id)
);

create table na_purges (
       purge_id	       integer
		       constraint na_purges_pk
		       primary key,
       top	       integer
		       constraint na_purges_top_nn
		       not null,
       bottom	       integer
		       constraint na_purges_bottom_nn
		       not null,
       aggregator_id   integer
		       constraint na_purges_aid_fk
		       references na_aggregators(aggregator_id)
		       constraint na_purges_aid_nn
		       not null,
       purge_date      timestamptz
		       default current_timestamp
);

create sequence na_purges_seq;


----------------
--
-- Subscriptions
--
----------------

create table na_subscriptions (
	aggregator_id		integer
                                constraint na_subscriptions_aid_fk
                                references na_aggregators(aggregator_id),
	source_id		integer
                                constraint na_subscriptions_sid_fk
                                references na_sources(source_id),
    source_title        varchar(100),
    show_description_p  boolean
                        constraint na_subscriptions_show_description_p_nn
                        not null
                        default true,
        creation_date		timestamptz
				default current_timestamp,
        constraint na_subscriptions_pk primary key (aggregator_id, source_id)
);

create index na_subscriptions_aid_idx on na_subscriptions(aggregator_id);

-------------------
--
-- User Preferences
--
-------------------

create table na_user_preferences (
	user_id			integer
				constraint na_user_prefs_uid_pk
				primary key
				constraint na_user_prefs_uid_fk
				references users(user_id),
	default_aggregator	integer
				constraint na_user_prefs_default_fk
				references na_aggregators(aggregator_id)
);


-----------------------
--
-- Pre-subscribed Feeds
--
-----------------------

-- source_id, package_id

create table na_presubscribed_feeds (
        source_id               integer
                                constraint na_presubscribed_feeds_sid_fk
                                references na_sources(source_id)
                                constraint na_presubscribed_feeds_sid_nn
                                not null,
        package_id              integer
                                constraint na_presubscribed_feeds_pid_fk
                                references apm_packages(package_id)
                                constraint na_presubscribed_feeds_pid_nn
                                not null
);

create sequence na_presubscribed_feeds_seq;


-------------------
--
-- Weblogs
--
-------------------

select acs_object_type__create_type (
	'na_weblog',			-- object_type
	'News Aggregator Weblog',	-- pretty_name
	'News Aggregator Weblogs',	-- pretty_plural
	'acs_object',			-- supertype
	'na_weblogs',			-- table_name
	'weblog_id',			-- id_column
	'news-aggregator',		-- package_name
	'f',				-- abstract_p
	null,				-- type_extension_table
	'na_weblog__name'		-- name_method
);

create table na_weblogs (
        weblog_id               integer
                                constraint na_weblogs_weblog_id_fk
				references acs_objects(object_id)
				constraint na_weblogs_weblog_id_nn
				not null,
        package_id              integer
                                constraint na_weblogs_pid_fk
                                references apm_packages(package_id)
                                constraint na_weblogs_pid_nn
                                not null,
        user_id                 integer
                                constraint na_weblogs_uid_fk
                                references users(user_id)
                                constraint na_weblogs_uid_nn
                                not null,
        weblog_name             varchar(100)
                                constraint na_weblogs_name_nn
                                not null,
        blog_type               varchar(100)
                                constraint na_weblogs_blog_type_nn
                                not null,
	base_url		varchar(500)
				constraint na_weblogs_base_url_nn
				not null,
        server                  varchar(500),
        port                    integer,
        path                    varchar(100),
        blogid                  integer,
        username                varchar(200),
        password                varchar(200)
);
