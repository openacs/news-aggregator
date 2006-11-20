<master>
  <property name="title">@page_title@</property>
  <property name="context">@context@</property>

<p>
  <h3>#news-aggregator.Source# <a href="@link@">@title@</a></h3>
</p>

<p>
  @content;noquote@
</p>

<if @weblog_p@ true>
 <formtemplate id="blog_item"></formtemplate>
 <p>
   <b>#news-aggregator.Note#</b> #news-aggregator.lt_You_will_not_usually_#
 </p>
</if>
<else>
 #news-aggregator.lt_No_weblog_options_ava#
</else>
