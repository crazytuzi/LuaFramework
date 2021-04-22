local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonWarInfoLogClient = class("QUIWidgetUnionDragonWarInfoLogClient", QUIWidget)
local QRichText = import("....utils.QRichText") 

function QUIWidgetUnionDragonWarInfoLogClient:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_rizhi.ccbi"
	local callBack = {
	}
	QUIWidgetUnionDragonWarInfoLogClient.super.ctor(self, ccbFile, callBack, options)
	self._contentLabel = QRichText.new(nil, 630, {stringType = 1, defaultSize = 22, defaultColor = COLORS.k, fontName = global.font_name})
	self._contentLabel:setAnchorPoint(ccp(0, 1))
	self._ccbOwner.node_content:addChild(self._contentLabel)
end

function QUIWidgetUnionDragonWarInfoLogClient:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetUnionDragonWarInfoLogClient:setInfo(data, index)
	local richStr, time = remote.unionDragonWar:encodeDragonWarLogsByType(data.content)
	local date = q.date("*t", time/1000)
	local timeStr = string.format("%02d:%02d", date.hour, date.min)
	self._contentLabel:setString(timeStr..richStr)

	-- self._ccbOwner.node_bg:setVisible(index%2~=0)
	self._ccbOwner.node_bg:setVisible(false)
	self._ccbOwner.sp_line:setVisible(index ~= 1)
end



return QUIWidgetUnionDragonWarInfoLogClient