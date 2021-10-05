<?xml version="1.0"?>

<queryset>

<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="news_aggregator::source::new.add_source">
        <querytext>
            select na_source__new (
                null, -- object_id
                :feed_url,
		:link,
                :channel_title,
                :description,
		:last_modified,
                '1',
                :package_id,
                :user_id,
                :creation_ip
            )
        </querytext>
</fullquery>

<fullquery name="news_aggregator::source::new.add_item">
      <querytext>
        select na_item__new (
                :source_id,
                :link,
                :guid,
        boolean :permalink_p,
                :title,
                :description,
                :content_encoded
        );
        </querytext>
    </fullquery>

<fullquery name="news_aggregator::source::update.add_item">
      <querytext>
        select na_item__new (
                :source_id,
                :link,
                :guid,
                :original_guid,
        boolean :permalink_p,
                :title,
                :description,
                :content_encoded,
                :author,
                coalesce(:pub_date, current_timestamp)
        );
        </querytext>
    </fullquery>

    <fullquery name="news_aggregator::source::delete.delete_source">
          <querytext>
            select na_source__delete(:source_id);
          </querytext>
    </fullquery>

</queryset>
