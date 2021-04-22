local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityPrepay = class("QUIWidgetActivityPrepay", QUIWidget)
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIWidgetActivityPrepay:ctor(options)
  	local ccbFile = "ccb/Widget_Prepay.ccbi"
	local callBacks = {
	  	{ccbCallbackName = "onTriggerGo", callback = handler(self, QUIWidgetActivityPrepay._onTriggerGo)},
	}
  	QUIWidgetActivityPrepay.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetActivityPrepay:setInfo(info)
	if not self._descRichText then
	    self._descRichText = QRichText.new({
	        {oType = "font", content = info.description or "",size = 22,color = ccc3(134,84,54)},
	    },470)
  		self._ccbOwner.node_desc:addChild(self._descRichText)
	    self._descRichText:setAnchorPoint(0, 1)
	end
	self._ccbOwner.tf_desc2:setString("")

	local startTimeTbl = q.date("*t", (info.start_at or 0)/1000)
	local endTimeTbl = q.date("*t", (info.end_at or 0)/1000)
	local timeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", 
		startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, 
		endTimeTbl.month, endTimeTbl.day, endTimeTbl.hour, endTimeTbl.min)
	self._ccbOwner.tf_time2:setString(timeStr)


	if not self._infoRichText then
	    self._infoRichText = QRichText.new({
	        {oType = "font", content = "领取方式：不删档公测开服后，用删档计费测试期间相同的账号登录游戏，即可领取奖励。",size = 22,color = ccc3(134,84,54)},
	    },470)
  		self._ccbOwner.node_info:addChild(self._infoRichText)
	    self._infoRichText:setAnchorPoint(0, 1)
	end
	self._ccbOwner.tf_info:setString("")
end

function QUIWidgetActivityPrepay:_onTriggerGo()
	if ENABLE_CHARGE() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

return QUIWidgetActivityPrepay