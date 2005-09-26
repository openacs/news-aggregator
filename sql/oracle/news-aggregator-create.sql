--
-- news-aggregator-create.sql
-- 
-- @author Simon Carstensen
-- 
-- @cvs-id $Id: news-aggregator.sql
--

declare
begin
    acs_object_type.create_type(
        object_type => 'na_source',
        pretty_name => 'Source',
        pretty_plural => 'Sources',
        supertype => 'acs_object',
        table_name => 'na_sources',
        id_column => 'source_id',
        package_name => null,
        abstract_p => 'f',
        type_extension_table => null,
        name_method => 'na_source.title'
    );
end;
/
show errors



create table na_sources (
       source_id                constraint na_sources_source_id_fk
                                references acs_objects(object_id)
                                constraint na_sources_source_id_pk
                                primary key,
       package_id            	constraint na_sources_package_id_fk
                                references apm_packages(package_id),
       owner_id                 constraint na_sources_owner_id_fk
			   	references users(user_id),
       feed_url                 varchar(100)
                                constraint na_sources_feed_url_nn
                                not null,
       link			varchar(100),
       title                    varchar(100),
       description              varchar(255),
       updates                  integer,
       last_scanned             date,
       last_modified		varchar(30)
);



create table na_items (
       item_id                      integer constraint na_items_pk
                                    primary key,
       source_id		    constraint na_items_source_id_fk
                                    references na_sources (source_id),
       link                         varchar(255),
       title                        varchar(255),
       description                  clob,
       creation_date                date,
       deleted_p		    char(1) default '0'
);



create sequence na_items_seq;

@@ news-aggregator-package-create
