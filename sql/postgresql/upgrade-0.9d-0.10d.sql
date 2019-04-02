begin;

ALTER TABLE na_items ADD CONSTRAINT na_items_unique_guid UNIQUE (guid,source_id);

end;
