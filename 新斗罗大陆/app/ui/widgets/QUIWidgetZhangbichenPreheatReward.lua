--
-- Kumo.Wang
-- 张碧晨主题曲活动预热——主界面进度条奖励Cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetZhangbichenPreheatReward = class("QUIWidgetZhangbichenPreheatReward", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetZhangbichenPreheatReward.EVENT_CLICK = "QUIWIDGETZHANGBICHENPREHEATREWARD.EVENT_CLICK"

function QUIWidgetZhangbichenPreheatReward:ctor(options)
	local ccbFile = "ccb/Widget_Zhangbichen_Preheat.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick",  callback = handler(self, QUIWidgetZhangbichenPreheatReward._onTriggerClick)},
	}
	QUIWidgetZhangbichenPreheatReward.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._isCanGet = false -- 是否可以领取
	self._isGet = false -- 是否已领取

	self._zhangbichenPreheatModel = remote.activityRounds:getZhangbichenPreheat()
end

function QUIWidgetZhangbichenPreheatReward:setInfo(info)
	if not info then return end

	self._info = info

	self._ccbOwner.tf_item_name:setString((self._info.expectation / 10000).."万")

	self._ccbOwner.node_item:removeAllChildren()
	local tbl = string.split(self._info.rewards, "^")
	if tbl and #tbl > 0 then
		self._itemId = tonumber(tbl[1])
		local itemCount = tonumber(tbl[2])
		self._itemType = ITEM_TYPE.ITEM
		if not self._itemId then
			self._itemType = tbl[1]
		end

		self._box = QUIWidgetItemsBox.new()
		self._box:setGoodsInfo(self._itemId, self._itemType, itemCount)
		self._box:setPromptIsOpen(true)
		self._ccbOwner.node_item:addChild(self._box)
	end

	self:refreshInfo()
end

function QUIWidgetZhangbichenPreheatReward:refreshInfo()
	if not self._box or not self._zhangbichenPreheatModel then return end

	local serverInfo = self._zhangbichenPreheatModel:getServerInfo()
	local currExpectation = tonumber(serverInfo.currExpectation) or 0
	if currExpectation > tonumber(self._info.expectation) then
		self._isCanGet = true
	end
	if self._isGet then
		self._isCanGet = false
		-- makeNodeFromNormalToGray(self._ccbOwner.node_item)
		self._ccbOwner.sp_done:setVisible(true)
		self._ccbOwner.sp_lock:setVisible(false)
		self._ccbOwner.ccb_effect:setVisible(false)
	else
		if self._isCanGet then
			-- makeNodeFromGrayToNormal(self._ccbOwner.node_item)
			self._ccbOwner.sp_done:setVisible(false)
			self._ccbOwner.sp_lock:setVisible(false)
			self._ccbOwner.ccb_effect:setVisible(true)
		else
			-- makeNodeFromGrayToNormal(self._ccbOwner.node_item)
			self._ccbOwner.sp_done:setVisible(false)
			self._ccbOwner.sp_lock:setVisible(true)
			self._ccbOwner.ccb_effect:setVisible(false)
		end
	end
end

function QUIWidgetZhangbichenPreheatReward:isGet(boo)
	self._isGet = boo
end

function QUIWidgetZhangbichenPreheatReward:_onTriggerClick()
	if self._isCanGet then
		self:dispatchEvent({name = QUIWidgetZhangbichenPreheatReward.EVENT_CLICK, info = self._info})
	else
		app.tip:itemTip(self._itemType, self._itemId)
	end
end

return QUIWidgetZhangbichenPreheatReward