--[[
 --
 -- add by vicky
 -- 2015.01.13  
 --
 --]]

 require("utility.richtext.richText") 


 local GuildDynamicItem = class("GuildDynamicItem", function()
 		return CCTableViewCell:new() 
 end)


 function GuildDynamicItem:getContentSize() 
 	if self._contentSz == nil then 
	 	local proxy = CCBProxy:create() 
	 	local rootnode = {} 
	 	local node = CCBuilderReaderLoad("guild/guild_guildDynamic_item.ccbi", proxy, rootnode) 
	 	self._contentSz = rootnode["item_bg"]:getContentSize() 
	end 
	
 	return self._contentSz 
 end 


 function GuildDynamicItem:getPlayerIcon()
    return self._rootnode["player_icon"]
 end 


 function GuildDynamicItem:create(param) 
 	local viewSize = param.viewSize 
 	local itemData = param.itemData 
 	
 	local proxy = CCBProxy:create() 
 	self._rootnode = {} 
 	local node = CCBuilderReaderLoad("guild/guild_guildDynamic_item.ccbi", proxy, self._rootnode) 
 	node:setPosition(viewSize.width/2, 0) 
 	self:addChild(node) 

    self:refreshItem(itemData) 

 	return self 
 end 


 function GuildDynamicItem:refresh(itemData) 
 	self:refreshItem(itemData) 
 end 


 function GuildDynamicItem:refreshItem(itemData) 
    -- dump(itemData) 

    self._rootnode["lv_lbl"]:setString("LV." .. tostring(itemData.roleLevel)) 
    self._rootnode["time_lbl"]:setString(tostring(itemData.timeStr)) 

    -- 头像
    ResMgr.refreshIcon({
        id = itemData.resId, 
        itemBg = self._rootnode["player_icon"], 
        resType = ResMgr.HERO, 
        cls = itemData.cls 
        }) 

    local function createText(text, contentNode)
        contentNode:removeAllChildren() 
    
        local infoNode = getRichText(text, contentNode:getContentSize().width) 
        infoNode:setPosition(0, contentNode:getContentSize().height - 30) 
        contentNode:addChild(infoNode) 
    end 

    -- 内容
    createText(itemData.content, self._rootnode["content_tag"]) 

 end 


 return GuildDynamicItem  
