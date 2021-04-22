--
-- Kumo.Wang
-- 鼠年春节活动福卡组件——单张福卡
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRatFestival = class("QUIWidgetRatFestival", QUIWidget)

QUIWidgetRatFestival.EVENT_CLICK = "QUIWIDGETRATFESTIVAL.EVENT_CLICK"

QUIWidgetRatFestival.STATE_NONE = 0 -- 尚未收集
QUIWidgetRatFestival.STATE_COMPLETE = 1 -- 可兑换
QUIWidgetRatFestival.STATE_DONE = 2 --已收集

function QUIWidgetRatFestival:ctor(options)
	local ccbFile = "ccb/Widget_RatFestival.ccbi"
	QUIWidgetRatFestival.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetRatFestival:setInfo(info, index, maxIndex)
	self._ratFestivalModel = remote.activityRounds:getRatFestival()
	if not self._ratFestivalModel or not info then return end

	self._info = info
	
	self._ccbOwner.sp_corner_right:setVisible(index == maxIndex)
	self._ccbOwner.sp_corner_left:setVisible(index == 1)

	QSetDisplayFrameByPath(self._ccbOwner.sp_name, self._info.name)

	QSetDisplayFrameByPath(self._ccbOwner.sp_card, self._info.card)
	--切圖
	local size = self._ccbOwner.node_mask:getContentSize()
	local lyImageMask = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
	local ccclippingNode = CCClippingNode:create()
	lyImageMask:setPositionX(self._ccbOwner.node_mask:getPositionX())
	lyImageMask:setPositionY(self._ccbOwner.node_mask:getPositionY())
	lyImageMask:ignoreAnchorPointForPosition(self._ccbOwner.node_mask:isIgnoreAnchorPointForPosition())
	lyImageMask:setAnchorPoint(self._ccbOwner.node_mask:getAnchorPoint())
	ccclippingNode:setStencil(lyImageMask)
	ccclippingNode:setInverted(false)
	self._ccbOwner.sp_card:retain()
	self._ccbOwner.sp_card:removeFromParent()
	ccclippingNode:addChild(self._ccbOwner.sp_card)
	self._ccbOwner.node_card:addChild(ccclippingNode)
	self._ccbOwner.sp_card:release()

	self:updateState()
end

function QUIWidgetRatFestival:updateState()
	if self._state == QUIWidgetRatFestival.STATE_DONE then 
		-- todo
		self._ccbOwner.node_money:setVisible(false)
		self._ccbOwner.tf_not_complete:setVisible(false)
		self._ccbOwner.ly_mask:setVisible(false)
		return 
	end

	local count = remote.items:getItemsNumByID(self._info.id)
	if count > 0 then 
		-- 已收集
		if self._state ~= QUIWidgetRatFestival.STATE_DONE then
			self._state = QUIWidgetRatFestival.STATE_DONE
			self:updateState()
			return
		end
	else
		if not self._state then
			self._state = QUIWidgetRatFestival.STATE_NONE
		end

		local price = self._ratFestivalModel:getLuckyCardConvertPriceById(self._info.id)
		local moneyId = self._ratFestivalModel:getLuckyCardFragmentItemId()
		local haveMoney = remote.items:getItemsNumByID(moneyId)
		if haveMoney >= price then
			self._state = QUIWidgetRatFestival.STATE_COMPLETE
			-- 可兑换
			-- todo
			local price = self._ratFestivalModel:getLuckyCardConvertPriceById(self._info.id)
			self._ccbOwner.tf_total_money:setString("x"..price)

			self._luckyCardFragmentItemId = self._ratFestivalModel:getLuckyCardFragmentItemId()
	        local path = remote.items:getURLForId(self._luckyCardFragmentItemId, "icon_1")
	        QSetDisplayFrameByPath(self._ccbOwner.sp_total_money, path)

			self._ccbOwner.node_money:setVisible(true)
			self._ccbOwner.tf_not_complete:setVisible(false)
			self._ccbOwner.ly_mask:setVisible(true)
			return
		else
			-- 尚未收集
			-- todo
			self._ccbOwner.node_money:setVisible(false)
			self._ccbOwner.tf_not_complete:setVisible(true)
			self._ccbOwner.ly_mask:setVisible(true)
		end
	end
end

function QUIWidgetRatFestival:setStateDone()
	self._state = QUIWidgetRatFestival.STATE_DONE
end

function QUIWidgetRatFestival:getInfo()
	return self._info
end

function QUIWidgetRatFestival:onTriggerClick()
	self:dispatchEvent({name = QUIWidgetRatFestival.EVENT_CLICK, info = self._info})
end

function QUIWidgetRatFestival:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetRatFestival