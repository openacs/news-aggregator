<master>
  <property name="title">@page_title@</property>
  <property name="context">@context@</property>

<p>
  <h3>Your News Aggregators</h3>
  <listtemplate name="aggregators"></listtemplate>
</p>
<p>
  <b>&raquo;</b> <a href="@aggregator_link@">Create new aggregator</a>
</p>

<if @aggregators:rowcount@ gt 1>
  <h3>Default News Aggregator</h3>
  <formtemplate id="aggregators">
    Select default aggregator: <br />
    <formwidget id="default_aggregator_id">
    <formwidget id="submit">
  </formtemplate>
</if>

<p>
  <h3>Your Weblogs</h3>
  <listtemplate name="weblogs"></listtemplate>
</p>
<p>
  <b>&raquo;</b> <a href="@package_url@weblog">Add new weblog</a>
</p>
