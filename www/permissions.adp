<master>

  <property name="title">@page_title@</property>
  <property name="context">@context@</property>
  
  <include src="aggregator-tabs" tab="permissions">

  <p>
  Manage detailed permissions for this aggregator. You can use this form to allow other users to view your personal feeds.
  <p>
  <include src="/packages/acs-subsite/www/permissions/perm-include" object_id="@aggregator_id@">
