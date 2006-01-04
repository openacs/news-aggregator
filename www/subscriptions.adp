<master>

  <property name="title">@page_title@</property>
  <property name="context">@context@</property>
  
  <include src="aggregator-tabs" tab="subscriptions">
  <p>
    Enter the URL of an XML news feed you want to subscribe to or choose a feed the system already knows about and then click on the Add button.
  </p>

  <formtemplate id=add_subscription></formtemplate>

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
