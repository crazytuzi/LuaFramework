-- @Author: liaoxianbo
-- @Date:   2020-04-08 14:44:13
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-23 17:43:21

local QBaseModel = import("...models.QBaseModel")
local QSoulTower = class("QSoulTower", QBaseModel)
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")

QSoulTower.STATE_UNLOCK = 0 --未解锁
QSoulTower.STATE_LOCK_NOPASS = 1 --解锁未通关
QSoulTower.STATE_PASSED = 2	--已通关

QSoulTower.EVENT_UPDATE_READTIPS = "EVENT_UPDATE_READTIPS"

function QSoulTower:ctor(options)
    QSoulTower.super.ctor(self)
end

function QSoulTower:didappear()
	self:initData()
end

function QSoulTower:disappear()
	self:initData()
end

function QSoulTower:initData()
	self._soultowerDungen = {}	--关卡信息
	self._getPassAwardId = {}	--已领取的通关奖励

	self._passAwardsInfoList = {} -- 通关奖励
	self._soultowerRankAwards = {} --排行奖励

	self._soulTowerRoundEndAwards = {}

	self._soulTowerMyInfo = {}
	self._soulTowerRoundInfo = {}

end

function QSoulTower:loginEnd()
	if self:soulTowerIsOpen() then
		self:getSoulTowerMyInfoRequset()
	end
end

function QSoulTower:soulTowerIsOpen(isTip)
    if app.unlock:checkLock("UNLOCK_SOUL_TOWER", isTip) then
        return true
    end

    return false
end

function QSoulTower:checkScore( )
	local myRank = self:getMySeverRank()
	local awardInfo = self:getSoulTowerRoundEndAward()

	if myRank <= 0 or q.isEmpty(awardInfo) == false then
		return true
	else
		return false
	end
end

function QSoulTower:checkRedTip()
	if not self:soulTowerIsOpen(false) then
		return false
	end
	local endTime = self._soulTowerRoundInfo and self._soulTowerRoundInfo.endAt or 0
	local lastTime = endTime/1000 - q.serverTime()
	if lastTime <= 0 then
		return false
	end
    -- if remote.stores:checkFuncShopRedTips(SHOP_ID.blackRockShop) then
    --     return true
    -- end

    if self:checkPassAwardTips() then
    	return true
    end
    local wave = self._soulTowerMyInfo and self._soulTowerMyInfo.wave or 0
    if wave <= 0 then
    	return true
    end
	return false
end

function QSoulTower:checkPassAwardTips()
	local receivedChapterIds = self:_anaylsisReceivedList()
	local passAwardsList = remote.soultower:getPassAwardsList()
	local tbl = {}
	local isReceivedTbl = {} --已领取
	local starRewardTbl = {} --可领取

	for _, chapter in pairs(passAwardsList) do
		local maxfloor,maxWave = self:getHistoryPassFloorWave(true)
		if maxfloor > chapter.soul_tower_floor or (maxfloor == chapter.soul_tower_floor and maxWave >= chapter.soul_tower_wave) then
			tbl[chapter.id] = {["id"] = chapter.id, ["floor"] = chapter.soul_tower_floor, ["lucky_draw"] = chapter.pass_reward, ["wave"] = chapter.soul_tower_wave}
		end
	end
	for _, value in pairs(tbl) do
		if receivedChapterIds and receivedChapterIds[value.id]  then
			table.insert(isReceivedTbl, value)
		else
			table.insert(starRewardTbl, value)
		end
	end
	if q.isEmpty(starRewardTbl) == false then
		return true
	end

	return false
end

--根据当前状态打开指定的dialog
function QSoulTower:openDialog(isTutoria)
    if self:soulTowerIsOpen(true) == false then
        return false
    end
    self:getSoulTowerMainInfoRequest(function()
    	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTowerMain"})
		if isTutoria then
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_SOULTOWER_CLOSE})
		end    	
    end,function()
    	if isTutoria then
    		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_SOULTOWER_QIANGZHI_CLOSE})
    	end
    end)
    
end
-- 1全服
function QSoulTower:getMySeverRank()
	return self._soulTowerMyInfo and self._soulTowerMyInfo.rank or 0
end

function QSoulTower:getMySoulTowerInfo( )
	return self._soulTowerMyInfo
end

function QSoulTower:setBattleFloor(floor)
	self._battleFloor = floor
end

function QSoulTower:getBattleFloor( )
	return self._battleFloor
end

function QSoulTower:setBattleDungenID(dungeonId)
	self._battleFloorDungenId = dungeonId
end

function QSoulTower:getBattleDungenID( )
	return self._battleFloorDungenId
end

function QSoulTower:getHistoryPassFloorWave(isRank)
	if q.isEmpty(self._soulTowerMyInfo) then
		return 1,0
	end
	local passFloor = self._soulTowerMyInfo.dungeonId
	if not isRank and (passFloor == nil or passFloor == 0) then -- 一层未打，后端默认0，前端默认1
		passFloor = 1
	end
	return passFloor, self._soulTowerMyInfo.wave or 0
end

function QSoulTower:getHistoryLockFloorWave()
	local dungenFloor = self:getAllSoulTowerFloorsByRound()
	local historyFloor = self._soulTowerMyInfo.dungeonId
	if historyFloor == nil or historyFloor == 0 then -- 一层未打，后端默认0，前端默认1
		historyFloor = 1
	end
	local historyWave  = self._soulTowerMyInfo.wave or 0
	local floorConfig = self:getFloorInfoByFloor(historyFloor) or {}
	local lockNewFloor = false
	local maxDungen = 1
	if q.isEmpty(floorConfig) == false then
		maxDungen = floorConfig[1].dungeon
	end
	for _, floorInfo in pairs(floorConfig) do
		maxDungen = math.max(maxDungen,floorInfo.dungeon)
	end

	if historyWave >= maxDungen and historyFloor < #dungenFloor then
		historyFloor = historyFloor +  1
		historyWave = 0
		lockNewFloor = true
	elseif historyFloor >= #dungenFloor then
		historyFloor = #dungenFloor
	end

	return lockNewFloor,historyFloor,historyWave
end

function QSoulTower:getMaxFloor()
	local dungenFloor = self:getAllSoulTowerFloorsByRound()
	return #dungenFloor
end

function QSoulTower:getMaxFloorDungenNum()
	local historyFloor = self._soulTowerMyInfo.dungeonId
	if historyFloor == nil or historyFloor == 0 then -- 一层未打，后端默认0，前端默认1
		historyFloor = 1
	end
	local floorConfig = self:getFloorInfoByFloor(historyFloor) or {}
	local maxDungen = 1
	if q.isEmpty(floorConfig) == false then
		maxDungen = floorConfig[1].dungeon
	end
	for _, floorInfo in pairs(floorConfig) do
		maxDungen = math.max(maxDungen,floorInfo.dungeon)
	end

	return maxDungen
end

function QSoulTower:getSoultowerRankAwards()
	local level = remote.user.level
	self._soultowerRankAwards = {}
	local allRankAwards = db:getStaticByName("soul_tower_rank")
	for _,v in pairs(allRankAwards) do
		if v.level_min <= level and v.level_max >= level then
			table.insert(self._soultowerRankAwards,v)
		end
	end
	return self._soultowerRankAwards
end

function QSoulTower:getMySoultowerRankAward(myRank)
	local data = self:getSoultowerRankAwards()
	local rank = myRank

    table.sort( data, function(a, b) 
    	return a.rank < b.rank 
    end )

    local tbl = {}
    for i = 1, #data do
        if ( data[i-1] ~= nil and rank > data[i-1].rank and rank <= data[i].rank ) 
            or data[i].rank == rank then
            tbl = data[i]
        end
    end

	return tbl
end

--获取通关奖励
function QSoulTower:getPassAwardsList()
	if q.isEmpty(self._passAwardsInfoList) then
		local awardsConfig = db:getStaticByName("soul_tower_reward")
		for _,awards in pairs(awardsConfig) do
			if awards.pass_reward then
				table.insert(self._passAwardsInfoList,awards)
			end
		end
		table.sort( self._passAwardsInfoList, function( a,b )
			return tonumber(a.id) < tonumber(b.id)
		end )		
	end

	return self._passAwardsInfoList
end
--
function QSoulTower:getAwardsByfloorWave(floor,wave)
	local awardTbl = {}
	local awardsConfig = db:getStaticByName("soul_tower_reward")
	for _,awards in pairs(awardsConfig) do
		if awards.soul_tower_floor == floor and wave == awards.soul_tower_wave then
			awardTbl.floor_reward = awards.floor_reward
			awardTbl.wave_reward = awards.wave_reward
		end
	end

	return awardTbl
end

-- 根据层数和wave获取升灵台的战力压制
function QSoulTower:getSoulTowerForce(floor, wave)
	local soultowerforce = db:getStaticByName("soul_tower_force")
    for _, v in pairs(soultowerforce) do
        if v.soul_tower_floor == floor and v.soul_tower_wave == wave then
            return v
        end
    end

    return nil
end

function QSoulTower:getMonsterInfoByWave(wave)
	if wave == nil then return nil end
	local allWaveMonster = db:getStaticByName("soul_tower_monster_wave")
	for _,v in pairs(allWaveMonster) do
		if v.dungeon_config_id == wave then
			return v
		end
	end

	return nil
end

function QSoulTower:getAllSoulTowerFloorsByRound()
	if q.isEmpty(self._soultowerDungen) then
		local floors = db:getStaticByName("soul_tower_floor")
		local allfloorNum = table.nums(floors)
		local round = self._soulTowerRoundInfo and self._soulTowerRoundInfo.roundNo or 1
		if round > allfloorNum and allfloorNum > 0 then
			round = (round % allfloorNum) == 0 and allfloorNum or round % allfloorNum 
		end
		for _,v in pairs(floors[tostring(round)] or {}) do
			if v.round == round  then
				if not self._soultowerDungen[v.floor] then
					self._soultowerDungen[v.floor] = {}
				end
				table.insert(self._soultowerDungen[v.floor],v)
			end
		end
	end

	return self._soultowerDungen
end

function QSoulTower:getFloorInfoByFloor(floor)
	local allFloorConfig = self:getAllSoulTowerFloorsByRound()
	return allFloorConfig[floor] or nil
end

---------------------------------------------------------------------------------
function QSoulTower:showFloor(ccbNode,floors,posY,isUnlock)
	if ccbNode and floors then
		ccbNode:removeAllChildren()
		local nodes = {}
	    local floorNum = tostring(math.ceil(floors))
		local dipaths = "ui/update_soultower/zi_slt_di.png"
	    local ziDi = CCSprite:create(dipaths)
	    ziDi:setPosition(-95, posY)
	    if isUnlock then
	    	ziDi:setColor(ccc3(76,76,76))
	    end
	    ccbNode:addChild(ziDi)
	    table.insert(nodes,ziDi)

	    local cengPath = "ui/update_soultower/zi_slt_ceng.png"
	    local ziceng = CCSprite:create(cengPath)
	    ccbNode:addChild(ziceng)
	    ziceng:setPosition(-51, posY)
	    if isUnlock then
	    	ziceng:setColor(ccc3(76,76,76))
	    end
	    local strLen = string.len(floorNum)
	    for i = 1, strLen, 1 do
	        local num = tonumber(string.sub(floorNum, i, i))
	        if num == 0 then num = 10 end
	        local paths = QResPath("soul_tower_large_num")
	        local spNum = CCSprite:create(paths[num])
	        ccbNode:addChild(spNum)
	        local width = spNum:getContentSize().width
	        spNum:setPosition(0, posY+5)
    	    if isUnlock then
		    	spNum:setColor(ccc3(76,76,76))
		    end
		    table.insert(nodes,spNum)
	    end	
	    table.insert(nodes,ziceng)
	    q.autoLayerNode(nodes,"x",-5) 
	end
end

--获取已领取的通关奖励
function QSoulTower:_anaylsisReceivedList()
	local receivedChapterIds = {}
	local rewardStr = self._soulTowerMyInfo and self._soulTowerMyInfo.dungeon_reward_info or ""
	local tbl = string.split(rewardStr,";")
	if not tbl or #tbl == 0 then return nil end

	for _, value in pairs(tbl) do
		if tonumber(value) then
			receivedChapterIds[tonumber(value)] = true
		end
	end
	return receivedChapterIds
end

-- /**
--  * 升灵台--个人信息
--  */
-- message SoulTowerMyInfo {
--     optional int32 dungeonId = 1;               //层数
--     optional int32 wave = 2;                    //波次
--     optional int64 passTime = 3;                 //通关时间 毫秒
--     optional string dungeon_reward_info = 4;    //已领取的通关奖励
-- }

-- /**
--  * 升灵台--轮次信息
--  */
-- message SoulTowerRoundInfo {
--     optional int32 roundNo = 1;                     //轮次id
--     optional int64 startAt = 2;                     //开始时间
--     optional int64 endAt = 3;                       //结束时间
-- }

-- /**
--  * 升灵台--轮次结算信息
--  */
-- message SoulTowerRoundEndRewardInfo {
--     optional int32 roundId = 1;     //轮次
--     optional int32 dungeonId = 2;   //层数
--     optional int32 wave = 3;        //波次
--     optional int64 passTime = 4;     //通关时间 毫秒
--     optional string reward = 5;     //奖励
-- }

function QSoulTower:setSoulTowerRoundEndAward(info)
	self._soulTowerRoundEndAwards = info
end

function QSoulTower:getSoulTowerRoundEndAward()
	return self._soulTowerRoundEndAwards
end

function QSoulTower:getSoulTowerMyRoundInfo()
	return self._soulTowerRoundInfo
end

---------------------------------------------------------------------------------

-- /**
--  * 升灵台--进入信息
--  */
-- message SoulTowerGetInfoResponse {
--     optional SoulTowerMyInfo myInfo = 1; //个人信息
--     optional SoulTowerRoundInfo roundInfo = 2; //轮次信息
--     optional SoulTowerRoundEndRewardInfo soulTowerRoundEndRewardInfo = 3; //轮次结算信息
-- }

-- /**
--  * 升灵台--战斗结束
--  */
-- message SoulTowerFightEndResponse {
--     optional SoulTowerMyInfo myInfo = 1; //个人信息
--     optional int64 fightReportId = 2; //战报ID
-- }

function QSoulTower:responseDataHandler(response,successFunc,failFunc)

	if response.soulTowerGetInfoResponse then
		self._soulTowerMyInfo = response.soulTowerGetInfoResponse.myInfo or {}
		self._soulTowerRoundInfo = response.soulTowerGetInfoResponse.roundInfo or {}
		self:setSoulTowerRoundEndAward(response.soulTowerGetInfoResponse.soulTowerRoundEndRewardInfo or {})	
	end

	if response.gfEndResponse and response.gfEndResponse.soulTowerFightEndResponse then
		self._soulTowerMyInfo = response.gfEndResponse.soulTowerFightEndResponse.myInfo or {}
	end

	self:dispatchEvent({name = QSoulTower.EVENT_UPDATE_READTIPS})

    if successFunc then 
        successFunc(response) 
        return
    end

    if failFunc then 
        failFunc(response)
    end
end

-- SOUL_TOWER_GET_MY_INFO 获取自己的信息
function QSoulTower:getSoulTowerMyInfoRequset(success,fail)
    local request = {api = "SOUL_TOWER_GET_MY_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end
-- SOUL_TOWER_GET_MAIN_INFO --主界面信息
function QSoulTower:getSoulTowerMainInfoRequest(success,fail)
    local request = {api = "SOUL_TOWER_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

function QSoulTower:soulTowerFightStartRequest(dungeonId,wave, battleFormation, success, fail, status)

    local soulTowerFightStartCheckRequest = {dungeonId = dungeonId,wave = wave}
    local gfStartRequest = {battleType = BattleTypeEnum.SOUL_TOWER, battleFormation = battleFormation, soulTowerFightStartCheckRequest = soulTowerFightStartCheckRequest,isQuick = false }
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}

    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, function(response)
    	 self:responseDataHandler(response, success, nil, true)
    end, function( response )
        self:responseDataHandler(response, nil, fail)
    end)
end

function QSoulTower:soulTowerFightEndRequest(dungenId,wave, battleKey,battleFormation, success, fail)   
    local soulTowerFightEndRequest = {dungeonId = dungenId,wave=wave}

    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.SOUL_TOWER, battleVerify = battleVerify,isQuick = false, isWin = nil, fightReportData  = fightReportData,
                                 soulTowerFightEndRequest = soulTowerFightEndRequest,battleFormation = battleFormation}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

--领取通关奖励
function QSoulTower:soulTowerGetAwardsRequest(id,success,fail)
	local soulTowerGetDungeonPassRewardRequest = {id = id}
    local request = {api = "SOUL_TOWER_GET_DUNGEON_PASS_REWARD",soulTowerGetDungeonPassRewardRequest = soulTowerGetDungeonPassRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

--领取结算奖励
function QSoulTower:soulTowerGetRoundAwardsRequest(round, success,fail )
	local soulTowerGetRoundEndRewardRequest = {roundId = round}
    local request = {api = "SOUL_TOWER_GET_ROUND_END_REWARD",soulTowerGetRoundEndRewardRequest = soulTowerGetRoundEndRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

--拉取通关记录
function QSoulTower:soulTowerGetReportRequest(floorId,wave,success,fail)
	local soulTowerGetReportRequest = {dungeonId = floorId,wave=wave}
    local request = {api = "SOUL_TOWER_GET_REPORTS",soulTowerGetReportRequest = soulTowerGetReportRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

return QSoulTower