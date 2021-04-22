-- @Author: xurui
-- @Date:   2018-08-07 11:46:36
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-27 10:34:45
local QBaseModel = import("...models.QBaseModel")
local QMetalCity = class("QMetalCity", QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")

QMetalCity.UPDATE_METALCITY_FIGHT_COUNT = "UPDATE_METALCITY_FIGHT_COUNT"

function QMetalCity:ctor(options)
	QMetalCity.super.ctor(self, options)

    self._metalCityConfigDict = {}              --金属之城关卡配置
    self._mapConfigDict = {}                    --金属之城副本配置

    self._metalCityInfoDict = {}                    --金属之城晚间信息
    self._metalCityReportList = {}                  --金属之城战报列表奖励
    self._metalCityRewardsStr = nil                 --金属之城奖励
    self._currentPassMetalNum = nil                 --金属之城当前通关的层数
    self._bossSkills = {}                           --金属之城所有boss机关技能
end

function QMetalCity:didappear()
    
end

function QMetalCity:disappear()

end

function QMetalCity:loginEnd()
    if self:checkMetalCityUnlock() then
        self:requestMetalCityMyInfo()
    end    
end

function QMetalCity:checkMetalCityUnlock(isTip, tips)
    if app.unlock:checkLock("UNLOCK_METALCITY", isTip, tips) == false then
       	return false
    end

    return true
end


function QMetalCity:openDialog(options)
	if self:checkMetalCityUnlock(true) then
        
        self:requestMetalCityMyInfo(function ( ... )
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMetalCity", options = options})
        end)
	end
end

function QMetalCity:getMetalCityConfig()
    if q.isEmpty(self._metalCityConfigDict) then
        self._metalCityConfigDict = {}
        local config = QStaticDatabase:sharedDatabase():getMetalCityMapConfig()

        for _, value in pairs(config) do
            self._metalCityConfigDict[tostring(value.num)] = value
        end
    end

    return self._metalCityConfigDict
end

function QMetalCity:getMetalCityMapConfig()
    if q.isEmpty(self._mapConfigDict) then
        self._mapConfigDict = {}
        local maps = QStaticDatabase:sharedDatabase():getMaps()
        for _, value in pairs(maps) do
            if value.dungeon_type == DUNGEON_TYPE.METALCITY then
                self._mapConfigDict[tostring(value.id)] = value
            end
        end
    end

    return self._mapConfigDict
end

function QMetalCity:getMetalCityConfigByChapter(chapter)
    if chapter == nil then return {} end

    local chapterInfo = {}
    local metalConfig = self:getMetalCityConfig()
    for _, value in pairs(metalConfig) do
        if value.metalcity_chapter == chapter then
            chapterInfo[#chapterInfo+1] = value
        end
    end

    return chapterInfo
end

function QMetalCity:getMetalCityChapterMaxNum()
    local lastChapter = 0
    local metalConfig = self:getMetalCityConfig()
    for _, value in pairs(metalConfig) do
        if lastChapter < value.metalcity_chapter then
            lastChapter = value.metalcity_chapter
        end
    end

    return lastChapter
end

function QMetalCity:getMetalCityConfigByFloor(floor)
    if floor == nil then return {} end

    local metalConfig = self:getMetalCityConfig()
    return metalConfig[tostring(floor)] or {}
end

function QMetalCity:getMetalCityMapConfigById(id)
    if id == nil then return {} end

    local metalMapConfig = self:getMetalCityMapConfig()
    return metalMapConfig[tostring(id)] or {}
end

function QMetalCity:getMetalCityFightCount()
    local totalVIPNum = QVIPUtil:getCountByWordField("metalcity_tims2", QVIPUtil:getMaxLevel())
    local vipFreeNum = QVIPUtil:getCountByWordField("metalcity_tims1")
    local buyCount = self._metalCityInfoDict.buyCount or 0
    local fightCount = self._metalCityInfoDict.fightCount or 0

    local currentNum = vipFreeNum + buyCount - fightCount
    local canBuyNum = totalVIPNum - buyCount

    return currentNum, canBuyNum
end

--主界面小红点
function QMetalCity:checMainPageRedTip(  )
    -- body
    if self:checkMetalCityShopRedTips() then
        return true
    end

    return false
end

--商店红点
function QMetalCity:checkMetalCityShopRedTips(  )
    -- body
    if remote.exchangeShop:checkExchangeShopRedTipsById(SHOP_ID.metalCityShop) then
        return true
    end
    return false
end

--获取所有的Boss机关技能
function QMetalCity:getAllBossSkills()
    if q.isEmpty(self._bossSkills) then
        local metalConfig = self:getMetalCityConfig()
        for _, value in pairs(metalConfig) do
            if value.jiguan_1 then
                self._bossSkills[value.jiguan_1] = value.jiguan_1
            end
            if value.jiguan_2 then
                self._bossSkills[value.jiguan_2] = value.jiguan_2
            end
        end
    end

    return self._bossSkills
end

--获取当前通关章节
function QMetalCity:getCurrentChapterNum()
    local curentFloorInfo = self:getMetalCityConfigByFloor((self._metalCityInfoDict.metalNum or 1)+1)

    if q.isEmpty(curentFloorInfo) then
        curentFloorInfo = self:getMetalCityConfigByFloor((self._metalCityInfoDict.metalNum or 1))
    end

    return curentFloorInfo.metalcity_chapter, (curentFloorInfo.metalcity_floor or 1) - 1
end

function QMetalCity:setCurrentPassMetalNum(metalNum)
    self._currentPassMetalNum = metalNum
end

function QMetalCity:getCurrentPassMetalNum()
    return self._currentPassMetalNum
end

--------------------------- event handler ----------------------------

function QMetalCity:updateMetalCityBuyFightCount()
    self:dispatchEvent({name = QMetalCity.UPDATE_METALCITY_FIGHT_COUNT})
end

--------------------------- server info ------------------------------

--[[
message UserMetalCity{
    optional string userId    = 1;
    optional int32 metalNum   = 2;//关卡层数
    optional int32 fightCount = 3;//战斗次数
    optional int32 buyCount   = 4;//购买次数
}
]]
function QMetalCity:setMetalCityMyInfo(info)
    for key, value in pairs(info) do
        self._metalCityInfoDict[key] = value
    end
end

function QMetalCity:getMetalCityMyInfo()
    return self._metalCityInfoDict
end

--[[
message MetalCityBattleReport{
    optional int32   metalNum  = 1;//关卡层数
    optional Fighter fighter   = 2;//战斗者
    optional int64 reportId    = 3;//战报ID
}
]]
function QMetalCity:setMetalCityReports(reports)
    self._metalCityReportList = reports
end

function QMetalCity:getMetalCityReports()
    return self._metalCityReportList
end

function QMetalCity:setMetalCityRewards(rewards)
    self._metalCityRewardsStr = rewards
end

function QMetalCity:getMetalCityRewards()
    return self._metalCityRewardsStr
end

function QMetalCity:setMetalCityRewardRatio(ratio)
    self._metalCityRewardRatioNum = ratio
end

function QMetalCity:getMetalCityRewardRatio()
    return self._metalCityRewardRatioNum or 1
end

----------------------------- 协议 -----------------------------
--[[
message MetalCityResponse {
    optional UserMetalCity userMetalCity        = 1;
    repeated MetalCityBattleReport reports      = 2;
    optional string rewards                     = 3;
}
]]
function QMetalCity:updateMetalServerInfo(response)
    if response.userMetalCity then
        self:setMetalCityMyInfo(response.userMetalCity)
    end

    if response.reports then
        self:setMetalCityReports(response.reports)
    end

    if response.rewards then
        self:setMetalCityRewards(response.rewards)
    end
end

--[[
    金属之城玩家信息
]]
function QMetalCity:requestMetalCityMyInfo(success, fail, status)
    local request = {api = "METAL_CITY_GET_INFO"}
    app:getClient():requestPackageHandler("METAL_CITY_GET_INFO", request, function (response)
        self:responsMetalCityInfo(response, success, nil, true)
    end, function (response)
        self:responsMetalCityInfo(response, nil, fail)
    end)
end

--[[
    金属之城战报
@param  optional int32 metalNum = 1;
]]
function QMetalCity:requestMetalCityReports(metalNum, success, fail, status)
    local metalCityGetReportRequest = {metalNum = metalNum}
    local request = {api = "METAL_CITY_GET_REPORTS", metalCityGetReportRequest = metalCityGetReportRequest}
    app:getClient():requestPackageHandler("METAL_CITY_GET_REPORTS", request, function (response)
        self:responsMetalCityInfo(response, success, nil, true)
    end, function (response)
        self:responsMetalCityInfo(response, nil, fail)
    end)
end

--[[
    金属之城购买挑战次数
]]
function QMetalCity:requestMetalCityBuyFightCount(success, fail, status)
    local request = {api = "METAL_CITY_BUY_FIGHT_COUNT"}
    app:getClient():requestPackageHandler("METAL_CITY_BUY_FIGHT_COUNT", request, function (response)
        self:responsMetalCityInfo(response, success, nil, true)
    end, function (response)
        self:responsMetalCityInfo(response, nil, fail)
    end)
end

--[[
    金属之城战斗开始
@param  optional int32 metalNum = 1;       挑战的关卡
]]
function QMetalCity:requestMetalCityFightStart(metalNum, battleFormation, battleFormation2, success, fail, status)
    local metalCityFightStartRequest = {metalNum = metalNum}
    local gfStartRequest = {battleType = BattleTypeEnum.METAL_CITY, battleFormation = battleFormation, battleFormation2 = battleFormation2, metalCityFightStartRequest = metalCityFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, function (response)
        self:responsMetalCityInfo(response, success, nil, true)
    end, function (response)
        self:responsMetalCityInfo(response, nil, fail)
    end)
end

--[[
    金属之城战斗结束
]]
function QMetalCity:requestMetalCityFightEnd(metalNum, isWin, battleKey,battleFormation,battleFormation2,success, fail, isHandlerError)
    local metalCityFightSuccessRequest = {metalNum = metalNum}
    local battleVerify = q.battleVerifyHandler(battleKey)
   
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    
    local gfEndRequest = {battleType = BattleTypeEnum.METAL_CITY, battleVerify = battleVerify, isQuick = false, isWin = isWin,
                                fightReportData = fightReportData, metalCityFightSuccessRequest = metalCityFightSuccessRequest,battleFormation = battleFormation,battleFormation2 = battleFormation2}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        if response.userComeBackRatio then
            self:setMetalCityRewardRatio(response.userComeBackRatio)
        end
        self:responsMetalCityInfo(response.gfEndResponse, success, nil, true)
    end, function (response)
        self:responsMetalCityInfo(response, nil, fail)
    end, nil, nil, isHandlerError)
end

--[[
    金属之城扫荡
]]
function QMetalCity:responsMetalCityFightQuick(metalNum, success, fail, status)
    local metalCityQuickFightRequest = {metalNum = metalNum}
    local gfQuickRequest = {battleType = BattleTypeEnum.METAL_CITY, metalCityQuickFightRequest = metalCityQuickFightRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, function (response)
        if response.userComeBackRatio then
            self:setMetalCityRewardRatio(response.userComeBackRatio)
        end
        self:responsMetalCityInfo(response, success, nil, true)
    end, function (response)
        self:responsMetalCityInfo(response, nil, fail)
    end, nil, nil, isHandlerError)
end


--[[
    金属之城服务器返回数据
]]
function QMetalCity:responsMetalCityInfo(data, success, fail, succeeded)
    if data.api == "METAL_CITY_BUY_FIGHT_COUNT" and data.error == "NO_ERROR" then
        app.taskEvent:updateTaskEventProgress(app.taskEvent.METAILCIT_BUY_FIGHT_COUNT_EVENT, 1)
    end

    if data.metalCityResponse then
        self:updateMetalServerInfo(data.metalCityResponse)
    end

    self:responseHandler(data, success, fail, succeeded)
end

return QMetalCity