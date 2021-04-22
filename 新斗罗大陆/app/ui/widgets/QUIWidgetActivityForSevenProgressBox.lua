--
-- Kumo.Wang
-- 1~14日活動進度條Box
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityForSevenProgressBox = class("QUIWidgetActivityForSevenProgressBox", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetActivityForSevenProgressBox.NONE = 0
QUIWidgetActivityForSevenProgressBox.RECEIVE = 1
QUIWidgetActivityForSevenProgressBox.DONE = 2

QUIWidgetActivityForSevenProgressBox.EVENT_CLICK = "QUIWIDGETACTIVITYFORSEVENPROGRESSBOX.EVENT_CLICK"

function QUIWidgetActivityForSevenProgressBox:ctor(options)
	local ccbFile = "ccb/Widget_SevenDayAcitivity_box.ccbi"
	QUIWidgetActivityForSevenProgressBox.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetActivityForSevenProgressBox:_resetAll()
	self._ccbOwner.node_box:setVisible(true)
	self._ccbOwner.node_box:setScale(0.6)
	self._ccbOwner.node_itembox:removeAllChildren()
	self._ccbOwner.node_itembox:setVisible(true)
	self._ccbOwner.node_itembox_effect:removeAllChildren()
	self._ccbOwner.node_itembox_effect:setVisible(true)
	self._ccbOwner.sp_done:setVisible(false)
	self._ccbOwner.tf_progress_num:setVisible(false)
end

function QUIWidgetActivityForSevenProgressBox:setInfo(info)
	self:_resetAll()

	self._info = info
	if not self._info then return end

	if self._info.state == QUIWidgetActivityForSevenProgressBox.RECEIVE then
		local effect = CCBuilderReaderLoad("Widget_AchieveHero_light_orange.ccbi", CCBProxy:create(), {})
		self._ccbOwner.node_itembox_effect:addChild(effect)
	end

	if self._info.itemInfo then
		local itembox = QUIWidgetItemsBox.new()
		itembox:setGoodsInfo(self._info.itemInfo.id, self._info.itemInfo.type, self._info.itemInfo.count)
		itembox:setPromptIsOpen(self._info.state ~= QUIWidgetActivityForSevenProgressBox.RECEIVE)
		if self._info.state ~= QUIWidgetActivityForSevenProgressBox.DONE then
			itembox:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._clickItemBox))
		end
		self._ccbOwner.node_itembox:addChild(itembox)
	end

	if self._info.isLast then
		self._ccbOwner.node_box:setScale(0.7)
	end

	self._ccbOwner.sp_done:setVisible(self._info.state == QUIWidgetActivityForSevenProgressBox.DONE)

	self._ccbOwner.tf_progress_num:setString(self._info.condition)
	self._ccbOwner.tf_progress_num:setVisible(true)

end

function QUIWidgetActivityForSevenProgressBox:_clickItemBox()
	self:dispatchEvent({name = QUIWidgetActivityForSevenProgressBox.EVENT_CLICK, index = self._info.index})
end

return QUIWidgetActivityForSevenProgressBox