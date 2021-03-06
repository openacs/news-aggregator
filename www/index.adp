<master>
  <property name="doc(title)">@page_title;literal@</property>
  <property name="context">@context;literal@</property>
  <property name="title">@page_title;literal@</property>
  <property name="head">
    <style type="text/css">
      .item_pub_date, .item_author {
           color: #777;
           padding-right: 1em;
      }
      .item_pub_date {
           font-size: 10px;
      }
    </style>
  </property>

<if @write_p;literal@ true>
  <p>
    <b>&raquo;</b> <a href="@url@subscriptions">#news-aggregator.Manage_Subscriptions#</a> <br />
    <if @allow_aggregator_edit_p;literal@ true>
        <b>#news-aggregator.raquo#</b> <a href="@aggregator_url@">#news-aggregator.lt_Manage_This_Aggregato#</a> <br />
    </if>
    <if @multiple_aggregators_p;literal@ true>
        <b>#news-aggregator.raquo#</b> <a href="@create_url@">#news-aggregator.lt_Create_New_Aggregator#</a><br />
    </if>
  <p>
    <if @aggregator_description@ not nil>
      @aggregator_description@
    </if>
    <else>
      This page lists <b>the most recent items</b> from the feeds you've <a href="@url@subscriptions">subscribed</a> to.
      <if @write_p;literal@ true and @purge_p;literal@ true>
          You can hit the <b>Purge button</b> to clean out the page. Clicking the <b>Save</b> icon <img border="0" src="@graphics_url@save.gif" width="16" height="16" alt="Save" /> will prevent an item from being purged.
      </if>
      <if @write_p;literal@ true and @public_p;literal@ false>
        Click on the <b>#news-aggregator.Post#</b> icon <img border="0" src="@graphics_url@post.gif" width="16" height="16" alt="Post this item to your Weblog" /> to add the item to your weblog.
      </if>
    </else>
  </p>
</if>
<else>
  <p>
</else>

<if @items:rowcount@ eq 0>
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
                    <if @public_p;literal@ false and @write_p;literal@ true>
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

<if @purge;literal@ true>
  <formtemplate id="purge"></formtemplate>
</if>


<if @enable_purge_p;literal@ true and @public_p;literal@ false and @purge_p;literal@ true>
    <p>
        #news-aggregator.Purges# <b>#news-aggregator.On#</b> | <a href="@purge_off_url@">#news-aggregator.Off#</a>
    </p>
</if>
<if @enable_purge_p;literal@ true and @public_p;literal@ false and @purge_p;literal@ false>
    <p>
        #news-aggregator.Purges# <a href="@purge_on_url@">#news-aggregator.On#</a> | <b>#news-aggregator.Off#</b>
    </p>
</if>

