<master>
  <property name="title">@page_title@</property>
  <property name="context">@context@</property>

  <p>
    Enter the URL of an XML news feed you want to subscribe to, then click on the Add button.
  </p>

  <formtemplate id="add_subscription">
    <table cellspacing="0" cellpadding="2"<if @formerror@ not nil>
		style="border: 1px red dashed"</if>>
      <tr>
        <td>
          <b>Source URL</b>: <formwidget id="feed_url">
          <formwidget id="add_submit">
          <if @new_source_id@ not nil and @new_source_title@ not nil>
            <p class="subscribed" align="center">
              Congratulations, you have been subscribed to <b>@new_source_title@</b>.
            </p>
          </if>
        </td>
      </tr>
    </table>
  </formtemplate>

  <if @sources:rowcount@ >
    <p>
      The following table lists the XML news feeds you've subscribed to. 
      To delete a subscription, check it and then click on the Unsubscribe button 
      at the bottom of the page.
    </p>
  </if>

  <p>
    <listtemplate name="sources"></listtemplate>
  </p>
