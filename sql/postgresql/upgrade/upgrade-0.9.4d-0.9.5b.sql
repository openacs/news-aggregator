alter table na_user_preferences alter column package_id set not null;
alter table na_user_preferences add constraint na_user_prefs_pk primary key (user_id, package_id);

