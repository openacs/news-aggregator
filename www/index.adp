<master>

<property name="title">News Aggregator</property>

<property name="context_bar">@context_bar@</property>

<blockquote>

  <formtemplate id="items">

    <if @items:rowcount@ >
 
      <table cellspacing="0" cellpadding="1" align="right">
        <tr>
          <td valign="top">
            <formwidget id="delete_submit">
          </td>
        </tr>
      </table>

    </if>

    This page lists the most recent items from the feeds you've <a href="subscriptions">subscribed</a> to. 

    <if @blogger_url@ not nil>
      Click on the Post button to post an item to your weblog. 
    </if>

    You can delete stories from this page by checking the items that you want to delete and then clicking 
    the Delete button. 

    <p>

    <if @items:rowcount@ eq 0>
      <i>No feeds.</i>
    </if>

    <else>
    <table cellspacing=1 cellpadding=0 border=0>
      <tr>
        <td bgcolor="#c0c0c0">
          <table cellspacing=1 cellpadding=5 border=0 width="100%">
            <multiple name="items">
	      <group column="sort_date">
                <tr bgcolor="#eeeeee">
                  <td>&nbsp;</td>
                    <td><b><a href="@items.link@" title="@items.description@">@items.title@</a>, @items.diff@</b>, <b><a href="@items.update_url@">update</a></b></td>
                    <td><a href="@items.feed_url@" title="Click to view the current XML source text for the channel.">RSS</a></td>
                </tr>
	        <group column="source_id">
                  <tr bgcolor="#ffffff">
  	            <td valign="top"><input type="checkbox" name="item_id" value="@items.item_id@"></td>
                      <td>
		        @items.content@
		        <if @items.item_link@ not nil>
                          <a href="@items.item_link@" title="Permanent URL for this entry">#</a>
		        </if>
		        <if @items.item_title@ not nil>
                          <a href="http://www.google.com/search?q=@items.item_title@" title="Search for @items.item_title@ on Google">G</a>
                        </if>
		      </td>
                      <td valign="top">&nbsp;</td>
                    </tr>
                  </group>
	        </group>
              </multiple>
            </table>
          </td>
        </tr>
        <tr bgcolor="#ffffff">
          <td align="right" colspan="3">
            <br><formwidget id="delete_submit">
          </td>
        </tr>
      </table>
    </else>
  </formtemplate>
</blockquote>
