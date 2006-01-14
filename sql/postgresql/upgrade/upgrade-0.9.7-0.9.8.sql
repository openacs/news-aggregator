-- set package_id to null as sources don't really belong to packages
create or replace function na_source__new (
    integer,      -- source_id
    varchar,      -- feed_url
    varchar,      -- link
    varchar,      -- title
    varchar,      -- description
    varchar,      -- last_modified
    boolean,      -- listed_p
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
    p_creation_user     alias for $8;
    p_creation_ip       alias for $9;
    v_source_id         integer;
begin
        v_source_id := acs_object__new (
                             p_source_id,
                             ''na_source'',
                             current_timestamp,
                             p_creation_user,
                             p_creation_ip,
                             null
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

        return v_source_id;

end;' language 'plpgsql';

-- MS: remove owner_id and package_id from na_sources as they are not used
-- title should be removed next if na_source remains an object (1/13/06)
alter table na_sources 
    drop column owner_id;

alter table na_sources 
    drop column package_id;

-- add on delete cascade so packages can uninstall cleanly
-- doing this for now, may eventually move this data to the user preferences package
alter table na_user_preferences
    drop constraint na_user_preferences_pid_fk;

alter table na_user_preferences
    add constraint na_user_preferences_pid_fk
        foreign key (package_id) 
        references apm_packages(package_id)
        on delete cascade;
