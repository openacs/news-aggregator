
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
    'na_source.title'                 -- name_method
);


create table na_sources (
       source_id                    integer
                                    constraint na_sources_source_id_fk
                                    references acs_objects(object_id)
                                    constraint na_sources_source_id_pk
                                    primary key,
       package_id                   integer
                                    constraint na_sources_source_id_fk
                                    references apm_packages(package_id),
       owner_id                     integer 
                                    constraint na_sources_owner_id_fk
                                    references users(user_id),
       feed_url                     varchar(100)
                                    constraint na_sources_feed_url_nn
                                    not null,
       link                         varchar(100),
       title                        varchar(100),
       description                  varchar(255),
       updates                      integer,
       last_scanned                 timestamp,
       last_modified                varchar(30)
);

create table na_items (
       item_id                      integer
                                    default nextval('na_items_item_id_seq')
                                    primary key,
       source_id                    integer
                                    constraint na_sources_source_id_fk
                                    references na_sources (source_id),
       link                         varchar(255),
       title                        varchar(255),
       description                  text,
       creation_date                timestamp,
       deleted_p                    boolean
);

create sequence na_items_item_id_seq;

create or replace function na_source__new (
    integer,    -- source_id
    integer,    -- package_id
    integer,    -- owner_id
    varchar,    -- feed_url
    varchar,    -- link
    varchar,    -- title
    varchar,    -- description
    integer,    -- updates
    timestamp,  -- last_scanned
    varchar,    -- last_modified
    varchar,    -- object_type
    integer,    -- creation_user
    varchar     -- creation_ip
) returns integer as '
declare
    p_source_id         alias for $1;
    p_package_id        alias for $2;
    p_owner_id          alias for $3;
    p_feed_url          alias for $4;
    p_link              alias for $5;
    p_title             alias for $6;
    p_description       alias for $7;
    p_updates           alias for $8;
    p_last_scanned      alias for $9;
    p_last_modified     alias for $10;
    p_object_type       alias for $11;
    p_creation_user     alias for $12;
    p_creation_ip       alias for $13;
    v_source_id         integer;
begin
        v_source_id := acs_object__new (
                             p_source_id,
                             p_object_type,
                             current_timestamp,
                             p_creation_user,
                             p_creation_ip,
                             p_package_id
        );

        insert into na_sources (
                source_id, 
                package_id, 
                owner_id, 
                feed_url, 
                link, 
                title, 
                description, 
                updates, 
                last_scanned, 
                last_modified
        ) values (
                v_source_id,
                p_package_id, 
                p_owner_id, 
                p_feed_url, 
                p_link, 
                p_title, 
                p_description, 
                p_updates, 
                p_last_scanned, 
                p_last_modified
        );

          PERFORM acs_permission__grant_permission(
          v_source_id,
          p_owner_id,
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

        delete from na_items
                   where source_id = p_source_id;

        delete from acs_permissions
                   where object_id = p_source_id;

        delete from na_sources
                   where source_id = p_source_id;

        raise NOTICE ''Deleting na_source and its belonging items...'';
        PERFORM acs_object__delete(p_source_id);

        return 0;

end;' language 'plpgsql';

create or replace function na_item__new (
    integer,    -- source_id
    varchar,    -- link
    varchar,    -- title
    varchar,    -- description
    timestamp,  -- creation_date
    boolean    -- deleted_p
) returns integer as '
declare
    p_source_id                 alias for $1;
    p_link                      alias for $2;
    p_title                     alias for $3;
    p_description               alias for $4;
    p_creation_date             alias for $5;
    p_deleted_p                 alias for $6;
begin

        insert into na_items
          (source_id, link, title, description, creation_date, deleted_p)
        values
          (p_source_id, p_link, p_title, p_description, p_creation_date, p_deleted_p);

          return 1;

end;' language 'plpgsql';

create or replace function na_source__title (integer)
returns varchar as '
declare
    p_source_id      alias for $1;
    v_source_title    na_sources.title%TYPE;
begin
        select title 
        into   v_source_title
        from   na_sources
        where  source_id = p_source_id;

    return v_source_title;
end;
' language 'plpgsql';
