--
-- zxs
-- 统一战报
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAgainstRecord = class("QUIWidgetAgainstRecord", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QReplayUtil = import("...utils.QReplayUtil")

QUIWidgetAgainstRecord.EVENT_CLICK_HEAD = "EVENT_CLICK_HEAD"
QUIWidgetAgainstRecord.EVENT_CLICK_SHARED = "EVENT_CLICK_SHARED"
QUIWidgetAgainstRecord.EVENT_CLICK_REPLAY = "EVENT_CLICK_REPLAY"
QUIWidgetAgainstRecord.EVENT_CLICK_RECORDE = "EVENT_CLICK_RECORDE"

function QUIWidgetAgainstRecord:ctor(options)
	local ccbFile = "ccb/Widget_AgainstRecord.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerHead", callback = handler(self, QUIWidgetAgainstRecord._onTriggerHead)},
		{ccbCallbackName = "onTriggerShare", callback = handler(self, QUIWidgetAgainstRecord._onTriggerShare)},
		{ccbCallbackName = "onTriggerReplay", callback = handler(self, QUIWidgetAgainstRecord._onTriggerReplay)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, QUIWidgetAgainstRecord._onTriggerDetail)},
	}
	QUIWidgetAgainstRecord.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetAgainstRecord:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.background, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.ly_bg_1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.ly_bg_2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.win_flag, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.lose_flag, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_rank, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_score, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_red_flag, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_red_rank, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_green_flag, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_green_rank, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.time, self._glLayerIndex)
	if self._head then
		self._glLayerIndex = self._head:initGLLayer()
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_replay, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_replay, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_share, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_share, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_detail, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_detail, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_head, self._glLayerIndex)
	return self._glLayerIndex
end

function QUIWidgetAgainstRecord:resetAll()
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.win_flag:setVisible(false)
	self._ccbOwner.lose_flag:setVisible(false)
	self._ccbOwner.node_rank:setVisible(false)
	self._ccbOwner.node_score:setVisible(false)
	self._ccbOwner.node_red_flag:setVisible(false)
	self._ccbOwner.node_green_flag:setVisible(false)
	self._ccbOwner.btn_detail:setVisible(false)
	self._ccbOwner.sp_detail:setVisible(false)
end

function QUIWidgetAgainstRecord:setInfo(info)
	self:resetAll()
	self._info = info
	self._replayId = info.replayId
	self._rankChange = info.rankChanged
	self._scoreChange = info.scoreChanged
	self._time = info.time or 0

	local nameStr = string.format("LV.%d %s", (info.level or 1), (info.nickname or ""))
	self._ccbOwner.tf_name:setString(nameStr)

	if not self._head then
		self._head = QUIWidgetAvatar.new()
		self._ccbOwner.node_head:addChild(self._head)
	end
	self._head:setInfo(info.avatar)
	self._head:setSilvesArenaPeak(info.championCount)
	self._ccbOwner.win_flag:setVisible(info.result)
	self._ccbOwner.lose_flag:setVisible(not info.result)

	if self._rankChange then
		self._ccbOwner.node_rank:setVisible(true)
		if self._rankChange >= 0 then
			self._ccbOwner.node_red_flag:setVisible(true)
			self._ccbOwner.tf_red_rank:setString(self._rankChange)
		else
			self._ccbOwner.node_green_flag:setVisible(true)
			self._ccbOwner.tf_green_rank:setString(-self._rankChange)
		end
	elseif self._scoreChange then
		self._ccbOwner.node_score:setVisible(true)
		self._ccbOwner.tf_score:setString(self._scoreChange)
	end

	local attackDesc = "挑战了我"
	if info.isInitiative then
		attackDesc = "被我挑战"
	end
	local timeStr = self:getTimeDescription(info.time or 0)
	self._ccbOwner.time:setString(timeStr..attackDesc)

	if info.scoreList then
		self._ccbOwner.btn_detail:setVisible(true)
		self._ccbOwner.sp_detail:setVisible(true)
	end
end

function QUIWidgetAgainstRecord:getTimeDescription(time)
	local gap = math.floor((q.serverTime()*1000 - time)/1000 )
	if gap > 0 then
		if gap < HOUR then
			return math.floor(gap/MIN) .. "分钟前"
		elseif gap < DAY then
			return math.floor(gap/HOUR) .. "小时前"
		elseif gap < WEEK then
			return math.floor(gap/DAY) .. "天前"
		else
			return "7天前"
		end
	end
	return "7天前"
end

function QUIWidgetAgainstRecord:getContentSize()
	local size = self._ccbOwner.background:getContentSize()
	return CCSize(size.width, size.height+6)
end

function QUIWidgetAgainstRecord:_onTriggerHead()
	self:dispatchEvent({name = QUIWidgetAgainstRecord.EVENT_CLICK_HEAD, info = self._info})
end

function QUIWidgetAgainstRecord:_onTriggerShare(event)
	self:dispatchEvent({name = QUIWidgetAgainstRecord.EVENT_CLICK_SHARED, info = self._info})
end

function QUIWidgetAgainstRecord:_onTriggerReplay(event)
	self:dispatchEvent({name = QUIWidgetAgainstRecord.EVENT_CLICK_REPLAY, info = self._info})
end

function QUIWidgetAgainstRecord:_onTriggerDetail(event)
	self:dispatchEvent({name = QUIWidgetAgainstRecord.EVENT_CLICK_RECORDE, info = self._info})
end

return QUIWidgetAgainstRecord