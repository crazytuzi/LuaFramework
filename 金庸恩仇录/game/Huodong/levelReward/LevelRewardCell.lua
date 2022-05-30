local LevelRewardCell = class("LevelRewardCell", function()
	return CCTableViewCell:new()
end)

function LevelRewardCell:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("reward/level_reward_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function LevelRewardCell:setTitle(index)
	self._rootnode.index:setString(common:getLanguageString("@BetRewardReceive", self.level))
end

function LevelRewardCell:getRewardBtn()
	return self._rootnode.rewardBtn
end

function LevelRewardCell:checkEnabled(index)
	local rewardBtn = self._rootnode.rewardBtn
	local rewarded = 0
	rewardBtn:setVisible(true)
	self._rootnode.tag_has_get:setVisible(false)
	if self.hasRewardLvs ~= nil then
		for _, v in ipairs(self.hasRewardLvs) do
			if v == self.level then
				rewarded = 1
				break
			end
		end
	end
	if self.level > self.curLevel then
		rewardBtn:setEnabled(false)
	elseif rewarded == 1 then
		rewardBtn:setVisible(false)
		self._rootnode.tag_has_get:setVisible(true)
	else
		rewardBtn:setEnabled(true)
	end
end

function LevelRewardCell:updateItem(itemData)
	for i, v in ipairs(itemData) do
		local reward = self._rootnode["reward_" .. tostring(i)]
		reward:setVisible(true)
		local rewardIcon = self._rootnode["reward_icon_" .. tostring(i)]
		rewardIcon:removeAllChildrenWithCleanup(true)
		ResMgr.refreshItemWithTagNumName({
		id = v.id,
		itemBg = rewardIcon,
		resType = v.iconType,
		isShowIconNum = false,
		itemNum = v.num,
		itemType = v.type,
		cls = 0
		})
	end
	local count = #itemData
	while count < 4 do
		self._rootnode["reward_" .. tostring(count + 1)]:setVisible(false)
		count = count + 1
	end
end

function LevelRewardCell:refreshItem(param)
	local index = param.index
	local itemData = param.itemData
	self.level = param.level
	self:setTitle(index + 1)
	self:checkEnabled(index)
	self:updateItem(itemData)
end

function LevelRewardCell:getIcon(index)
	return self._rootnode["reward_icon_" .. tostring(index)]
end

function LevelRewardCell:setRewardEnabled(bEnable)
	self._rootnode.rewardBtn:setEnabled(bEnable)
end

function LevelRewardCell:create(param)
	self.cellIndex = param.id
	self.level = param.level
	self.curLevel = param.curLevel
	self.hasRewardLvs = param.hasRewardLvs
	self.viewSize = param.viewSize
	local cellData = param.cellData
	local rewardListener = param.rewardListener
	local informationListener = param.informationListener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("reward/level_reward_item.ccbi", proxy, self._rootnode)
	node:setPosition(self.viewSize.width / 2, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	
	--ÁìÈ¡½±Àø
	local rewardBtn = self._rootnode.rewardBtn
	rewardBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if rewardListener then
			rewardBtn:setEnabled(false)
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			rewardListener(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	self:refreshItem({
	index = self.cellIndex,
	level = param.level,
	itemData = cellData.itemData
	})
	return self
end

function LevelRewardCell:getLevel()
	return self.level
end

function LevelRewardCell:refresh(param)
	self:refreshItem(param)
end

function LevelRewardCell:getReward(hasRewardLvs)
	self.hasRewardLvs = hasRewardLvs
	local rewardBtn = self._rootnode.rewardBtn
	rewardBtn:setVisible(false)
	self._rootnode.tag_has_get:setVisible(true)
end

return LevelRewardCell