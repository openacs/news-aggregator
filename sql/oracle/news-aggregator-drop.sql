--
-- news-aggregator-drop.sql
-- 
-- @author Simon Carstensen
-- 
-- @cvs-id $Id: news-aggregator-drop.sql
--

begin

    for na_source in (select source_id from na_sources) loop

        na_source.del(na_source.source_id);
    end loop;

    acs_object_type.drop_type(
        object_type => 'na_source',
        cascade_p => 't'
    );

end;
/
show errors

@@ news-aggregator-package-drop

drop table na_items;
drop table na_sources;
