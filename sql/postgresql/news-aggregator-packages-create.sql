--
-- Postgresql packages for the News Aggregator package
--
-- @author Simon Carstensen (simon@bcuni.net)
-- @creation-date 2003-06-26


----------------
--
-- Aggregators
--
----------------

create or replace function na_aggregator__new (
    integer,    -- aggregator_id
    varchar,    -- aggregator_name
    varchar,    -- description
    integer,    -- package_id
    boolean,    -- public_p
    integer,    -- creation_user
    varchar     -- creation_ip
) returns integer as '
declare
    p_aggregator_id     alias for $1;
    p_aggregator_name   alias for $2;
    p_description       alias for $3;
    p_package_id        alias for $4;
    p_public_p          alias for $5;
    p_creation_user     alias for $6;
    p_creation_ip       alias for $7;
    v_aggregator_id          integer;
    v_max_item_id	     integer;
begin
        v_aggregator_id := acs_object__new (
                             p_aggregator_id,
                             ''na_aggregator'',
                             current_timestamp,
                             p_creation_user,
                             p_creation_ip,
                             p_package_id
        );

	select max(item_id) into v_max_item_id
		from na_items;
        
        insert into na_aggregators (
                aggregator_id, 
                aggregator_name,
                description,
                maintainer_id,
                package_id,
                public_p,
		aggregator_bottom
        ) values (
                v_aggregator_id,
                p_aggregator_name,
                p_description,
                p_creation_user,
                p_package_id,
                p_public_p,
		v_max_item_id
        );
        
        PERFORM acs_permission__grant_permission(
                    v_aggregator_id,
                    p_creation_user,
                    ''admin''
        );

        return v_aggregator_id;

end;' language 'plpgsql';


create or replace function na_aggregator__delete (
    integer -- aggregator_id
)
returns integer as '
declare
  p_aggregator_id   alias for $1;
begin

        delete from acs_permissions
                where object_id = p_aggregator_id;

        delete from na_subscriptions
                where aggregator_id = p_aggregator_id;
	
	update na_user_preferences
		set default_aggregator = null
		where default_aggregator = p_aggregator_id;

	delete from na_purges
		where aggregator_id = p_aggregator_id;

	delete from na_saved_items
		where aggregator_id = p_aggregator_id;
	
        delete from na_aggregators
                where aggregator_id = p_aggregator_id;

        PERFORM acs_object__delete(p_aggregator_id);

        return 0;

end;' language 'plpgsql';


create or replace function na_aggregator__name (integer)
returns varchar as '
declare
    p_aggregator_id      alias for $1;
    v_aggregator_name    na_aggregators.aggregator_name%TYPE;
begin
        select aggregator_name 
        into   v_aggregator_name
        from   na_aggregators
        where  aggregator_id = p_aggregator_id;

    return v_aggregator_name;

end;' language 'plpgsql'; 


----------------
--
-- Sources
--
----------------

create or replace function na_source__new (
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
) returns integer as '
declare
    p_source_id         alias for $1;
    p_feed_url          alias for $2;
    p_link              alias for $3;
    p_title             alias for $4;
    p_description       alias for $5;
    p_last_modified     alias for $6;
    p_listed_p          alias for $7;
    p_package_id        alias for $8;
    p_creation_user     alias for $9;
    p_creation_ip       alias for $10;
    v_source_id         integer;
begin
        v_source_id := acs_object__new (
                             p_source_id,
                             ''na_source'',
                             current_timestamp,
                             p_creation_user,
                             p_creation_ip,
                             p_package_id
        );

        insert into na_sources (
                source_id, 
                feed_url, 
                link, 
                title, 
                description, 
                last_scanned, 
                last_modified,
                listed_p
        ) values (
                v_source_id,
                p_feed_url, 
                p_link, 
                p_title, 
                p_description,
                current_timestamp, 
                p_last_modified,
                p_listed_p
        );

          PERFORM acs_permission__grant_permission(
                    v_source_id,
                    p_creation_user,
                    ''admin''
          );

        return v_source_id;

end;' language 'plpgsql';


create or replace function na_source__delete (
    integer -- source_id
)
returns integer as '
declare
  p_source_id   alias for $1;
begin

        delete from acs_permissions
                   where object_id = p_source_id;
	
	delete from na_purges
		where (top in (select item_id
				from na_items
				where source_id = p_source_id)
		    or bottom in (select item_id
		    		from na_items
				where source_id = p_source_id));

        delete from na_items
                where source_id = p_source_id;

        delete from na_subscriptions
                where source_id = p_source_id;
	
        delete from na_sources
                   where source_id = p_source_id;

        PERFORM acs_object__delete(p_source_id);

        return 0;

end;' language 'plpgsql';


create or replace function na_source__name (integer)
returns varchar as '
declare
    p_source_id      alias for $1;
    v_source_name    na_sources.title%TYPE;
begin
        select title 
        into   v_source_name
        from   na_sources
        where  source_id = p_source_id;

    return v_source_name;
end;
' language 'plpgsql';


----------------
--
-- Items
--
----------------

create or replace function na_item__new (
    integer,      -- source_id
    varchar,      -- link
    varchar,      -- guid
    varchar,      -- original_guid
    boolean,      -- permalink_p
    varchar,      -- title
    varchar,      -- description
    varchar,      -- content_encoded
    varchar,      -- author
    timestamptz   -- pub_date
) returns integer as '
declare
    p_source_id                 alias for $1;
    p_link                      alias for $2;
    p_guid                      alias for $3;
    p_original_guid             alias for $4;
    p_permalink_p               alias for $5;
    p_title                     alias for $6;
    p_description               alias for $7;
    p_content_encoded           alias for $8;
    p_author                    alias for $9;
    p_pub_date                  alias for $10;
begin

        insert into na_items (
           source_id,
           link, 
           guid,
           original_guid,
           permalink_p,
           title, 
           description,
           content_encoded,
           author,
           pub_date, 
           creation_date
        ) values (
           p_source_id,
           p_link, 
           p_guid,
           p_original_guid,
           p_permalink_p,
           p_title, 
           p_description,
           p_content_encoded,
           p_author,
           p_pub_date,
           current_timestamp
        );

        return 1;

end;' language 'plpgsql';


----------------
--
-- Subscriptions
--
----------------

create or replace function na_subscription__new (
    integer,      -- aggregator_id
    integer,      -- source_id
    timestamptz   -- creation_date
) returns integer as '
declare
    p_aggregtor_id                      alias for $1;
    p_source_id                         alias for $2;
    p_creation_date                     alias for $3;
begin

        insert into na_subscriptions (
           aggregator_id,
           source_id,
           creation_date
        ) values (
           p_aggregator_id,
           p_source_id,
           p_creation_date
        );

        return 1;

end;' language 'plpgsql';

create or replace function na_weblog__name (integer)
returns varchar as '
declare
    p_weblog_id         alias for $1;
    v_name              varchar;
begin
    select weblog_name into v_name
        from na_weblogs
        where weblog_id = p_weblog_id;
    return v_name;
end;
' language 'plpgsql';

create or replace function na_weblog__new (
    integer,     -- weblog_id
    integer,     -- package_id
    varchar,	 -- blog_type
    varchar,     -- weblog_name
    varchar,     -- base_url
    integer,     -- creation_user
    varchar      -- creation_ip
) returns integer as '
declare
    p_weblog_id               alias for $1;
    p_package_id           alias for $2;
    p_blog_type		alias for $3;
    p_weblog_name                 alias for $4;
    p_base_url           alias for $5;
    p_creation_user        alias for $6;
    p_creation_ip          alias for $7;
    v_weblog_id          integer;
begin
    v_weblog_id := acs_object__new (
        p_weblog_id,
        ''na_weblog'',
        current_timestamp,
        p_creation_user,
        p_creation_ip,
        p_package_id
    );

    insert into na_weblogs (
      weblog_id, 
      package_id,
      blog_type,
      weblog_name,
      base_url,
      user_id
    ) values (
      v_weblog_id, 
      p_package_id,
      p_blog_type,
      p_weblog_name,
      p_base_url,
      p_creation_user
    );

    return v_weblog_id;   
end;
' language 'plpgsql';

create or replace function na_weblog__delete (integer)
returns integer as '
declare
    p_weblog_id alias for $1;
begin
    delete from na_weblogs
        where weblog_id = p_weblog_id;

    PERFORM acs_object__delete(p_weblog_id);
    return 0;
end;
' language 'plpgsql';

