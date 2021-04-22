--
-- Kumo.Wang
-- 鼠年春节活动福卡抽奖——进度条box
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRatFestivalTavernProgressBarBox = class("QUIWidgetRatFestivalTavernProgressBarBox", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetRatFestivalTavernProgressBarBox.NONE = 0
QUIWidgetRatFestivalTavernProgressBarBox.RECEIVE = 1
QUIWidgetRatFestivalTavernProgressBarBox.DONE = 2

QUIWidgetRatFestivalTavernProgressBarBox.EVENT_CLICK = "QUIWIDGETACTIVITYFORSEVENPROGRESSBOX.EVENT_CLICK"

function QUIWidgetRatFestivalTavernProgressBarBox:ctor(options)
	local ccbFile = "ccb/Widget_RatFestival_Progress_Box.ccbi"
	QUIWidgetRatFestivalTavernProgressBarBox.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetRatFestivalTavernProgressBarBox:_resetAll()
	self._ccbOwner.node_box:setVisible(true)
	self._ccbOwner.node_box:setScale(0.6)
	self._ccbOwner.node_itembox:removeAllChildren()
	self._ccbOwner.node_itembox:setVisible(true)
	self._ccbOwner.node_itembox_effect:removeAllChildren()
	self._ccbOwner.node_itembox_effect:setVisible(true)
	self._ccbOwner.sp_done:setVisible(false)
	self._ccbOwner.tf_progress_num:setVisible(false)
end

function QUIWidgetRatFestivalTavernProgressBarBox:setInfo(info)
	self:_resetAll()

	self._info = info
	if not self._info then return end

	if self._info.state == QUIWidgetRatFestivalTavernProgressBarBox.RECEIVE then
		local effect = CCBuilderReaderLoad("Widget_AchieveHero_light_orange.ccbi", CCBProxy:create(), {})
		self._ccbOwner.node_itembox_effect:addChild(effect)
	end

	if self._info.itemInfo then
		local itembox = QUIWidgetItemsBox.new()
		itembox:setGoodsInfo(self._info.itemInfo.id, self._info.itemInfo.type, self._info.itemInfo.count)
		itembox:setPromptIsOpen(self._info.state ~= QUIWidgetRatFestivalTavernProgressBarBox.RECEIVE)
		if self._info.state ~= QUIWidgetRatFestivalTavernProgressBarBox.DONE then
			itembox:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._clickItemBox))
		end
		self._ccbOwner.node_itembox:addChild(itembox)
	end

	if self._info.isLast then
		self._ccbOwner.node_box:setScale(0.7)
	end

	self._ccbOwner.sp_done:setVisible(self._info.state == QUIWidgetRatFestivalTavernProgressBarBox.DONE)

	self._ccbOwner.tf_progress_num:setString(self._info.condition)
	self._ccbOwner.tf_progress_num:setVisible(true)

end

function QUIWidgetRatFestivalTavernProgressBarBox:_clickItemBox()
	self:dispatchEvent({name = QUIWidgetRatFestivalTavernProgressBarBox.EVENT_CLICK, index = self._info.index})
end

return QUIWidgetRatFestivalTavernProgressBarBox