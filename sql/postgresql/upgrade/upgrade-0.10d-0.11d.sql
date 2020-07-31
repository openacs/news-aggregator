begin;

--
-- Refedefine aggregator foreign key constraints to avoid the need for
-- package uninstantiation callbacks
--

alter table na_aggregators drop constraint na_aggregators_pid_fk;
alter table na_aggregators add constraint na_aggregators_pid_fk foreign key (package_id) references apm_packages(package_id) on delete cascade;

alter table na_saved_items drop constraint na_saved_items_aid_fk;
alter table na_saved_items add constraint na_saved_items_aid_fk foreign key (aggregator_id) references na_aggregators(aggregator_id) on delete cascade;

alter table na_purges drop constraint na_purges_aid_fk;
alter table na_purges add constraint na_purges_aid_fk foreign key (aggregator_id) references na_aggregators(aggregator_id) on delete cascade;

alter table na_subscriptions drop constraint na_subscriptions_aid_fk;
alter table na_subscriptions add constraint na_subscriptions_aid_fk foreign key (aggregator_id) references na_aggregators(aggregator_id) on delete cascade;

alter table na_user_preferences drop constraint na_user_prefs_default_fk;
alter table na_user_preferences add constraint na_user_prefs_default_fk foreign key (default_aggregator) references na_aggregators(aggregator_id) on delete set null;

create or replace function na_aggregator__delete (
    p_aggregator_id na_aggregators.aggregator_id%TYPE -- aggregator_id
)
returns integer as $$
begin
    PERFORM acs_object__delete(p_aggregator_id);
    return 0;
end;
$$ language 'plpgsql';

end;
