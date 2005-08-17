--
-- news-aggregator
-- 
-- Upgrade from 0.5d2 to 0.5d3
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

    procedure del (
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

    procedure del (
        source_id in na_sources.source_id%TYPE
    )
    is
    begin

        delete from na_items
                   where source_id = na_source.del.source_id;

        delete from acs_permissions
                   where object_id = na_source.del.source_id;

        delete from na_sources
        where source_id = na_source.del.source_id;

        acs_object.del(na_source.del.source_id);

    end del;

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

-- Package na_item
create or replace package na_item
as

    function new (
        source_id in na_items.source_id%TYPE default null,
        link in na_items.link%TYPE default null,
	title in na_items.title%TYPE default null,
	description in varchar default null,
        creation_date in na_items.creation_date%TYPE default sysdate,
        deleted_p in na_items.deleted_p%TYPE default '0'
    ) return integer;


end na_item;
/
show errors

create or replace package body na_item
as

    function new (
        source_id in na_items.source_id%TYPE default null,
        link in na_items.link%TYPE default null,
	title in na_items.title%TYPE default null,
	description in varchar default null,
        creation_date in na_items.creation_date%TYPE default sysdate,
        deleted_p in na_items.deleted_p%TYPE default '0'
    ) return integer
    is
        v_resultado integer;
	v_item_id na_items.item_id%TYPE;
    begin

	select na_items_seq.nextval into v_item_id from dual;

        insert into na_items
          (item_id, source_id, link, title, description, creation_date, deleted_p)
        values
          (v_item_id, 
	   na_item.new.source_id, 
	   na_item.new.link, 
	   na_item.new.title, 
	   na_item.new.description, 
	   na_item.new.creation_date, 
	   na_item.new.deleted_p);

	select 1 into v_resultado from dual;
	return v_resultado;
	end new;
end na_item;
/
show errors

