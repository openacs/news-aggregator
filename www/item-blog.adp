<master>
  <property name="title">@page_title@</property>
  <property name="context">@context@</property>

<p>
  <h3>Source: <a href="@link@">@title@</a></h3>
</p>

<p>
  @content;noquote@
</p>

<if @weblog_p@ true>
 <formtemplate id="blog_item"></formtemplate>
 <p>
   <b>Note:</b> You will not usually come back to the aggregator.
 </p>
</if>
<else>
 No weblog options available!
</else>