--
-- news-aggregator-package-create.sql
-- 
-- @author Simon Carstensen
-- 
-- @cvs-id $Id: news-aggregator-package-create.sql
--

create or replace package na_source
as

    function new (
        source_id in na_sources.source_id%TYPE default null,
        package_id in na_sources.package_id%TYPE,
        feed_url in na_sources.feed_url%TYPE default null,
        link in na_sources.link%TYPE default null,
	title in na_sources.title%TYPE default null,
	description in na_sources.description%TYPE default null,
        creation_user in acs_objects.creation_user%TYPE default null,
        creation_ip in acs_objects.creation_ip%TYPE default null
    ) return na_sources.source_id%TYPE;

    procedure delete (
        source_id in na_sources.source_id%TYPE
    );

    function title (
        source_id in na_sources.source_id%TYPE
    ) return na_sources.title%TYPE;

end na_source;
/
show errors

create or replace package body na_source
as

    function new (
	source_id in na_sources.source_id%TYPE default null,
        package_id in na_sources.package_id%TYPE,
        feed_url in na_sources.feed_url%TYPE default null,
        link in na_sources.link%TYPE default null,
	title in na_sources.title%TYPE default null,
	description in na_sources.description%TYPE default null,
        creation_user in acs_objects.creation_user%TYPE default null,
        creation_ip in acs_objects.creation_ip%TYPE default null
    ) return na_sources.source_id%TYPE
    is
        v_source_id na_sources.source_id%TYPE;
    begin

        v_source_id := acs_object.new(
            object_id => na_source.new.source_id,
            object_type => 'na_source',
            creation_date => sysdate,
            creation_user => na_source.new.creation_user,
            creation_ip => na_source.new.creation_ip,
            context_id => na_source.new.package_id
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
            na_source.new.package_id,
	    na_source.new.creation_user,
            na_source.new.feed_url,
            na_source.new.link,
            na_source.new.title,
            na_source.new.description,
	    '0',
            sysdate,
	    sysdate
        );

        return v_source_id;

    end new;

    procedure delete (
        source_id in na_sources.source_id%TYPE
    )
    is
    begin

        delete
        from na_sources
        where source_id = na_source.delete.source_id;

        acs_object.delete(na_source.delete.source_id);

    end delete;

    function title (
        source_id in na_sources.source_id%TYPE
    ) return na_sources.title%TYPE
    is
        v_title na_sources.title%TYPE;
    begin

        select title
        into v_title
        from na_sources
        where source_id = na_source.title.source_id;

        return v_title;

    end title;

end na_source;
/
show errors
