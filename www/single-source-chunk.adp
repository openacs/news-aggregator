 <multiple name="items">
      <div class="na-item-source-title na-item">
       <span class="na-item-source-title-text">
         <if @items.link@ not nil>
           <a href="@items.link@" title="@items.description@">@items.title;noquote@</a>
         </if>
         <else>
           @items.title;noquote@
         </else>
       </span>, from @items.chunk_updated@
      </div>
       <group column="pub_datestamp"> 
        <if @items.show_description_p@ true>
          <div class="na-item-with-desc na-item">
           <a name="@items.item_id@">
           <div class="na-item-with-desc-title na-item">
            <if @items.item_title@ not nil>
             <a href="@items.item_link@" class="na-item">@items.item_title;noquote@</a>
            </if>
           </div>
           <div class="na-item-pub-time">#news-aggregator.lt_Posted_itemspub_time_#
            <if @items.item_link@ not nil and @items.item_guid_link@ not nil>
             <a href="@items.item_guid_link@" title="Permanent URL for this entry">#</a>
            </if>        
           </div>
           @items.content;noquote@
           <div class="na-item-button-bar">
            <if @write_p@ true>
             <if @items.save_url@ not nil>
               <a href="@items.save_url@" alt="Save" class="button">#news-aggregator.Save#</a>
             </if>
             <if @items.unsave_url@ not nil>
              <a href="@items.unsave_url@" alt="Unsave" class="button">#news-aggregator.Unsave#</a>
             </if>
            </if>
            <if @blog_p@ true>
             <a href="@items.item_blog_url@" alt="Post this item to your Weblog" class="button">#news-aggregator.Blog#</a>
            </if>
           </div>
          </div>
        </if>
        <else>
          <div class="na-item-title-only na-item">
          <a name="@items.item_id@">
            <a href="@items.item_link@" class="na-item-title-only-title">@items.item_title;noquote@</a>
            <span class="na-item-pub-time">#news-aggregator.lt_Posted_itemspub_time_#</span>
            <if @items.item_link@ not nil and @items.item_guid_link@ not nil>
             <a href="@items.item_guid_link@" title="Permanent URL for this entry">#</a>
            </if>&nbsp;
            <if @write_p@ true>
            <if @items.save_url@ not nil>
              <a href="@items.save_url@" alt="Save" class="button">#news-aggregator.Save#</a>
            </if>
            <if @items.unsave_url@ not nil>
             <a href="@items.unsave_url@" alt="Unsave" class="button">#news-aggregator.Unsave#</a>
            </if>
            </if>
            <if @blog_p@ true>
              <a href="@items.item_blog_url@" alt="Post this item to your Weblog" class="button">#news-aggregator.Blog#</a>
            </if>
          </div>
        </else>
    </group>
  </multiple>
