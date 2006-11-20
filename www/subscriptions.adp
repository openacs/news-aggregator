<master>

  <property name="title">@page_title@</property>
  <property name="context">@context@</property>
  
  <include src="aggregator-tabs" tab="subscriptions">
  <p>#news-aggregator.Enter_the_URL_of_an_XML_news_feed#</p>

  <formtemplate id=add_subscription></formtemplate>

  <if @sources:rowcount@ >
    <p>
      #news-aggregator.lt_The_following_table_l#
    </p>
  </if>

  <p>
    <listtemplate name="sources"></listtemplate>
  </p>

