--[[
 --
 -- add by vicky
 -- 2015.01.07 
 --
 --]]

 local data_config_union_config_union = require("data.data_config_union_config_union") 

 local NORMAL_FONT_SIZE = 22 
 local SMALL_FONT_SIZE = 18 

 local GuildMemberNormalItem = class("GuildMemberNormalItem", function()
 		return CCTableViewCell:new() 
 end)


 function GuildMemberNormalItem:getContentSize()
 	if self._contentSz == nil then 
	 	local proxy = CCBProxy:create() 
	 	local rootnode = {} 
	 	local node = CCBuilderReaderLoad("guild/guild_guildMember_normal_item.ccbi", proxy, rootnode) 
	 	self._contentSz = rootnode["item_bg"]:getContentSize() 
        self:addChild(node)
        node:removeSelf()
	end 
	
 	return self._contentSz 
 end 


 function GuildMemberNormalItem:getPlayerIcon()
    return self._rootnode["player_icon"]
 end 


 function GuildMemberNormalItem:create(param) 
 	local viewSize = param.viewSize 
 	local itemData = param.itemData 
    local jobFunc = param.jobFunc 
 	
 	local proxy = CCBProxy:create() 
 	self._rootnode = {} 
 	local node = CCBuilderReaderLoad("guild/guild_guildMember_normal_item.ccbi", proxy, self._rootnode) 
 	node:setPosition(viewSize.width/2, 0) 
 	self:addChild(node) 

    -- 在线时间 (颜色根据在线、离线改变) 
    self._onlineLbl = self:createTTF("待定", ccc3(58, 209, 73), self._rootnode["online_lbl"], SMALL_FONT_SIZE)     
    self._onlineLbl:setPosition(-self._onlineLbl:getContentSize().width/2, -self._onlineLbl:getContentSize().height/2) 

    -- 切磋次数
    self._battleTimesLbl = self:createTTF("今日剩余切磋次数:20", ccc3(255, 178, 69), self._rootnode["battle_times_lbl"], SMALL_FONT_SIZE) 
    self._battleTimesLbl:setPosition(-self._battleTimesLbl:getContentSize().width/2, self._battleTimesLbl:getContentSize().height/2) 

    -- 捐献 
    self._buildLbl = self:createTTF("待定", ccc3(255, 178, 69), self._rootnode["build_lbl"], SMALL_FONT_SIZE) 
    self._buildLbl:setPosition(-self._buildLbl:getContentSize().width/2, self._buildLbl:getContentSize().height/2) 

 	-- 帮务按钮 
	self._rootnode["job_btn"]:addHandleOfControlEvent(function() 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if jobFunc ~= nil then 
            jobFunc(self) 
        end 
    end, CCControlEventTouchUpInside) 

    self._centerPosY_up = self._rootnode["center_node"]:getPositionY() 
    self._centerPosY_down = self._centerPosY_up - 10  

    self:refreshItem(itemData) 

 	return self 
 end 


 function GuildMemberNormalItem:createTTF(text, color, node, size)
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


 function GuildMemberNormalItem:refresh(itemData) 
 	self:refreshItem(itemData) 
 end 


 function GuildMemberNormalItem:refreshItem(itemData) 
    -- dump(itemData) 
    if itemData.isSelf == true then 
        -- 剩余贡献
        self:createTTF(tostring(itemData.lastContribute), ccc3(78, 255, 0), self._rootnode["gongxian_lbl"]) 
        self._rootnode["lelft_gongxian_node"]:setVisible(true)  
        self._rootnode["center_node"]:setPositionY(self._centerPosY_up)
    elseif itemData.isSelf == false then 
        self._rootnode["lelft_gongxian_node"]:setVisible(false) 
        self._rootnode["center_node"]:setPositionY(self._centerPosY_down)
    end 

    if itemData.jopType == GUILD_JOB_TYPE.normal then 
        self._rootnode["cell_bg_leader"]:setVisible(false) 
        self._rootnode["cell_bg_normal"]:setVisible(true) 
        self._rootnode["mem_icon"]:setVisible(false) 
        self._rootnode["mem_normal_lbl"]:setVisible(true) 
    else
        self._rootnode["cell_bg_leader"]:setVisible(true) 
        self._rootnode["cell_bg_normal"]:setVisible(false) 
        self._rootnode["mem_icon"]:setVisible(true) 
        self._rootnode["mem_normal_lbl"]:setVisible(false) 
        self._rootnode["mem_leader_lbl"]:setString(GUILD_JOB_NAME[itemData.jopType + 1]) 
    end 

	self._rootnode["guild_lv_lbl"]:setString("LV." .. tostring(itemData.roleLevel)) 
	self._rootnode["guild_name_lbl"]:setString(tostring(itemData.roleName))  

    -- 竞技排名  
    self:createTTF(tostring(itemData.rank), ccc3(238, 12, 205), self._rootnode["arena_lbl"]) 

    -- 个人总贡献 
    self:createTTF(tostring(itemData.totalContribute), ccc3(247, 228, 97), self._rootnode["total_gongxian_lbl"]) 

    -- 战斗力 
    self:createTTF(tostring(itemData.attack), ccc3(78, 255, 0), self._rootnode["power_lbl"]) 

    self._battleTimesLbl:setString("今日剩余切磋次数:" .. tostring(itemData.defenseNum)) 
    self._buildLbl:setString(tostring(itemData.buildStr))  
    self._onlineLbl:setString(tostring(itemData.onlineStr)) 
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


 return GuildMemberNormalItem  

