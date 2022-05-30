local DailyLoginCell = class("DailyLoginCell", function()
	return CCTableViewCell:new()
end)

function DailyLoginCell:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("reward/daily_login_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function DailyLoginCell:setTitle(index)
	local days = self.totalDays - 1
	if index > days then
		self._rootnode.index:setString(common:getLanguageString("@CheckIn") .. days .. common:getLanguageString("@CheckInDays"))
	else
		self._rootnode.index:setString(common:getLanguageString("@CheckInNo") .. index .. common:getLanguageString("@Day"))
	end
end

function DailyLoginCell:getTutoBtn()
	return self._rootnode.rewardBtn
end

function DailyLoginCell:checkEnabled(index)
	local rewardBtn = self._rootnode.rewardBtn
	local curDay_index = self.curDay - 1
	rewardBtn:setVisible(true)
	self._rootnode.tag_has_get:setVisible(false)
	if index ~= curDay_index then
		rewardBtn:setEnabled(false)
		if index < curDay_index then
			rewardBtn:setVisible(false)
			self._rootnode.tag_has_get:setVisible(true)
		else
		end
	elseif self.isSign then
		rewardBtn:setVisible(false)
		self._rootnode.tag_has_get:setVisible(true)
	else
		rewardBtn:setEnabled(true)
	end
end

function DailyLoginCell:updateItem(itemData)
	if #itemData > 4 then
		table.remove(itemData, 3)
	end
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

function DailyLoginCell:refreshItem(param)
	local index = param.index
	local itemData = param.itemData
	self:setTitle(index + 1)
	self:checkEnabled(index)
	self:updateItem(itemData)
end

function DailyLoginCell:getIcon(index)
	return self._rootnode["reward_icon_" .. tostring(index)]
end

function DailyLoginCell:setRewardEnabled(bEnable)
	self._rootnode.rewardBtn:setEnabled(bEnable)
end

function DailyLoginCell:create(param)
	self.cellIndex = param.id
	self.curDay = param.curDay
	self.isSign = param.isSign
	self.viewSize = param.viewSize
	self.totalDays = param.totalDays
	local cellData = param.cellData
	local rewardListener = param.rewardListener
	local informationListener = param.informationListener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("reward/daily_login_item.ccbi", proxy, self._rootnode)
	node:setPosition(self.viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height * 0.5)
	self:addChild(node)
	
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
	itemData = cellData.itemData
	})
	return self
end

function DailyLoginCell:runEnterAnim()
	local delayTime = self.cellIndex * 0.15
	local sequence = transition.sequence({
	CCCallFuncN:create(function()
		self:setPosition(cc.p(self:getContentSize().width * 0.5 + display.width * 0.5, self:getPositionY()))
	end),
	CCDelayTime:create(delayTime),
	CCMoveBy:create(0.3, cc.p(-(self:getContentSize().width / 2 + display.width / 2), 0))
	})
	self:runAction(sequence)
end

function DailyLoginCell:refresh(param)
	self:refreshItem(param)
end

function DailyLoginCell:getReward(isSign)
	self.isSign = isSign
	local rewardBtn = self._rootnode.rewardBtn
	rewardBtn:setVisible(false)
	self._rootnode.tag_has_get:setVisible(true)
end

return DailyLoginCell