<master>

<h2>Manage @ag_info.aggregator_name@</h2>

Use tabs below to modify options for this aggregator. Options for @instance_name@ are 
available on the <a href="./settings">settings</a> page.

<p>

<div id="subnavbar-div">
  <div id="subnavbar-container">
    <div id="subnavbar">

     <if @tab@ eq "general">
      <div class="tab" id="subnavbar-here">General</div>
     </if>
     <else>
      <div class="tab"><a href="?tab=general">General</a></div>
     </else

     <if @tab@ eq "subscriptions">
      <div class="tab" id="subnavbar-here">Subscriptions</div>
     </if>
     <else>
      <div class="tab"><a href="?tab=subscriptions">Subscriptions</a></div>
     </else>

     <if @tab@ eq "permissions">
      <div class="tab" id="subnavbar-here">Permissions</div>
     </if>
     <else>
      <div class="tab"><a href="?tab=permissions">Permissions</a></div>
     </else>

    </div>
  </div>
</div>

  <if @tab@ eq "general">
     <p>
     Edit attributes for this aggregator:
     <p>
     <include src="aggregator" &=page_title &=context>
  </if>

  <if @tab@ eq "subscriptions">
     <p>
     <include src="subscriptions" &=page_title &=context>
  </if>

  <if @tab@ eq "permissions">
     <p>
     Manage detailed permissions for this aggregator. You can use this form to allow other users to view your personal feeds.
     <p>
     <include src="/packages/acs-subsite/www/permissions/perm-include" object_id="@aggregator_id@">
  </if>

<property name="title">@page_title@</property>
<property name="context">@context@</property>
