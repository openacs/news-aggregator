--drop na_item functions
drop function na_item__new (integer,varchar,varchar,varchar,timestamptz,boolean);

--drop na_item table
drop table na_items;
drop sequence na_items_item_id_seq;

--drop na_source functions
drop function na_source__new (integer,integer,integer,varchar,varchar,varchar,varchar,integer,timestamptz,varchar,varchar,integer,varchar);
drop function na_source__delete (integer);
drop function na_source__title (integer);

delete from acs_permissions where object_id in (select source_id from na_sources);

--drop na_source objects
create function inline_0 ()
returns integer as '
declare
	object_rec		record;
begin
	for object_rec in select object_id from acs_objects where object_type=''na_source''
	loop
		perform acs_object__delete( object_rec.object_id );
		end loop;

		return 0;
end;' language 'plpgsql';

select inline_0();
drop function inline_0();

--drop na_source table
drop table na_sources;

--drop na_source type
select acs_object_type__drop_type(
          'na_source',
	  	  't'
       );
