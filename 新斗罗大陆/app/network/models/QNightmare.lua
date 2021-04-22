-- 噩梦副本数据类
-- Author: wkwang
-- Date: 2016-8-24
--
local QBaseModel = import("...models.QBaseModel")
local QNightmare = class("QNightmare",QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")

QNightmare.EVENT_UPDATE = "EVENT_UPDATE"
QNightmare.EVENT_BEST_PASS_UPDATE = "EVENT_BEST_PASS_UPDATE"

function QNightmare:ctor(options)
	QNightmare.super.ctor(self)
	self._nightmares = {}
    self._nightmareConfigs = {}
    self._unlockIds = {}
    self._bestPass = {}
    self._totalCount = 0
end

function QNightmare:didappear()
	QNightmare.super.didappear(self)
    self:initConfigs()
end

function QNightmare:disappear()
    -- body
end

function QNightmare:setBattleId(nightmareId)
    self._nightmareId = nightmareId
end

function QNightmare:getBattleId(nightmareId)
    return self._nightmareId
end

--初始化噩梦本配置信息
function QNightmare:initConfigs()
	self.config = QStaticDatabase:sharedDatabase():getMaps()
	local mapConfigs = {}
    self._nightmareConfigs = {}
    local nightmareArr = {}
	for _,value in pairs(self.config) do
		if tonumber(value.dungeon_type) == DUNGEON_TYPE.NIGHTMARE then
            value.int_instance_id = tonumber(value.int_instance_id)
            if self._nightmareConfigs[value.int_instance_id] == nil then 
                table.insert(nightmareArr, value.int_instance_id)
                self._nightmareConfigs[value.int_instance_id] = {configs = {}, isLock = true}
            end
            local tbl = self._nightmareConfigs[value.int_instance_id].configs
            table.insert(tbl, value)
            self._totalCount = self._totalCount + 1
		end
	end
    for _,value in pairs(self._nightmareConfigs) do
        table.sort(value.configs, function (a,b)
            return a.int_dungeon_id < b.int_dungeon_id
        end )
    end
    table.sort(nightmareArr, function (a,b)
        return a < b
    end)
    for index,nightmareId in ipairs(nightmareArr) do
        self._nightmareConfigs[nightmareId].index = index
    end
end

--根据章节ID获取章节信息
function QNightmare:getConfigByNightmareId(nightmareId)
    return self._nightmareConfigs[nightmareId]
end

--根据副本ID获取副本信息
function QNightmare:getConfigByDungeonId(dungeonId)
    for _,value in pairs(self._nightmareConfigs) do
        for _,config in ipairs(value.configs) do
            if config.int_dungeon_id == dungeonId then
                return value
            end
        end
    end
end

--添加徽章属性到战队中
function QNightmare:addPropToTeam(isDispatch)
    if isDispatch == nil then isDispatch = true end
    local config = QStaticDatabase:sharedDatabase():getBadgeByCount((remote.user.nightmareDungeonPassCount or 0))
    if config ~= nil then
        local prop = {}
        for name,filed in pairs(QActorProp._field) do
            if config[name] ~= nil then
                prop[name] = config[name]
            end
        end
        remote.herosUtil:addExtendsProp( prop, "nightmareProp", isDispatch)
    end
end

--删除徽章属性到战队中
function QNightmare:removePropToTeam()
    remote.herosUtil:removeExtendsProp("nightmareProp", true)
end

--根据普通副本的ID获取已经解锁的噩梦章节Id
function QNightmare:getNightmareIdByNormalId(dungeonId)
    return self._unlockIds[dungeonId]
end

--获取可显示在界面的噩梦本列表
function QNightmare:getNightmareMaps()
    local tbl = {}
    local count = 0
    for _,value in pairs(self._nightmareConfigs) do
        if value.isLock == false then
            count = count + 1
        end
        table.insert(tbl, value.configs[1].int_instance_id)
    end
    table.sort(tbl, function (a,b)
        return a < b
    end)
    return tbl,count
end

--获取所有已经解锁的噩梦本
function QNightmare:getAllUnlockNightmare(isFilterPass)
    local tbl = {}
    for _,value in pairs(self._unlockIds) do
        --过滤掉通关的副本
        local progress,totalCount = self:getProgressByNightmareId(value)
        if progress < totalCount or isFilterPass == false then
            table.insert(tbl, value)
        end
    end
    table.sort(tbl, function (a,b)
        return a < b
    end)
    return tbl
end

--根据章节ID获取章节是否通关
function QNightmare:getProgressByNightmareId(nightmareId)
    local _nightmareConfigs = self:getConfigByNightmareId(nightmareId).configs
    local nightmareInfo = self:getNightmareByNightmareId(nightmareId)
    if nightmareInfo == nil or nightmareInfo.passProgress == nil or nightmareInfo.passProgress == 0 then
        return 0, #_nightmareConfigs
    end
    for index,config in ipairs(_nightmareConfigs) do
        if config.int_dungeon_id == nightmareInfo.passProgress then
            return index, #_nightmareConfigs
        end
    end
end

--更新副本信息
--查看是否有解锁的信息
function QNightmare:updateInstanceInfo()
    for _,value in pairs(self._nightmareConfigs) do
        if value.isLock == true then
            if #value.configs > 0 and value.configs[1].unlock_dungeon_id ~= nil then
                if remote.instance:dungeonLastPassAt(value.configs[1].unlock_dungeon_id) > 0 then
                    value.isLock = false
                    self._unlockIds[value.configs[1].unlock_dungeon_id] = value.configs[1].int_instance_id
                end
            end
        end
    end
end

--登陆结束后准备做的事情
function QNightmare:loginEnd( ... )
	self:requestNightmare() --暂时不开启
end

--获取总的通关进度
function QNightmare:getTotalCount()
    return self._totalCount
end

--根据指定的章节ID获取关卡进度
function QNightmare:getNightmareByNightmareId(nightmareId)
	return self._nightmares[nightmareId]
end

--更新本地的噩梦本进度
function QNightmare:setNightmareDungeonInfo(dungeons)
	for _,value in ipairs(dungeons) do
		self._nightmares[value.chapterId] = value
	end
	self:dispatchEvent({name = QNightmare.EVENT_UPDATE})
end

--设置某章节的最佳通关
function QNightmare:setBestPass(passInfo)
    if passInfo.dungeonInfo ~= nil then
        for _,value in ipairs(passInfo.dungeonInfo) do
            self._bestPass[value.dungeonId] = value.force
        end
        self:dispatchEvent({name = QNightmare.EVENT_BEST_PASS_UPDATE})
    end
end

function QNightmare:getBestPass(dungeonId)
    return self._bestPass[dungeonId] 
end

--设置战斗结束宝箱内容
function QNightmare:setChestResult(chestResult)
    self._chestResult = chestResult
end

--获取战斗结束宝箱内容
function QNightmare:getChestResult()
    return self._chestResult
end

--获取是否显示小红点
function QNightmare:getDungeonRedPoint()
    if ENABLE_NIGHTMARE == false then return false end
    
    return app.unlock:getUnlockNightmare() and app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.NIGHTMARE)
end

--获取是否显示小红点
function QNightmare:setDungeonClick()
    return app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.NIGHTMARE)
end

---------------------------------------------请求后端数据---------------------------------------------

        -- NIGHTMARE_DUNGEON_GET_CHAPTER_INFO          = 7201;                     // 获取玩家的噩梦副本章节信息 无参数
        -- NIGHTMARE_DUNGEON_FIGHT_START               = 7202;                     // 噩梦副本战斗开始  参考参数：NightmareFightStartRequest
        -- NIGHTMARE_DUNGEON_FIGHT_END                 = 7203;                     // 噩梦副本战斗结束  参考参数：NightmareFightEndRequest
        -- NIGHTMARE_DUNGEON_GET_PASS_HISTORY          = 7204;                     // 噩梦副本单关最佳通关以及首杀信息拉取 参考参数：NightmarePassHistoryRequest


    -- optional NightmareDungeonFightStartResponse nightmareDungeonFightStartResponse = 401;
    -- optional NightmareDungeonFightEndResponse nightmareDungeonFightEndResponse = 402;
    -- optional NightmareDungeonPassHistoryResponse nightmareDungeonPassHistoryResponse = 403;
    -- repeated NightmareDungeonChapterInfo nightmareDungeonChapterInfo = 404;

--请求获取噩梦本数据
function QNightmare:requestNightmare(success, fail)
    local request = {api = "NIGHTMARE_DUNGEON_GET_CHAPTER_INFO"}
    app:getClient():requestPackageHandler("NIGHTMARE_DUNGEON_GET_CHAPTER_INFO", request, function (data)
    	if data.nightmareDungeonChapterInfo ~= nil then
    		self:setNightmareDungeonInfo(data.nightmareDungeonChapterInfo)
    	end
        if success ~= nil then
            success(data)
        end
    end, fail)
end

--请求获取噩梦指定关卡的最佳通关信息和首通信息
function QNightmare:nightmarePassHistoryRequest(dungeonId, battleFormation, success, fail)
	local nightmarePassHistoryRequest = {dungeonId = dungeonId}
    local gfStartRequest = {battleType = BattleTypeEnum.DUNGEON_NIGHTMARE, battleFormation = battleFormation, nightmarePassHistoryRequest = nightmarePassHistoryRequest}
    local request = {api = "NIGHTMARE_DUNGEON_GET_PASS_HISTORY", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("NIGHTMARE_DUNGEON_GET_PASS_HISTORY", request, function (data)
        if success ~= nil then
            success(data)
        end
    end, fail)
end

--请求噩梦本战斗开始
function QNightmare:nightmareFightStartRequest(dungeonId, battleFormation, success, fail)
	local nightmareFightStartRequest = {dungeonId = dungeonId, battleFormation = battleFormation}
    local gfStartRequest = {battleType = BattleTypeEnum.DUNGEON_NIGHTMARE, battleFormation = battleFormation, nightmareFightStartRequest = nightmareFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, function (data)
        if success ~= nil then
            success(data)
        end
    end, fail)
end

--请求噩梦本战斗结束
function QNightmare:nightmareFightEndRequest(dungeonId, battleVerify, isWin, success, fail)
	local nightmareFightEndRequest = {dungeonId = dungeonId}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    nightmareFightEndRequest.battleVerify = q.battleVerifyHandler(battleVerify)

    local gfEndRequest = {battleType = BattleTypeEnum.DUNGEON_NIGHTMARE,battleVerify = nightmareFightEndRequest.battleVerify, isQuick = false, isWin = isWin
                                ,fightReportData = fightReportData, nightmareFightEndRequest = nightmareFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (data)
        if data.gfEndResponse ~= nil and data.gfEndResponse.nightmareDungeonFightEndResponse.nightmareDungeonChapterInfo ~= nil then
            self:setNightmareDungeonInfo({data.gfEndResponse.nightmareDungeonFightEndResponse.nightmareDungeonChapterInfo})
        end
        if success ~= nil then
            success(data)
        end
    end, fail)
end

--请求噩梦本所有关卡最佳通关信息
function QNightmare:nightmareGetBestPassForceRequest(chapterId, success, fail)
    local nightmareGetBestPassForceRequest = {chapterId = chapterId}
    local request = {api = "NIGHTMARE_DUNGEON_GET_CHAPTER_BEST_PASS_FORCE", nightmareGetBestPassForceRequest = nightmareGetBestPassForceRequest}
    app:getClient():requestPackageHandler("NIGHTMARE_DUNGEON_GET_CHAPTER_BEST_PASS_FORCE", request, function (data)
        if  data.nightmareDungeonGetChapterBestPassForceResponse ~= nil then
            self:setBestPass(data.nightmareDungeonGetChapterBestPassForceResponse)
        end
        if success ~= nil then
            success(data)
        end
    end, fail)
end

return QNightmare