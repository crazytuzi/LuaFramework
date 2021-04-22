-- @Author: zhouxiaoshu
-- @Date:   2019-04-29 11:59:05
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-16 20:46:55
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetConsortiaWarRecordLog = class("QUIWidgetConsortiaWarRecordLog", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QRichText = import("....utils.QRichText") 

function QUIWidgetConsortiaWarRecordLog:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_rizhi.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetConsortiaWarRecordLog.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._richText = QRichText.new({}, 640)
	self._richText:setAnchorPoint(ccp(0, 1))
	self._ccbOwner.node_content:addChild(self._richText)
end

function QUIWidgetConsortiaWarRecordLog:onEnter()
end

function QUIWidgetConsortiaWarRecordLog:onExit()
end

function QUIWidgetConsortiaWarRecordLog:setInfo(info, index)
	local dateTime = q.date("*t", (info.createdAt or 0)/1000)
	local timeStr = string.format("%02d:%02d", dateTime.hour, dateTime.min)
	local paramTbl = string.split(info.param, "#")
	local union1 = string.format("【%s】", paramTbl[1])
	local num,unit = q.convertLargerNumber(paramTbl[3])
	local name1 = string.format("【%s】(战力%s)", paramTbl[2], num..unit)
	local union2 = string.format("【%s】", paramTbl[4])
	local hallName = string.format("【%s】", paramTbl[5])
	if info.eventType == 1002 then
		self._richText:setString({
			{oType = "font", content = timeStr, size = 20, color = COLORS.j},
	        {oType = "font", content = union1,size = 20, color = COLORS.k},
			{oType = "font", content = "的", size = 20, color = COLORS.j},
	        {oType = "font", content = name1,size = 20, color = COLORS.k},
	        {oType = "font", content = "发现了", size = 20, color = COLORS.j},
	        {oType = "font", content = union2,size = 20, color = COLORS.K},
			{oType = "font", content = "的", size = 20, color = COLORS.j},
	        {oType = "font", content = hallName,size = 20, color = COLORS.K},
			{oType = "font", content = "的", size = 20, color = COLORS.j},
	        {oType = "font", content = "【散落在地上的战旗】" or "0",size = 20, color = COLORS.K},
			{oType = "font", content = "并摧毁了", size = 20, color = COLORS.j},
	        {oType = "font", content = paramTbl[6] or "0",size = 20, color = COLORS.k},
			{oType = "font", content = "面旗帜", size = 20, color = COLORS.j},
	    })
	else
		local num,unit = q.convertLargerNumber(paramTbl[7])
		local name2 = string.format("【%s】(战力%s)", paramTbl[6], num..unit)
		self._richText:setString({
			{oType = "font", content = timeStr, size = 20, color = COLORS.j},
	        {oType = "font", content = union1,size = 20, color = COLORS.k},
			{oType = "font", content = "的", size = 20, color = COLORS.j},
	        {oType = "font", content = name1,size = 20, color = COLORS.k},
	        {oType = "font", content = "进攻了", size = 20, color = COLORS.j},
	        {oType = "font", content = union2,size = 20, color = COLORS.K},
			{oType = "font", content = "的", size = 20, color = COLORS.j},
	        {oType = "font", content = hallName,size = 20, color = COLORS.K},
			{oType = "font", content = "成员", size = 20, color = COLORS.j},
	        {oType = "font", content = name2,size = 20, color = COLORS.K},
			{oType = "font", content = "，战斗获胜，摧毁了", size = 20, color = COLORS.j},
	        {oType = "font", content = paramTbl[8] or "0",size = 20, color = COLORS.k},
	        {oType = "font", content = "面旗帜", size = 20, color = COLORS.j},
	    })
	end
	-- self._ccbOwner.node_bg:setVisible(index%2~=0)
end

function QUIWidgetConsortiaWarRecordLog:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return size
end

return QUIWidgetConsortiaWarRecordLog
