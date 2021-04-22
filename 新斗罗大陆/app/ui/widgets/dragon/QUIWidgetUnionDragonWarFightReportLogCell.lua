-- 
-- zxs
-- 武魂战战报日志
-- 
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonWarFightReportLogCell = class("QUIWidgetUnionDragonWarFightReportLogCell", QUIWidget)
local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QRichText = import("....utils.QRichText")

function QUIWidgetUnionDragonWarFightReportLogCell:ctor(options)
	local ccbFile = "ccb/Widget_society_union_log_sheet2.ccbi"
	local callBack = {
	}
	QUIWidgetUnionDragonWarFightReportLogCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetUnionDragonWarFightReportLogCell:setInfo(param)
	self._info = param.info or {}
	self._index = param.index

	local textCfg, createAt = remote.unionDragonWar:encodeDragonWarLogsByType(self._info.content)
	if self._richText == nil then
		self._richText = QRichText.new(nil,646,{stringType = 1, defaultColor = COLORS.a, defaultSize = 20, fontName = global.font_name})
		self._richText:setAnchorPoint(0,1)
		self._ccbOwner.content:addChild(self._richText)
	end
	self._richText:setString(textCfg)

	local time = q.date("%H:%M", createAt/1000)
	self._ccbOwner.time:setString(time)
end

function QUIWidgetUnionDragonWarFightReportLogCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetUnionDragonWarFightReportLogCell