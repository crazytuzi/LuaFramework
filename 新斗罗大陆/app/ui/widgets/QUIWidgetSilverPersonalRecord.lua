--
-- Author: MOUSECUTE
-- Date: 2016-07-28
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverPersonalRecord = class("QUIWidgetSilverPersonalRecord", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QReplayUtil = import("...utils.QReplayUtil")

local REPLAY_CD_LIMIT = "%d分钟内只允许发送%d条战报，%s后可以发送"
local REPLAY_CD = 5 -- 10m
local REPLAY_COUNT = 5

QUIWidgetSilverPersonalRecord.GAP = 6

function QUIWidgetSilverPersonalRecord:ctor(options)
	local ccbFile = "ccb/Widget_SilverMine_grzb.ccbi"
	local callBacks = {
		{ccbCallbackName = "onHead", callback = handler(self, QUIWidgetSilverPersonalRecord._onHead)},
		{ccbCallbackName = "onTriggerShare", callback = handler(self, QUIWidgetSilverPersonalRecord._onTriggerShare)},
		{ccbCallbackName = "onTriggerReplay", callback = handler(self, QUIWidgetSilverPersonalRecord._onTriggerReplay)},
	}
	QUIWidgetSilverPersonalRecord.super.ctor(self, ccbFile, callBacks, options)

	self._contentHeight = self._ccbOwner.background:getContentSize().height

    -- lastMoveTime is used to know whether an event is a click or gesture movement
	self._parent = options.parent
	self._userId = options.userId
	self._nickName = options.nickName or ""
	self._level = options.level or ""
	self._avatar = options.avatar 
	self._result = options.result == true and 1 or 0 -- 0 means lost
	self._time = options.time or -1
	self._type = REPORT_TYPE.SILVERMINE
	self._replayId = options.replay
	self._mineId = options.mineId

	if self._replayId then
		self._ccbOwner.buttons:setVisible(true)
	else
		self._ccbOwner.buttons:setVisible(false)
	end

	-- self._ccbOwner.node_hands:setVisible(false)
end

function QUIWidgetSilverPersonalRecord:onEnter()
	self._ccbOwner.nickName:setString(self._nickName)
	self._ccbOwner.level:setString("LV." .. self._level)
	q.autoLayerNode({self._ccbOwner.level, self._ccbOwner.nickName}, "x", 10)

	-- self._ccbOwner.time:setString(self:getTimeDescription(self._time))
	local timeTbl = q.date("*t", self._time/1000)
	if timeTbl and table.nums(timeTbl) > 0 then
		self._ccbOwner.date:setString(timeTbl.month.."-"..timeTbl.day)
		self._ccbOwner.time:setString(timeTbl.hour..":"..timeTbl.min)
	else
		self._ccbOwner.date:setString("0-0")
		self._ccbOwner.time:setString("0:0")
	end
	self._ccbOwner.node_headPicture:removeAllChildren()
	self._ccbOwner.node_headPicture:addChild(QUIWidgetAvatar.new(self._avatar))

	if self._result == 1 then
		self._ccbOwner.win_flag:setVisible(true)
		self._ccbOwner.lose_flag:setVisible(false)
	else
		self._ccbOwner.win_flag:setVisible(false)
		self._ccbOwner.lose_flag:setVisible(true)
	end

	local mineConfig = remote.silverMine:getMineConfigByMineId(self._mineId)
	if mineConfig then
		-- mineConfig.mine_name.." "..
		self._ccbOwner.event:setString(remote.silverMine:getMineCNNameByQuality(mineConfig.mine_quality))
	else
		self._ccbOwner.event:setString("N/A")
	end

	q.autoLayerNode({self._ccbOwner.date, self._ccbOwner.time, self._ccbOwner.event}, "x", 10)
end

function QUIWidgetSilverPersonalRecord:getTimeDescription(time)
	if time == nil or time == -1 then
		return "N/A"
	end

	local gap = math.floor((q.serverTime()*1000 - time)/1000 )
	if gap > 0 then
		if gap < 60 * 60 then
			return math.floor(gap/60) .. "分钟前"
		elseif gap < 24 * 60 * 60 then
			return math.floor(gap/(60 * 60)) .. "小时前"
		elseif gap < 7 * 24 * 60 * 60 then
			return math.floor(gap/(24 * 60 * 60)) .. "天前"
		else
			return "7天前"
		end
	end

	return "7天前"
end

function QUIWidgetSilverPersonalRecord:onExit()
end

function QUIWidgetSilverPersonalRecord:_onHead()
	if self._parent._isMoving then
		return
	end

	if self._type == REPORT_TYPE.ARENA then
		assert(false, "QUIWidgetSilverPersonalRecord does not support report type: "..REPORT_TYPE.ARENA)
	elseif self._type == REPORT_TYPE.GLORY_TOWER then
		assert(false, "QUIWidgetSilverPersonalRecord does not support report type: "..REPORT_TYPE.GLORY_TOWER)
	elseif self._type == REPORT_TYPE.GLORY_ARENA then
		assert(false, "QUIWidgetSilverPersonalRecord does not support report type: "..REPORT_TYPE.GLORY_ARENA)
	elseif self._type == REPORT_TYPE.SILVERMINE then
		-- todo
		remote.silverMine:silverMineQueryFighterRequest(self._userId, function(data)
			local fighter = data.silverMineFightReportQueryFighterResponse.fighter
			local force = 0
			if fighter.heros ~= nil then
				for _,hero in pairs(fighter.heros or {}) do
					force = force + hero.force
				end
			end
			if fighter.subheros ~= nil then
				for _,hero in pairs(fighter.subheros or {}) do
					force = force + hero.force
				end
			end
			if fighter.sub2heros ~= nil then
				for _,hero in pairs(fighter.sub2heros or {}) do
					force = force + hero.force
				end
			end
			if fighter.sub3heros ~= nil then
				for _,hero in pairs(fighter.sub3heros or {}) do
					force = force + hero.force
				end
			end
	  		-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGloryFigterInfo",
	    -- 		options = {info = {name = self._nickName, level = self._level, avatar = self._avatar, victory = fighter.victory, no_victory = true, force = force, 
	    -- 		heros = fighter.heros or {}, subheros = fighter.subheros or {}, text = "胜利场数", vip = fighter.vip, 
	    -- 		consortiaName = (fighter.consortiaName and string.len(fighter.consortiaName) > 0) and fighter.consortiaName or nil}}}, {isPopCurrentDialog = false})
	  		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
                options = {fighter = fighter, awardTitle1 = "胜利场数", awardValue1 = fighter.victory, isPVP = true}}, {isPopCurrentDialog = false})
		end)
	else
		assert(false, "unknown report type: "..tostring(self._type))
	end
end

function QUIWidgetSilverPersonalRecord:getContentSize()
	return self._ccbOwner.background:getContentSize()
end

function QUIWidgetSilverPersonalRecord:_onTriggerReplay(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_record) == false then return end
    app.sound:playSound("common_small")
	QReplayUtil:getReplayInfo(self._replayId, function (data)
		QReplayUtil:downloadReplay(self._replayId, function (replay)
			QReplayUtil:play(replay)
		end, nil, self._type)
	end, nil, self._type)
end

function QUIWidgetSilverPersonalRecord:_onTriggerShare(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_share) == false then return end
    app.sound:playSound("common_small")
	local earliestTime, replayCount = app:getServerChatData():getEarliestReplaySentTime()
	print("replayCount " .. replayCount .. " earliestTime " .. earliestTime .. " serverTime " .. q.serverTime())
	if replayCount >= REPLAY_COUNT and q.serverTime() - earliestTime < REPLAY_CD * 60 then
		app.tip:floatTip(string.format(REPLAY_CD_LIMIT, REPLAY_CD, REPLAY_COUNT, q.timeToHourMinuteSecond(REPLAY_CD * 60 - (q.serverTime() - earliestTime), true)))
		return
	end

	QReplayUtil:getReplayInfo(self._replayId, function (data)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogReplayShare", 
			options = {rivalName = self._nickName, replayId = self._replayId, myNickName = remote.user.nickname, replayType = self._type}}, {isPopCurrentDialog = false})
	end, nil, self._type)
end

-- function QUIWidgetSilverPersonalRecord:showSelected()
	-- self._ccbOwner.node_hands:setVisible(true)
-- end

return QUIWidgetSilverPersonalRecord