-- 
-- zxs
-- 周基金奖励
-- 
local QUIWidget = import(".QUIWidget")
local QUIWidgetActivityWeekFundClient = class("QUIWidgetActivityWeekFundClient", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetActivityWeekFundClient.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetActivityWeekFundClient:ctor(options)
    local ccbFile = "ccb/Widget_zhoujijin_client.ccbi"
    local callBacks = {
    	{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)}
    }
    QUIWidgetActivityWeekFundClient.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._isReady = false
    self._itemBox = {}
end

function QUIWidgetActivityWeekFundClient:setInfo(param)
	self:resetAll()
	self._info = param.info

	self._ccbOwner.tf_day:setString("第"..(self._info.awardIndex or 0).."天")
	self:setIsReady(param.isReady)
	self:setIsDone(param.isDone)

	local awards = self._info.award or {}
	for i = 1, 2 do 
		if awards[i] then
			if self._itemBox[i] == nil then
				self._itemBox[i] = QUIWidgetItemsBox.new()
				self._ccbOwner["node_item"..i]:addChild(self._itemBox[i])
				self._itemBox[i]:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._clickAwardsBox))
			end
			self._itemBox[i]:setGoodsInfo(awards[i].id, awards[i].type or awards[i].typeName, awards[i].count)
			self._itemBox[i]:setPromptIsOpen(not self._isReady)
		end
	end
	
	if #awards == 1 then
		self._ccbOwner.node_item1:setPositionX(136)
		self._ccbOwner.node_item2:setVisible(false)
	else
		self._ccbOwner.node_item1:setPositionX(91)
		self._ccbOwner.node_item2:setVisible(true)
	end
end

function QUIWidgetActivityWeekFundClient:registerItemBoxPrompt( index, list )
	for i = 1, 2 do
		if self._itemBox[i] ~= nil then
			list:registerItemBoxPrompt(index, i, self._itemBox[i])
		end
	end
end

function QUIWidgetActivityWeekFundClient:resetAll()
	self._ccbOwner.node_effect:setVisible(false)
	self._ccbOwner.is_ready:setVisible(false)
	self._ccbOwner.node_done:setVisible(false)
end

function QUIWidgetActivityWeekFundClient:setIsReady(state)
	if state == nil then state = false end

	self._isReady = state
	self._ccbOwner.node_effect:setVisible(state)
	self._ccbOwner.is_ready:setVisible(state)
end

function QUIWidgetActivityWeekFundClient:setIsDone(state)
	if state == nil then state = false end

	self._ccbOwner.node_done:setVisible(state)
end

function QUIWidgetActivityWeekFundClient:_clickAwardsBox()
	self:_onTriggerClick()
end

function QUIWidgetActivityWeekFundClient:getContentSize()
	local size = self._ccbOwner.is_ready:getContentSize()
	size.width = size.width + 10
    return size
end

function QUIWidgetActivityWeekFundClient:_onTriggerClick()
	if self._isReady then
		self:dispatchEvent({name = QUIWidgetActivityWeekFundClient.EVENT_CLICK, info = self._info})
	end
end

return QUIWidgetActivityWeekFundClient