<master>
  <property name="title">@page_title@</property>
  <property name="context">@context@</property>
  <property name="header_stuff"><style type="text/css"><!-- .item_pub_time, .item_author { color: #777; padding-right: 1em; }
.item_pub_time { font-size: 10px; }  
 --></style></property>

<!-- MS: would like to lay this out without tables -->
<table border="0">
  <tr>
   <td width="100%" valign="top">
    <h2>@aggregator_name;noquote@</h2>
    <if @aggregator_description@ not nil>
      @aggregator_description;noquote@
    </if>
    <else>
      This page lists <b>the most recent items</b> from the feeds you've <a href="@url@manage?tab=subscriptions">subscribed</a> to.
    </else>
    <p>   
    <if @enable_purge_p@ true>
        You can hit the Purge button to clean out the page. Clicking the <a href="#" class="button">Save</a> button will prevent an item from being purged.
    </if>
    <if @write_p@ true>
        Click the <a href="#" class="button">Blog</a> button to post the item to a weblog (you will have a choice of weblogs to post to).
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
     <a href="@url@aggregator-edit" class="button">Manage Reader</a>
    </if>
    <a href="@url@settings" class="button">Manage @instance_name@</a>
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
 <if @multiple_sources_p@ false>
   <include src="single-source-chunk" blog_p="@blog_p@" write_p="@write_p@" &items="items">
 </if>
 <else>
   <include src="multi-source-chunk" blog_p="@blog_p@" write_p="@write_p@" &items="items">
 </else>
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

