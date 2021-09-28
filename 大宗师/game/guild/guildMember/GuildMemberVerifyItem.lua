--[[
 --
 -- add by vicky
 -- 2015.01.07 
 --
 --]]

 local data_config_union_config_union = require("data.data_config_union_config_union") 

 local NORMAL_FONT_SIZE = 22 
 local SMALL_FONT_SIZE = 18 

 local GuildMemberVerifyItem = class("GuildMemberVerifyItem", function()
 		return CCTableViewCell:new() 
 end)


 function GuildMemberVerifyItem:getContentSize()
 	if self._contentSz == nil then 
	 	local proxy = CCBProxy:create() 
	 	local rootnode = {} 
	 	local node = CCBuilderReaderLoad("guild/guild_guildMember_verify_item.ccbi", proxy, rootnode) 
	 	self._contentSz = rootnode["item_bg"]:getContentSize() 
	end 
	
 	return self._contentSz 
 end 


 function GuildMemberVerifyItem:getRoleId()
    return self._roleId 
 end


 function GuildMemberVerifyItem:getPlayerIcon()
    return self._rootnode["player_icon"]
 end 


 function GuildMemberVerifyItem:setBtnEnabled(bEnabled)
    self._rootnode["accept_btn"]:setEnabled(bEnabled) 
    self._rootnode["reject_btn"]:setEnabled(bEnabled) 
 end


 function GuildMemberVerifyItem:create(param) 
 	local viewSize = param.viewSize 
 	local itemData = param.itemData 
    local acceptFunc = param.acceptFunc 
    local rejectFunc = param.rejectFunc 
 	
 	local proxy = CCBProxy:create() 
 	self._rootnode = {} 
 	local node = CCBuilderReaderLoad("guild/guild_guildMember_verify_item.ccbi", proxy, self._rootnode) 
 	node:setPosition(viewSize.width/2, 0) 
 	self:addChild(node) 

    local function createTTF(text, size, color, node)
        local lbl = ui.newTTFLabelWithShadow({
            text = text,
            size = size, 
            color = color,
            shadowColor = ccc3(0,0,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
        }) 

        node:addChild(lbl) 
        return lbl 
    end

    -- 在线时间 (颜色根据在线、离线改变) 
    self._onlineLbl = self:createTTF(tostring(itemData.rank), ccc3(58, 209, 73), self._rootnode["online_lbl"], SMALL_FONT_SIZE)  
    self._onlineLbl:setPosition(-self._onlineLbl:getContentSize().width/2, -self._onlineLbl:getContentSize().height/2) 

 	-- 接收按钮 
	self._rootnode["accept_btn"]:addHandleOfControlEvent(function() 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if acceptFunc ~= nil then 
            self:setBtnEnabled(false) 
            acceptFunc(self) 
        end 
    end, CCControlEventTouchUpInside) 

    -- 拒绝按钮 
    self._rootnode["reject_btn"]:addHandleOfControlEvent(function() 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if rejectFunc ~= nil then 
            self:setBtnEnabled(false) 
            rejectFunc(self) 
        end 
    end, CCControlEventTouchUpInside) 

    self:refreshItem(itemData) 

 	return self 
 end 


 function GuildMemberVerifyItem:createTTF(text, color, node, size)
    node:removeAllChildren() 
    local lbl = ui.newTTFLabelWithShadow({
        text = text,
        size = size or NORMAL_FONT_SIZE, 
        color = color,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
    }) 

    node:addChild(lbl) 
    return lbl 
 end


 function GuildMemberVerifyItem:refresh(itemData) 
 	self:refreshItem(itemData) 
 end 


 function GuildMemberVerifyItem:refreshItem(itemData) 
    dump(itemData)
    self._roleId = itemData.roleId 

	self._rootnode["guild_lv_lbl"]:setString("LV." .. tostring(itemData.roleLevel)) 
	self._rootnode["guild_name_lbl"]:setString(tostring(itemData.roleName))  
    
    -- 竞技排名  
    self:createTTF(tostring(itemData.rank), ccc3(238, 12, 205), self._rootnode["arena_lbl"]) 

    -- 战斗力 
    self:createTTF(tostring(itemData.attack), ccc3(234, 62, 43), self._rootnode["power_lbl"])      

    -- 申请时间 
    self:createTTF(tostring(itemData.timeStr), ccc3(78, 255, 0), self._rootnode["time_lbl"])      

    self._onlineLbl:setString(tostring(itemData.onlineStr)) 
    self._onlineLbl:setPosition(-self._onlineLbl:getContentSize().width/2, -self._onlineLbl:getContentSize().height/2) 
    if itemData.isOnline == true then 
        self._onlineLbl:setColor(ccc3(58, 209, 73)) 
    else
        self._onlineLbl:setColor(ccc3(255, 255, 255))  
    end 

    ResMgr.refreshIcon({
        id = itemData.resId, 
        itemBg = self._rootnode["player_icon"], 
        resType = ResMgr.HERO, 
        cls = itemData.rolecls
        })
    
 end 


 return GuildMemberVerifyItem  

