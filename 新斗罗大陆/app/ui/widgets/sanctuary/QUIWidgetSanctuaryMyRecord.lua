-- 
-- zxs
-- 个人记录
-- 
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSanctuaryMyRecord = class("QUIWidgetSanctuaryMyRecord", QUIWidget)
local QUIViewController = import("...QUIViewController")
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")

QUIWidgetSanctuaryMyRecord.EVENT_CLICK_SHARED = "EVENT_CLICK_SHARED"
QUIWidgetSanctuaryMyRecord.EVENT_CLICK_REPLAY = "EVENT_CLICK_REPLAY"
QUIWidgetSanctuaryMyRecord.EVENT_CLICK_RECORDE = "EVENT_CLICK_RECORDE"

function QUIWidgetSanctuaryMyRecord:ctor(options)
	local ccbFile = "ccb/Widget_Sanctuary_battlerecord.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
		{ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},
		{ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
    }
    QUIWidgetSanctuaryMyRecord.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSanctuaryMyRecord:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.background, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_head, self._glLayerIndex)
	if self._icon then
		self._glLayerIndex = self._icon:initGLLayer(self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_rank1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_green_rank, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_rank2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_red_rank, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_win_flag, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_lose_flag, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_record, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_record, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_share, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_share, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_replay, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_replay, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_force_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_force, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_server, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_fighter_num, self._glLayerIndex)
	return self._glLayerIndex
end

function QUIWidgetSanctuaryMyRecord:setInfo(info)
	self._info = info

	local rival, result, attackScore, defenseScore, scoreList, addScore = self:calculatorResult()
	self._rivalName = rival.name or ""
	self._userId = rival.userId or ""
	self._result = result
	self._attackScore = attackScore
	self._defenseScore = defenseScore
	self._scoreList = scoreList
	
	-- set flag
	self._ccbOwner.sp_win_flag:setVisible(result)
	self._ccbOwner.sp_lose_flag:setVisible(not result)

	if addScore >= 0 then
		self._ccbOwner.node_red_flag:setVisible(false)
		self._ccbOwner.node_green_flag:setVisible(true)
		self._ccbOwner.tf_green_rank:setString(addScore)
	else
		self._ccbOwner.node_green_flag:setVisible(false)
		self._ccbOwner.node_red_flag:setVisible(true)
		self._ccbOwner.tf_red_rank:setString(addScore)
	end
	self._ccbOwner.tf_name:setString("LV."..(rival.level or "0")..self._rivalName)
	self._ccbOwner.tf_server:setString(rival.game_area_name)
	local force = rival.force or 0
	local num,unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_force:setString(num..unit)
	self._ccbOwner.node_head:removeAllChildren()
	self._icon = QUIWidgetAvatar.new(rival.avatar)
	self._icon:setSilvesArenaPeak(rival.championCount)
	self._ccbOwner.node_head:addChild(self._icon)

	local numStr = string.format("第%d场", info.index)
	if info.type == 1 then
		if info.currRound == remote.sanctuary.ROUND_64 then
			numStr = "64强赛"
		elseif info.currRound == remote.sanctuary.ROUND_32 then
			numStr = "32强赛"
		elseif info.currRound == remote.sanctuary.ROUND_16 then
			numStr = "16强赛"
		elseif info.currRound == remote.sanctuary.ROUND_8 then
			numStr = "8强赛"
		elseif info.currRound == remote.sanctuary.ROUND_4 then
			numStr = "4强赛"
		elseif info.currRound == remote.sanctuary.ROUND_2 then
			numStr = "冠军赛"
			if info.isThirdRound then
				numStr = "季军赛"
			end
		end
	end
	self._ccbOwner.tf_fighter_num:setString(numStr)
end

function QUIWidgetSanctuaryMyRecord:calculatorResult()
	local me = nil
	local rival = nil
	local result = nil 
	local attackScore = self._info.fighter1BattleScore
	local defenseScore = self._info.fighter2BattleScore
	local addScore = self._info.fighter1AddScore

	if self._info.fighter1.userId == remote.user.userId then
		rival = self._info.fighter2
		result = self._info.success
	else
		rival = self._info.fighter1
		result = not self._info.success
	end
	local score = string.split(self._info.scoreInfo, ";")
	for i = 1, #score do
		if score[i] == "1" then
			score[i] = true
		elseif score[i] == "0" then
			score[i] = false
		end
	end
	return rival, result, attackScore, defenseScore, score, addScore
end

function QUIWidgetSanctuaryMyRecord:getContentSize()
	local size = self._ccbOwner.background:getContentSize()
	return CCSize(size.width, size.height-2)
end

function QUIWidgetSanctuaryMyRecord:_onTriggerShare()
	self:dispatchEvent({name = QUIWidgetSanctuaryMyRecord.EVENT_CLICK_SHARED, info = self._info, rivalName = self._rivalName})
end

function QUIWidgetSanctuaryMyRecord:_onTriggerReplay()
	self:dispatchEvent({name = QUIWidgetSanctuaryMyRecord.EVENT_CLICK_REPLAY, info = self._info})
end

function QUIWidgetSanctuaryMyRecord:_onTriggerRecord()
	local leftId = self._info.fighter1.userId
	self:dispatchEvent({name = QUIWidgetSanctuaryMyRecord.EVENT_CLICK_RECORDE, info = self._info, userId = self._userId, result = self._result, 
		attackScore = self._attackScore, defenseScore = self._defenseScore, scoreList = self._scoreList, leftId = leftId})
end

return QUIWidgetSanctuaryMyRecord
