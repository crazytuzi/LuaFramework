--
-- dsl
-- 统一战报 大号记录
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAgainstRecordBig = class("QUIWidgetAgainstRecordBig", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QReplayUtil = import("...utils.QReplayUtil")

QUIWidgetAgainstRecordBig.EVENT_CLICK_HEAD = "EVENT_CLICK_HEAD"
QUIWidgetAgainstRecordBig.EVENT_CLICK_SHARED = "EVENT_CLICK_SHARED"
QUIWidgetAgainstRecordBig.EVENT_CLICK_REPLAY = "EVENT_CLICK_REPLAY"
QUIWidgetAgainstRecordBig.EVENT_CLICK_RECORDE = "EVENT_CLICK_RECORDE"

function QUIWidgetAgainstRecordBig:ctor(options)
	local ccbFile = "ccb/Widget_AgainstRecord_big.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerHead1", callback = handler(self, QUIWidgetAgainstRecordBig._onTriggerHead1)},
		{ccbCallbackName = "onTriggerHead2", callback = handler(self, QUIWidgetAgainstRecordBig._onTriggerHead2)},
		{ccbCallbackName = "onTriggerHead3", callback = handler(self, QUIWidgetAgainstRecordBig._onTriggerHead3)},
		{ccbCallbackName = "onTriggerShare", callback = handler(self, QUIWidgetAgainstRecordBig._onTriggerShare)},
		{ccbCallbackName = "onTriggerReplay", callback = handler(self, QUIWidgetAgainstRecordBig._onTriggerReplay)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, QUIWidgetAgainstRecordBig._onTriggerDetail)},
	}
	QUIWidgetAgainstRecordBig.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.node_againstRecord_replay:setVisible(false)

	self._ccbOwner.node_againstRecord_detail:setPosition(self._ccbOwner.node_againstRecord_share:getPosition())
	self._ccbOwner.node_againstRecord_share:setPosition(self._ccbOwner.node_againstRecord_replay:getPosition())
end

function QUIWidgetAgainstRecordBig:initGLLayer(glLayerIndex)
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
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_desc, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.time, self._glLayerIndex)
	if self._head1 then
		self._glLayerIndex = self._head1:initGLLayer()
	end
	if self._head2 then
		self._glLayerIndex = self._head2:initGLLayer()
	end
	if self._head3 then
		self._glLayerIndex = self._head3:initGLLayer()
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

function QUIWidgetAgainstRecordBig:resetAll()
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.tf_desc:setString("")
	self._ccbOwner.win_flag:setVisible(false)
	self._ccbOwner.lose_flag:setVisible(false)
	self._ccbOwner.node_rank:setVisible(false)
	self._ccbOwner.node_score:setVisible(false)
	self._ccbOwner.node_red_flag:setVisible(false)
	self._ccbOwner.node_green_flag:setVisible(false)
	self._ccbOwner.btn_detail:setVisible(false)
	self._ccbOwner.sp_detail:setVisible(false)
end

function QUIWidgetAgainstRecordBig:setInfo(info)
	self:resetAll()
	self._info = info
	self._replayId = info.replayId
	self._rankChange = info.rankChanged
	self._scoreChange = info.scoreChanged
	self._time = info.time or 0
	self._reportIdList = info.reportIdList

	self._teamList = info.teamList or {}

	local nameStr = (info.nickname or "")
	self._ccbOwner.tf_name:setString(nameStr)

	if not self._head1 then
		self._head1 = QUIWidgetAvatar.new()
		self._ccbOwner.node_head1:addChild(self._head1)
	end
	self._head1:setInfo(self._teamList[1].avatar)
	self._head1:setSilvesArenaPeak(self._teamList[1].championCount)

	if not self._head2 then
		self._head2 = QUIWidgetAvatar.new()
		self._ccbOwner.node_head2:addChild(self._head2)
	end
	self._head2:setInfo(self._teamList[2].avatar)
	self._head2:setSilvesArenaPeak(self._teamList[2].championCount)

	if not self._head3 then
		self._head3 = QUIWidgetAvatar.new()
		self._ccbOwner.node_head3:addChild(self._head3)
	end
	self._head3:setInfo(self._teamList[3].avatar)
	self._head3:setSilvesArenaPeak(self._teamList[3].championCount)

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

	local attackDesc = "挑战了我方小队"
	if info.isInitiative then
		attackDesc = "被我方成员挑战"
	end
	local timeStr = self:getTimeDescription(info.time or 0)
	self._ccbOwner.time:setString(timeStr)
	self._ccbOwner.tf_desc:setString(attackDesc)

	-- if info.scoreList then
		self._ccbOwner.btn_detail:setVisible(true)
		self._ccbOwner.sp_detail:setVisible(true)
	-- end
end

function QUIWidgetAgainstRecordBig:getTimeDescription(time)
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

function QUIWidgetAgainstRecordBig:getContentSize()
	local size = self._ccbOwner.background:getContentSize()
	return CCSize(size.width, size.height+6)
end

function QUIWidgetAgainstRecordBig:_onTriggerHead1()
	self:dispatchEvent({name = QUIWidgetAgainstRecordBig.EVENT_CLICK_HEAD, index = 1, info = self._info})
end

function QUIWidgetAgainstRecordBig:_onTriggerHead2()
	self:dispatchEvent({name = QUIWidgetAgainstRecordBig.EVENT_CLICK_HEAD, index = 2, info = self._info})
end

function QUIWidgetAgainstRecordBig:_onTriggerHead3()
	self:dispatchEvent({name = QUIWidgetAgainstRecordBig.EVENT_CLICK_HEAD, index = 3, info = self._info})
end

function QUIWidgetAgainstRecordBig:_onTriggerShare(event)
	self:dispatchEvent({name = QUIWidgetAgainstRecordBig.EVENT_CLICK_SHARED, info = self._info})
end

function QUIWidgetAgainstRecordBig:_onTriggerReplay(event)
	self:dispatchEvent({name = QUIWidgetAgainstRecordBig.EVENT_CLICK_REPLAY, info = self._info})
end

function QUIWidgetAgainstRecordBig:_onTriggerDetail(event)
	self:dispatchEvent({name = QUIWidgetAgainstRecordBig.EVENT_CLICK_RECORDE, info = self._info})
end

return QUIWidgetAgainstRecordBig