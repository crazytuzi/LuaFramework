--
-- Kumo.Wang
-- 西尔维斯大斗魂场战斗期准备战斗界面
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaPeakAgainstClient = class("QUIWidgetSilvesArenaPeakAgainstClient", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetSilvesArenaPeakAgainstClientCell = import(".QUIWidgetSilvesArenaPeakAgainstClientCell")
local QUIWidgetSilvesArenaPeakGroupBtn = import(".QUIWidgetSilvesArenaPeakGroupBtn")

QUIWidgetSilvesArenaPeakAgainstClient.EVENT_CLIENT = "QUIWidgetSilvesArenaPeakAgainstClient.EVENT_CLIENT"

function QUIWidgetSilvesArenaPeakAgainstClient:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Peak_Against.ccbi"
  	local callBacks = {
		{ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
  	}
	QUIWidgetSilvesArenaPeakAgainstClient.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_replay)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

    if options then
    	self._scale = options.scale or 1
    end
	self:_init()
end

function QUIWidgetSilvesArenaPeakAgainstClient:onEnter()
	QUIWidgetSilvesArenaPeakAgainstClient.super.onEnter(self)
	
	self._silvesArenaProxy = cc.EventProxy.new(remote.silvesArena)
    self._silvesArenaProxy:addEventListener(remote.silvesArena.STATE_UPDATE, handler(self, self.update))
    self._silvesArenaProxy:addEventListener(remote.silvesArena.EVENT_STAKE_UPDATE, handler(self, self.updateStakeData))
    self._silvesArenaProxy:addEventListener(remote.silvesArena.EVENT_PEAK_TEAM_UPDATE, handler(self, self.update))

	self:update()
end

function QUIWidgetSilvesArenaPeakAgainstClient:onExit()
	QUIWidgetSilvesArenaPeakAgainstClient.super.onExit(self)

	if self._silvesArenaProxy then
		self._silvesArenaProxy:removeAllEventListeners()
	end
end

function QUIWidgetSilvesArenaPeakAgainstClient:getClassName()
	return "QUIWidgetSilvesArenaPeakAgainstClient"
end

function QUIWidgetSilvesArenaPeakAgainstClient:updateStakeData()
	self:_updateStakeData(true)
end

function QUIWidgetSilvesArenaPeakAgainstClient:update()
	if not self._ccbView then return end
	if q.isEmpty(remote.silvesArena.peakTeamInfo) then return end

	local peakState = remote.silvesArena:getCurPeakState()
	local isfinalRound = nil
	if peakState == remote.silvesArena.PEAK_READY_TO_4
		or peakState == remote.silvesArena.PEAK_WAIT_TO_4
		or peakState == remote.silvesArena.PEAK_4_IN_2 then

		isfinalRound = false
	elseif peakState == remote.silvesArena.PEAK_READY_TO_FINAL
		or peakState == remote.silvesArena.PEAK_WAIT_TO_FINAL
		or peakState == remote.silvesArena.PEAK_FINAL_FIGHT then

		isfinalRound = true
	end

	if not self._curIndex or (self._isfinalRound ~= nil and self._isfinalRound == isfinalRound) then 
		self._curIndex = 1 
	end
	self._isfinalRound = isfinalRound
	self:_reset()

	
	self._myGroupIndex = 0
	self._groupData = {}
	if self._isfinalRound then
		table.sort(remote.silvesArena.peakTeamInfo, function(a, b)
			if a.currRound ~= b.currRound then
				return a.currRound > b.currRound
			else
				return a.position < b.position
			end
		end)
	else
		table.sort(remote.silvesArena.peakTeamInfo, function(a, b)
			return a.position < b.position
		end)
	end
	local groupIndex = 1
	for i = 1, #remote.silvesArena.peakTeamInfo, 1 do
		if remote.silvesArena.peakTeamInfo[i].currRound >= self._minRound then
			if not self._groupData[groupIndex] then
				self._groupData[groupIndex] = {}
			end
			if remote.silvesArena.peakTeamInfo[i].teamId == remote.silvesArena.myTeamInfo.teamId then
				self._myGroupIndex = groupIndex
				table.insert(self._groupData[groupIndex], remote.silvesArena.myTeamInfo)
			else
				table.insert(self._groupData[groupIndex], remote.silvesArena.peakTeamInfo[i])
			end

			if #self._groupData[groupIndex] >= self._groupSize then
				groupIndex = groupIndex + 1
			end
		end
	end
	for _, groupData in ipairs(self._groupData) do
		if #groupData >= 2 then
			table.sort(groupData, function(a, b)
				return a.position < b.position
			end)
		end
	end
	self._btnCells = {}
	for index = 1, #self._groupData, 1 do
		if not self._btnCells[index] then
			self._btnCells[index] = QUIWidgetSilvesArenaPeakGroupBtn.new({index = index, myGroupIndex = self._myGroupIndex})
			if self._isfinalRound then
				if self._groupData[index][1].currRound > self._minRound then
					self._btnCells[index]:setBtnName("冠军赛")
				else
					self._btnCells[index]:setBtnName("季军赛")
				end
			end
			self._btnCells[index]:addEventListener(QUIWidgetSilvesArenaPeakGroupBtn.EVENT_CLICK, handler(self, self._onBtnClick))
			self._ccbOwner.node_group_btn:addChild(self._btnCells[index])
			self._btnCells[index]:setPositionX(self._btnCells[index]:getContentSize().width * (index - 1) + self._btnCells[index]:getContentSize().width / 2)
		end
		if self._btnCells[index] then
			self._btnCells[index]:update(self._curIndex)
		end
	end

	if not q.isEmpty(self._btnCells) then
		self._ccbOwner.node_group_btn:setPositionX(- self._btnCells[1]:getContentSize().width * #self._btnCells / 2)
	end

	self:_updateStakeData(true)
	self:_updateView()
end

function QUIWidgetSilvesArenaPeakAgainstClient:_reset()
	self._ccbOwner.node_against_view:setScale(self._scale)

	for i = 1, remote.silvesArena.MAX_TEAM_MEMBER_COUNT , 1 do
		local enemyNode = self._ccbOwner["node_enemy_"..i]
		if enemyNode then
			enemyNode:removeAllChildren()
			enemyNode:setVisible(true)
		end

		local userNode = self._ccbOwner["node_user_"..i]
		if userNode then
			userNode:removeAllChildren()
			userNode:setVisible(true)
		end
	end

	self._ccbOwner.node_team_info_1:setVisible(false)
	self._ccbOwner.node_team_info_2:setVisible(false)

	self._ccbOwner.sp_vs:setVisible(true)

	self._ccbOwner.tf_score_1:setVisible(false)
	self._ccbOwner.tf_score_vs:setVisible(false)
	self._ccbOwner.tf_score_2:setVisible(false)
	self._ccbOwner.tf_my_stake:setVisible(false)

	self._ccbOwner.node_btn_ok:setVisible(false)
	self._ccbOwner.node_btn_replay:setVisible(false)

	self._ccbOwner.node_group_btn:removeAllChildren()
end

function QUIWidgetSilvesArenaPeakAgainstClient:_onBtnClick(event)
	if not event or not event.index then return end
	if event.index == self._curIndex then return end

	self._curIndex = event.index

	for _, btn in pairs(self._btnCells) do
		btn:update(self._curIndex)
	end

	self:_updateStakeData()
	self:_updateView()
end


function QUIWidgetSilvesArenaPeakAgainstClient:_init()
	self._groupSize = 2 -- 一组2人（取决于ccb）
	self._minRound = 3 -- 最小轮次
	self._avatarDic = {userAvatar = {}, enemyAvatar = {}}
	self._betInfo = {}
end

function QUIWidgetSilvesArenaPeakAgainstClient:_updateInfo()
	if q.isEmpty(self._groupData) then return end

	local peakState = remote.silvesArena:getCurPeakState()
	if peakState == remote.silvesArena.PEAK_WAIT_TO_4
		or peakState == remote.silvesArena.PEAK_WAIT_TO_FINAL then

		self._ccbOwner.node_btn_ok:setVisible(true)
	elseif peakState == remote.silvesArena.PEAK_READY_TO_4
		or peakState == remote.silvesArena.PEAK_4_IN_2 
		or peakState == remote.silvesArena.PEAK_READY_TO_FINAL
		or peakState == remote.silvesArena.PEAK_FINAL_FIGHT then

		self._ccbOwner.node_btn_ok:setVisible(false)
	end

	local groupData = self._groupData[self._curIndex]
	if groupData and #groupData >= 2 then
		local team1Id = groupData[1].teamId
		local team2Id = groupData[2].teamId
		local info = self._betInfo[team1Id..team2Id]
		if not q.isEmpty(info) then
			if info.scoreId and info.scoreId > 0 then
				-- 有比赛结果
				self._ccbOwner.node_btn_replay:setVisible(true)
				self._ccbOwner.tf_my_stake:setVisible(false)
				local scoreList = remote.silvesArena.PEAK_SCORE_LIST[info.scoreId]
				if not q.isEmpty(scoreList) then
					self._ccbOwner.sp_vs:setVisible(false)
					self._ccbOwner.tf_score_1:setVisible(true)
					self._ccbOwner.tf_score_vs:setVisible(true)
					self._ccbOwner.tf_score_2:setVisible(true)

					self._ccbOwner.tf_score_1:setString(scoreList[1])
					self._ccbOwner.tf_score_2:setString(scoreList[2])
				end
			elseif info.myScoreId and info.myScoreId > 0 then
				self:_updateMyStake()
			end
		end
	end
end

function QUIWidgetSilvesArenaPeakAgainstClient:_updateStakeData(isForce)
	local groupData = self._groupData[self._curIndex]
	if groupData and #groupData >= 2 then
		local team1Id = groupData[1].teamId
		local team2Id = groupData[2].teamId
		if not isForce and self._betInfo[team1Id..team2Id] then 
			-- 进入界面的时候，拉取一次押注信息，之后不拉
			self:_updateMyStake()
			self:_updateTeamInfo()
			self:_updateInfo()
			return 
		end 
		remote.silvesArena:silvesPeakBetInfoRequest(team1Id, team2Id, function(data)
			if self._ccbView then
				if data.silvesArenaInfoResponse and data.silvesArenaInfoResponse.silvesPeakUserBetInfo and not q.isEmpty(data.silvesArenaInfoResponse.silvesPeakUserBetInfo[1]) then
					local id1 = data.silvesArenaInfoResponse.silvesPeakUserBetInfo[1].team1 and data.silvesArenaInfoResponse.silvesPeakUserBetInfo[1].team1.teamId
					local id2 = data.silvesArenaInfoResponse.silvesPeakUserBetInfo[1].team2 and data.silvesArenaInfoResponse.silvesPeakUserBetInfo[1].team2.teamId
					if id1 and id2 then
		                self._betInfo[id1..id2] = data.silvesArenaInfoResponse.silvesPeakUserBetInfo[1]
	               	end
	            end
	            -- QKumo(self._betInfo)
	            self:_updateMyStake()
	            self:_updateTeamInfo()
	            self:_updateInfo()
           	end
		end, function()
            self:_updateMyStake()
            self:_updateTeamInfo()
            self:_updateInfo()
		end)
	end
end

function QUIWidgetSilvesArenaPeakAgainstClient:_updateMyStake()
	local groupData = self._groupData[self._curIndex]
	if groupData and #groupData >= 2 then
		local team1Id = groupData[1].teamId
		local team2Id = groupData[2].teamId
		local info = self._betInfo[team1Id..team2Id]
		if not q.isEmpty(info) then
			if (not info.scoreId or info.scoreId == 0) and info.myScoreId and info.myScoreId > 0 then
				self._ccbOwner.node_btn_ok:setVisible(false)
				local scoreList = remote.silvesArena.PEAK_SCORE_LIST[info.myScoreId]
				self._ccbOwner.tf_my_stake:setString("押注："..scoreList[1].." : "..scoreList[2])
				self._ccbOwner.tf_my_stake:setVisible(true)
				return
			end
		end
	end
	self._ccbOwner.tf_my_stake:setVisible(false)
end

function QUIWidgetSilvesArenaPeakAgainstClient:_updateView()
	self:_updateEnemyTeamView()
	self:_updateUserTeamInfo()
end

function QUIWidgetSilvesArenaPeakAgainstClient:_updateEnemyTeamView()
	local groupData = self._groupData[self._curIndex]
	if not groupData or not groupData[2] or q.isEmpty(groupData[2]) then return end
	local info = groupData[2]
	local isMe = remote.silvesArena.myTeamInfo and info.teamId == remote.silvesArena.myTeamInfo.teamId
	-- QKumo(info, "[Team2]")
	local enemyTeamList = {}
	if not q.isEmpty(info.leader) then
		table.insert(enemyTeamList, info.leader)
	end
	if not q.isEmpty(info.member1) then
		table.insert(enemyTeamList, info.member1)
	end
	if not q.isEmpty(info.member2) then
		table.insert(enemyTeamList, info.member2)
	end
	if #enemyTeamList == 0 then
		return
	end

	table.sort(enemyTeamList, function(a, b)
		return a.silvesArenaFightPos < b.silvesArenaFightPos
	end)

	for i = 1, remote.silvesArena.MAX_TEAM_MEMBER_COUNT, 1 do
		local node = self._ccbOwner["node_enemy_"..i]
		if node then
			node:removeAllChildren()
			if enemyTeamList and enemyTeamList[i] and enemyTeamList[i].defaultActorId then
				local peakState = remote.silvesArena:getCurPeakState()
				
				local isNotHide = true
				if peakState == remote.silvesArena.PEAK_READY_TO_4
					or peakState == remote.silvesArena.PEAK_READY_TO_FINAL then
					
					isNotHide = isMe
				end
				local avatar = QUIWidgetSilvesArenaPeakAgainstClientCell.new({ info = enemyTeamList[i], index = i, isNotHide = isNotHide, isLeft = false })
				node:addChild(avatar)
				self._avatarDic.enemyAvatar[i] = avatar
			end
		end
	end
end

function QUIWidgetSilvesArenaPeakAgainstClient:_updateUserTeamInfo()
	local groupData = self._groupData[self._curIndex]
	if not groupData or not groupData[1] or q.isEmpty(groupData[1]) then return end
	local info = groupData[1]
	local isMe = remote.silvesArena.myTeamInfo and info.teamId == remote.silvesArena.myTeamInfo.teamId
	-- QKumo(info, "[Team1]")
	local userTeamList = {}
	if not q.isEmpty(info.leader) then
		table.insert(userTeamList, info.leader)
	end
	if not q.isEmpty(info.member1) then
		table.insert(userTeamList, info.member1)
	end
	if not q.isEmpty(info.member2) then
		table.insert(userTeamList, info.member2)
	end
	if #userTeamList == 0 then
		return
	end

	table.sort(userTeamList, function(a, b)
		return a.silvesArenaFightPos < b.silvesArenaFightPos
	end)

	for i = 1, remote.silvesArena.MAX_TEAM_MEMBER_COUNT, 1 do
		local node = self._ccbOwner["node_user_"..i]
		if node then
			node:removeAllChildren()
			if userTeamList and userTeamList[i] and userTeamList[i].defaultActorId then
				local peakState = remote.silvesArena:getCurPeakState()
				
				local isNotHide = true
				if peakState == remote.silvesArena.PEAK_READY_TO_4
					or peakState == remote.silvesArena.PEAK_READY_TO_FINAL then
					
					isNotHide = isMe
				end
				local avatar = QUIWidgetSilvesArenaPeakAgainstClientCell.new({ info = userTeamList[i], index = i, isNotHide = isNotHide, isLeft = true })
				node:addChild(avatar)
				self._avatarDic.userAvatar[i] = avatar
			end
		end
	end
end

function QUIWidgetSilvesArenaPeakAgainstClient:_updateTeamInfo()
	local groupData = self._groupData[self._curIndex]
	if q.isEmpty(groupData) then return end

	local betKey = ""
	for i, data in ipairs(groupData) do
		self._ccbOwner["tf_team_name_"..i]:setString(data.teamName)

		local isMe = remote.silvesArena.myTeamInfo and data.teamId == remote.silvesArena.myTeamInfo.teamId
		local totalForce, totalNumber = remote.silvesArena:getTotalForceAndTotalNumberByTeamInfo(data, isMe)
		if totalForce and totalNumber then
		    local num, unit = q.convertLargerNumber(totalForce/totalNumber)
			self._ccbOwner["tf_team"..i.."_force"]:setString( num..(unit or "") )
		else
			self._ccbOwner["tf_team"..i.."_force"]:setString(0)
		end

		betKey = betKey..data.teamId
		self._ccbOwner["node_team_info_"..i]:setVisible(true)
	end
	if self._betInfo[betKey] then
		local info = self._betInfo[betKey].scoreDetailInfos
		if not q.isEmpty(info) then
			table.sort(info, function(a, b)
				return a.scoreId < b.scoreId
			end)
			local team1Count = 0
			local team2Count = 0
			for i, value in ipairs(info) do
				if i < 3 then
					-- 1,2 押注1队赢
					team1Count = team1Count + value.totalNum
				else
					-- 3,4 押注2队赢
					team2Count = team2Count + value.totalNum
				end
			end
			self._ccbOwner["tf_team1_bet"]:setString( team1Count.."人" )
			self._ccbOwner["tf_team2_bet"]:setString( team2Count.."人" )
			return
		end
	end
	self._ccbOwner["tf_team1_bet"]:setString( "0人" )
	self._ccbOwner["tf_team2_bet"]:setString( "0人" )
end

function QUIWidgetSilvesArenaPeakAgainstClient:_onTriggerReplay(event)
	local groupData = self._groupData[self._curIndex]
	if not groupData or not groupData[1] or q.isEmpty(groupData[1]) then return end
	
	remote.silvesArena:silvesPeakGetBattleInfoRequest(groupData[1].teamId, groupData[2].teamId, function ( data )
        local battleReport = data.silvesArenaInfoResponse.battleReport
        local lastfightAt = 0
        for i, v in ipairs(battleReport) do
            if v.fightersData then
                local content = crypto.decodeBase64(v.fightersData)
                local replayInfo = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayInfo", content)

                v.replayInfo = replayInfo
            end
            if lastfightAt == 0 or lastfightAt < v.fightAt then
                lastfightAt = v.fightAt
            end
            -- QKumo(v.replayInfo)
        end
        battleReport.reportType = reportType
        battleReport.matchingId = matchingId
        battleReport.reportIdList = reportIdList
        battleReport.fightAt = lastfightAt
        
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaRecordDetail",
            options = {info = battleReport, isFight = isFight, showShare = false}}, {isPopCurrentDialog = false})
    end)
end

function QUIWidgetSilvesArenaPeakAgainstClient:_onTriggerOK(event)
	if event then
		app.sound:playSound("common_small")
	end
	local peakState = remote.silvesArena:getCurPeakState()
	if peakState ~= remote.silvesArena.PEAK_WAIT_TO_4 and peakState ~= remote.silvesArena.PEAK_WAIT_TO_FINAL then
		app.tip:floatTip("当前押注时间未到哦～")
		return
	end
	
	local groupData = self._groupData[self._curIndex]
	if q.isEmpty(groupData) then return end
	
	local player1 = groupData[1]
	local player2 = groupData[2]

	if q.isEmpty(player1) or q.isEmpty(player2) then return end

	local maxNum = 0
	if peakState == remote.silvesArena.PEAK_WAIT_TO_4 then
		maxNum = db:getConfigurationValue("team_arena_peak_war_bet_max_4")
	elseif peakState == remote.silvesArena.PEAK_WAIT_TO_FINAL then
		if groupData[1].currRound > self._minRound then
			maxNum = db:getConfigurationValue("team_arena_peak_war_bet_max_2")
		else
			maxNum = db:getConfigurationValue("team_arena_peak_war_bet_max_3")
		end
	end

	if maxNum == 0 then return end

	local maxBet = db:getConfigurationValue("team_arena_peak_max")
	local minBet = db:getConfigurationValue("team_arena_peak_min")
	local betInfo = self._betInfo[player1.teamId..player2.teamId]
	
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaPeakStake",
		options = {player1 = player1, player2 = player2, maxNum = maxNum, maxBet = maxBet, minBet = minBet, betInfo = betInfo}}, {isPopCurrentDialog = false})	
end

return QUIWidgetSilvesArenaPeakAgainstClient