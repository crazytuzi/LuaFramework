local ChongzhiRewardItem = class("ChongzhiRewardItem", function()
	return CCTableViewCell:new()
end)

function ChongzhiRewardItem:getContentSize()
	if self._cntSize == nil then
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("shop/shop_chongzhi_vipReward_item.ccbi", proxy, rootnode)
		local contentSize = rootnode.reward:getContentSize()
		self._cntSize = cc.size(contentSize.width + 15, contentSize.height)
	end
	return self._cntSize
end

function ChongzhiRewardItem:refreshItem(param)
	local itemData = param.itemData
	local rewardIcon = self._rootnode.reward_icon
	rewardIcon:removeAllChildrenWithCleanup(true)
	ResMgr.refreshItemWithTagNumName({
	id = itemData.id,
	itemBg = rewardIcon,
	resType = itemData.iconType,
	isShowIconNum = false,
	itemNum = itemData.num,
	itemType = itemData.type,
	cls = 0
	})
end

function ChongzhiRewardItem:create(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("shop/shop_chongzhi_vipReward_item.ccbi", proxy, self._rootnode)
	local contentSize = self._rootnode.reward:getContentSize()
	node:setPosition(contentSize.width * 0.5 + 7.5, self:getContentSize().height * 0.5)
	self:addChild(node)
	self:refreshItem(param)
	self._cntSize = cc.size(contentSize.width + 15, contentSize.height)
	return self
end

function ChongzhiRewardItem:refresh(param)
	self:refreshItem(param)
end

return ChongzhiRewardItem