--[[
 --
 -- add by vicky
 -- 2015.01.12   
 --
 --]]


 local COST_TYPE = {
 	silver = 1, 
 	gold = 2, 
 }

 local yColor = ccc3(255, 222, 0)


 local GuildDadianContributeItem = class("GuildDadianContributeItem", function()
 		return CCTableViewCell:new() 
 	end )


 function GuildDadianContributeItem:getContentSize()
 	if self._contentSz == nil then 
	 	local proxy = CCBProxy:create() 
	 	local rootnode = {} 
	 	local node = CCBuilderReaderLoad("guild/guild_dadian_contribute_item.ccbi", proxy, rootnode) 
	 	self._contentSz = rootnode["item_bg"]:getContentSize() 
	end 
	
 	return self._contentSz 
 end 


 function GuildDadianContributeItem:getId()
 	return self._id 
 end 


 function GuildDadianContributeItem:setBtnEnabled(bEnabled)
 	self._rootnode["contributeBtn"]:setEnabled(bEnabled) 
 end 
 

 function GuildDadianContributeItem:create(param)
 	local viewSize = param.viewSize 
 	local itemData = param.itemData 
 	local hasContribute = param.hasContribute
 	local contributeFunc = param.contributeFunc 
 	local proxy = CCBProxy:create() 
 	self._rootnode = {} 
 	local node = CCBuilderReaderLoad("guild/guild_dadian_contribute_item.ccbi", proxy, self._rootnode) 
 	node:setPosition(0, viewSize.height/2)  
 	self:addChild(node) 

 	-- 消耗
    self:createTTF("消耗", FONT_COLOR.WHITE, self._rootnode["msg_lbl_1_1"])  

 	-- 增加帮派资金 
    self:createTTF("增加", FONT_COLOR.WHITE, self._rootnode["msg_lbl_2_1"]) 
    local msgLbl = self:createTTF("帮派资金", FONT_COLOR.WHITE, self._rootnode["msg_lbl_2_3"]) 
    msgLbl:setPosition(-msgLbl:getContentSize().width, 0)  

    -- 增加个人贡献 
    self:createTTF("增加", FONT_COLOR.WHITE, self._rootnode["msg_lbl_3_1"])  
    msgLbl = self:createTTF("个人贡献", ccc3(0, 219, 52), self._rootnode["msg_lbl_3_3"]) 
    msgLbl:setPosition(-msgLbl:getContentSize().width, 0) 

 	self:refreshItem(itemData) 

 	local contributeBtn = self._rootnode["contributeBtn"]  	
 	if hasContribute == true then 
 		contributeBtn:setEnabled(false) 
 	elseif hasContribute == false then 
 		contributeBtn:setEnabled(true) 

		contributeBtn:addHandleOfControlEvent(function(eventName,sender) 
	        if contributeFunc ~= nil then 
	        	contributeFunc(self) 
	        end 
	        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
	    end,CCControlEventTouchUpInside)
	end 


 	return self 
 end 


 function GuildDadianContributeItem:createTTF(text, color, node)
 	node:removeAllChildren() 

    local lbl = ui.newTTFLabelWithShadow({
        text = text,
        size = 18, 
        color = color,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
    }) 

    node:addChild(lbl) 
    return lbl 
 end


 function GuildDadianContributeItem:refresh(itemData)
 	self:refreshItem(itemData)
 end


 function GuildDadianContributeItem:refreshItem(itemData) 
 	self._id = itemData.id 

 	local iconName = "#guild_dd_coin_icon_" .. tostring(self._id) .. ".png" 
  	self._rootnode["coin_icon"]:setDisplayFrame(display.newSprite(iconName):getDisplayFrame()) 
  	local titleName = "#guild_dd_title_icon_" .. tostring(self._id) .. ".png" 
  	self._rootnode["title_icon"]:setDisplayFrame(display.newSprite(titleName):getDisplayFrame())  

  	-- 帮派资金
    local addLbl = self:createTTF(tostring(itemData.addmoney), yColor, self._rootnode["msg_lbl_2_2"]) 
    addLbl:setPosition(-addLbl:getContentSize().width/2, 0) 

    -- 个人贡献
    local selfLbl = self:createTTF(tostring(itemData.requirements), yColor, self._rootnode["msg_lbl_3_2"]) 
    selfLbl:setPosition(-selfLbl:getContentSize().width/2, 0) 

    -- 消耗
    local color 
    local needCoinStr  
    if itemData.type == COST_TYPE.silver then 
    	color = ccc3(22, 255, 255) 
    	needCoinStr = tostring(itemData.number) .. " 银币"
    elseif itemData.type == COST_TYPE.gold then 
    	color = yColor
    	needCoinStr = tostring(itemData.number) .. " 元宝"
    end 

    self:createTTF(needCoinStr, color, self._rootnode["msg_lbl_1_2"])  

 end 



 return GuildDadianContributeItem 
