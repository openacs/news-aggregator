<master>

<property name="title">Subscriptions</property>

<property name="context_bar">@context_bar@</property>

<p>

<table cellspacing=0 cellpadding=4 width="80%" border=0 align=center>
  <tr>
    <td valign=top>

      Enter the URL of an XML news feed you want to subscribe to in the box below, 
      then click on the Add button.

      <formtemplate id="add_subscription">
        URL: <formwidget id="feed_url"><formwidget id="add_submit">
      </formtemplate>

      <if @sources:rowcount@ >

        The following table lists the XML news feeds you've subscribed to. Included is the name of the 
	source, linked to its Web page, the time or day it last changed, the number of times it has 
	changed since you subscribed, and a link to the XML file for the channel. To delete a subscription, 
	check it and then click on the Unsubscribe button at the bottom of the page.
      </if>

      <formtemplate id="delete_subscription">

      <blockquote>
        <table cellspacing=0 cellpadding=0 border=0>
          <tr>
            <td bgcolor="#cccccc">
              <table cellspacing=1 cellpadding=5 border=0 width="100%">  
	        <multiple name="sources">
                  <tr bgcolor="#ffffff">
                    <td><input type="checkbox" name="source_id" value="@sources.source_id@"></td>
                    <td nowrap><a href="@sources.link@" title="@sources.description@">@sources.title@</a></td>
                    <td nowrap>@sources.last_scanned@</td>
	            <td>@sources.updates@</td>
                    <td><a href="@sources.feed_url@" title="Click to view the current XML source text for the channel.">RSS</a></td>
                  </tr>
	        </multiple>
              </table>
            </td>
          </tr>
        </table>
      </blockquote>

      <if @sources:rowcount@ >
        <formwidget id="delete_submit">
      </if>
      </formtemplate>
    </td>
  </tr>
</table>
