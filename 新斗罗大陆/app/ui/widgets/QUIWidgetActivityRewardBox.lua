-- 
-- zxs
-- 累计奖励box
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityRewardBox = class("QUIWidgetActivityRewardBox", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QListView = import("...views.QListView")

QUIWidgetActivityRewardBox.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetActivityRewardBox:ctor(options)
	local ccbFile = "Widget_Activity_sevenday_bar.ccbi"
	local callBacks = {
		--{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetActivityRewardBox._onTriggerClick)}
	}
	QUIWidgetActivityRewardBox.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetActivityRewardBox:setInfo(info, callback)
	self._info = info
	self._callback = callback

	self._canGet = false
	if not info.isGet and info.isComplete then
		self._canGet = true
	end

	local awards = info.awards
	local param = {itemId = awards.id, itemType = awards.typeName, count = awards.count}
    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setInfo(param)
	itemBox:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._onTriggerClick))
    itemBox:setPromptIsOpen(not self._canGet)
    if not info.isGet and info.effect and info.effect == 1 then
		itemBox:showBoxEffect("effects/leiji_light.ccbi", true, 0, 0, 0.6)
	end
    self._ccbOwner.node_box:removeAllChildren()
    self._ccbOwner.node_box:addChild(itemBox)
	self._ccbOwner.tf_count:setVisible(false) 

	self._ccbOwner.node_effect:setVisible(false)
	self._ccbOwner.sp_get:setVisible(false)
    makeNodeFromGrayToNormal(self._ccbOwner.node_box)
	if info.isGet then
		self._ccbOwner.sp_get:setVisible(true)
    	makeNodeFromNormalToGray(self._ccbOwner.node_box)
	elseif info.isComplete then
		self._ccbOwner.node_effect:setVisible(true)
	end
end

function QUIWidgetActivityRewardBox:setHideGet()
	self._ccbOwner.sp_get:setVisible(false)
end

function QUIWidgetActivityRewardBox:setDesc(desc)
	self._ccbOwner.tf_count:setString(desc) 
	self._ccbOwner.tf_count:setVisible(true) 
end

function QUIWidgetActivityRewardBox:getContentSize()
	return self._ccbOwner.node_box:getContentSize()
end

function QUIWidgetActivityRewardBox:_onTriggerClick()
	if not self._canGet then
		return
	end
	self:dispatchEvent({name = QUIWidgetActivityRewardBox.EVENT_CLICK, info = self._info})
end

return QUIWidgetActivityRewardBox

