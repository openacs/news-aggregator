 <multiple name="items">
      <div style="background-color: #eeeeee; padding-top: 6px; padding-bottom: 6px; padding-left: 4px; margin-top: 10px; margin-bottom: 10px;">
       <span style="font-size: 125%; font-weight: bold;"><a href="@items.link@" title="@items.description@">@items.title;noquote@</a></span>, from @items.chunk_updated@
      </div>
       <group column="pub_date"> 
        <if @items.show_description_p@ true>
          <div style="margin-left: 10px; margin-top: 15px; margin-bottom: 15px;">
           <a name="@items.item_id@">
           <div style="font-size: 115%; font-weight: bold; margin-bottom: 5px;">
            <if @items.item_title@ not nil>
             <a href="@items.item_link@">@items.item_title;noquote@</a>
            </if>
           </div>
           <div class="item_pub_time" style="margin-bottom: 5px;">Posted: @items.pub_time@
            <if @items.item_link@ not nil and @items.item_guid_link@ not nil>
             <a href="@items.item_guid_link@" title="Permanent URL for this entry">#</a>
            </if>        
           </div>
           @items.content;noquote@
           <div style="margin-top: 10px; margin-bottom: 10px;" class="list-button-bar">
            <if @write_p@ true>
             <if @items.save_url@ not nil>
               <a href="@items.save_url@" alt="Save" class="button">Save</a>
             </if>
             <if @items.unsave_url@ not nil>
              <a href="@items.unsave_url@" alt="Unsave" class="button">Unsave</a>
             </if>
            </if>
            <if @blog_p@ true>
             <a href="@items.item_blog_url@" alt="Post this item to your Weblog" class="button">Blog</a>
            </if>
           </div>
          </div>
        </if>
        <else>
          <div style="margin-left: 10px; margin-top:5px; margin-bottom: 5px;">
          <a name="@items.item_id@">
            <span style="font-size: 110%;"><a href="@items.item_link@">@items.item_title;noquote@</a></span>
            Posted: @items.pub_time@&nbsp;
            <if @items.item_link@ not nil and @items.item_guid_link@ not nil>
             <a href="@items.item_guid_link@" title="Permanent URL for this entry">#</a>
            </if>&nbsp;
            <if @write_p@ true>
            <if @items.save_url@ not nil>
              <a href="@items.save_url@" alt="Save" class="button">Save</a>
            </if>
            <if @items.unsave_url@ not nil>
             <a href="@items.unsave_url@" alt="Unsave" class="button">Unsave</a>
            </if>
            </if>
            <if @blog_p@ true>
              <a href="@items.item_blog_url@" alt="Post this item to your Weblog" class="button">Blog</a>
            </if></div>
        </else>
    </group>
  </multiple>