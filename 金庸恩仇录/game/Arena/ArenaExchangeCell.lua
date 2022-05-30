local ArenaExchangeCell = class(ArenaExchangeCell, function()
	return CCTableViewCell:new()
end)
local ARENA_EXCHANGE_TYPE = 1
local HUASHAN_SHOP_TYPE = 2
local KUAFU_EXCHANGE_TYPE = 3
local BANGZHAN_EXCHANGE_TYPE = 4

function ArenaExchangeCell:getContentSize()
	if self.Cntsize ~= nil then
	else
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("arena/exchange_item.ccbi", proxy, rootnode)
		self.Cntsize = node:getContentSize()
	end
	return self.Cntsize
end

function ArenaExchangeCell:ctor(cellType)
	self.cellType = cellType or ARENA_EXCHANGE_TYPE
end

function ArenaExchangeCell:resetByCellType()
	if self.cellType == ARENA_EXCHANGE_TYPE then
		self._rootnode.shengwang_icon:setVisible(true)
		self._rootnode.lingshi_icon:setVisible(false)
	elseif self.cellType == KUAFU_EXCHANGE_TYPE then
		self._rootnode.shengwang_icon:setVisible(true)
		self._rootnode.lingshi_icon:setVisible(false)
		self._rootnode.propLabel_1:setString(common:getLanguageString("@WeiWang") .. ":")
		self._rootnode.shengwang_icon:setDisplayFrame(display.newSprite("#icon_weigwang.png"):getDisplayFrame())
	elseif self.cellType == BANGZHAN_EXCHANGE_TYPE then
		self._rootnode.shengwang_icon:setVisible(true)
		self._rootnode.lingshi_icon:setVisible(false)
		self._rootnode.propLabel_1:setString(common:getLanguageString("@GuildBattleExploit") .. ":")
		self._rootnode.shengwang_icon:setDisplayFrame(display.newSprite("ui/ui_CommonResouces/ui_gongxun_icon.png"):getDisplayFrame())
	else
		self._rootnode.shengwang_icon:setVisible(false)
		self._rootnode.lingshi_icon:setVisible(true)
		self._rootnode.propLabel_1:setString(common:getLanguageString("@QuickStone"))
	end
end

function ArenaExchangeCell:create(param)
	local viewSize = param.viewSize
	self._informationFunc = param.informationFunc
	self._exchangeFunc = param.exchangeFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("arena/exchange_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width / 2, 0)
	self:addChild(node)
	self:resetByCellType()
	self:updateItem(param.itemData)
	
	self._rootnode.exchangeBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._exchangeFunc ~= nil then
			self:updateExchangeBtn(false)
			self._exchangeFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	return self
end

function ArenaExchangeCell:tableCellTouched(x, y)
	local icon = self._rootnode.itemIcon
	local size = icon:getContentSize()
	if cc.rectContainsPoint(cc.rect(0, 0, size.width, size.height), icon:convertToNodeSpace(cc.p(x, y))) then
		if  self._informationFunc then
			self._informationFunc(self)
		end
	end
end

function ArenaExchangeCell:updateExchangeBtn(bEnabled)
	self._rootnode.exchangeBtn:setEnabled(bEnabled)
end

function ArenaExchangeCell:updateExchangeNum(limitNum, had)
	self._itemData.limitNum = limitNum or self._itemData.limitNum
	self._itemData.had = had or self._itemData.had
	if self._itemData.limitNum == 0 then
		self:updateExchangeBtn(false)
	else
		self:updateExchangeBtn(true)
	end
	if self._itemData.limitNum == -1 then
		self._rootnode.exchange_num_lbl:setVisible(false)
	else
		self._rootnode.exchange_num_lbl:setVisible(true)
		local tips = {
		common:getLanguageString("@Total"),
		common:getLanguageString("@ToDay"),
		common:getLanguageString("@Week")
		}
		local text = common:getLanguageString("@CanExchange", tips[self._itemData.type1], self._itemData.limitNum)
		self._rootnode.exchange_num_lbl:setString(text)
	end
end

function ArenaExchangeCell:updateItem(itemData)
	self._itemData = itemData
	self:updateExchangeNum(self._itemData.limitNum, self._itemData.had)
	local rewardIcon = self._rootnode.itemIcon
	rewardIcon:removeAllChildrenWithCleanup(true)
	ResMgr.refreshIcon({
	id = self._itemData.id,
	resType = self._itemData.iconType,
	itemBg = rewardIcon,
	iconNum = self._itemData.num,
	isShowIconNum = false,
	numLblSize = 22,
	numLblColor = FONT_COLOR.GREEN,
	numLblOutColor = FONT_COLOR.BLACK,
	itemType = self._itemData.type
	})
	local canhunIcon = self._rootnode.reward_canhun
	local suipianIcon = self._rootnode.reward_suipian
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)
	
	local nameColor = ResMgr.getItemNameColorByType(self._itemData.id, self._itemData.iconType)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = self._itemData.name,
	size = 24,
	color = nameColor,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER
	})
	
	ResMgr.replaceKeyLableEx(nameLbl, self._rootnode, "itemNameLbl", 0, 0)
	nameLbl:align(display.LEFT_CENTER)
	
	self._rootnode.itemDesLbl:setString(self._itemData.describe)
	if game.player:getLevel() >= self._itemData.needLevel then
		self._rootnode.tag_level_node:setVisible(false)
	else
		self._rootnode.tag_level_node:setVisible(true)
		self._rootnode.dengji_num:setString(self._itemData.needLevel)
	end
	self._rootnode.shengwang_num:setString(self._itemData.needReputation)
	alignNodesOneByOne(self._rootnode.lingshi_name, self._rootnode.lingshi_num, 2)
	alignNodesOneByOne(self._rootnode.propLabel_1, self._rootnode.shengwang_num, 2)
end

function ArenaExchangeCell:refresh(itemData)
	self:updateItem(itemData)
end

return ArenaExchangeCell