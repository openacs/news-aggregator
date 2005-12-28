alter table na_user_preferences add column package_id integer constraint na_user_preferences_pid_fk references apm_packages(package_id);
alter table na_user_preferences drop constraint na_user_prefs_uid_pk;
