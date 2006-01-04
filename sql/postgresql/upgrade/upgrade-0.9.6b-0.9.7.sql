# Create a few indexes to speed up index page query
create index na_saved_items_aggregator_id_idx on na_saved_items(aggregator_id);
create index na_purges_aggregator_id_idx on na_purges(aggregator_id);
create index na_aggregators_package_id_idx on na_aggregators(package_id);
