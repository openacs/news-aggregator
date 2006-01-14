ad_library {
    Callback procs for handling APM logic
    
    @creation-date 2005-28-12
    @author Michael Steigman (michael@steigman.net)
}

namespace eval news_aggregator::apm {}

ad_proc -private news_aggregator::apm::before_uninstantiate {
    -package_id:required
} {
    Callback proc to delete package aggregators and sources before removing an instance.
} {    
    db_foreach select_instance_aggregators {} {
	news_aggregator::aggregator::delete -aggregator_id $aggregator_id
    }

    # delete any dangling sources
    db_foreach select_unused_sources {} {
	news_aggregator::source::delete -source_id $source_id
    }
}


ad_proc -private news_aggregator::apm::after_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    NA package after-upgrade callback proc
} {
    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
        -spec {
            0.9d 0.9.4d {
		# get all aggregators in user prefs table along with their package ids
		db_foreach default_aggregator {
		    select distinct u.default_aggregator, a.package_id
                      from na_user_preferences u, na_aggregators a
                     where u.default_aggregator = a.aggregator_id
		} {
		    db_dml set_package_id {
			update na_user_preferences
                           set package_id = :package_id
                         where default_aggregator = :default_aggregator
		    }
		}
            }
            0.9.7 0.9.8 {
		db_foreach get_sources {
		    select source_id
		      from na_sources
		} {

		    db_dml clear_context_id {
			update acs_objects
			   set context_id = null
			 where object_id = :source_id
		    }
		    
		    db_dml clear_perms {
			delete from acs_permissions
			 where object_id = :source_id
		    }
		    
		}
	    }
        }
}
