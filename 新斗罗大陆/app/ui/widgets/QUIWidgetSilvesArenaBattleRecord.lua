-- 
-- Kumo.Wang
-- 西尔维斯战报查看界面cell
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaBattleRecord = class("QUIWidgetSilvesArenaBattleRecord", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QReplayUtil = import("...utils.QReplayUtil")

QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_HEAD = "EVENT_CLICK_HEAD"
QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_SHARED = "EVENT_CLICK_SHARED"
QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_REPLAY = "EVENT_CLICK_REPLAY"
QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_RECORDE = "EVENT_CLICK_RECORDE"

function QUIWidgetSilvesArenaBattleRecord:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Battle_Record.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerHead1", callback = handler(self, self._onTriggerHead1)},
		{ccbCallbackName = "onTriggerHead2", callback = handler(self, self._onTriggerHead2)},
		{ccbCallbackName = "onTriggerHead3", callback = handler(self, self._onTriggerHead3)},
		{ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},
		-- {ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
	}
	QUIWidgetSilvesArenaBattleRecord.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._headList = {}
end

function QUIWidgetSilvesArenaBattleRecord:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.background, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.win_flag, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.lose_flag, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_red_flag, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_red_rank, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_green_flag, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_green_rank, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_desc, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.time, self._glLayerIndex)
	for _, head in ipairs(self._headList) do
		if head and head.initGLLayer then
			self._glLayerIndex = head:initGLLayer()
		end
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_share, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_share, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_detail, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_detail, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_head, self._glLayerIndex)
	return self._glLayerIndex
end

function QUIWidgetSilvesArenaBattleRecord:resetAll()
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.tf_desc:setString("")
	self._ccbOwner.win_flag:setVisible(false)
	self._ccbOwner.lose_flag:setVisible(false)
	self._ccbOwner.node_rank:setVisible(false)
	self._ccbOwner.node_red_flag:setVisible(false)
	self._ccbOwner.node_green_flag:setVisible(false)
	self._ccbOwner.btn_share:setVisible(true)
	self._ccbOwner.sp_share:setVisible(true)
	self._ccbOwner.btn_detail:setVisible(true)
	self._ccbOwner.sp_detail:setVisible(true)
end

function QUIWidgetSilvesArenaBattleRecord:setInfo(info)
	self:resetAll()

	self._info = info
	self._playerInfoList = info.playerInfoList or {}

	if info.nickname then
		self._ccbOwner.tf_name:setString(info.nickname)
		self._ccbOwner.tf_name:setVisible(true)
	else
		self._ccbOwner.tf_name:setVisible(false)
	end

	if not q.isEmpty(info.playerInfoList) then
		local index = 1
		while true do
			local node = self._ccbOwner["node_head"..index]
			local data = info.playerInfoList[index] or {}
			if node and data.avatar then
				node:removeAllChildren()
				local head = QUIWidgetAvatar.new()
				head:setInfo(data.avatar)
				head:setSilvesArenaPeak(data.championCount)
				node:addChild(head)
				table.insert(self._headList, head)
				index = index + 1
			else
				break
			end
		end
	end

	if info.isWin ~= nil then
		self._ccbOwner.win_flag:setVisible(info.isWin)
		self._ccbOwner.lose_flag:setVisible(not info.isWin)
	else
		self._ccbOwner.win_flag:setVisible(false)
		self._ccbOwner.lose_flag:setVisible(false)
	end

	if info.addScore then
		self._ccbOwner.node_rank:setVisible(true)
		if info.addScore >= 0 then
			self._ccbOwner.node_green_flag:setVisible(true)
			self._ccbOwner.tf_green_rank:setString(info.addScore)
		else
			self._ccbOwner.node_red_flag:setVisible(true)
			self._ccbOwner.tf_red_rank:setString(info.addScore)
		end
	end

	local descText = info.isAttack and "被我方成员挑战" or "挑战了我方小队"
	self._ccbOwner.tf_desc:setString(descText)

	local timeStr = self:_getTimeDescription(info.fightAt or 0)
	self._ccbOwner.time:setString(timeStr)
end

function QUIWidgetSilvesArenaBattleRecord:_getTimeDescription(time)
	local gap = (q.serverTime()*1000 - time)/1000
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

function QUIWidgetSilvesArenaBattleRecord:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilvesArenaBattleRecord:_onTriggerHead1()
	self:dispatchEvent({name = QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_HEAD, index = 1, info = self._info})
end

function QUIWidgetSilvesArenaBattleRecord:_onTriggerHead2()
	self:dispatchEvent({name = QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_HEAD, index = 2, info = self._info})
end

function QUIWidgetSilvesArenaBattleRecord:_onTriggerHead3()
	self:dispatchEvent({name = QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_HEAD, index = 3, info = self._info})
end

function QUIWidgetSilvesArenaBattleRecord:_onTriggerShare(event)
	self:dispatchEvent({name = QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_SHARED, info = self._info})
end

function QUIWidgetSilvesArenaBattleRecord:_onTriggerDetail(event)
	self:dispatchEvent({name = QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_RECORDE, info = self._info})
end

return QUIWidgetSilvesArenaBattleRecord