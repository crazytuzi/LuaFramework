--[[
 --
 -- add by vicky
 -- 2015.03.10 
 --
 --]]  

 local GuildFubenRankItem = class("GuildFubenRankItem", function()
 		return CCTableViewCell:new() 
 	end)


 function GuildFubenRankItem:getContentSize()
 	if self.cntSize == nil then 
 		local proxy = CCBProxy:create()
	    local rootNode = {}

	    local node = CCBuilderReaderLoad("guild/guild_fuben_rank_item.ccbi", proxy, rootNode)
	    self.cntSize = rootNode["itemBg"]:getContentSize()
	    self:addChild(node) 
        node:removeSelf() 
 	end 

 	return self.cntSize 
 end

 
 function GuildFubenRankItem:create(param)  
 	local viewSize = param.viewSize 
 	local itemData = param.itemData 
 	local checkFunc = param.checkFunc 

 	self._rootnode = {}
 	local proxy = CCBProxy:create()
 	local node = CCBuilderReaderLoad("guild/guild_fuben_rank_item.ccbi", proxy, self._rootnode) 
	node:setPosition(viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height * 0.5)
	self:addChild(node) 

	self._rootnode["zhenrongBtn"]:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
			if checkFunc ~= nil then 
				checkFunc(self) 
			end 
		end, CCControlEventTouchUpInside) 

	self:updateItem(itemData) 

	return self 
 end


 function GuildFubenRankItem:refresh(itemData)
 	self:updateItem(itemData) 
 end 


 function GuildFubenRankItem:createTTF(text, color, node, size) 
    node:removeAllChildren() 
    local lbl = ui.newTTFLabelWithOutline({
        text = text,
        size = size or 20, 
        color = color,
        outlineColor = ccc3(10,10,10),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
    }) 

    node:addChild(lbl) 
    return lbl 
 end 


 function GuildFubenRankItem:updateItem(itemData) 
 	-- 背景
 	local bgName = "#sh_bg_4.png" 
 	local lvBgName = "#sh_lv_bg_4.png" 
 	local playerBgName = "#sh_name_bg_4.png" 

 	if itemData.rank < 4 then 
 		bgName = "#sh_bg_" .. itemData.rank .. ".png" 
 		playerBgName = "#sh_name_bg_" .. itemData.rank .. ".png" 
 		lvBgName = "#sh_lv_bg_" .. itemData.rank .. ".png" 
 	end 

 	self._rootnode["bg_node"]:removeAllChildren() 
 	local bg = display.newScale9Sprite(bgName, 0, 0, self._rootnode["bg_node"]:getContentSize()) 
 	bg:setAnchorPoint(0, 0)
 	self._rootnode["bg_node"]:addChild(bg) 

 	self._rootnode["name_bg"]:removeAllChildren() 
 	local playerBg = display.newScale9Sprite(playerBgName, 0, 0, self._rootnode["name_bg"]:getContentSize()) 
 	playerBg:setAnchorPoint(0, 0)
 	self._rootnode["name_bg"]:addChild(playerBg) 

 	self._rootnode["lv_bg"]:setDisplayFrame(display.newSprite(lvBgName):getDisplayFrame()) 
 	
 	self._rootnode["lv_lbl"]:setString("LV." .. tostring(itemData.roleLevel))
 	self._rootnode["name_lbl"]:setString(itemData.name)

 	self._rootnode["attack_lbl"]:setString(itemData.attackNum or 0) 
 	self._rootnode["hurt_lbl"]:setString(itemData.attackHp or 0) 

 	if itemData.guildName ~= nil and itemData.guildName ~= "" then 
	 	self._rootnode["guild_name_lbl"]:setString("[" .. tostring(itemData.guildName) .. "]") 
	else
		self._rootnode["guild_name_lbl"]:setString("")
	end 

	-- 排行 
	if itemData.rank > 3 then 
		local fontSize = 42 
	 	if itemData.rank > 9 then 
	 		fontSize = 32 
	 	elseif itemData.rank > 99 then 
	 		fontSize = 26
	 	end 

	    local rankNumLbl = self:createTTF(tostring(itemData.rank), ccc3(251, 235, 197), self._rootnode["rank_num_lbl"], fontSize) 
	    rankNumLbl:setPosition(-rankNumLbl:getContentSize().width/2, 0) 
	    self._rootnode["rank_icon"]:setVisible(true)
	    self._rootnode["mark_icon"]:setVisible(false) 
	else 
	 	local markIcon = "#sh_mark_" .. itemData.rank .. ".png" 
		self._rootnode["mark_icon"]:setDisplayFrame(display.newSprite(markIcon):getDisplayFrame()) 
		self._rootnode["rank_icon"]:setVisible(false)
	    self._rootnode["mark_icon"]:setVisible(true) 
	end 
 	

 	if itemData.isTrueData ~= nil and not itemData.isTrueData then 
 		self._rootnode["zhenrongBtn"]:setEnabled(false) 
 	else
 		self._rootnode["zhenrongBtn"]:setEnabled(true) 
 	end 
 end 



 return GuildFubenRankItem 
