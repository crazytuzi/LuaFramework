-- 
-- zxs
-- 玩法日历每天的每个任务
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGameCalendarCell = class("QUIWidgetGameCalendarCell", QUIWidget)

local QScrollView = import("...views.QScrollView") 
local QQuickWay = import("...utils.QQuickWay")

QUIWidgetGameCalendarCell.EVENT_CLICK_SELECT = "EVENT_CLICK_SELECT"

function QUIWidgetGameCalendarCell:ctor(options)
	local ccbFile = "ccb/Widget_wanfarili_cell.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetGameCalendarCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetGameCalendarCell:onEnter()
end

function QUIWidgetGameCalendarCell:onExit()
end

function QUIWidgetGameCalendarCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetGameCalendarCell:updateInfo()
	local isSetting = remote.calendar:getIsSetting()
	if isSetting then
		self._ccbOwner.node_info:setPositionX(55)
		self._ccbOwner.node_bg:setVisible(true)
		--self._ccbOwner.node_bg:setVisible(false)
	else
		self._ccbOwner.node_info:setPositionX(73)
		self._ccbOwner.node_bg:setVisible(false)
		--self._ccbOwner.node_bg:setVisible(true)
	end
end

function QUIWidgetGameCalendarCell:setInfo(info)
	self._info = info

	self._ccbOwner.tf_name:setString(info.game_name)
	self._ccbOwner.tf_time:setString(info.content)
	if info.icon then
        self._ccbOwner.node_icon:removeAllChildren()
		local icon = CCSprite:create(info.icon)
		icon:setScale(82/icon:getContentSize().width)
		self._ccbOwner.node_icon:addChild(icon)
	end
	if info.unlockConditionStr and info.unlockConditionStr ~= "" then
		self._ccbOwner.ly_lock:setVisible(true)
		self._ccbOwner.tf_lock:setString(info.unlockConditionStr)
	else
		self._ccbOwner.ly_lock:setVisible(false)
		self._ccbOwner.tf_lock:setVisible(false)
	end
	if info.double_rewards ~= 1 then
		self._ccbOwner.node_up:setVisible(false)
	else
		self._ccbOwner.node_up:setVisible(true)
	end

	self._select = info.isSelect
	self._ccbOwner.sp_on:setVisible(self._select)

	self:updateInfo()
end

function QUIWidgetGameCalendarCell:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetGameCalendarCell.EVENT_CLICK_SELECT, id = self._info.id, select = self._select})
end

return QUIWidgetGameCalendarCell