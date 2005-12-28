<master>
  <property name="title">@page_title@</property>
  <property name="context">@context@</property>
  <property name="header_stuff"><style type="text/css"><!-- .item_pub_date, .item_author { color: #777; padding-right: 1em; }
.item_pub_date { font-size: 10px; }  
 --></style></property>

<!-- MS: would like to lay this out without tables -->
<table border="0">
  <tr>
   <td width="100%">
    <h2>@aggregator_name@</h2>
    <if @aggregator_description@ not nil>
      @aggregator_description@
    </if>
    <else>
      This page lists <b>the most recent items</b> from the feeds you've <a href="@url@manage?tab=subscriptions">subscribed</a> to.
    </else>
    <p>   
    <if @public_p@ false and @enable_purge_p@ true>
        You can hit the <b>Purge button</b> to clean out the page. Clicking the <b>Save</b> icon <img border="0" src="@graphics_url@save.gif" width="16" height="16" alt="Save" /> will prevent an item from being purged.
        Click on the <b>#news-aggregator.Post#</b> icon <img border="0" src="@graphics_url@post.gif" width="16" height="16" alt="Post this item to your Weblog" /> to add the item to your weblog.
    </if>
   </td>
   <td valign="top" align="right">
    <if @num_options@ gt 1>
     <nobr><ul class="action-links">
      <li><formtemplate id="aggregators">
      Visit another aggregator <formwidget id=aggregator>
      </formtemplate></li>
     </ul></nobr>
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
    <a href="@create_url@" class="button">#news-aggregator.lt_Create_New_Aggregator#</a>
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
  <table cellspacing=1 cellpadding=0 border=0>
    <tr>
      <td bgcolor="#c0c0c0">
        <table cellspacing=1 cellpadding=8 border=0 width="100%">
          <multiple name="items">
	    <group column="sort_date">
              <tr bgcolor="#eeeeee">
                <td colspan=2>
                  <b><a href="@items.link@" title="@items.description@">@items.title@</a>#news-aggregator.updated_x_time_ago#</b>                   
                  <a href="@items.technorati_url@"><img src="@graphics_url@technorati.png" width ="50" height="14" alt="Technorati Cosmos" border="0"></a>
                </td>
              </tr>
	      <group column="source_id">
                <tr bgcolor="#ffffff" id="@items.item_id@">
                  <td>
		    @items.content;noquote@
		    <if @items.item_link@ not nil and @items.item_guid_link@ not nil>
                      <a href="@items.item_guid_link@" title="Permanent URL for this entry">#</a>
		    </if>
		  </td>
                  <td valign="top" width="40" align="left">
                    <if @public_p@ false and @write_p@ true>
       		      <if @items.save_url@ not nil>
		        <a href="@items.save_url@"><img border="0" src="@graphics_url@save.gif" width="16" height="16" alt="Save" /></a>
		      </if>
		      <if @items.unsave_url@ not nil>
		        <a href="@items.unsave_url@"><img border="0" src="@graphics_url@delete.gif" width="16" height="16" alt="Unsave" /></a>
		      </if>
                      <a href="@items.item_blog_url@"><img border="0" src="@graphics_url@post.gif" width="16" height="16" alt="Post this item to your Weblog" /></a>
                    </if>
                    
                    <span class="item_pub_date">@items.pub_date@</span>
		  </td>
                </tr>
              </group>
	    </group>
          </multiple>
        </table>
      </td>
    </tr>
  </table>
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

