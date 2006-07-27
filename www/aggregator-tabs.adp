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
      <div class="tab"><a href="aggregator-edit?aggregator_id=@aggregator_id@">General</a></div>
     </else

     <if @tab@ eq "subscriptions">
      <div class="tab" id="subnavbar-here">Subscriptions</div>
     </if>
     <else>
      <div class="tab"><a href="subscriptions?aggregator_id=@aggregator_id@">Subscriptions</a></div>
     </else>

     <if @tab@ eq "permissions">
      <div class="tab" id="subnavbar-here">Permissions</div>
     </if>
     <else>
      <div class="tab"><a href="permissions?aggregator_id=@aggregator_id@">Permissions</a></div>
     </else>

    </div>
  </div>
</div>
