local GuildShopGemItem = class("GuildShopGemItem", function()
	return CCTableViewCell:new()
end)

function GuildShopGemItem:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("guild/guild_shop_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function GuildShopGemItem:updateItem(itemData)
	self._itemData = itemData
	local exchangeBtn = self._rootnode.exchangeBtn
	local topNode = self._rootnode.tag_top_node
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
			color = cc.c3b(239, 158, 3),
			size = 40
			})
			ResMgr.replaceKeyLableEx(lbl, self._rootnode, "open_lbl", 0, 0)
			lbl:align(display.CENTER)
			topNode:setVisible(true)
			exchangeBtn:setEnabled(false)
		end
	end
	local rewardIcon = self._rootnode.reward_icon
	rewardIcon:removeAllChildrenWithCleanup(true)
	ResMgr.refreshIcon({
	id = self._itemData.itemId,
	resType = self._itemData.iconType,
	itemBg = rewardIcon,
	iconNum = self._itemData.num,
	isShowIconNum = false,
	numLblSize = 22,
	numLblColor = cc.c3b(0, 255, 0),
	numLblOutColor = FONT_COLOR.BLACK,
	itemType = self._itemData.type
	})
	local canhunIcon = self._rootnode.reward_canhun
	local suipianIcon = self._rootnode.reward_suipian
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)
	local nameColor = ResMgr.getItemNameColorByType(self._itemData.itemId, self._itemData.iconType)
	
	--物品名称
	local name_lbl =  ResMgr.createShadowMsgTTF({
	text = self._itemData.name,
	color = nameColor,
	size = 22,
	shadowColor = FONT_COLOR.BLACK
	})
	ResMgr.replaceKeyLableEx(name_lbl, self._rootnode, "name_lbl", 0, 0)
	name_lbl:align(display.LEFT_CENTER)
	
	--消耗帮贡
	local cost_lbl = ResMgr.createShadowMsgTTF({
	text = self._itemData.cost,
	color = FONT_COLOR.LIGHT_ORANGE,
	size = 22,
	shadowColor = FONT_COLOR.BLACK
	})
	ResMgr.replaceKeyLableEx(cost_lbl, self._rootnode, "cost_lbl", 0, 0)
	cost_lbl:align(display.LEFT_CENTER)
	
	self._rootnode.left_num_lbl:setString(tostring(self._itemData.exchange))
	if self._showType == GUILD_SHOP_TYPE.gem then
		self._rootnode.msg_lbl_1:setString(common:getLanguageString("@GuildName"))
		self._rootnode.msg_lbl_2:setString(common:getLanguageString("@JinDay"))
		self._rootnode.msg_lbl_3:setString(common:getLanguageString("@GuildShopItemLeft"))
	elseif self._showType == GUILD_SHOP_TYPE.prop then
		self._rootnode.msg_lbl_1:setString(common:getLanguageString("@GuildShopMember"))
		self._rootnode.msg_lbl_3:setString(common:getLanguageString("@GuildShopExchange"))
		if self._itemData.exchangeType == 1 then
			self._rootnode.msg_lbl_2:setString(common:getLanguageString("@JinDay"))
		elseif self._itemData.exchangeType == 2 then
			self._rootnode.msg_lbl_2:setString(common:getLanguageString("@Total"))
		end
	end
	alignNodesOneByOne(self._rootnode.cost_msg_lbl, self._rootnode.cost_lbl_Tag, 0)
	alignNodesOneByOne(self._rootnode.cost_lbl_Tag, self._rootnode.cost_lbl)
	alignNodesOneByAll({
	self._rootnode.msg_lbl_1,
	self._rootnode.msg_lbl_2,
	self._rootnode.msg_lbl_3,
	self._rootnode.left_num_lbl
	})
end

function GuildShopGemItem:getIcon()
	return self._rootnode.tag_top_node
end

function GuildShopGemItem:getItemData()
	return self._itemData
end

function GuildShopGemItem:setBtnEnabled(bEnable)
	self._rootnode.exchangeBtn:setEnabled(bEnable)
end

function GuildShopGemItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local exchangeFunc = param.exchangeFunc
	self._informationFunc = param.informationFunc
	self._showType = param.showType
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_shop_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height * 0.5)
	self:addChild(node)
	
	self._rootnode.exchangeBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if exchangeFunc ~= nil then
			self:setBtnEnabled(false)
			exchangeFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	self.cost_msg_lbl = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@Tribute"),
	color = cc.c3b(255, 222, 0),
	--parentNode = self._rootnode.cost_msg_lbl,	
	size = 22
	})
	ResMgr.replaceKeyLableEx(self.cost_msg_lbl, self._rootnode, "cost_msg_lbl", 0, 0)
	self.cost_msg_lbl:align(display.LEFT_CENTER)
	
	self:updateItem(itemData)
	return self
end

function GuildShopGemItem:tableCellTouched(x, y)
	local icon = self._rootnode.reward_icon
	local size = icon:getContentSize()
	if self._iconTouch == true and cc.rectContainsPoint(cc.rect(0, 0, size.width, size.height), icon:convertToNodeSpace(cc.p(x, y))) then
		if self._informationFunc  ~= nil then
			self._informationFunc(self)
		end
	end
end
function GuildShopGemItem:setIconTouchEnabled(bEnabled)
	self._iconTouch = bEnabled
	self._rootnode.reward_icon:setTouchEnabled(bEnabled)
end

function GuildShopGemItem:refresh(itemData)
	self:updateItem(itemData)
end

function GuildShopGemItem:getReward(itemData)
	self:updateItem(itemData)
end

return GuildShopGemItem