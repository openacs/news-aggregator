ad_library {
    APM Callbacks Procs
}

namespace eval news_aggregator::apm {}

ad_proc -private news_aggregator::apm::after_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    Before upgrade callback
} {
    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
        -spec {
            0.9d 0.10d {
                db_transaction {
                    # Keep only the most recent entry having a certain
                    # guid.source_id. This combination will have to be
                    # unique after the upgrade, because we are
                    # inserting a new constraint.
                    set key ""
                    db_foreach get_duplicated_guid_news {
                        select item_id, guid, source_id
                        from na_items
                        order by source_id desc, pub_date desc, creation_date desc
                    } {
                        set row_key ${guid}.${source_id}
                        if {$key eq $row_key} {
                            db_dml delete_duplicate {
                                delete from na_items
                                where item_id = :item_id
                            }
                        } else {
                            set key $row_key
                        }
                    }
                }
            }
        }
}
