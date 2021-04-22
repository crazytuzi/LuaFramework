--[[	
	文件名称：QUIWidgetRushBuyRecord.lua
	创建时间：2017-02-14 19:45:35
	作者：nieming
	描述：QUIWidgetRushBuyRecord
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetRushBuyRecord = class("QUIWidgetRushBuyRecord", QUIWidget)

function QUIWidgetRushBuyRecord:ctor(options)
	local ccbFile = "Widget_SixYuan_Buylog2.ccbi"
	local callBacks = {
	}
	QUIWidgetRushBuyRecord.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetRushBuyRecord:setInfo(info,index)
	local dateTime = q.date("*t", info.buyAt/1000)
	if index %2 == 1 then
		self._ccbOwner.shadow:setVisible(true)
	else
		self._ccbOwner.shadow:setVisible(false)
	end

	-- self._ccbOwner.time:setString(string.format("%d-%02d-%02d %02d:%02d:%02d", dateTime.year, dateTime.month, dateTime.day,dateTime.hour, dateTime.min, dateTime.sec))
	self._ccbOwner.time:setString(string.format("%02d-%02d %02d:%02d:%02d", dateTime.month, dateTime.day,dateTime.hour, dateTime.min, dateTime.sec))
	self._ccbOwner.name:setString(string.format("%s(%s)",info.nickname,info.gameAreaName))
	self._ccbOwner.buyCount:setString(info.buyCount)
end

function QUIWidgetRushBuyRecord:getContentSize()
	return self._ccbOwner.cellsize:getContentSize()
end

return QUIWidgetRushBuyRecord
