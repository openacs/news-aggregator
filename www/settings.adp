<master>
  <property name="title">@page_title@</property>
  <property name="context">@context@</property>

<h2>@page_title@</h2>
<p>
You have the ability to view the following aggregators in @instance_name@. If You select a default aggregator,  
you will automatically be directed there when visiting @instance_name@. If you have write privileges on 
a particular aggregator, you will have the option to edit or delete it as well.
  <listtemplate name="aggregators"></listtemplate>
</p>
<p>
  <b>&raquo;</b> <a href="@aggregator_link@">Create new aggregator</a>
</p>

<p>&nbsp;</p>
<p>
The weblogs below will show up as options (in addition to any blogger instances you can post to on your subsite) 
when you choose to blog about a news item. 
  <listtemplate name="weblogs"></listtemplate>
</p>
<p>
  <b>&raquo;</b> <a href="@package_url@weblog">Add new weblog</a>
</p>
