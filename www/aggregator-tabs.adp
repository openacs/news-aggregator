<h2>#news-aggregator.Manage# @ag_info.aggregator_name@</h2>

#news-aggregator.lt_Use_tabs_below_to_mod# <a href="./settings">#news-aggregator.settings#</a> #news-aggregator.page#

<p>

<div id="subnavbar-div">
  <div id="subnavbar-container">
    <div id="subnavbar">

     <if @tab@ eq "general">
      <div class="tab" id="subnavbar-here">#news-aggregator.General#</div>
     </if>
     <else>
      <div class="tab"><a href="aggregator-edit?aggregator_id=@aggregator_id@">#news-aggregator.General#</a></div>
     </else

     <if @tab@ eq "subscriptions">
      <div class="tab" id="subnavbar-here">#news-aggregator.Subscriptions#</div>
     </if>
     <else>
      <div class="tab"><a href="subscriptions?aggregator_id=@aggregator_id@">#news-aggregator.Subscriptions#</a></div>
     </else>

     <if @tab@ eq "permissions">
      <div class="tab" id="subnavbar-here">#news-aggregator.Permissions#</div>
     </if>
     <else>
      <div class="tab"><a href="permissions?aggregator_id=@aggregator_id@">#news-aggregator.Permissions#</a></div>
     </else>

    </div>
  </div>
</div>

