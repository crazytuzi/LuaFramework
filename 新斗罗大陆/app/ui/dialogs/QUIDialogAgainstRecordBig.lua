--
-- zxs
-- 战报统一dialog 大号记录
-- 
-- reportType 不一样的地方需要添加

local QUIDialog = import(".QUIDialog")
local QUIDialogAgainstRecordBig = class("QUIDialogAgainstRecordBig", QUIDialog)
local QUIWidgetAgainstRecord = import("..widgets.QUIWidgetAgainstRecord")
local QUIWidgetAgainstRecordBig = import("..widgets.QUIWidgetAgainstRecordBig")
local QUIWidgetAgainstTopRecord = import("..widgets.QUIWidgetAgainstTopRecord")
local QListView = import("...views.QListView")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("..QUIViewController")

QUIDialogAgainstRecordBig.TAB_NORMAL = "TAB_NORMAL"
QUIDialogAgainstRecordBig.TAB_TOP = "TAB_TOP"

function QUIDialogAgainstRecordBig:ctor(options)
	self._reportType = options.reportType
	local ccbFile = "ccb/Dialog_AgainstRecord_Big.ccbi"

	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogAgainstRecordBig._onTriggerClose)},
		{ccbCallbackName = "onTriggerNormal", callback = handler(self, QUIDialogAgainstRecordBig._onTriggerNormal)},
		{ccbCallbackName = "onTriggerTop", callback = handler(self, QUIDialogAgainstRecordBig._onTriggerTop)},
	}
	QUIDialogAgainstRecordBig.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._selectTab = options.selectTab or QUIDialogAgainstRecordBig.TAB_NORMAL
	self._reportType = options.reportType
	self._normalData = {}
	self._topData = {}
	self._data = {}
	self._ccbOwner.frame_tf_title:setString("战 报")

	self:initListView()
	self:selectTabs()
end 

-- 重置按钮
function QUIDialogAgainstRecordBig:resetAll()
	self._ccbOwner.btn_normal:setEnabled(true)
	self._ccbOwner.btn_normal:setHighlighted(false)
	self._ccbOwner.btn_top:setEnabled(true)
	self._ccbOwner.btn_top:setHighlighted(false)
	self._ccbOwner.sp_normal_tips:setVisible(false)
	self._ccbOwner.sp_top_tips:setVisible(false)
end

function QUIDialogAgainstRecordBig:selectTabs()
	self:getOptions().selectTab = self._selectTab
	self:resetAll()
	self._data = {}

	local callback = function()
		if not self:safeCheck() then
			return
		end
		if self._selectTab == QUIDialogAgainstRecordBig.TAB_NORMAL then
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

	if self._selectTab == QUIDialogAgainstRecordBig.TAB_NORMAL then
		self._ccbOwner.btn_normal:setEnabled(false)
		self._ccbOwner.btn_normal:setHighlighted(true)
		self:initNormalAgainstType(callback)
	elseif self._selectTab == QUIDialogAgainstRecordBig.TAB_TOP then
		self._ccbOwner.btn_top:setEnabled(false)
		self._ccbOwner.btn_top:setHighlighted(true)
		self:initTopAgainstType(callback)
	end
end

function QUIDialogAgainstRecordBig:initNormalAgainstType(callback)
	-- 已经拉取过数据了
	if next(self._normalData) then
		callback()
		return
	end

	if self._reportType == REPORT_TYPE.SILVES_ARENA then	
		local type = 1;  -- 0:防守记录; 1:进攻记录
		remote.silvesArena:silvesArenaTeamHistoryRequest(type,function (data)
			local fightReprts = data.silvesArenaInfoResponse.battleHistoryList or {}
			for _, v in pairs(fightReprts) do

					local rival = v.team2fighterList
					local result = v.success

					local info = {}
					info.type = REPORT_TYPE.SILVES_ARENA
					info.result = result

					info.teamList = {}
					for i,v in ipairs(rival) do
						if v then
							local uInfo = {}

							uInfo.userId = v.userId
							uInfo.level = v.level
							uInfo.vip = v.vip
							uInfo.avatar = v.avatar
							table.insert(info.teamList,uInfo)
						end
					end

					info.matchingId = v.matchingId
					info.avatarList = {rival[1].avatar,rival[2].avatar,rival[3].avatar}
					info.nickname = v.team2Name

					info.time = v.fightAt
					info.reportIdList = v.reportIdList
					info.isInitiative = v.team1fighterList == nil
					info.rankChanged = v.team1AddScore
					table.insert(self._normalData, info)

			end
			callback()
		end)

	end

end

function QUIDialogAgainstRecordBig:initTopAgainstType(callback)
	-- 已经拉取过数据了
	if next(self._topData) then
		callback()
		return
	end

	if self._reportType == REPORT_TYPE.SILVES_ARENA then
		local type = 0;  -- 0:防守记录; 1:进攻记录
		remote.silvesArena:silvesArenaTeamHistoryRequest(type,function (data)
			local fightReprts = data.silvesArenaInfoResponse.battleHistoryList or {}
			for _, v in pairs(fightReprts) do

					local rival = v.team1fighterList
					local result = v.success

					local info = {}
					info.type = REPORT_TYPE.SILVES_ARENA
					info.result = not result

					info.teamList = {}
					for i,v in ipairs(rival) do
						if v then
							local uInfo = {}

							uInfo.userId = v.userId
							uInfo.level = v.level
							uInfo.vip = v.vip
							uInfo.avatar = v.avatar
							table.insert(info.teamList,uInfo)
						end
					end
					info.matchingId = v.matchingId
					info.avatarList = {rival[1].avatar,rival[2].avatar,rival[3].avatar}
					info.nickname = v.team1Name

					info.time = v.fightAt
					info.reportIdList = v.reportIdList
					info.isInitiative = v.team1fighterList == nil
					info.rankChanged = v.team1AddScore

					table.insert(self._topData, info)

			end
			callback()
		end)
	else	
		local lastOpenTime = app:getUserOperateRecord():getRecordByType("top_report_last_open") or 0
		app:getUserOperateRecord():setRecordByType("top_report_last_open", q.serverTime())

		local battleType = QReplayUtil:getBattleTypeNumByReportType(REPORT_TYPE.SOTO_TEAM)
		app:getClient():globalGetTopFightReportDataRequest(battleType, function (data)
			local fightReprts = data.globalGetTopFightReportDataResponse.reportDatas or {}


			for _, v in pairs(fightReprts) do

				local me = v.fighter1
				local rival = v.fighter2

				local result = v.scoreList[1]
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
				info.rankChanged = me.rank
				-- info.rankChanged = me.rank - me.lastRank
				info.avatar = rival.avatar
				info.time = v.fightAt or v.fighter1.lastFightAt or v.createdAt
				info.reportId = v.fightReportId
				info.vip = rival.vip

				-- add
				info.fighter1 = v.fighter1
				info.fighter2 = v.fighter2
				info.scoreList = v.scoreList
				info.createdAt = v.createdAt

				table.insert(self._topData, info)
			end

			callback()
		end)
	end

end

function QUIDialogAgainstRecordBig:initListView()
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

function QUIDialogAgainstRecordBig:_renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
		item = QUIWidgetAgainstRecordBig.new()
		
		item:addEventListener(QUIWidgetAgainstRecordBig.EVENT_CLICK_HEAD, handler(self, self.itemClickHandler))
		item:addEventListener(QUIWidgetAgainstRecordBig.EVENT_CLICK_RECORDE, handler(self, self.itemClickHandler))
		item:addEventListener(QUIWidgetAgainstRecordBig.EVENT_CLICK_SHARED, handler(self, self.itemClickHandler))
		item:addEventListener(QUIWidgetAgainstRecordBig.EVENT_CLICK_REPLAY, handler(self, self.itemClickHandler))

    	isCacheNode = false
    end
    item:setInfo(itemData, self._reportType, self._selectTab)
    item:initGLLayer()
    info.item = item
    info.size = item:getContentSize()

	list:registerBtnHandler(index, "btn_head1", "_onTriggerHead1")
	list:registerBtnHandler(index, "btn_head2", "_onTriggerHead2")
	list:registerBtnHandler(index, "btn_head3", "_onTriggerHead3")
	list:registerBtnHandler(index, "btn_detail", "_onTriggerDetail", nil, true)
	list:registerBtnHandler(index, "btn_share", "_onTriggerShare", nil, true)
	list:registerBtnHandler(index, "btn_replay", "_onTriggerReplay", nil, true)

    return isCacheNode
end

function QUIDialogAgainstRecordBig:itemClickHandler(event)
	if not event.name then
		return
	end

	local info = event.info
	-- local userId = info.userId or info.fighter2.userId
	local reportType = info.type or self._reportType
	-- local reportId = info.reportId or info.fightReportId

	print("itemClickHandler info ~~~~~~",info)
	printTable(info)

	if event.name == QUIWidgetAgainstRecord.EVENT_CLICK_HEAD then
		local teamList = info.teamList
		local index = event.index
		local userId = teamList[index].userId

		remote.silvesArena:silvesLookUserDetail(userId)

		-- remote.silvesArena:silvesArenaQueryUserDataRequest(userId, function (data)
		-- 	if self.class then
		-- 		local fighter = data.silvesArenaInfoResponse.fighter or {}
		-- 		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
		-- 		options = {fighter = fighter, forceTitle1 = "玩家信息：", model = GAME_MODEL.NORMAL, isPVP = true}}, {isPopCurrentDialog = false})
		-- 	end
		-- end, fail, status)

	elseif event.name == QUIWidgetAgainstRecord.EVENT_CLICK_SHARED then

		local isFight = self._selectTab == QUIDialogAgainstRecordBig.TAB_NORMAL
		local matchingId = info.matchingId
		local reportIdList = info.reportIdList

		remote.silvesArena:silvesShareFightBatter(reportType,isFight,matchingId,reportIdList)

		-- local repostIdStr = ""
		-- for i,v in pairs(reportIdList) do
		-- 	if v then
		-- 		if repostIdStr == "" then
		-- 			repostIdStr = v
		-- 		else	
		-- 			repostIdStr = repostIdStr .. ";" .. v
		-- 		end
		-- 	end
		-- end
		-- repostIdStr = repostIdStr .. "$" .. matchingId
		-- repostIdStr = repostIdStr .. ";" .. (isFight and 1 or 0)

		-- remote.silvesArena:silvesArenaBattleHistoryDetailRequest(reportIdList,matchingId , function ( data )
		-- 	if self.class then

		-- 		local battleReport = data.silvesArenaInfoResponse.battleReport
		-- 		local team1Name = battleReport[1].team1Name
		-- 		local team2Name = battleReport[1].team2Name

		-- 		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogReplayShare", 
		-- 			options = {rivalName = team1Name, myNickName = team2Name, replayId = repostIdStr, replayType = reportType}}, {isPopCurrentDialog = false})
		-- 	end
		-- end)

	elseif event.name == QUIWidgetAgainstRecord.EVENT_CLICK_REPLAY then
		QReplayUtil:getReplayInfo(reportId, function (data)
			QReplayUtil:downloadReplay(reportId, function (replay)
				QReplayUtil:play(replay, data.scoreList, data.fightReportStats, true)
			end, nil, reportType)
		end, nil, reportType)

	elseif event.name == QUIWidgetAgainstRecord.EVENT_CLICK_RECORDE then

		if not event.name then
			return
		end
		local reportIdList = info.reportIdList
		local matchingId = info.matchingId

		local isFight = self._selectTab == QUIDialogAgainstRecordBig.TAB_NORMAL

		remote.silvesArena:silvesLookHistoryDetail(reportType,reportIdList, matchingId,isFight)

	end
end

function QUIDialogAgainstRecordBig:topItemClickHandler(event)
	-- if not event.name then
	-- 	return
	-- end

	-- local info = event.info
	-- local reportType = self._reportType
	-- local reportId = info.fightReportId
	-- local userId1 = info.fighter1.userId
	-- local userId2 = info.fighter2.userId
	-- if event.name == QUIWidgetAgainstTopRecord.EVENT_CLICK_TOP_RECORDE then
	-- 	QReplayUtil:getReplayInfo(reportId, function(data)
	-- 		local detailInfo = {}
	-- 		detailInfo.reportId = reportId
	-- 		detailInfo.reportType = reportType
	-- 		detailInfo.time = info.createdAt
	-- 		detailInfo.scoreList = info.scoreList
	-- 		detailInfo.fighter1 = info.fighter1
	-- 		detailInfo.fighter2 = info.fighter2
	-- 		detailInfo.replayInfo = data
	-- 		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTopAgainstRecordDetail",
	--     		options = {info = detailInfo}}, {isPopCurrentDialog = false})
	-- 	end, nil, reportType)
	-- end
end

function QUIDialogAgainstRecordBig:_onTriggerNormal(event)
	if self._selectTab == QUIDialogAgainstRecordBig.TAB_NORMAL then return end
    app.sound:playSound("common_switch")

	self._selectTab = QUIDialogAgainstRecordBig.TAB_NORMAL
	self:selectTabs()
end

function QUIDialogAgainstRecordBig:_onTriggerTop(event)
	if self._selectTab == QUIDialogAgainstRecordBig.TAB_TOP then return end
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
    
	self._selectTab = QUIDialogAgainstRecordBig.TAB_TOP
	self:selectTabs()
end

function QUIDialogAgainstRecordBig:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogAgainstRecordBig:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogAgainstRecordBig
