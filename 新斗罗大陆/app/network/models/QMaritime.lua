-- @Author: xurui
-- @Date:   2016-12-24 10:45:25
-- @Last Modified by:   vicentboo
-- @Last Modified time: 2019-09-04 14:43:23

local QBaseModel = import("...models.QBaseModel")
local QMaritime = class("QMaritime", QBaseModel)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QMaritime.EVENT_UPDATE_MYINFO = "EVENT_UPDATE_MYINFO"
QMaritime.EVENT_UPDATE_TRANSPORT_NUM = "EVENT_UPDATE_TRANSPORT_NUM"
QMaritime.EVENT_UPDATE_ROBBERY_NUM = "EVENT_UPDATE_ROBBERY_NUM"

function QMaritime:ctor(options)
	QMaritime.super.ctor(self)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._myInfo = {}            -- 我的信息
	self._myShipInfo = {}		 -- 我的船
	self._enemyShipsInfoList = {}	 -- 对手的船
	self._shipConfigDict = {}    -- 仙品配置信息
	self._awardsConfigList = {}    -- 仙品配置信息

	self._rewardInfosDict = {}		 -- 可领取的奖励
	self._replayTip = false      -- 战报红点
	self._topShipId = 0           -- 最大仙品id
	self._bestShipId = 0           -- 第二最大仙品id
	self._projectReplayTip = false  --保护战报红点 

	self.startShipId = 2
end

function QMaritime:didappear()
end

function QMaritime:disappear()
end

function QMaritime:loginEnd()
	if app.unlock:getUnlockMaritime() then	
		self:requestMaritimeMyInfo(false)
	end
end

function QMaritime:openDialog()
	if app.unlock:getUnlockMaritime(true) then	
		self._myShipInfo = {}		 -- 我的船
		self._enemyShipsInfoList = {}	 -- 对手的船
		
		self:requestMaritimeMyInfo(true, function()
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaritimeMain", options = {isShowAwards = true}})
			end)
	end
end

function QMaritime:setMaritimeInfo(data)
	if data.myInfo then
		for key, value in pairs(data.myInfo) do
			self._myInfo[key] = value
		end
		self:dispatchEvent({name = QMaritime.EVENT_UPDATE_MYINFO})

		if data.myInfo.defenseArmy then 
       		self:updateDefendTeam(data.myInfo)
       	end
	end
	if data.myShipInfo then
		self._myShipInfo = data.myShipInfo
	end
	if data.shipInfos then
		self._enemyShipsInfoList = data.shipInfos
	end
	if data.rewardInfos then
		self._rewardInfosDict = data.rewardInfos
	end
end

function QMaritime:updateDefendTeam(data)
    local battleFormation1 = data.defenseArmy or {}
    if q.isEmpty(battleFormation1) then
        battleFormation1 = remote.teamManager:getDefaultTeam(remote.teamManager.MARITIME_DEFEND_TEAM1)
    end
    if q.isEmpty(battleFormation1) == false then
        local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.MARITIME_DEFEND_TEAM1, false)
        teamVO:setTeamDataWithBattleFormation(battleFormation1)
    end   

    local battleFormation2 = data.defense2Army or {}
    if q.isEmpty(battleFormation2) then
        battleFormation2 = remote.teamManager:getDefaultTeam(remote.teamManager.MARITIME_DEFEND_TEAM2)
    end
    if q.isEmpty(battleFormation2) == false then
        local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.MARITIME_DEFEND_TEAM2, false)
        teamVO:setTeamDataWithBattleFormation(battleFormation2)
    end
end

function QMaritime:addNewShip(ships)
	for _, value in pairs(ships) do
		if value.userId == remote.user.userId then
			self._myShipInfo = value
		else
			local isUpdate = false
			for i = 1, #self._enemyShipsInfoList do
				if value.userId == self._enemyShipsInfoList[i].userId then
					self._enemyShipsInfoList[i] = value
					isUpdate = true
				end
			end
			if isUpdate == false then
				table.insert(self._enemyShipsInfoList, value)
			end
		end
	end
end

function QMaritime:getMyMaritimeInfo()
	return self._myInfo or {}
end

function QMaritime:getMyShipInfo()
	return self._myShipInfo or {}
end

function QMaritime:getEnemyShipInfo()
	return self._enemyShipsInfoList or {}
end

function QMaritime:addRobberyNumShipInfo(shipInfo, num)
	if num == nil then num = 1 end

	for i = 1, #self._enemyShipsInfoList do
		if self._enemyShipsInfoList[i].userId == shipInfo.userId then
			self._enemyShipsInfoList[i].lootedCnt = self._enemyShipsInfoList[i].lootedCnt + 1
		end
	end
end

function QMaritime:removeShipInfo(shipInfo)
	if shipInfo == nil then return end

	for i = 1, #self._enemyShipsInfoList do
		if self._enemyShipsInfoList[i].userId == shipInfo.userId then
			table.remove(self._enemyShipsInfoList, i)
			break
		end
	end
end

function QMaritime:getShipInfoByUserId(userId)
	if self._myShipInfo.userId == userId then
		return self._myShipInfo
	end

	for _, value in pairs(self._enemyShipsInfoList) do
		if value.userId == userId then
			return value
		end
	end
	return {}
end

function QMaritime:setProtecter(protecter)
	self._protecter = protecter
end

function QMaritime:getProtecter()
	return self._protecter
end

function QMaritime:updateReplayTip(state)
	self._replayTip = state
end

function QMaritime:updateProjectReplayTip(state)
	self._projectReplayTip = state
end
--[[
	根据UserID, 商船ID、被劫次数、战队等级获得剩余奖励
]]
function QMaritime:getMaritimeAwardsInfo(userId, shipId, level)
	local lastAwards = {}
	local robberyAwards = {}
	local shipAwards = self:getMaritimeShipAwardsInfoByShipId(shipId, level)
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	local robberyScale = configuration["maritime_proportion"].value or 0

	local shipInfo = self:getShipInfoByUserId(userId)

	local index = 1
	while shipAwards["type_"..index] do
		local count = 0
		if shipAwards["plunder_"..index] == 1 then
			count = shipAwards["num_"..index] * robberyScale
			robberyAwards[#robberyAwards+1] = {id = shipAwards["id_"..index], typeName = shipAwards["type_"..index], count = math.ceil(count)}
		end
		count = shipAwards["num_"..index] - shipInfo.lootedCnt * count
		lastAwards[#robberyAwards+1] = {id = shipAwards["id_"..index], typeName = shipAwards["type_"..index], count = math.ceil(count)}
		index = index + 1
	end

	return lastAwards, robberyAwards
end

function QMaritime:getMaritemeEscortTime()
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	local escortTotalTime = configuration["MARITIME_ESCORT_END_TIME"].value
	local lastTime = self._myInfo.joinEscortAt/1000 + escortTotalTime*HOUR
	return lastTime
end

function QMaritime:checkIsDoubleTime()
	-- local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	-- local doubleTime = configuration["maritime_double_time"].value
	-- if doubleTime == nil then return false end

	-- doubleTime = string.split(doubleTime, ";")
	-- local nowTime = q.date("*t", q.serverTime())
	-- for _, value in pairs(doubleTime) do
	-- 	local time = string.split(value, ",")
	-- 	if nowTime.hour >= tonumber(time[1]) and nowTime.hour < tonumber(time[2]) then
	-- 		return true
	-- 	end
	-- end
	return false
end

function QMaritime:checkMaritimeRedTips()
	if app.unlock:getUnlockMaritime() == false then
		return false
	end

	if self:checkAwardsTips() then
		return true
	end
	
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	local transportNum = configuration["maritime_cishu"].value
	local myInfo = self:getMyMaritimeInfo()
	local num = transportNum + (myInfo.buyMaritimeCnt or 0) - (myInfo.maritimeCnt or 0)
	if num > 0 then
		return true
	end

	return false
end

function QMaritime:checkSpecialTips()
	if app.unlock:getUnlockMaritime() == false then
		return false
	end

	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	local transportNum = configuration["maritime_cishu"].value
	local myInfo = self:getMyMaritimeInfo()
	local num = transportNum + (myInfo.buyMaritimeCnt or 0) - (myInfo.maritimeCnt or 0)
	if next(self._myShipInfo) == nil and num > 0 then
		return true
	end

	return false
end
function QMaritime:checkAwardsTips()
	if next(self._rewardInfosDict) == nil then
		return false
	end

	for _, value in pairs(self._rewardInfosDict) do
		if value.status == 2 then
			return true
		end
	end

	return false
end

function QMaritime:checkReplayTips()
	return self._replayTip
end

function QMaritime:checkProjectReplayTips()
	return self._projectReplayTip
end

function QMaritime:checkEscortTips()
	local myInfo = self:getMyMaritimeInfo()
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()

	local protecterNum = configuration["maritime_protect"].value - (myInfo.escortCnt or 0)

	if protecterNum > 0 and myInfo.escortStatus == 0 then
		return true
	end
	return false
end

function QMaritime:checkIsAccountTime()
	-- local nowTime = q.serverTime()
	-- local openTime = q.getTimeForHMS("04", "00", "00")
	-- local closeTime = q.getTimeForHMS("05", "00", "00")

	-- if nowTime >= openTime and nowTime <= closeTime then
	-- 	return true
	-- end
	return false
end

function QMaritime:checkCanRobberyShip(shipInfo)
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	local rebberyTimes = configuration["maritime_be_plunder"].value
	local isLoot = false
	local lootUserIds = string.split(shipInfo.lootUserIds, ";")
	for _, useId in pairs(lootUserIds) do
		if useId == remote.user.userId then
			isLoot = true
			break
		end
	end
	local robberyNum = shipInfo.lootedCnt or 0
	if rebberyTimes - robberyNum <= 0 or isLoot == true then
		return true
	end

	return false
end

function QMaritime:updateTransportNum()
	self:dispatchEvent({name = QMaritime.EVENT_UPDATE_TRANSPORT_NUM})
end

function QMaritime:updateRobberyNum()
	self:dispatchEvent({name = QMaritime.EVENT_UPDATE_ROBBERY_NUM})
end

function QMaritime:checkTeamIsFull()
    local team1Main = remote.teamManager:checkTeamIsFull(remote.teamManager.MARITIME_DEFEND_TEAM1, 1)
    local team1Help = remote.teamManager:checkTeamIsFull(remote.teamManager.MARITIME_DEFEND_TEAM1, 2)
    local team2Main = remote.teamManager:checkTeamIsFull(remote.teamManager.MARITIME_DEFEND_TEAM2, 1)
    local team2Help = remote.teamManager:checkTeamIsFull(remote.teamManager.MARITIME_DEFEND_TEAM2, 2)

    if team1Main and team1Help and team2Main and team2Help then
        return false
    end

    return true
end

----------------------------- 量表数据 --------------------------

--根据船只ID获取船只信息
function QMaritime:getMaritimeShipInfoByShipId(shipId)
	if shipId == nil then return end

	local config = self:getMaritimeShipConfig()
    return config[tostring(shipId)]
end

function QMaritime:getMaritimeShipConfig( ... )
	if q.isEmpty(self._shipConfigDict) then
		local config = QStaticDatabase:sharedDatabase():getStaticByName("maritime_ship")
    	self._shipConfigDict = config
    end

    return self._shipConfigDict
end

function QMaritime:getMaritimeTopShipIdAndBestShipId()
	if self._topShipId == 0 then
		local config = self:getMaritimeShipConfig()
		for _, value in pairs(config) do
			if value.id > self._topShipId then
				self._topShipId = value.id
			end
		end
	end

	if self._bestShipId == 0 then
		local config = self:getMaritimeShipConfig()
		for _, value in pairs(config) do
			if value.id > self._bestShipId and value.id < self._topShipId then
				self._bestShipId = value.id
			end
		end
	end

	return self._topShipId, self._bestShipId
end

--根据船只ID获取船只奖励信息
function QMaritime:getMaritimeShipAwardsInfoByShipId(shipId, level)
    if shipId == nil then return {} end

    local shipInfos = {}
	local config = self:getMaritimeShipAwardsInfo()
	shipInfos = config[tostring(shipId)] or {}
    
    return shipInfos
end

--根据船只ID获取船只奖励信息
function QMaritime:getMaritimeShipAwardsInfo()
    return QStaticDatabase:sharedDatabase():getStaticByName("maritime_reward")
end

-- 获取海商排行奖励
function QMaritime:getMaritimeRankAwards()
	local awards = QStaticDatabase:sharedDatabase():getStaticByName("rank_reward")
    return awards["maritime_benfu"]
end

----------------------------- 协议 -----------------------------

function QMaritime:responseHandler(data, success, fail, succeeded)
	if succeeded == true then
        if success ~= nil then
            success(data)
        end
    else
        if fail ~= nil then
            fail(data)
        end
    end
end

--[[
	拉取海商信息协议请求
]]
function QMaritime:requestMaritimeMyInfo(receiveShips, success, fail, status)
	local maritimeGetMyInfoRequest = {receiveShips = receiveShips}
    local request = {api = "MARITIME_GET_MY_INFO", maritimeGetMyInfoRequest = maritimeGetMyInfoRequest}
    app:getClient():requestPackageHandler("MARITIME_GET_MY_INFO", request, function (response)
        self:responseMaritimeMyInfo(response, success, nil, true)
    end, function (response)
        self:responseMaritimeMyInfo(response, nil, fail)
    end)
end

--[[
	拉取海商协议返回
]]
function QMaritime:responseMaritimeMyInfo(data, success, fail, succeeded)
	if data.maritimeGetMyInfoResponse then
		self:setMaritimeInfo(data.maritimeGetMyInfoResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	刷新船只协议请求
	int type: 1:刷新一次 2:终极仙品 3:特级仙品
]]
function QMaritime:requestMaritimeRefreshShip(shipType, success, fail, status)
	local maritimeRefreshShipRequest = {type = shipType}
    local request = {api = "MARITIME_REFRESH_SHIP", maritimeRefreshShipRequest = maritimeRefreshShipRequest}
    app:getClient():requestPackageHandler("MARITIME_REFRESH_SHIP", request, function (response)
        self:responseMaritimeRefreshShip(response, success, nil, true)
    end, function (response)
        self:responseMaritimeRefreshShip(response, nil, fail)
    end)
end

--[[
	刷新船只协议返回
]]
function QMaritime:responseMaritimeRefreshShip(data, success, fail, succeeded)
	if data.maritimeRefreshShipResponse then
		self:setMaritimeInfo(data.maritimeRefreshShipResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	存放海商防守阵容协议请求
]]
function QMaritime:requestSetMaritimeDefenseTeam(battleFormation1, battleFormation2, success, fail, status)
    local request = {api = "MARITIME_CHANGE_DEFENSE_HEROS", battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    app:getClient():requestPackageHandler("MARITIME_CHANGE_DEFENSE_HEROS", request, function (response)
        self:responseSetMaritimeDefenseTeam(response, success, nil, true)
    end, function (response)
        self:responseSetMaritimeDefenseTeam(response, nil, fail)
    end)
end

--[[
	存放海商防守阵容协议返回
]]
function QMaritime:responseSetMaritimeDefenseTeam(data, success, fail, succeeded)
	if data.maritimeChangeDefenseHerosResponse then
		self:setMaritimeInfo(data.maritimeChangeDefenseHerosResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	加入保护协议请求
]]
function QMaritime:requestMaritimeJoinEscort(success, fail, status)
    local request = {api = "MARITIME_JOIN_ESCORT"}
    app:getClient():requestPackageHandler("MARITIME_JOIN_ESCORT", request, function (response)
        self:responseMaritimeJoinEscort(response, success, nil, true)
    end, function (response)
        self:responseMaritimeJoinEscort(response, nil, fail)
    end)
end

--[[
	加入保护协议返回
]]
function QMaritime:responseMaritimeJoinEscort(data, success, fail, succeeded)

	app.taskEvent:updateTaskEventProgress(app.taskEvent.MARITIME_JOIN_ESCORT_EVENT, 1)

	if data.maritimeJoinEscortResponse then
		self:setMaritimeInfo(data.maritimeJoinEscortResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	拉取保护列表协议请求
]]
function QMaritime:requestGetMaritimeEscortList(success, fail, status)
    local request = {api = "MARITIME_JOIN_ESCORT_LIST"}
    app:getClient():requestPackageHandler("MARITIME_JOIN_ESCORT_LIST", request, function (response)
        self:responseSetMaritimeJoinEscort(response, success, nil, true)
    end, function (response)
        self:responseSetMaritimeJoinEscort(response, nil, fail)
    end)
end

--[[
	拉取保护列表协议返回
]]
function QMaritime:responseSetMaritimeJoinEscort(data, success, fail, succeeded)
	self:responseHandler(data, success, fail, succeeded)
end

function QMaritime:requestMaritimeFightStartRequest(battleType, rivalUserId, battleFormation1, battleFormation2,success,fail)
	-- body
	local gfStartRequest = {battleType = battleType,battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail)
end

--[[
	海商掠夺协议请求
]]
function QMaritime:requestMaritimeFightEnd(userId, battleKey, battleFormation1, battleFormation2, success, fail, status)
	local maritimeFightEndRequest = {userId = userId}
	local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    maritimeFightEndRequest.battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.MARITIME, battleVerify = maritimeFightEndRequest.battleVerify, isQuick = false, isWin = nil,
                         fightReportData = fightReportData, battleFormation = battleFormation1, battleFormation2 = battleFormation2, maritimeFightEndRequest = maritimeFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        self:responseMaritimeFightEnd(response, success, nil, true)
    end, function (response)
        self:responseMaritimeFightEnd(response, nil, fail)
    end)
end

--[[
	海商掠夺协议返回
]]
function QMaritime:responseMaritimeFightEnd(data, success, fail, succeeded)
	if data.gfEndResponse and data.gfEndResponse.maritimeFightEndResponse then
		self:setMaritimeInfo(data.gfEndResponse.maritimeFightEndResponse)
		self:addNewShip({data.gfEndResponse.maritimeFightEndResponse.lootedShipInfo})
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	购买掠夺次数协议请求
]]
function QMaritime:requestBuyRobberyNum(success, fail, status)
    local request = {api = "MARITIME_BUY_LOOT_CNT"}
    app:getClient():requestPackageHandler("MARITIME_BUY_LOOT_CNT", request, function (response)
        self:responseBuyRobberyNum(response, success, nil, true)
    end, function (response)
        self:responseBuyRobberyNum(response, nil, fail)
    end)
end

--[[
	购买掠夺次数协议返回
]]
function QMaritime:responseBuyRobberyNum(data, success, fail, succeeded)
	if data.maritimeBuyLootCntResponse then
		self:setMaritimeInfo(data.maritimeBuyLootCntResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end


--[[
	海商战报上传协议请求
]]
function QMaritime:requestUploadMaritimeReplay(replayId, content, replayInfo, success, fail, status)
	local fightReportUploadRequest = {arenaFightReportId = replayId, fightReportData = content, fightersData = replayInfo}
    local request = {api = "MARITIME_FIGHT_REPORT_UPLOAD", fightReportUploadRequest = fightReportUploadRequest}
    app:getClient():requestPackageHandler("MARITIME_FIGHT_REPORT_UPLOAD", request, function (response)
        self:responseUploadMaritimeReplay(response, success, nil, true)
    end, function (response)
        self:responseUploadMaritimeReplay(response, nil, fail)
    end)
end

--[[
	海商战报上传协议返回
]]
function QMaritime:responseUploadMaritimeReplay(data, success, fail, succeeded)
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	海商战报下载协议请求
]]
function QMaritime:requestDownloadMaritimeReplay(replayId, success, fail, status)
	local maritimeGetFightReportDataRequest = {fightReportId = replayId}
    local request = {api = "MARITIME_GET_FIGHT_REPORT_DATA", maritimeGetFightReportDataRequest = maritimeGetFightReportDataRequest}
    app:getClient():requestPackageHandler("MARITIME_GET_FIGHT_REPORT_DATA", request, function (response)
        self:responseDownloadMaritimeReplay(response, success, nil, true)
    end, function (response)
        self:responseDownloadMaritimeReplay(response, nil, fail)
    end)
end

--[[
	海商战报下载协议返回
]]
function QMaritime:responseDownloadMaritimeReplay(data, success, fail, succeeded)
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	请求海商战报信息协议请求
]]
function QMaritime:requestGetMaritimeReplayInfo(replayId, success, fail, status)
	local maritimeGetFightReportDataRequest = {fightReportId = replayId}
    local request = {api = "MARITIME_GET_FIGHT_REPORT_DATA", maritimeGetFightReportDataRequest = maritimeGetFightReportDataRequest}
    app:getClient():requestPackageHandler("MARITIME_GET_FIGHT_REPORT_DATA", request, function (response)
        self:responseDownloadMaritimeReplay(response, success, nil, true)
    end, function (response)
        self:responseDownloadMaritimeReplay(response, nil, fail)
    end)
end

--[[
	请求海商战报信息协议返回
]]
function QMaritime:responseDownloadMaritimeReplay(data, success, fail, succeeded)
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	请求海商战报列表协议请求
]]
function QMaritime:requestGetMaritimeReplayList(replayType, success, fail, status)
	local maritimeGetFightReportListRequest = {type = replayType}
    local request = {api = "MARITIME_GET_FIGHT_REPORT_LIST", maritimeGetFightReportListRequest = maritimeGetFightReportListRequest}
    app:getClient():requestPackageHandler("MARITIME_GET_FIGHT_REPORT_LIST", request, function (response)
        self:responseGetMaritimeReplayList(response, success, nil, true)
    end, function (response)
        self:responseGetMaritimeReplayList(response, nil, fail)
    end)
end

--[[
	请求海商战报列表协议返回
]]
function QMaritime:responseGetMaritimeReplayList(data, success, fail, succeeded)
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	运镖奖励列表协议请求
	repeated int shipInfoIds
]]
function QMaritime:requestGetMaritimeRewardList(success, fail, status)
    local request = {api = "MARITIME_SHIP_REWARD_LIST"}
    app:getClient():requestPackageHandler("MARITIME_SHIP_REWARD_LIST", request, function (response)
        self:responseGetMaritimeRewardList(response, success, nil, true)
    end, function (response)
        self:responseGetMaritimeRewardList(response, nil, fail)
    end)
end

--[[
	运镖奖励列表协议返回
]]
function QMaritime:responseGetMaritimeRewardList(data, success, fail, succeeded)
	if data.maritimeShipRewardListResponse then
		self:setMaritimeInfo(data.maritimeShipRewardListResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	领取运镖奖励协议请求
	repeated int shipInfoIds
]]
function QMaritime:requestGetMaritimeReward(shipInfoIds, success, fail, status)
	local maritimeGetShipRewardRequest = {shipInfoIds = shipInfoIds}
    local request = {api = "MARITIME_GET_SHIP_REWARD", maritimeGetShipRewardRequest = maritimeGetShipRewardRequest}
    app:getClient():requestPackageHandler("MARITIME_GET_SHIP_REWARD", request, function (response)
        self:responseGetMaritimeReward(response, success, nil, true)
    end, function (response)
        self:responseGetMaritimeReward(response, nil, fail)
    end)
end

--[[
	领取运镖奖励协议返回
]]
function QMaritime:responseGetMaritimeReward(data, success, fail, succeeded)
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	换一批船协议请求
]]
function QMaritime:requestGetOtherShip(success, fail, status)
    local request = {api = "MARITIME_SHIP_CHANGE"}
    app:getClient():requestPackageHandler("MARITIME_SHIP_CHANGE", request, function (response)
        self:responseGetOtherShip(response, success, nil, true)
    end, function (response)
        self:responseGetOtherShip(response, nil, fail)
    end)
end

--[[
	请求海商战报信息协议返回
]]
function QMaritime:responseGetOtherShip(data, success, fail, succeeded)
	if data.maritimeShipChangeResponse then
		if data.maritimeShipChangeResponse.shipInfos == nil then
			data.maritimeShipChangeResponse.shipInfos = {}
		end
		self:setMaritimeInfo(data.maritimeShipChangeResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	旧船结算后拉新船协议请求
	int count  要拉新船的数量
]]
function QMaritime:requestGetNewShip(count, success, fail, status)
	local maritimeGetNewShipRequest = {count = count}
    local request = {api = "MARITIME_GET_NEW_SHIP", maritimeGetNewShipRequest = maritimeGetNewShipRequest}
    app:getClient():requestPackageHandler("MARITIME_GET_NEW_SHIP", request, function (response)
        self:responseGetNewShip(response, success, nil, true)
    end, function (response)
        self:responseGetNewShip(response, nil, fail)
    end)
end

--[[
	旧船结算后拉新船协议返回
]]
function QMaritime:responseGetNewShip(data, success, fail, succeeded)
	if data.maritimeGetNewShipResponse and data.maritimeGetNewShipResponse.shipInfos then
		self:addNewShip(data.maritimeGetNewShipResponse.shipInfos)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	船只加速协议请求
]]
function QMaritime:requestMaritimeShipQuick(success, fail, status)
    local request = {api = "MARITIME_SHIP_QUICK"}
    app:getClient():requestPackageHandler("MARITIME_SHIP_QUICK", request, function (response)
        self:responseMaritimeShipQuick(response, success, nil, true)
    end, function (response)
        self:responseMaritimeShipQuick(response, nil, fail)
    end)
end

--[[
	船只加速协议返回
]]
function QMaritime:responseMaritimeShipQuick(data, success, fail, succeeded)
	if data.maritimeShipQuickResponse then
		self:setMaritimeInfo(data.maritimeShipQuickResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	开始商运协议请求
	string escortUserId 护送者的userId
]]
function QMaritime:requestMaritimeShipStart(escortUserId, success, fail, status)
	local maritimeShipStartRequest = {escortUserId = escortUserId}
    local request = {api = "MARITIME_SHIP_START", maritimeShipStartRequest = maritimeShipStartRequest}
    app:getClient():requestPackageHandler("MARITIME_SHIP_START", request, function (response)
        self:responseMaritimeShipStart(response, success, nil, true)
    end, function (response)
        self:responseMaritimeShipStart(response, nil, fail)
    end)
end

--[[
	开始商运协议返回
]]
function QMaritime:responseMaritimeShipStart(data, success, fail, succeeded)

	app.taskEvent:updateTaskEventProgress(app.taskEvent.MARITIME_SHIP_START_EVENT, 1)
	
	if data.maritimeShipStartResponse then
		self:setMaritimeInfo(data.maritimeShipStartResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	购买商运次数协议请求
]]
function QMaritime:requestBuyMaritimeShipNum(success, fail, status)
    local request = {api = "MARITIME_SHIP_BUY_CNT"}
    app:getClient():requestPackageHandler("MARITIME_SHIP_BUY_CNT", request, function (response)
        self:responseBuyMaritimeShipNum(response, success, nil, true)
    end, function (response)
        self:responseBuyMaritimeShipNum(response, nil, fail)
    end)
end

--[[
	购买商运次数协议返回
]]
function QMaritime:responseBuyMaritimeShipNum(data, success, fail, succeeded)
	if data.maritimeShipBuyCntResponse then
		self:setMaritimeInfo(data.maritimeShipBuyCntResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	查看船只信息协议请求
	string userId 船只的userId
]]
function QMaritime:requestGetMaritimeShipInfo(userId, success, fail, status)
	local maritimeQueryShipRequest = {userId = userId}
    local request = {api = "MARITIME_QUERY_SHIP", maritimeQueryShipRequest = maritimeQueryShipRequest}
    app:getClient():requestPackageHandler("MARITIME_QUERY_SHIP", request, function (response)
        self:responseGetMaritimeShipInfo(response, success, nil, true)
    end, function (response)
        self:responseGetMaritimeShipInfo(response, nil, fail)
    end)
end

--[[
	购买商运次数协议返回
]]
function QMaritime:responseGetMaritimeShipInfo(data, success, fail, succeeded)
	if data.maritimeQueryShipResponse then
		self:addNewShip(data.maritimeQueryShipResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	查询玩家信息协议请求
	string userId 船只的userId
]]
function QMaritime:requestQueryMaritimeShipInfo(userId, success, fail, status)
	local maritimeQueryFighterRequest = {userId = userId}
    local request = {api = "MARITIME_QUERY_FIGHTER", maritimeQueryFighterRequest = maritimeQueryFighterRequest}
    app:getClient():requestPackageHandler("MARITIME_QUERY_FIGHTER", request, function (response)
        self:responseQueryMaritimeShipInfo(response, success, nil, true)
    end, function (response)
        self:responseQueryMaritimeShipInfo(response, nil, fail)
    end)
end

--[[
	查询玩家信息协议返回
]]
function QMaritime:responseQueryMaritimeShipInfo(data, success, fail, succeeded)
	--data.maritimeQueryShipResponse 
	self:responseHandler(data, success, fail, succeeded)
end


return QMaritime