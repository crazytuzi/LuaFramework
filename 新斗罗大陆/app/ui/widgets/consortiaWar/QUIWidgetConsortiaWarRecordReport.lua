-- @Author: zhouxiaoshu
-- @Date:   2019-04-29 11:58:57
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-13 19:44:47
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetConsortiaWarRecordReport = class("QUIWidgetConsortiaWarRecordReport", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")
local QRichText = import("....utils.QRichText")

QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_HEAD = "EVENT_CLICK_HEAD"
QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_SHARED = "EVENT_CLICK_SHARED"
QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_REPLAY = "EVENT_CLICK_REPLAY"
QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_RECORDE = "EVENT_CLICK_RECORDE"

function QUIWidgetConsortiaWarRecordReport:ctor(options)
	local ccbFile = "ccb/Widget_Unionwar_zhanbao.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerHead", callback = handler(self, self._onTriggerHead)},
		{ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
		{ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
    }
    QUIWidgetConsortiaWarRecordReport.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._richText = QRichText.new({}, 300)
	self._richText:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.node_desc:addChild(self._richText)
end

function QUIWidgetConsortiaWarRecordReport:onEnter()
end

function QUIWidgetConsortiaWarRecordReport:onExit()
end

function QUIWidgetConsortiaWarRecordReport:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.background, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_time, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_desc, self._glLayerIndex)
	if self._head then
		self._glLayerIndex = self._head:initGLLayer()
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_replay, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_share, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_detail, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_head, self._glLayerIndex)
	return self._glLayerIndex
end

function QUIWidgetConsortiaWarRecordReport:setInfo(info)
	self._info = info
	local fighter = info.fighter
	local dateTime = q.date("*t", (info.happenAt or 0)/1000)
	local timeStr = string.format("%02d-%02d %02d:%02d", dateTime.month, dateTime.day, dateTime.hour, dateTime.min)
	local nameStr = string.format("【LV.%d %s】", (fighter.level or 1), (fighter.name or ""))
	if fighter.userId ~= remote.user.userId then
		self._richText:setString({
			{oType = "font", content = timeStr.." 摧毁了", size = 20, color = COLORS.j},
	        {oType = "font", content = nameStr, size = 20, color = COLORS.k},
	        {oType = "font", content = tostring(info.breakThroughFlagCount), size = 20, color = COLORS.k},
	        {oType = "font", content = "面旗帜", size = 20, color = COLORS.j},
	    })
	else
		self._richText:setString({
			{oType = "font", content = timeStr.." 被", size = 20, color = COLORS.j},
	        {oType = "font", content = nameStr,size = 20, color = COLORS.k},
	        {oType = "font", content = "摧毁了", size = 20, color = COLORS.j},
	        {oType = "font", content = tostring(info.breakThroughFlagCount), size = 20, color = COLORS.l},
	        {oType = "font", content = "面旗帜", size = 20, color = COLORS.j},
	    })
	end

	if not self._head then
		self._head = QUIWidgetAvatar.new()
		self._ccbOwner.node_head:removeAllChildren()
		self._ccbOwner.node_head:addChild(self._head)
	end
	self._head:setInfo(fighter.avatar)
	self._head:setSilvesArenaPeak(fighter.championCount)
end

function QUIWidgetConsortiaWarRecordReport:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return size
end

function QUIWidgetConsortiaWarRecordReport:_onTriggerHead()
	self:dispatchEvent({name = QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_HEAD, info = self._info})
end

function QUIWidgetConsortiaWarRecordReport:_onTriggerShare()
	self:dispatchEvent({name = QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_SHARED, info = self._info})
end

function QUIWidgetConsortiaWarRecordReport:_onTriggerReplay()
	self:dispatchEvent({name = QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_REPLAY, info = self._info})
end

function QUIWidgetConsortiaWarRecordReport:_onTriggerDetail()
	self:dispatchEvent({name = QUIWidgetConsortiaWarRecordReport.EVENT_CLICK_RECORDE, info = self._info})
end

return QUIWidgetConsortiaWarRecordReport
