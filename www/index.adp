<master>
  <property name="title">@page_title@</property>
  <property name="context">@context@</property>

<if @write_p@ true>
  <p>
    <b>&raquo;</b> <a href="@url@subscriptions">Manage Subscriptions</a> <br />
    <b>&raquo;</b> <a href="@aggregator_url@">Manage This Aggregator</a> <br />
  <p>
    <if @aggregator_description@ not nil>
      @aggregator_description@
    </if>
    <else>
      This page lists <b>the most recent items</b> from the feeds you've <a href="@url@subscriptions">subscribed</a> to.
      You can hit the <b>Purge button</b> to clean out the page. Clicking the <b>Save</b> icon <img border="0" src="@graphics_url@save.gif" width="16" height="16" alt="Save" /> will prevent an item from being purged.
      Click on the <b>Post</b> icon <img border="0" src="@graphics_url@post.gif" width="16" height="16" alt="Post this item to your Weblog" /> to add the item to your weblog.
    </else>
  </p>
</if>
<else>
  <p>
</else>

<if @items:rowcount@ false>
  <i>No items.</i>
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
                  <b><a href="@items.link@" title="@items.description@">@items.title@</a>,
                  updated @items.diff@</b>                   
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
                  <td valign="top" width="40" align="center">
                    <if @public_p@ false and @write_p@ true>
       		      <if @items.save_url@ not nil>
		        <a href="@items.save_url@"><img border="0" src="@graphics_url@save.gif" width="16" height="16" alt="Save" /></a>
		      </if>
		      <if @items.unsave_url@ not nil>
		        <a href="@items.unsave_url@"><img border="0" src="@graphics_url@delete.gif" width="16" height="16" alt="Unsave" /></a>
		      </if>
                      <a href="@items.item_blog_url@"><img border="0" src="@graphics_url@post.gif" width="16" height="16" alt="Post this item to your Weblog" /></a>
                    </if>
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

<if @public_p@ false and @purge@ true and @purge_p@ true>
  <formtemplate id="purge"></formtemplate>
</if>

    
<if @public_p@ false and @purge_p@ true>
    <p>
        Purges: <b>On</b> | <a href="@purge_off_url@">Off</a>
    </p>
</if>
<if @public_p@ false and @purge_p@ false>
    <p>
        Purges: <a href="@purge_on_url@">On</a> | <b>Off</b> 
    </p>   
</if>
