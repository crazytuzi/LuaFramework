local DengjiTouziItem = class("DengjiTouziItem", function ()
	return CCTableViewCell:new()
end)
function DengjiTouziItem:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("nbhuodong/dengjiTouzi_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end
function DengjiTouziItem:getLevel()
	return self._level
end
function DengjiTouziItem:create(param)
	local viewSize = param.viewSize
	local rewardListener = param.rewardListener
	local itemData = param.itemData
	self._hasGetAry = param.hasGetAry or {}
	self._curLevel = param.curLevel
	self._hasBuy = param.hasBuy
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/dengjiTouzi_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height * 0.5)
	self:addChild(node)
	self:refreshItem(itemData)
	self._rootnode.rewardBtn:addHandleOfControlEvent(function (eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if rewardListener ~= nil then
			rewardListener(self)
		end
	end,
	CCControlEventTouchUpInside)
	return self
end

function DengjiTouziItem:refresh(itemData)
	self:refreshItem(itemData)
end

function DengjiTouziItem:refreshItem(itemData)
	self._level = itemData.level
	if self._hasBuy == true then
		local hasGet = false
		for i, v in ipairs(self._hasGetAry) do
			if self._level == v then
				hasGet = true
				break
			end
		end
		if hasGet then
			self._rootnode.rewardBtn:setVisible(false)
			self._rootnode.tag_has_get:setVisible(true)
		else
			self._rootnode.tag_has_get:setVisible(false)
			self._rootnode.rewardBtn:setVisible(true)
			if self._level <= self._curLevel then
				self._rootnode.rewardBtn:setEnabled(true)
			else
				self._rootnode.rewardBtn:setEnabled(false)
			end
		end
	else
		self._rootnode.rewardBtn:setEnabled(false)
		self._rootnode.rewardBtn:setVisible(true)
		self._rootnode.tag_has_get:setVisible(false)
	end
	self._rootnode.level_top:setString(tostring(self._level) .. common:getLanguageString("@BetReward"))
	self._rootnode.level_bottom:setString(common:getLanguageString("@BetRewardReceive", self._level))
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
	})
end

function DengjiTouziItem:getReward(hasGetAry)
	self._hasGetAry = hasGetAry
	local rewardBtn = self._rootnode.rewardBtn
	rewardBtn:setVisible(false)
	self._rootnode.tag_has_get:setVisible(true)
end

return DengjiTouziItem