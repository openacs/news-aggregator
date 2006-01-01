<master>
  <property name="title">@page_title@</property>
  <property name="context">@context@</property>
  <property name="header_stuff"><style type="text/css"><!-- .item_pub_date, .item_author { color: #777; padding-right: 1em; }
.item_pub_date { font-size: 10px; }  
 --></style></property>

<!-- MS: would like to lay this out without tables -->
<table border="0">
  <tr>
   <td width="100%" valign="top">
    <h2>@aggregator_name@</h2>
    <if @aggregator_description@ not nil>
      @aggregator_description@
    </if>
    <else>
      This page lists <b>the most recent items</b> from the feeds you've <a href="@url@manage?tab=subscriptions">subscribed</a> to.
    </else>
    <p>   
    <if @enable_purge_p@ true>
        You can hit the Purge button to clean out the page. Clicking the Save button will prevent an item from being purged.
    </if>
    <if @write_p@ true>
        Click the Blog button to post the item to a weblog (you will have a choice of weblogs to post to).
    </if>
   </td>
   <td valign="top" align="right">
    <if @num_options@ gt 1>
     <formtemplate id="aggregators">
      <formwidget id=aggregator>
     </formtemplate>     
    </if> 
   </td>
  </tr>
<table>

<if @write_p@ true>
  <div class="list-button-bar">
  <p>
    <if @allow_aggregator_edit_p@ true>
     <a href="@url@manage" class="button">Manage @aggregator_name@</a>
    </if>
    <a href="@url@settings" class="button">@instance_name@ Settings</a>
  </div>
  <p>
</if>
<else>
  <p>
</else>

<if @items:rowcount@ false>
  <i>#news-aggregator.No_items#</i>
</if>
<else>
 <multiple name="items">
   <group column="sort_date"> 
      <div style="background-color: #eeeeee; padding-top: 10px; padding-bottom: 10px; padding-left: 5px;">
       <span style="font-size: 125%; font-weight: bold;"><a href="@items.link@" title="@items.description@">@items.title@</a></span> #news-aggregator.updated_x_time_ago#
      </div>
       <group column="source_id">
         <div style="margin-left: 10px; margin-top: 15px; margin-bottom: 15px;">
          <a name="@items.item_id@">
          <div style="font-size: 115%; font-weight: bold; margin-bottom: 5px;">
           <if @items.item_title@ not nil>
            <a href="@items.item_link@">@items.item_title@</a>
           </if>
          </div>
          <div class="item_pub_date" style="margin-bottom: 5px;">Posted: @items.pub_date@
           <if @items.item_link@ not nil and @items.item_guid_link@ not nil>
            <a href="@items.item_guid_link@" title="Permanent URL for this entry">#</a>
           </if>        
          </div>
          @items.content;noquote@
          <div style="margin-top: 10px; margin-bottom: 10px;" class="list-button-bar">
           <if @write_p@ true>
            <if @items.save_url@ not nil>
              <a href="@items.save_url@" alt="Save" class="button">Save</a>
            </if>
            <if @items.unsave_url@ not nil>
             <a href="@items.unsave_url@" alt="Unsave" class="button">Unsave</a>
            </if>
           </if>
           <if @blog_p@ true>
            <a href="@items.item_blog_url@" alt="Post this item to your Weblog" class="button">Blog</a>
           </if>
          </div>
         </div>
       </group>
    </group>
  </multiple>
</else>

<if @enable_purge_p@ true and @public_p@ false and @purge@ true and @purge_p@ true>
  <formtemplate id="purge"></formtemplate>
</if>

    
<if @enable_purge_p@ true and @public_p@ false and @purge_p@ true>
    <p>
        #news-aggregator.Purges# <b>#news-aggregator.On#</b> | <a href="@purge_off_url@">#news-aggregator.Off#</a>
    </p>
</if>
<if @enable_purge_p@ true and @public_p@ false and @purge_p@ false>
    <p>
        #news-aggregator.Purges# <a href="@purge_on_url@">#news-aggregator.On#</a> | <b>#news-aggregator.Off#</b> 
    </p>   
</if>

