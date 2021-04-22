--
-- Kumo.Wang
-- zhangbichen主题曲活动——全服音浪Icon
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetZhangbichenReward = class("QUIWidgetZhangbichenReward", QUIWidget)

local QUIViewController = import("..QUIViewController")

QUIWidgetZhangbichenReward.EVENT_CLICK = "QUIWIDGETZHANGBICHENREWARD.EVENT_CLICK"

function QUIWidgetZhangbichenReward:ctor(options)
	local ccbFile = "ccb/Widget_Activity_Zhangbichen_Formal_Icon.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick",  callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetZhangbichenReward.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._isCanGet = false -- 是否可以领取
	self._isGet = false -- 是否已领取

	self._zhangbichenModel = remote.activityRounds:getZhangbichen()
end

function QUIWidgetZhangbichenReward:setInfo(info)
	if not info then return end
	self._info = info
	self._ccbOwner.tf_box_name:setString((self._info.expectation).."音符")

	self:refreshInfo()
end

function QUIWidgetZhangbichenReward:refreshInfo()
	if not self._zhangbichenModel then return end
	-- local pathList = QResPath("zhangbichenFormalBoxImg")[tonumber(self._info.id)]
	local pathList = QResPath("zhangbichenFormalBoxImg")[tonumber(5)]
	if pathList then
		QSetDisplayFrameByPath(self._ccbOwner.sp_box, pathList[1])
	end

	local serverInfo = self._zhangbichenModel:getServerInfo()
	local currNum = tonumber(serverInfo.currNum) or 0
	if currNum >= tonumber(self._info.expectation) then
		self._isCanGet = true
	end
	if self._isGet then
		self._isCanGet = false
		if pathList then
			QSetDisplayFrameByPath(self._ccbOwner.sp_box, pathList[2])
		end
		self._ccbOwner.ccb_effect:setVisible(false)
	else
		if self._isCanGet then
			self._ccbOwner.ccb_effect:setVisible(true)
		else
			self._ccbOwner.ccb_effect:setVisible(false)
		end
	end
end

function QUIWidgetZhangbichenReward:isGet(boo)
	self._isGet = boo
end

function QUIWidgetZhangbichenReward:_onTriggerClick()
	if self._isCanGet then
		self:dispatchEvent({name = QUIWidgetZhangbichenReward.EVENT_CLICK, box = self, info = self._info})
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogZhangbichenChestAward", options = {info = self._info}})
	end
end

return QUIWidgetZhangbichenReward