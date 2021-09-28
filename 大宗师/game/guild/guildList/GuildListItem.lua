--[[
 --
 -- add by vicky
 -- 2014.12.30 
 --
 --]]

 local data_config_union_config_union = require("data.data_config_union_config_union") 

 local NORMAL_FONT_SIZE = 22 

 local GuildListItem = class("GuildListItem", function()
 		return CCTableViewCell:new() 
 end)


 function GuildListItem:getContentSize()
 	if self._contentSz == nil then 
	 	local proxy = CCBProxy:create() 
	 	local rootnode = {} 
	 	local node = CCBuilderReaderLoad("guild/guild_guildList_item.ccbi", proxy, rootnode) 
	 	self._contentSz = rootnode["item_bg"]:getContentSize() 
        self:addChild(node)
        node:removeSelf()
	end 
	
 	return self._contentSz 
 end 


 function GuildListItem:setBtnEnabled(bEnabled)
 	self._rootnode["applyBtn"]:setEnabled(bEnabled)
 	self._rootnode["cancelApplyBtn"]:setEnabled(bEnabled) 
 end 


 function GuildListItem:setAppled(bAppled)
 	if bAppled == true then 
 		self._rootnode["applyBtn"]:setVisible(false)
 		self._rootnode["cancelApplyBtn"]:setVisible(true) 	
 	elseif bAppled == false then 
 		self._rootnode["applyBtn"]:setVisible(true)
 		self._rootnode["cancelApplyBtn"]:setVisible(false) 
 	end 
 end


 function GuildListItem:create(param) 
 	local viewSize = param.viewSize 
 	local itemData = param.itemData 
 	local applyFunc = param.applyFunc
    self._isInUnion = param.isInUnion 
 	self._guildTotalNum = param.totalNum 
 	self._curGuildNum = param.curGuildNum 
 	self._isCanShowMoreBtn = param.isCanShowMoreBtn 
 	self._id = param.id 
 	
 	local proxy = CCBProxy:create() 
 	self._rootnode = {} 
 	local node = CCBuilderReaderLoad("guild/guild_guildList_item.ccbi", proxy, self._rootnode) 
 	node:setPosition(viewSize.width/2, 0) 
 	self:addChild(node) 

 	-- 申请按钮 
	self._rootnode["applyBtn"]:addHandleOfControlEvent(function()
        if applyFunc ~= nil then 
        	self:setBtnEnabled(false) 
        	applyFunc(self) 
        end 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
    end, CCControlEventTouchUpInside)

	-- 取消申请按钮 
    self._rootnode["cancelApplyBtn"]:addHandleOfControlEvent(function()
		if applyFunc ~= nil then 
			self:setBtnEnabled(false) 
        	applyFunc(self) 
        end 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
    end, CCControlEventTouchUpInside)

    self:refreshItem(itemData) 

 	return self 
 end 


 function GuildListItem:createTTF(text, color, node, size)
    node:removeAllChildren() 
    local lbl = ui.newTTFLabelWithOutline({
        text = text,
        size = size or NORMAL_FONT_SIZE, 
        color = color,
        outlineColor = ccc3(10,10,10),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
    }) 

    node:addChild(lbl) 
    return lbl 
 end


 function GuildListItem:refresh(param) 
 	self._id = param.id 
 	self:refreshItem(param.itemData) 
 end 


 function GuildListItem:refreshItem(itemData) 
    -- 是否显示获取更多帮派
    if self._isCanShowMoreBtn and self._id == self._curGuildNum then 
        self._rootnode["normal_node"]:setVisible(false) 
        self._rootnode["getMore_tag"]:setVisible(true) 

    else 
        self._rootnode["normal_node"]:setVisible(true) 
        self._rootnode["getMore_tag"]:setVisible(false) 

     	-- 排行 
     	local fontSize = 42 
     	if self._id > 9 then 
     		fontSize = 32 
     	elseif self._id > 99 then 
     		fontSize = 26
     	end 

        local rankNumLbl = self:createTTF(tostring(self._id), ccc3(251, 235, 197), self._rootnode["rank_num_lbl"], fontSize) 
        rankNumLbl:setPosition(-rankNumLbl:getContentSize().width/2, 0) 

        -- 帮主名称 
        self:createTTF(tostring(itemData.leaderName), ccc3(238, 12, 205), self._rootnode["player_name_lbl"]) 

        -- 帮主等级 
        self:createTTF("LV." .. tostring(itemData.leaderLevel), ccc3(238, 12, 205), self._rootnode["player_lv_lbl"]) 

        -- 帮派成员数量
        self:createTTF(tostring(itemData.nowRoleNum) .. "/" .. tostring(itemData.roleNum), ccc3(247, 228, 97), self._rootnode["member_num_lbl"]) 

        -- 战斗力
        self:createTTF(tostring(itemData.sumAttack), ccc3(78, 255, 0), self._rootnode["guild_power_lbl"]) 

    	-- 申请按钮/取消申请按钮 
        if self._isInUnion == false then 
        	if itemData.apply == true then 
        		self._rootnode["applyBtn"]:setVisible(false)
        		self._rootnode["cancelApplyBtn"]:setVisible(true)
        	elseif itemData.apply == false then 
        		self._rootnode["applyBtn"]:setVisible(true)
        		self._rootnode["cancelApplyBtn"]:setVisible(false)
        	end
        else
            self._rootnode["applyBtn"]:setVisible(false)
            self._rootnode["cancelApplyBtn"]:setVisible(false)
        end 

    	self._rootnode["guild_lv_lbl"]:setString("LV." .. tostring(itemData.level)) 
    	self._rootnode["guild_name_lbl"]:setString(tostring(itemData.name)) 

    	if itemData.unionOutdes ~= nil and itemData.unionOutdes ~= "" then 
    		self._rootnode["guild_declaration_lbl"]:setString("帮派宣言: " .. tostring(itemData.unionOutdes)) 
    	else
    		self._rootnode["guild_declaration_lbl"]:setString("帮派宣言: " .. data_config_union_config_union[1].guild_note_msg) 
    	end 
    end 

 end 


 return GuildListItem  

