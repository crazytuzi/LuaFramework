local MonthCardRewardItem = class("MonthCardRewardItem", function ()
	return CCTableViewCell:new()
end)

function MonthCardRewardItem:getContentSize()
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/month_card_rewardItem.ccbi", proxy, rootnode)
	local contentSize = rootnode.reward:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return cc.size(contentSize.width + 15, contentSize.height)
end

function MonthCardRewardItem:refreshItem(param)
	local itemData = param.itemData
	local rewardIcon = self._rootnode.reward_icon
	rewardIcon:removeAllChildrenWithCleanup(true)
	ResMgr.refreshIcon({
	id = itemData.id,
	resType = itemData.iconType,
	itemBg = rewardIcon,
	iconNum = itemData.num,
	isShowIconNum = false,
	numLblSize = 22,
	numLblColor = display.COLOR_GREEN,
	numLblOutColor = display.COLOR_BLACK,
	itemType = itemData.type
	})
	local canhunIcon = self._rootnode.reward_canhun
	local suipianIcon = self._rootnode.reward_suipian
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)
	local nameKey = "reward_name"
	local nameColor = ResMgr.getItemNameColorByType(itemData.id, itemData.iconType)
	local dimensions_vn = cc.size(100, 100)
	local align_vn = ui.TEXT_ALIGN_CENTER
	local v_aling_vn = ui.TEXT_VALIGN_BOTTOM
	
	local nameLbl = ui.newTTFLabelWithShadow({
	text = itemData.name,
	size = 20,
	color = nameColor,
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = align_vn,
	dimensions = dimensions_vn,
	valign = v_aling_vn
	})
	ResMgr.replaceKeyLableEx(nameLbl, self._rootnode, nameKey, 0, nameLbl:getContentSize().height / 2)
	nameLbl:align(display.CENTER)
end

function MonthCardRewardItem:create(param)
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/month_card_rewardItem.ccbi", proxy, self._rootnode)
	local contentSize = self._rootnode.reward:getContentSize()
	node:setPosition(contentSize.width * 0.7, _viewSize.height * 0.5)
	self:addChild(node)
	self:refreshItem(param)
	return self
end

function MonthCardRewardItem:refresh(param)
	self:refreshItem(param)
end

return MonthCardRewardItem