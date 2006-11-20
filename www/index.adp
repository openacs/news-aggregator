<master>
<property name="title">@page_title@</property>
<property name="context">@context@</property>
<property name="header_stuff">@package_css;noquote@</property>

<div style="margin-bottom: 5px;">
 <span style="float: right; padding-left: 20px;">
  <if @num_options@ gt 1>
   <formtemplate id="aggregators">
    <formwidget id=aggregator>
   </formtemplate>     
  </if>
 </span>
 <if @aggregator_description@ not nil>
   @aggregator_description;noquote@
  </div>
 </if>

 <else>
  </div>
	#news-aggregator.lt_This_page_lists#
  </else>

<div>
 <if @enable_purge_p@ true and @public_p@ false>
   #news-aggregator.lt_You_can_hit_the_Purge#
 </if>
 <if @write_p@ true and @blog_p@ true>
   Click the <a href="#" class="button">Blog</a> button to post the item to a weblog (you will have a choice of weblogs to post to).
 </if>
</div>

<div style="margin-top: 10px;">
 <if @write_p@ true>
    <if @allow_aggregator_edit_p@ true>
     <a href="@url@aggregator-edit" class="button">Manage Reader</a>
    </if>
    <a href="@url@settings" class="button">Manage @instance_name@</a>
 </if>
</div>

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
