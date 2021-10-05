<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="news_aggregator::aggregator::delete.delete_aggregator">
          <querytext>
                select na_aggregator__delete (
                        :aggregator_id
                );

          </querytext>
    </fullquery>

    <fullquery name="news_aggregator::aggregator::new.new_aggregator">
	  <querytext>
		select na_aggregator__new (
			null,
			:aggregator_name,
                        :description,
			:package_id,
			:public_p,
			:creation_user,
			:creation_ip
		)
	  </querytext>
    </fullquery>

</queryset>
