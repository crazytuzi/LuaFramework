local VipLibaoRewardItem = class("VipLibaoRewardItem", function()
	return CCTableViewCell:new()
end)

function VipLibaoRewardItem:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("shop/shop_vipLibao_reward_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function VipLibaoRewardItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("shop/shop_vipLibao_reward_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width / 2, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	self._rootnode.itemDesLbl:setColor(ccc3(59, 4, 4))
	self:refreshItem(itemData)
	return self
end

function VipLibaoRewardItem:refresh(itemData)
	self:refreshItem(itemData)
end

function VipLibaoRewardItem:refreshItem(itemData)
	self._rootnode.itemDesLbl:setString(tostring(itemData.describe))
	local rewardIcon = self._rootnode.itemIcon
	rewardIcon:removeAllChildrenWithCleanup(true)
	ResMgr.refreshIcon({
	id = itemData.id,
	resType = itemData.iconType,
	itemBg = rewardIcon,
	itemType = itemData.type
	})
	local canhunIcon = self._rootnode.reward_canhun
	local suipianIcon = self._rootnode.reward_suipian
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)
	local nameColor = ResMgr.getItemNameColorByType(itemData.id, itemData.iconType)
	self._rootnode.name_lbl:setString(tostring(itemData.name))
	self._rootnode.name_lbl:setColor(nameColor)
	self._rootnode.top_num_lbl:setString(common:getLanguageString("@Quantity") .. tostring(itemData.num))
end

return VipLibaoRewardItem