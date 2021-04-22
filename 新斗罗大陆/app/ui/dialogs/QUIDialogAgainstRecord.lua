--
-- zxs
-- 战报统一dialog
-- 
-- reportType 不一样的地方需要添加

local QUIDialog = import(".QUIDialog")
local QUIDialogAgainstRecord = class("QUIDialogAgainstRecord", QUIDialog)
local QUIWidgetAgainstRecord = import("..widgets.QUIWidgetAgainstRecord")
local QUIWidgetAgainstTopRecord = import("..widgets.QUIWidgetAgainstTopRecord")
local QListView = import("...views.QListView")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("..QUIViewController")

QUIDialogAgainstRecord.TAB_NORMAL = "TAB_NORMAL"
QUIDialogAgainstRecord.TAB_TOP = "TAB_TOP"

function QUIDialogAgainstRecord:ctor(options)
	local ccbFile = "ccb/Dialog_AgainstRecord.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogAgainstRecord._onTriggerClose)},
		{ccbCallbackName = "onTriggerNormal", callback = handler(self, QUIDialogAgainstRecord._onTriggerNormal)},
		{ccbCallbackName = "onTriggerTop", callback = handler(self, QUIDialogAgainstRecord._onTriggerTop)},
	}
	QUIDialogAgainstRecord.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._selectTab = options.selectTab or QUIDialogAgainstRecord.TAB_NORMAL
	self._reportType = options.reportType
	self._normalData = {}
	self._topData = {}
	self._data = {}
	self._ccbOwner.frame_tf_title:setString("战 报")

	self:initListView()
	self:selectTabs()
end 

-- 重置按钮
function QUIDialogAgainstRecord:resetAll()
	self._ccbOwner.btn_normal:setEnabled(true)
	self._ccbOwner.btn_normal:setHighlighted(false)
	self._ccbOwner.btn_top:setEnabled(true)
	self._ccbOwner.btn_top:setHighlighted(false)
	self._ccbOwner.sp_normal_tips:setVisible(false)
	self._ccbOwner.sp_top_tips:setVisible(false)
end

function QUIDialogAgainstRecord:selectTabs()
	self:getOptions().selectTab = self._selectTab
	self:resetAll()
	self._data = {}

	local callback = function()
		if not self:safeCheck() then
			return
		end
		if self._selectTab == QUIDialogAgainstRecord.TAB_NORMAL then
			self._data = self._normalData
		else
			self._data = self._topData
		end

		table.sort(self._data, function (x, y)
			if x.time and y.time then
				return x.time > y.time
			else
				return x.createdAt > y.createdAt
			end
		end)
		if self._listView then
			self._listView:clear()
		end
		self:initListView()
	end

	if self._selectTab == QUIDialogAgainstRecord.TAB_NORMAL then
		self._ccbOwner.btn_normal:setEnabled(false)
		self._ccbOwner.btn_normal:setHighlighted(true)
		self:initNormalAgainstType(callback)
	elseif self._selectTab == QUIDialogAgainstRecord.TAB_TOP then
		self._ccbOwner.btn_top:setEnabled(false)
		self._ccbOwner.btn_top:setHighlighted(true)
		self:initTopAgainstType(callback)
	end
end

function QUIDialogAgainstRecord:initNormalAgainstType(callback)
	-- 已经拉取过数据了
	if next(self._normalData) then
		callback()
		return
	end

	if self._reportType == REPORT_TYPE.ARENA then
		app:getClient():arenaAgainstRecordRequest(function(data)
			local fightReprts = data.arenaResponse.histories or {}
			for _, v in pairs(fightReprts) do
				local me = v.fighter1
				local rival = v.fighter2
				local result = v.success
				if me.userId ~= remote.user.userId then
					me, rival = rival, me
					result = not result
				end
				local info = {}
				info.type = REPORT_TYPE.ARENA
				info.userId = rival.userId
				info.nickname = rival.name
				info.level = rival.level
				info.result = result
				info.isInitiative = v.fighter1.userId == remote.user.userId
				info.rankChanged = me.rank - me.lastRank
				info.avatar = rival.avatar
				info.time = v.fighter1.lastFightAt
				info.reportId = v.arenaFightReportId
				info.vip = rival.vip
				table.insert(self._normalData, info)
			end
			callback()
		end)
	elseif self._reportType == REPORT_TYPE.GLORY_TOWER then
		remote.tower:towerQueryHistoryRequest(function(data)
			local fightReprts = data.towerHistories or {}
			for _, v in pairs(fightReprts) do
				local me = v.tower1
				local rival = v.tower2
				local result = v.success
				if me.userId ~= remote.user.userId then
					me, rival = rival, me
					result = not result
				end
				local info = {}
				info.type = REPORT_TYPE.GLORY_TOWER
				info.userId = rival.userId
				info.nickname = rival.nickname
				info.level = rival.team_level
				info.result = result
				info.isInitiative = v.tower1.userId == remote.user.userId
				info.scoreChanged = me.score - me.lastScore
				info.avatar = rival.icon
				info.time = v.tower1.lastFightingAt
				info.reportId = v.fightReportId
				info.vip = rival.vip
				info.env = rival.env
				info.victory = rival.victory,
				table.insert(self._normalData, info)
			end
			callback()
		end)
	elseif self._reportType == REPORT_TYPE.GLORY_ARENA then
		remote.tower:requestGloryArenaAgainstRecordRequest(function(data)
			local fightReprts = data.gloryCompetitionQueryHistoryResponse.gloryCompetitionHistories or {}
			for _, v in pairs(fightReprts) do
				local me = v.fighter1
				local rival = v.fighter2
				local result = v.success
				if me.userId ~= remote.user.userId then
					me, rival = rival, me
					result = not result
				end
				local info = {}
				info.type = REPORT_TYPE.GLORY_ARENA
				info.userId = rival.userId
				info.nickname = rival.name
				info.level = rival.level
				info.result = result
				info.isInitiative = v.fighter1.userId == remote.user.userId
				info.rankChanged = me.rank - me.lastRank
				info.avatar = rival.avatar
				info.time = v.fighter1.lastFightAt
				info.reportId = v.fightReportId
				info.vip = rival.vip
				info.env = rival.env
				info.victory = rival.victory,
				table.insert(self._normalData, info)
			end
			callback()
		end)
	elseif self._reportType == REPORT_TYPE.STORM_ARENA then
		remote.stormArena:requestStormArenaAgainstRecord(function (data)
			local fightReprts = data.stormQueryHistoryResponse.stormHistories or {}
			for _, v in pairs(fightReprts) do
				local me = v.fighter1
				local rival = v.fighter2
				local result = v.success
				if me.userId ~= remote.user.userId then
					me, rival = rival, me
					result = not result
				end
				local info = {}
				info.type = REPORT_TYPE.STORM_ARENA
				info.userId = rival.userId
				info.nickname = rival.name
				info.level = rival.level
				info.result = result
				info.isInitiative = v.fighter1.userId == remote.user.userId
				info.rankChanged = me.rank - me.lastRank
				info.avatar = rival.avatar
				info.time = v.fighter1.lastFightAt
				info.reportId = v.fightReportId
				info.vip = rival.vip
				info.scoreList = v.scoreList
				table.insert(self._normalData, info)
			end
			callback()
		end)
	elseif self._reportType == REPORT_TYPE.FIGHT_CLUB then
		remote.fightClub:requestFightClubGetReportList(function (data)
			local fightReprts = data.fightClubResponse.reports or {}
			for _, v in pairs(fightReprts) do
				local me = v.fighter1
				local rival = v.fighter2
				local result = v.success
				if me.userId ~= remote.user.userId then
					me, rival = rival, me
					result = not result
				end
				local info = {}
				info.type = REPORT_TYPE.FIGHT_CLUB
				info.userId = rival.userId
				info.nickname = rival.name
				info.level = rival.level
				info.result = result
				info.isInitiative = v.fighter1.userId == remote.user.userId
				info.avatar = rival.avatar
				info.time = v.fightAt
				info.reportId = v.reportId
				info.vip = rival.vip
				table.insert(self._normalData, info)
			end
			callback()
		end)
	elseif self._reportType == REPORT_TYPE.SOTO_TEAM then
		remote.sotoTeam:sotoTeamFightHistoryRequest(function (data)
			local fightReprts = data.sotoTeamUserInfoResponse.histories or {}
			for _, v in pairs(fightReprts) do
				local me = v.fighter1
				local rival = v.fighter2
				local result = v.success
				if me.userId ~= remote.user.userId then
					me, rival = rival, me
					result = not result
				end
				local info = {}
				info.type = REPORT_TYPE.SOTO_TEAM
				info.userId = rival.userId
				info.nickname = rival.name
				info.level = rival.level
				info.result = result
				info.isInitiative = v.fighter1.userId == remote.user.userId
				info.rankChanged = me.rank - me.lastRank
				info.avatar = rival.avatar
				info.time = v.fightAt or v.fighter1.lastFightAt
				info.reportId = v.reportId
				info.vip = rival.vip
				table.insert(self._normalData, info)
			end
			callback()
		end)	
	end
end

-- message GlobalTopFightReportData {
--     optional int64 fightReportId = 1;                                           //战报ID
--     optional Fighter fighter1 = 2;                                              //挑战者1
--     optional Fighter fighter2 = 3;                                              //挑战者2
--     repeated bool scoreList = 4;                                                //战斗得分 一小队1:0 两小队 2:1
--     optional string param = 5;                                                  //一些战报中需要的参数 玩家之间用;相隔 参数之间用:相隔 example:竞技场 1;2 龙战 1000522（每份战报伤害）
--     optional int64 createdAt = 6;                                               //战报产生时间
-- }

function QUIDialogAgainstRecord:initTopAgainstType(callback)
	-- 已经拉取过数据了
	if next(self._topData) then
		callback()
		return
	end

	local lastOpenTime = app:getUserOperateRecord():getRecordByType("top_report_last_open") or 0
	app:getUserOperateRecord():setRecordByType("top_report_last_open", q.serverTime())

	local battleType = QReplayUtil:getBattleTypeNumByReportType(self._reportType)
	app:getClient():globalGetTopFightReportDataRequest(battleType, function (data)
		self._topData = data.globalGetTopFightReportDataResponse.reportDatas or {}
		for i, v in pairs(self._topData) do
			if (v.createdAt or 0)/1000 > lastOpenTime then
				v.isNew = true
			else
				v.isNew = false
			end
		end
		callback()
	end)
end

function QUIDialogAgainstRecord:initListView()
	self._ccbOwner.node_no:setVisible(not next(self._data))
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        curOriginOffset = 0,
	        isVertical = true,
	        enableShadow = true,
	      	ignoreCanDrag = true,
	      	spaceY = -8,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogAgainstRecord:_renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
    	if self._selectTab == QUIDialogAgainstRecord.TAB_NORMAL then
	    	item = QUIWidgetAgainstRecord.new()
			item:addEventListener(QUIWidgetAgainstRecord.EVENT_CLICK_HEAD, handler(self, self.itemClickHandler))
			item:addEventListener(QUIWidgetAgainstRecord.EVENT_CLICK_RECORDE, handler(self, self.itemClickHandler))
			item:addEventListener(QUIWidgetAgainstRecord.EVENT_CLICK_SHARED, handler(self, self.itemClickHandler))
			item:addEventListener(QUIWidgetAgainstRecord.EVENT_CLICK_REPLAY, handler(self, self.itemClickHandler))
		else
			item = QUIWidgetAgainstTopRecord.new()
			item:addEventListener(QUIWidgetAgainstTopRecord.EVENT_CLICK_TOP_RECORDE, handler(self, self.topItemClickHandler))
		end
    	isCacheNode = false
    end
    item:setInfo(itemData, self._reportType)
    item:initGLLayer()
    info.item = item
    info.size = item:getContentSize()

    if self._selectTab == QUIDialogAgainstRecord.TAB_NORMAL then 
	    list:registerBtnHandler(index, "btn_head", "_onTriggerHead")
	    list:registerBtnHandler(index, "btn_detail", "_onTriggerDetail", nil, true)
	    list:registerBtnHandler(index, "btn_share", "_onTriggerShare", nil, true)
	    list:registerBtnHandler(index, "btn_replay", "_onTriggerReplay", nil, true)
	else
	    list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
	end

    return isCacheNode
end

function QUIDialogAgainstRecord:itemClickHandler(event)
	if not event.name then
		return
	end

	local info = event.info
	local userId = info.userId
	local reportType = info.type
	local reportId = info.reportId
	if event.name == QUIWidgetAgainstRecord.EVENT_CLICK_HEAD then
		if reportType == REPORT_TYPE.ARENA  then
			app:getClient():arenaQueryFighterRequest(userId, function(data)
				local fighter = data.arenaResponse.fighter or {}
		  		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	                options = {fighter = fighter, specialTitle1 = "胜利场数：", specialValue1 = fighter.victory, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
			end)
		elseif reportType == REPORT_TYPE.GLORY_TOWER then
			remote.tower:towerQueryFightRequest(userId, info.env, info.actorIds, function(data)
				local fighter = data.towerFightersDetail[1] or {}
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	                options = {fighter = fighter, specialTitle1 = "胜利场数：", specialValue1 = fighter.victory, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
			end)
		elseif reportType == REPORT_TYPE.GLORY_ARENA then
			app:getClient():topGloryArenaRankUserRequest(userId, function(data)
				local fighter = data.towerFightersDetail[1] or {}
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	                options = {fighter = fighter, specialTitle1 = "胜利场数：", specialValue1 = fighter.victory, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
			end)
		elseif reportType == REPORT_TYPE.STORM_ARENA then
			remote.stormArena:stormArenaQueryDefenseHerosRequest(userId, function(data)
				local fighter = data.towerFightersDetail[1] or {}
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
	    			options = {fighterInfo = fighter, isPVP = true}}, {isPopCurrentDialog = false})
			end)
		elseif reportType == REPORT_TYPE.FIGHT_CLUB then
			remote.fightClub:requestQueryFightClubDefendTeam(userId, function(data)
				local fighter = data.towerFightersDetail[1] or {}
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	    			options = {fighter = fighter, forceTitle1 = "防守战力：", model = GAME_MODEL.NORMAL, isPVP = true}}, {isPopCurrentDialog = false})
			end)
		elseif reportType == REPORT_TYPE.SOTO_TEAM then
			remote.sotoTeam:sotoTeamQueryFighterRequest(userId, function(data)
				local fighter = data.towerFightersDetail[1] or {}
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	    			options = {fighter = fighter, forceTitle1 = "防守战力：", model = GAME_MODEL.NORMAL, isPVP = true}}, {isPopCurrentDialog = false})
			end)
		end
	elseif event.name == QUIWidgetAgainstRecord.EVENT_CLICK_SHARED then
		local rivalName = info.nickname
		QReplayUtil:getReplayInfo(reportId, function (data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogReplayShare", 
				options = {rivalName = rivalName, myNickName = remote.user.nickname, replayId = reportId, replayType = reportType}}, {isPopCurrentDialog = false})
		end, nil, reportType)

	elseif event.name == QUIWidgetAgainstRecord.EVENT_CLICK_REPLAY then
		QReplayUtil:getReplayInfo(reportId, function (data)
			QReplayUtil:downloadReplay(reportId, function (replay)
				QReplayUtil:play(replay, data.scoreList, data.fightReportStats, true)
			end, nil, reportType)
		end, nil, reportType)

	elseif event.name == QUIWidgetAgainstRecord.EVENT_CLICK_RECORDE then
		if reportType == REPORT_TYPE.STORM_ARENA then
			remote.stormArena:stormArenaQueryDefenseHerosRequest(userId, function(data)
				local fighter = (data.towerFightersDetail or {})[1] or {}
				QReplayUtil:getReplayInfo(reportId, function(data)
					local detailInfo = {}
					detailInfo.isInitiative = info.isInitiative
					detailInfo.scoreList = info.scoreList
					detailInfo.fighter = fighter
					detailInfo.replayInfo = data
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAgainstRecordDetail",
			    		options = {info = detailInfo}}, {isPopCurrentDialog = false})
				end, nil, reportType)
			end)
		end
	end
end

function QUIDialogAgainstRecord:topItemClickHandler(event)
	if not event.name then
		return
	end

	local info = event.info
	local reportType = self._reportType
	local reportId = info.fightReportId
	local userId1 = info.fighter1.userId
	local userId2 = info.fighter2.userId
	if event.name == QUIWidgetAgainstTopRecord.EVENT_CLICK_TOP_RECORDE then
		QReplayUtil:getReplayInfo(reportId, function(data)
			local detailInfo = {}
			detailInfo.reportId = reportId
			detailInfo.reportType = reportType
			detailInfo.time = info.createdAt
			detailInfo.scoreList = info.scoreList
			detailInfo.fighter1 = info.fighter1
			detailInfo.fighter2 = info.fighter2
			detailInfo.replayInfo = data
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTopAgainstRecordDetail",
	    		options = {info = detailInfo}}, {isPopCurrentDialog = false})
		end, nil, reportType)
	end
end

function QUIDialogAgainstRecord:_onTriggerNormal(event)
	if self._selectTab == QUIDialogAgainstRecord.TAB_NORMAL then return end
    app.sound:playSound("common_switch")

	self._selectTab = QUIDialogAgainstRecord.TAB_NORMAL
	self:selectTabs()
end

function QUIDialogAgainstRecord:_onTriggerTop(event)
	if self._selectTab == QUIDialogAgainstRecord.TAB_TOP then return end
    app.sound:playSound("common_switch")

	if self._reportType == REPORT_TYPE.ARENA then
		app:triggerBuriedPoint(21600)
    elseif self._reportType == REPORT_TYPE.GLORY_TOWER then
		app:triggerBuriedPoint(21601)
    elseif self._reportType == REPORT_TYPE.GLORY_ARENA then
		app:triggerBuriedPoint(21602)
    elseif self._reportType == REPORT_TYPE.STORM_ARENA then
		app:triggerBuriedPoint(21604)
    elseif self._reportType == REPORT_TYPE.FIGHT_CLUB then
		app:triggerBuriedPoint(21605)
    end	
    
	self._selectTab = QUIDialogAgainstRecord.TAB_TOP
	self:selectTabs()
end

function QUIDialogAgainstRecord:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogAgainstRecord:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogAgainstRecord
