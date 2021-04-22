local QBaseModel = import("...models.QBaseModel")
local QSparField = class("QSparField",QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")

QSparField.STEP_STATUS_ONE = 0
QSparField.STEP_STATUS_TWO = 1
QSparField.STEP_STATUS_THREE = 2

QSparField.STATUS_BOX = "STATUS_BOX"
QSparField.STATUS_GO = "STATUS_GO"
QSparField.STATUS_END = "STATUS_END"
QSparField.STATUS_FIGHT = "STATUS_FIGHT"

QSparField.FINAL_WAVE = 5

QSparField.EXTENDS_PROP_SPARFIELD = "EXTENDS_PROP_SPARFIELD"

function QSparField:ctor(options)
	QSparField.super.ctor(self)
    self._myInfo = {}
end

function QSparField:didappear()
	QSparField.super.didappear(self)
    self._skillConfigs = {}
    self._isRedTips = true
end

function QSparField:disappear()
	QSparField.super.disappear(self)
end

function QSparField:loginEnd()
    if app.unlock:checkLock("SPAR_UNLOCK", false) then
        self:sparFieldGetMyInfoRequest()
    end
end

--设置晶石场的个人信息
function QSparField:setSparFieldMyInfo(myInfo)
    if myInfo == nil then return end
    self._oldInfo = self._myInfo
    self._myInfo = myInfo

    -- tmp fix start: http://jira.joybest.com.cn/browse/WOW-20453
    -- 30014   冰女  ->  10014      
    -- 30015   牛头人 ->   10005      
    -- 30017   脑残吼 ->   10041    
    -- 30018   黑暗女王    ->   10038  
    -- 30021   暴风酿酒师   ->    10024
    local map = {
        [30014] = 10014,
        [30015] = 10005,
        [30017] = 10041,
        [30018] = 10038,
        [30021] = 10024,
    }
    if self._myInfo.legendHeroIds then
        for i, id in ipairs(self._myInfo.legendHeroIds) do
            if map[id] then
                self._myInfo.legendHeroIds[i] = map[id]
            end
        end
    end
    -- tmp fix end
end

--获取晶石场的个人信息
function QSparField:getSparFieldMyInfo()
    return self._myInfo or {}
end

--获取晶石场的探索等级
function QSparField:getSparFieldLevel()
    local myInfo = self:getSparFieldMyInfo()
    local starCount = myInfo.totalStarCount or 0
    local starConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelByStarCount(starCount)
    if starConfig == nil then 
        starConfig = {}
    end
    return starConfig.lev or 0
end

--获取第几波
function QSparField:getWave()
    if self._fightInfo ~= nil then
        if self._fightInfo.boxInfo ~= nil and self._fightInfo.boxInfo.waveId ~= nil then
            return self._fightInfo.boxInfo.waveId
        elseif self._fightInfo.fighterInfo ~= nil then
            return self._fightInfo.fighterInfo.waveId
        end
    end
    return 0
end

--设置晶石场的战斗信息
function QSparField:setSparFieldFightInfo(fightInfo)
    self._fightInfo = fightInfo
end

--删除传奇魂师的加成
function QSparField:removeSparFieldLegendHeros()
    remote.herosUtil:removeExtendsProp(QSparField.EXTENDS_PROP_SPARFIELD)
end

--添加传奇魂师的加成
function QSparField:addSparFieldLegendHeros()
    local props = QStaticDatabase:sharedDatabase():getSparFieldLegend()
    if self._myInfo.legendHeroIds ~= nil then
        for _,actorId in ipairs(self._myInfo.legendHeroIds) do
            remote.herosUtil:addExtendsPropById(props, QSparField.EXTENDS_PROP_SPARFIELD, actorId)
        end
    end    
    remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

--获取传奇魂师列表
function QSparField:getLegendHeroIds()
    return self._myInfo.legendHeroIds
end

--获取晶石场的战斗信息
    -- optional SparFieldWaveFighterInfo fighterInfo = 1;      //关卡对手信息
    -- optional SparFieldWaveBoxInfo boxInfo = 2;              //关卡宝箱信息
function QSparField:getSparFieldFightInfo()
    return self._fightInfo or {}
end

--设置宝箱的状态
function QSparField:setBoxStatus(status)
    local fightInfo = self:getSparFieldFightInfo()
    local boxInfo = fightInfo.boxInfo
    if boxInfo ~= nil then
        boxInfo.status = status
    end
end

--设置战斗的状态
function QSparField:setFightStatus(status)
    local fightInfo = self:getSparFieldFightInfo()
    local fighterInfo = fightInfo.fighterInfo
    if fighterInfo ~= nil then
        fighterInfo.status = status
    end
end

--设置进入战斗
function QSparField:setInBattle(b)
    self._isInBattle = b
end

--获取是否进入战斗
function QSparField:getInBattle()
   return self._isInBattle 
end

--获取这次战斗得到的星星
function QSparField:getFightStarCount()
    local oldStar = 0
    if self._oldInfo ~= nil then
        oldStar = self._oldInfo.totalStarCount
    end
    local newStar = 0
    if self._myInfo ~= nil then
        newStar = self._myInfo.totalStarCount
    end
    return newStar - oldStar
end

--检查是否升级
function QSparField:checkLevelUp()
    local oldStar = 0
    if self._oldInfo ~= nil then
        oldStar = self._oldInfo.totalStarCount
    end
    local newStar = 0
    if self._myInfo ~= nil then
        newStar = self._myInfo.totalStarCount
    end
    local oldStarConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelByStarCount(oldStar)
    local newStarConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelByStarCount(newStar)
    local oldLevel = 0
    local newLevel = 0
    if oldStarConfig ~= nil then
        oldLevel = oldStarConfig.lev or 0
    end
    if newStarConfig ~= nil then
        newLevel = newStarConfig.lev or 0
    end
    return newLevel > oldLevel
end

--打开界面
function QSparField:openSparField()
    if app.unlock:checkLock("SPAR_UNLOCK", true) == false then
        return
    end
    self._isRedTips = false
    self:sparFieldEnterRequest(function ()
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSparField"})
    end)
end

--获取每日的地图背景
function QSparField:getSparMap()
    local time = q.serverTime()
    time = math.floor(time/DAY)
    local maps = QStaticDatabase:sharedDatabase():getSparMap()
    local totalCount = table.nums(maps)
    local index = time%totalCount + 1
    return maps[tostring(index)].map
end

--获取当前状态
--返回 状态ID，关卡ID，(true 敌人还是 false宝箱)
function QSparField:getStatus()
    local fightInfo = self:getSparFieldFightInfo()
    local boxInfo = fightInfo.boxInfo
    if boxInfo ~= nil then
        if boxInfo.status == remote.sparField.STEP_STATUS_ONE then
            return remote.sparField.STATUS_BOX,boxInfo.waveId, false
        elseif boxInfo.status == remote.sparField.STEP_STATUS_TWO then
            return remote.sparField.STATUS_GO,boxInfo.waveId, false
        end
    end

    local fighterInfo = fightInfo.fighterInfo
    if fighterInfo ~= nil then
        if fighterInfo.status == remote.sparField.STEP_STATUS_ONE then
            return remote.sparField.STATUS_FIGHT,fighterInfo.waveId, true
        elseif fighterInfo.status == remote.sparField.STEP_STATUS_TWO then
            return remote.sparField.STATUS_GO,fighterInfo.waveId, true
        elseif fighterInfo.status == remote.sparField.STEP_STATUS_THREE then
            return remote.sparField.STATUS_END,fighterInfo.waveId, true
        end
    end
    return remote.sparField.STATUS_GO,0,false
end

--检查小红点
function QSparField:checkRedTips()
    if app.unlock:checkLock("SPAR_UNLOCK") == false then
        return false
    end
    if self._isRedTips == true then
        return true
    end
    if remote.exchangeShop:checkExchangeShopRedTipsById(SHOP_ID.sparShop) == true then
        return true
    end
    return false
end

--------------------------proto part-------------------------------

--请求获取自己的信息
function QSparField:sparFieldGetMyInfoRequest(success, fail)
    local request = {api = "SPAR_FIELD_GET_MY_INFO"}
    app:getClient():requestPackageHandler("SPAR_FIELD_GET_MY_INFO", request, function (response)
        self:sparFieldGetMyInfoResponse(response, success, nil, true)
    end, function (response)
        self:sparFieldGetMyInfoResponse(response, nil, fail)
    end)
end

function QSparField:sparFieldGetMyInfoResponse(data, success, fail, succeeded)
	if data.sparFieldGetMyInfoResponse ~= nil and data.sparFieldGetMyInfoResponse.userInfo ~= nil then
        self:setSparFieldMyInfo(data.sparFieldGetMyInfoResponse.userInfo)
	end
    self:responseHandler(data,success,fail, succeeded)
end

--请求获取晶石场关卡信息
function QSparField:sparFieldGetWavesFighterRequest(waveId, success, fail)
	local sparFieldGetWavesFighterRequest = {waveId = waveId}
    local request = {api = "SPAR_FIELD_GET_WAVES_FIGHTER", sparFieldGetWavesFighterRequest = sparFieldGetWavesFighterRequest}
    app:getClient():requestPackageHandler("SPAR_FIELD_GET_WAVES_FIGHTER", request, function (response)
        self:sparFieldGetWavesFighterResponse(response, success, nil, true)
    end, function (response)
        self:sparFieldGetWavesFighterResponse(response, nil, fail)
    end)
end

function QSparField:sparFieldGetWavesFighterResponse(data, success, fail, succeeded)
	if data.sparFieldGetWavesFighterResponse ~= nil then
        self:setSparFieldFightInfo(data.sparFieldGetWavesFighterResponse)
	end
    self:responseHandler(data,success,fail, succeeded)
end

--请求刷新传奇魂师的信息
function QSparField:sparFieldRefreshLegendHerosRequest(success, fail)
	local sparFieldRefreshLegendHerosRequest = {}
    local request = {api = "SPAR_FIELD_REFRESH_LEGEND_HEROS", sparFieldRefreshLegendHerosRequest = sparFieldRefreshLegendHerosRequest}
    app:getClient():requestPackageHandler("SPAR_FIELD_REFRESH_LEGEND_HEROS", request, function (response)
        self:sparFieldRefreshLegendHerosResponse(response, success, nil, true)
    end, function (response)
        self:sparFieldRefreshLegendHerosResponse(response, nil, fail)
    end)
end

function QSparField:sparFieldRefreshLegendHerosResponse(data, success, fail, succeeded)
	if data.sparFieldRefreshLegendHerosResponse ~= nil then
        self:setSparFieldMyInfo(data.sparFieldRefreshLegendHerosResponse.userInfo)
	end
    self:responseHandler(data,success,fail, succeeded)
end


function QSparField:sparFieldFightStartRequest(battleType, rivalUserId, battleFormation,success,fail)
    local gfStartRequest = {battleType = battleType,battleFormation = battleFormation}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    self:requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail, false)
end
--请求晶石场战斗结束
function QSparField:sparFieldFightEndRequest(waveId, difficulty, fightReportData, battleFormation, battleKey, success, fail)
	local sparFieldFightEndRequest = {waveId = waveId, difficulty = difficulty}
    local battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.SPAR_FIELD, battleVerify = battleVerify, isQuick = false, isWin = nil,
                         fightReportData = fightReportData, battleFormation = battleFormation, sparFieldFightEndRequest = sparFieldFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        self:sparFieldFightEndResponse(response, success, nil, true)
    end, function (response)
        self:sparFieldFightEndResponse(response, nil, fail)
    end)
end

function QSparField:sparFieldFightEndResponse(data, success, fail, succeeded)
	if data.gfEndResponse ~= nil and data.gfEndResponse.sparFieldFightEndResponse ~= nil then
        self:setSparFieldMyInfo(data.gfEndResponse.sparFieldFightEndResponse.userInfo)
	end
    self:responseHandler(data,success,fail, succeeded)
end

--请求晶石场开宝箱
function QSparField:sparFieldOpenWaveBoxRequest(waveId, success, fail)
	local sparFieldOpenWaveBoxRequest = {waveId = waveId}
    local request = {api = "SPAR_FIELD_OPEN_WAVE_BOX", sparFieldOpenWaveBoxRequest = sparFieldOpenWaveBoxRequest}
    app:getClient():requestPackageHandler("SPAR_FIELD_OPEN_WAVE_BOX", request, function (response)
        self:sparFieldOpenWaveBoxResponse(response, success, nil, true)
    end, function (response)
        self:sparFieldOpenWaveBoxResponse(response, nil, fail)
    end)
end

function QSparField:sparFieldOpenWaveBoxResponse(data, success, fail, succeeded)
    if data.sparFieldOpenWaveBoxResponse ~= nil then
        self:setSparFieldMyInfo(data.sparFieldOpenWaveBoxResponse.userInfo)
    end
    self:responseHandler(data,success,fail, succeeded)
end

--通过某一个关
function QSparField:sparFieldPassWaveRequest(waveId, isFighter, success, fail)
    local sparFieldPassWaveRequest = {waveId = waveId, isFighter = isFighter}
    local request = {api = "SPAR_FIELD_PASS_WAVE", sparFieldPassWaveRequest = sparFieldPassWaveRequest}
    app:getClient():requestPackageHandler("SPAR_FIELD_PASS_WAVE", request, function (response)
        self:sparFieldPassWaveResponse(response, success, nil, true)
    end, function (response)
        self:sparFieldPassWaveResponse(response, nil, fail)
    end)
end

function QSparField:sparFieldPassWaveResponse(data, success, fail, succeeded)
    if data.sparFieldPassWaveResponse ~= nil then
        self:setSparFieldMyInfo(data.sparFieldPassWaveResponse.userInfo)
        self:setSparFieldFightInfo({fighterInfo = data.sparFieldPassWaveResponse.fighterInfo, boxInfo = data.sparFieldPassWaveResponse.boxInfo})
    end
    self:responseHandler(data,success,fail, succeeded)
end

--拉取玩家信息和副本信息
function QSparField:sparFieldEnterRequest(success, fail)
    local sparFieldEnterRequest = {}
    local request = {api = "SPAR_FIELD_ENTER", sparFieldEnterRequest = sparFieldEnterRequest}
    app:getClient():requestPackageHandler("SPAR_FIELD_ENTER", request, function (response)
        self:sparFieldEnterResponse(response, success, nil, true)
    end, function (response)
        self:sparFieldEnterResponse(response, nil, fail)
    end)
end

function QSparField:sparFieldEnterResponse(data, success, fail, succeeded)
    if data.sparFieldEnterResponse ~= nil then
        self:setSparFieldMyInfo(data.sparFieldEnterResponse.userInfo)
        self:setSparFieldFightInfo({fighterInfo = data.sparFieldEnterResponse.fighterInfo, boxInfo = data.sparFieldEnterResponse.boxInfo})
    end
    self:responseHandler(data,success,fail, succeeded)
end

--领取最终的大宝箱
function QSparField:sparFieldGetFinalRewardRequest(success, fail)
    local sparFieldGetFinalRewardRequest = {}
    local request = {api = "SPAR_FIELD_GET_FINAL_REWARD", sparFieldGetFinalRewardRequest = sparFieldGetFinalRewardRequest}
    app:getClient():requestPackageHandler("SPAR_FIELD_GET_FINAL_REWARD", request, function (response)
        self:sparFieldGetFinalRewardResponse(response, success, nil, true)
    end, function (response)
        self:sparFieldGetFinalRewardResponse(response, nil, fail)
    end)
end

function QSparField:sparFieldGetFinalRewardResponse(data, success, fail, succeeded)
    if data.sparFieldGetFinalRewardResponse ~= nil then
        self:setSparFieldMyInfo(data.sparFieldGetFinalRewardResponse.userInfo)
    end
    self:responseHandler(data,success,fail, succeeded)
end

return QSparField