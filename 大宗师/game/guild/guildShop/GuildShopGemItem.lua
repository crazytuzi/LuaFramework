--[[
 --
 -- add by vicky
 -- 2015.02.10 
 --
 --]]

local GuildShopGemItem = class("GuildShopGemItem", function()
	return CCTableViewCell:new()
end)


function GuildShopGemItem:getContentSize() 
	local proxy = CCBProxy:create()
    local rootNode = {}

    local node = CCBuilderReaderLoad("guild/guild_shop_item.ccbi", proxy, rootNode)
    local size = rootNode["itemBg"]:getContentSize()
    self:addChild(node)
    node:removeSelf()
    return size
end 


-- 更新奖励图标、名称、数量
function GuildShopGemItem:updateItem(itemData) 
	self._itemData = itemData 

	-- 兑换按钮
	local exchangeBtn = self._rootnode["exchangeBtn"]  
	local topNode = self._rootnode["tag_top_node"] 

	if self._showType == GUILD_SHOP_TYPE.gem then 
		self:setIconTouchEnabled(true) 
		topNode:setVisible(false) 
		if self._itemData.isBuyed == true or self._itemData.exchange <= 0 then 
			exchangeBtn:setEnabled(false) 
		else 
			exchangeBtn:setEnabled(true)  
		end 

	elseif self._showType == GUILD_SHOP_TYPE.prop then 
		if self._itemData.hasOpen == true then 
			self:setIconTouchEnabled(true) 
			self:setBtnEnabled(true) 
			topNode:setVisible(false) 
			if self._itemData.exchange <= 0 then 
				exchangeBtn:setEnabled(false) 
			else 
				exchangeBtn:setEnabled(true) 
			end 

		elseif self._itemData.hasOpen == false then 
			self:setIconTouchEnabled(false)  
			local lbl = ResMgr.createShadowMsgTTF({
					text = self._itemData.openMsg, 
					color = ccc3(239, 158, 3), 
					parentNode = self._rootnode["open_lbl"], 
					size = 40, 
					})
			lbl:setPosition(-lbl:getContentSize().width/2, 0) 

			topNode:setVisible(true) 
			exchangeBtn:setEnabled(false)   
		end 
	end 

	-- 图标
	local rewardIcon = self._rootnode["reward_icon"]
	rewardIcon:removeAllChildrenWithCleanup(true)
	ResMgr.refreshIcon({
		id = self._itemData.itemId, 
		resType = self._itemData.iconType, 
		itemBg = rewardIcon, 
		iconNum = self._itemData.num, 
		isShowIconNum = false, 
		numLblSize = 22, 
		numLblColor = ccc3(0, 255, 0), 
		numLblOutColor = ccc3(0, 0, 0) 
	}) 

	-- 属性图标
	local canhunIcon = self._rootnode["reward_canhun"]
	local suipianIcon = self._rootnode["reward_suipian"]
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)

	if self._itemData.type == 3 then
		-- 装备碎片
		suipianIcon:setVisible(true) 
	elseif self._itemData.type == 5 then
		-- 残魂(武将碎片)
		canhunIcon:setVisible(true) 
	end 

	-- 名称
	local nameColor = ccc3(255, 255, 255)
	if self._itemData.iconType == ResMgr.ITEM or self._itemData.iconType == ResMgr.EQUIP then 
		nameColor = ResMgr.getItemNameColor(self._itemData.itemId)
	elseif self._itemData.iconType == ResMgr.HERO then 
		nameColor = ResMgr.getHeroNameColor(self._itemData.itemId)
	end 

	ResMgr.createShadowMsgTTF({
		text = self._itemData.name, 
		color = nameColor, 
		parentNode = self._rootnode["name_lbl"], 
		size = 22 
		})

	-- 消耗贡献值 
	ResMgr.createShadowMsgTTF({
		text = self._itemData.cost, 
		color = ccc3(255, 255, 255), 
		parentNode = self._rootnode["cost_lbl"], 
		size = 22 
		})

	-- 剩余兑换数量相关 
	self._rootnode["left_num_lbl"]:setString(tostring(self._itemData.exchange)) 

	if self._showType == GUILD_SHOP_TYPE.gem then 
		self._rootnode["msg_lbl_1"]:setString("帮派") 
		self._rootnode["msg_lbl_2"]:setString("今日") 
		self._rootnode["msg_lbl_3"]:setString("还剩下     个") 
		
	elseif self._showType == GUILD_SHOP_TYPE.prop then 
		self._rootnode["msg_lbl_1"]:setString("个人") 
		self._rootnode["msg_lbl_3"]:setString("可兑换     个") 

		-- exchangeType:1-个人每日兑换，2-个人总兑换
		if self._itemData.exchangeType == 1 then 
			self._rootnode["msg_lbl_2"]:setString("今日") 
		elseif self._itemData.exchangeType == 2 then 
			self._rootnode["msg_lbl_2"]:setString("总共") 
		end 
	end 
	
end


function GuildShopGemItem:getIcon()
    return self._rootnode["tag_top_node"] 
end


function GuildShopGemItem:getItemData()
    return self._itemData; 
end


function GuildShopGemItem:setBtnEnabled(bEnable)
	self._rootnode["exchangeBtn"]:setEnabled(bEnable) 
end


function GuildShopGemItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData 
	local exchangeFunc = param.exchangeFunc 
	local informationFunc = param.informationFunc 
	self._showType = param.showType 

	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("guild/guild_shop_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height * 0.5)
	self:addChild(node)

	-- 兑换按钮
	local exchangeBtn = self._rootnode["exchangeBtn"] 
	exchangeBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
	        if exchangeFunc ~= nil then 
	        	self:setBtnEnabled(false)
	        	exchangeFunc(self) 
	        end
	    end, CCControlEventTouchUpInside)

	ResMgr.createShadowMsgTTF({
		text = "贡献:", 
		color = ccc3(255, 222, 0), 
		parentNode = self._rootnode["cost_msg_lbl"], 
		size = 22 
		})

	local rewardIcon = self._rootnode["reward_icon"] 
	self:setIconTouchEnabled(true) 
	rewardIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)  
        self:setIconTouchEnabled(false) 
        if (event.name == "began") then
        	return true  
        elseif (event.name == "ended") then 
        	if informationFunc ~= nil then 
	        	informationFunc(self)
	        end 
        end
    end)

	self:updateItem(itemData) 

	return self
end 

function GuildShopGemItem:setIconTouchEnabled(bEnabled) 
    self._rootnode["reward_icon"]:setTouchEnabled(bEnabled) 
end 


function GuildShopGemItem:refresh(itemData)
	self:updateItem(itemData) 
end


-- 改变按钮的状态
function GuildShopGemItem:getReward(itemData)
	self:updateItem(itemData) 
end


return GuildShopGemItem
