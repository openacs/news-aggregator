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

drop function na_item__new (
    integer,      -- source_id
    varchar,      -- link
    varchar,      -- guid
    varchar,      -- original_guid 
    boolean,      -- permalink_p
    varchar,      -- title
    varchar,       -- description,
    varchar      -- content_encoded
);

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

