local ChallengeFubenRewardCell = class("ChallengeFubenRewardCell", function()
	return CCTableViewCell:new()
end)

function ChallengeFubenRewardCell:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("challenge/challengeFuben_reward_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function ChallengeFubenRewardCell:updateItem(itemData)
	self._rootnode.title_text:setString(itemData.iconName)
	for i, v in ipairs(itemData.cellDatas) do
		local reward = self._rootnode["reward_" .. tostring(i)]
		reward:setVisible(true)
		local rewardIcon = self._rootnode["reward_icon_" .. tostring(i)]
		rewardIcon:removeAllChildrenWithCleanup(true)
		ResMgr.refreshItemWithTagNumName({
		id = v.id,
		itemBg = rewardIcon,
		resType = v.iconType,
		isShowIconNum = 0,
		itemType = v.type
		})
	end
	local count = #itemData.cellDatas
	while count < 5 do
		self._rootnode["reward_" .. tostring(count + 1)]:setVisible(false)
		count = count + 1
	end
end

function ChallengeFubenRewardCell:getIcon(index)
	return self._rootnode["reward_icon_" .. tostring(index)]
end

function ChallengeFubenRewardCell:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local rewardListener = param.rewardListener
	local informationListener = param.informationListener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("challenge/challengeFuben_reward_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, 0)
	self:addChild(node)
	self:updateItem(itemData)
	return self
end

function ChallengeFubenRewardCell:refresh(itemData)
	self:updateItem(itemData)
end

return ChallengeFubenRewardCell