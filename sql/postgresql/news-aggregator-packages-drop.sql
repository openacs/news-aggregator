-- Drop script for the News Aggregator application
-- @author Simon Carstensen (simon@bcuni.net)
-- @creation-date 2003-05-21


-- drop functions associated with weblogs
drop function na_weblog__delete(integer);
drop function na_weblog__name(integer);
drop function na_weblog__new(integer, integer, varchar, varchar, varchar, integer, varchar);
select acs_object_type__drop_type('na_weblog', true);

--drop na_subscription functions
drop function na_subscription__new (
    integer,      -- aggregator_id
    integer,      -- source_id
    timestamptz   -- creation_date
);

--drop na_item functions
drop function na_item__new (
    integer,      -- source_id
    varchar,      -- link
    varchar,      -- guid
    varchar,      -- original_guid 
    boolean,      -- permalink_p
    varchar,      -- title
    varchar,       -- description
    varchar,      -- content_encoded
    varchar,      -- author
    timestamptz     -- pub_date
);

--drop na_source functions
drop function na_source__name(
    integer         -- source_id
);

drop function na_source__delete(
    integer         -- source_id
);

drop function na_source__new(
    integer,      -- source_id
    varchar,      -- feed_url
    varchar,      -- link
    varchar,      -- title
    varchar,      -- description
    varchar,      -- last_modified
    boolean,      -- listed_p
    integer,      -- package_id
    integer,      -- creation_user
    varchar       -- creation_ip
);

--drop na_aggregator functions
drop function na_aggregator__name (
    integer     -- aggregator_id
);

drop function na_aggregator__delete (
    integer     -- aggregator_id
);

drop function na_aggregator__new (
    integer,    -- aggregator_id
    varchar,    -- aggregator_name
    varchar,    -- description
    integer,    -- package_id
    boolean,    -- public_p
    integer,    -- creation_user
    varchar     -- creation_ip
);
