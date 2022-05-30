local ShenmiCell = class(ShenmiCell, function()
	return CCTableViewCell:new()
end)

function ShenmiCell:getContentSize()
	if self.Cntsize ~= nil then
	else
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("nbhuodong/shenmi_duihuan_item.ccbi", proxy, rootnode)
		self.Cntsize = rootnode.itemBg:getContentSize()
	end
	return self.Cntsize
end

function ShenmiCell:create(param)
	local viewSize = param.viewSize
	self._informationFunc = param.informationFunc
	self._exchangeFunc = param.exchangeFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/shenmi_duihuan_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height * 0.5)
	self:addChild(node)
	self:updateItem(param.itemData)
	
	--À©Õ¹
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

function ShenmiCell:tableCellTouched(x, y)
	local icon = self._rootnode["itemIcon"]
	local bound = icon:getCascadeBoundingBox()
	if bound:containsPoint(cc.p(x, y)) then
		self._informationFunc(self)
	end
end

function ShenmiCell:setIconTouchEnabled(bEnabled)
	self._rootnode.itemIcon:setTouchEnabled(bEnabled)
end

function ShenmiCell:updateExchangeBtn(bEnabled)
	self._rootnode.exchangeBtn:setEnabled(bEnabled)
end

function ShenmiCell:updateExchangeNum(num)
	self._itemData.limitNum = num or self._itemData.limitNum
	self._rootnode.exchange_num:setString(common:getLanguageString("@ExchangeTime") .. self._itemData.limitNum)
	if self._itemData.limitNum == 0 then
		self:updateExchangeBtn(false)
	else
		self:updateExchangeBtn(true)
	end
end

function ShenmiCell:updateItem(itemData)
	self._itemData = itemData
	self:updateExchangeNum(self._itemData.limitNum)
	local rewardIcon = self._rootnode.itemIcon
	rewardIcon:removeAllChildrenWithCleanup(true)
	ResMgr.refreshIcon({
	id = self._itemData.id,
	resType = self._itemData.iconType,
	itemBg = rewardIcon,
	iconNum = self._itemData.num,
	isShowIconNum = false,
	numLblSize = 22,
	numLblColor = cc.c3b(0, 255, 0),
	numLblOutColor = cc.c3b(0, 0, 0),
	itemType = self._itemData.type
	})
	local canhunIcon = self._rootnode.reward_canhun
	local suipianIcon = self._rootnode.reward_suipian
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)
	local nameColor = ResMgr.getItemNameColorByType(self._itemData.id, self._itemData.iconType)
	if self._nameLbl ~= nil then
		self._nameLbl:setString(self._itemData.name)
		self._nameLbl:setColor(nameColor)
	else
		self._nameLbl = ui.newTTFLabelWithShadow({
		text = self._itemData.name,
		size = 22,
		color = nameColor,
		shadowColor = display.COLOR_BLACK,
		font = FONTS_NAME.font_haibao,
		align = ui.TEXT_ALIGN_CENTER
		})
		ResMgr.replaceKeyLableEx(self._nameLbl, self._rootnode, "name_lbl", 0, 0)
		self._nameLbl:align(display.LEFT_TOP)
	end
	if self._itemData.moneyType == 1 then
		self._rootnode.cost_name:setString(common:getLanguageString("@Goldlabel"))
	elseif self._itemData.moneyType == 2 then
		self._rootnode.cost_name:setString(common:getLanguageString("@SilverCoin"))
	elseif self._itemData.moneyType == 10 then
		self._rootnode.cost_name:setString(common:getLanguageString("@Spirit"))
	elseif self._itemData.moneyType == 16 then
		self._rootnode.cost_name:setString(common:getLanguageString("@lingyu"))
	end
	ResMgr.refreshMoneyIcon({
	itemBg = self._rootnode.cost_icon,
	moneyType = self._itemData.moneyType
	})
	self._rootnode.cost_num:setString(tostring(self._itemData.price))
	alignNodesOneByOne(self._rootnode.cost_name, self._rootnode.cost_icon)
	alignNodesOneByOne(self._rootnode.cost_icon, self._rootnode.cost_num, 5)
end

function ShenmiCell:refresh(itemData)
	self:updateItem(itemData)
end

return ShenmiCell