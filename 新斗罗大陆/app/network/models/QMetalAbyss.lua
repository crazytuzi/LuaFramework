local QBaseModel = import("...models.QBaseModel")
local QMetalAbyss = class("QMetalAbyss", QBaseModel)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")



QMetalAbyss.EVENT_METAl_ABYSS_UPDATE           = "EVENT_METAl_ABYSS_UPDATE"


QMetalAbyss.EVENT_METAl_ABYSS_MY_INFO			= "EVENT_METAl_ABYSS_MY_INFO"
QMetalAbyss.EVENT_METAl_ABYSS_MAIN_INFO			= "EVENT_METAl_ABYSS_MAIN_INFO"
QMetalAbyss.EVENT_METAl_ABYSS_RESET				= "EVENT_METAl_ABYSS_RESET"
QMetalAbyss.EVENT_METAl_ABYSS_GET_WAVE_FIGHTER	= "EVENT_METAl_ABYSS_GET_WAVE_FIGHTER"
QMetalAbyss.EVENT_METAl_ABYSS_GET_WAVE_BOX		= "EVENT_METAl_ABYSS_GET_WAVE_BOX"
QMetalAbyss.EVENT_METAl_ABYSS_PASS_WAVE			= "EVENT_METAl_ABYSS_PASS_WAVE"
QMetalAbyss.EVENT_METAl_ABYSS_GET_STAR_REWARD	= "EVENT_METAl_ABYSS_GET_STAR_REWARD"




function QMetalAbyss:ctor()
    QMetalAbyss.super.ctor(self)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self:resetLocalData()
    
end

function QMetalAbyss:resetLocalData()
    self._dispatchList = {}
    self._userInfo = nil
    self._waveFighterInfo = nil
    self._waveBoxInfo = nil
    self._waveShopInfo = nil
    self._levelUpReward = nil
    self._abyssIsOpen = true
    self._abyssNeedRefesh = false
    self._lastDifficult = nil
end


function QMetalAbyss:resetData()
    self:resetLocalData()

    self._abyssLevelConfig = {}
    local  configs = db:getStaticByName("abyss_level_config")
    for k,v in pairs(configs or {}) do
        self._abyssLevelConfig[v.lev] = v
    end
    self._abyssLev = {}
    local  lvconfigs = db:getStaticByName("abyss_lev")
    for k,v in pairs(lvconfigs or {}) do
        self._abyssLev[v.lev] = v
    end


end

function QMetalAbyss:didappear()
    QMetalAbyss.super.didappear(self)
    self:resetData()

    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.markUpdateHandler))
end

function QMetalAbyss:loginEnd(success)
    if success then
        success()
    end
    -- self:initLocalData()
    if app.unlock:checkLock("UNLOCK_ABYSS", isTips)  then
        self:abyssGetMyInfoRequestRequest()
    end
end

function QMetalAbyss:disappear()
    QMetalAbyss.super.disappear(self)
    if self._userEventProxy ~= nil then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end 
end

function QMetalAbyss:markUpdateHandler(event)
    if event.time == nil or event.time == 5 then
        self._abyssNeedRefesh = true
    end
end



function QMetalAbyss:checkMetalAbyssIsUnLock(isTips)

    if not self._abyssIsOpen or self._abyssIsOpen == false then
        return false
    end

    if not app.unlock:checkLock("UNLOCK_ABYSS", isTips)  then
        return false
    end

    return true
end


function QMetalAbyss:checMainPageRedTip()
    if self:checkMetalAbyssIsUnLock() then
        return false
    end

    if self._userInfo and self._userInfo.resetCount == 0 then
        return true
    end

    return false
end


function QMetalAbyss:openDialog(callback)
        print(" QMetalAbyss:openDialog1")

    if not self:checkMetalAbyssIsUnLock(true) then
        print(" QMetalAbyss:openDialog2")
        return false
    end    
    -- if callback then
    --     callback()
    -- end
    -- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMetalAbyssMain"})
    
    self:abyssGetMainInfoRequestRequest(function()
        print(" QMetalAbyss:openDialog3")
        if callback then
            callback()
        end
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMetalAbyssMain"})
    end)
    
end


function QMetalAbyss:setAbyssIsOpen(data)
    self._abyssIsOpen = data
end

function QMetalAbyss:setAbyssUserInfo(data)
	self._userInfo = data
end

function QMetalAbyss:getAbyssUserInfo()
	return self._userInfo
end

function QMetalAbyss:setAbyssWaveFighterInfo(data)
	self._waveFighterInfo = data
end

function QMetalAbyss:getAbyssWaveFighterInfo()
	return self._waveFighterInfo
end

function QMetalAbyss:setAbyssWaveBoxInfo(data)
	self._waveBoxInfo = data
end

function QMetalAbyss:getAbyssWaveBoxInfo()
	return self._waveBoxInfo
end

function QMetalAbyss:setAbyssWaveShopInfo(data)
    self._waveShopInfo = data
end

function QMetalAbyss:getAbyssWaveShopInfo()
    return self._waveShopInfo
end

function QMetalAbyss:setAbyssWaveShopInfoBuyTimes(idx)
    if self._waveShopInfo and self._waveShopInfo[idx] then
        self._waveShopInfo[idx].buyCount = 1
    end
end

function QMetalAbyss:setAbyssLevelUpReward(data)
    self._levelUpReward = data

end

function QMetalAbyss:getAbyssLevelUpReward()
    return self._levelUpReward 
end

function QMetalAbyss:getAbyssRefreshMark()
    return self._abyssNeedRefesh 
end



function QMetalAbyss:setAbyssLastDifficult(diff)
    self._lastDifficult = diff

end

function QMetalAbyss:getAbyssLastDifficult()
    return self._lastDifficult
end


function QMetalAbyss:checkStarRewardsIsGetten(rewardId)
    local idsTbl = self._userInfo.awardedStarRewards or {}
    if q.isEmpty(idsTbl) then
        return false
    end
    for i,v in ipairs(idsTbl) do
        if rewardId == v then
            return true
        end
    end

    return false
end

----------------------------- 协议 -----------------------------
    -- optional AbyssGetMyInfoRequest abyssGetMyInfoRequest = 803; //
    -- optional AbyssGetMainInfoRequest abyssGetMainInfoRequest = 804; //
    -- optional AbyssResetRequest abyssResetRequest = 805; //
    -- optional AbyssRefreshRequest abyssRefreshRequest = 806; //
    -- optional AbyssGetWavesFighterRequest abyssGetWavesFighterRequest = 807; //
    -- optional AbyssOpenWaveBoxRequest abyssOpenWaveBoxRequest = 808; //
    -- optional AbyssPassWaveRequest abyssPassWaveRequest = 809; //
    -- optional AbyssGetStarRewardRequest abyssGetStarRewardRequest = 810; //

    -- optional AbyssGetMyInfoResponse abyssGetMyInfoResponse = 1115; //
    -- optional AbyssGetMainInfoResponse abyssGetMainInfoResponse = 1116; //
    -- optional AbyssResetResponse abyssResetResponse = 1117; //
    -- optional AbyssGetWavesFighterResponse abyssGetWavesFighterResponse = 1118; //
    -- optional AbyssOpenWaveBoxResponse abyssOpenWaveBoxResponse = 1119; //
    -- optional AbyssPassWaveResponse abyssPassWaveResponse = 1120; //
    -- optional AbyssGetStarRewardResponse abyssGetStarRewardResponse = 1121; //

-- message AbyssWaveFighterInfo {
--     optional int32 waveId = 1; //金属深渊关卡ID(0-5)
--     repeated Fighter fighters = 2; //金属深渊关卡对手信息
--     optional int32 status = 3; //0:初始状态,1:对手被击败,2:走过关卡对手信息
-- }

-- message AbyssWaveBoxInfo {
--     optional int32 waveId = 1; //金属深渊关卡ID(0-5)
--     optional string boxId = 2; //宝箱ID
--     optional int32 boxNum = 3; //宝箱数量
--     optional int32 status = 4; //0:初始状态,1:宝箱被领取,2:走过关卡宝箱信息
-- }

-- message AbyssUserInfo {
    -- optional int32 waveId = 1; //当前所在的金属深渊关卡ID(0-5)
    -- repeated int32 passedWaveIds = 2; //已经通关的金属深渊关卡ID集合
    -- repeated int32 awardedWaveIds = 3; //已领取宝箱奖励的金属深渊关卡ID集合
    -- optional int32 todayStarCount = 4; //今日获得的总星星数
    -- optional int32 totalStarCount = 5; //获得的总星星数
    -- repeated int32 awardedStarRewards = 6; //已经领取的星级奖励Id集合
    -- optional int32 refreshCount = 7; //金属深渊刷新次数
    -- optional int32 resetCount = 8; //金属深渊重置次数
-- }


function QMetalAbyss:initLocalData()
    self._userInfo = nil
    self._waveFighterInfo = nil
    self._waveBoxInfo = nil


    self._userInfo  = {}
    self._userInfo.waveId = 0
    self._userInfo.todayStarCount = 1
    self._userInfo.totalStarCount =10
    self._userInfo.refreshCount = 0
    self._userInfo.resetCount = 0


    self._waveBoxInfo  = {}
    self._waveBoxInfo.boxId = 1
    self._waveBoxInfo.boxNum = 1
    self._waveBoxInfo.status = 1

    self._waveFighterInfo = {}
    self._waveFighterInfo.boxId = 1
    self._waveFighterInfo.status = 1


end


function QMetalAbyss:_dispatchAll()
    local tbl = {}
    for _, name in pairs(self._dispatchList) do
        if not tbl[name] then
            self:dispatchEvent({name = name})
            tbl[name] = true
        end
    end
    self._dispatchList = {}
end

function QMetalAbyss:responseHandler(data, success, fail, succeeded)
	--进游戏拉取简单信息
	if data.abyssGetMyInfoResponse ~= nil then
        self:setAbyssUserInfo(data.abyssGetMyInfoResponse.userInfo)
		self:setAbyssIsOpen(data.abyssGetMyInfoResponse.abyssIsOpen)
		table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_MY_INFO) 
    end
	--主信息
	if data.abyssGetMainInfoResponse ~= nil then
		self:setAbyssUserInfo(data.abyssGetMainInfoResponse.userInfo)
		self:setAbyssWaveFighterInfo(data.abyssGetMainInfoResponse.fighterInfo)
        self:setAbyssWaveBoxInfo(data.abyssGetMainInfoResponse.boxInfo)
		self:setAbyssWaveShopInfo(data.abyssGetMainInfoResponse.shopInfo)
        self._abyssNeedRefesh = false
        remote.metalAbyss:setAbyssLastDifficult(0)
		-- table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_MAIN_INFO) 
    end
    --重置
	if data.abyssResetResponse ~= nil then
		self:setAbyssUserInfo(data.abyssResetResponse.userInfo)
        self:setAbyssWaveFighterInfo(nil)
        self:setAbyssWaveBoxInfo(nil)
        self:setAbyssWaveShopInfo(nil)
  --       table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_RESET) 
		-- table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_UPDATE) 
    end
	if data.abyssWaveRefreshResponse ~= nil then
		self:setAbyssUserInfo(data.abyssWaveRefreshResponse.userInfo)
        self:setAbyssWaveFighterInfo(data.abyssWaveRefreshResponse.fighterInfo)
        -- table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_UPDATE) 
    end    
    --挑战对手信息
	if data.abyssGetWavesFighterResponse ~= nil then
  		self:setAbyssWaveFighterInfo(data.abyssGetWavesFighterResponse.fighterInfo)
		self:setAbyssWaveBoxInfo(data.abyssGetWavesFighterResponse.boxInfo)          
		-- table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_GET_WAVE_FIGHTER) 
  --       table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_UPDATE) 
    end
    --开宝箱
	if data.abyssOpenWaveBoxResponse ~= nil then
		self:setAbyssUserInfo(data.abyssOpenWaveBoxResponse.userInfo)
        self._waveBoxInfo.status = 1
        -- table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_GET_WAVE_BOX) 
        -- table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_UPDATE) 
    end
    --通过关卡宝箱或对手
	if data.abyssPassWaveResponse ~= nil then
		self:setAbyssUserInfo(data.abyssPassWaveResponse.userInfo)
		self:setAbyssWaveFighterInfo(data.abyssPassWaveResponse.fighterInfo)
		self:setAbyssWaveBoxInfo(data.abyssPassWaveResponse.boxInfo)
        -- self:setAbyssWaveShopInfo(data.abyssPassWaveResponse.shopInfo)

		-- table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_PASS_WAVE) 
  --       table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_UPDATE)
    end
	--领取星级奖励    
	if data.abyssGetStarRewardResponse ~= nil then
		self:setAbyssUserInfo(data.abyssGetStarRewardResponse.userInfo)
		-- table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_GET_STAR_REWARD) 
    end
	--战斗结束    
	if data.gfEndResponse and data.gfEndResponse.abyssFightEndResponse ~= nil then
        if data.gfEndResponse.isWin then
            self:setAbyssUserInfo(data.gfEndResponse.abyssFightEndResponse.userInfo)
            self:setAbyssWaveShopInfo(data.gfEndResponse.abyssFightEndResponse.shopInfo)
            self:setAbyssLevelUpReward(data.gfEndResponse.abyssFightEndResponse.levelUpReward)
            if data.gfEndResponse.abyssFightEndResponse.userInfo.waveId == 5 then
                self._waveFighterInfo.status = 2
            else
                self._waveFighterInfo.status = 1
            end
            -- 
            remote.user:addPropNumForKey("todayMetalAbyssFightCount")
        end
		-- table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_FIGHT_END) 
  --       table.insert(self._dispatchList,QMetalAbyss.EVENT_METAl_ABYSS_UPDATE)
    end

    self:_dispatchAll()
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

-- /**
--  * 金属深渊-获得我的信息Request
--  */
function QMetalAbyss:abyssGetMyInfoRequestRequest(success, fail)
    local request = {api = "ABYSS_GET_MY_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- /**
--  * 金属深渊-获得我的信息Request
--  */
function QMetalAbyss:abyssGetMainInfoRequestRequest(success, fail)
    local request = {api = "ABYSS_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- /**
--  * 金属深渊-重置关卡
--  */
function QMetalAbyss:abyssResetRequest(success, fail)
    local request = {api = "ABYSS_RESET"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- /**
--  * 金属深渊-刷新关卡
--  */
function QMetalAbyss:abyssRefreshRequest(waveId , success, fail)
	local abyssRefreshRequest = {waveId = waveId}
    local request = {api = "ABYSS_WAVE_REFRESH" , abyssRefreshRequest = abyssRefreshRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- /**
--  * 金属深渊-关卡的Fighter信息Request
--  */
function QMetalAbyss:abyssGetWavesFighterRequest(waveId ,success, fail)
	local abyssGetWavesFighterRequest = {waveId = waveId}
    local request = {api = "ABYSS_GET_WAVES_FIGHTER" , abyssGetWavesFighterRequest = abyssGetWavesFighterRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- /**
--  * 金属深渊-查询对手
--  */
function QMetalAbyss:abyssQueryFighterRequest(userId ,success, fail)
	local abyssQueryFighterRequest = {userId = userId}
    local request = {api = "ABYSS_QUERY_FIGHTER" , abyssQueryFighterRequest = abyssQueryFighterRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- /**
--  * 金属深渊-开启关卡宝箱Request
--  */
function QMetalAbyss:abyssOpenWaveBoxRequest(waveId ,success, fail)
	local abyssOpenWaveBoxRequest = {waveId = waveId}
    local request = {api = "ABYSS_OPEN_WAVE_BOX",abyssOpenWaveBoxRequest = abyssOpenWaveBoxRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- /**
--  * 金属深渊-通过关卡宝箱或对手Request
--  */
function QMetalAbyss:abyssPassWaveRequest(waveId ,isFighter ,success, fail)
	local abyssPassWaveRequest = {waveId = waveId , isFighter = isFighter }
    local request = {api = "ABYSS_PASS_WAVE", abyssPassWaveRequest = abyssPassWaveRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- /**
--  * 金属深渊-领取星级奖励
--  */
function QMetalAbyss:abyssGetStarRewardRequest(rewardId , success, fail)
	local abyssGetStarRewardRequest = {rewardId = rewardId}
    local request = {api = "ABYSS_GET_STAR_REWARD",abyssGetStarRewardRequest=abyssGetStarRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- /**
--  * 金属深渊-战斗开始
--  */
-- message AbyssFightStartRequest {
--     optional int32 waveId = 1; //金属深渊关卡ID(0-5)
--     optional string userId = 2;//
-- }
function QMetalAbyss:abyssFightStartRequest(waveId,userId, battleFormation, battleFormation2, battleFormation3 ,success, fail)
	local abyssFightStartRequest = {waveId = waveId , userId = userId}
    local gfStartRequest = {battleType = BattleTypeEnum.ABYSS, abyssFightStartRequest = abyssFightStartRequest
    , battleFormation = battleFormation , battleFormation2 = battleFormation2 , battleFormation3 = battleFormation3}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- /**
--  * 金属深渊-战斗结束
--  */
function QMetalAbyss:abyssFightEndRequest(waveId,difficulty, battleKey, battleFormation, battleFormation2, battleFormation3, success, fail)
    local abyssFightEndRequest = {waveId = waveId , difficulty = difficulty}

    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.ABYSS, battleVerify = battleVerify,fightReportData  = fightReportData
    , battleFormation = battleFormation , battleFormation2 = battleFormation2 , battleFormation3 = battleFormation3 , abyssFightEndRequest = abyssFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
/**
 * 金属深渊-商店购买
 */
message AbyssBuyGoodRequest {
    optional int32 gridId = 1; //金属深渊购买商品
}
]]
function QMetalAbyss:abyssBuyGoodRequest(gridId , success, fail)
    local abyssBuyGoodRequest = {gridId = gridId }
    local request = {api = "ABYSS_BUY",abyssBuyGoodRequest = abyssBuyGoodRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[

    1:{
        index =1,
        id =1
    },
    2:{
        index =1,
        id =12
    },
    3:{
        index =2,
        id =1
    },

]]
---- 本地量表读取
function QMetalAbyss:getNextLevelConfigByExp(star)
    local resultConfig = nil
    for i,v in ipairs(self._abyssLevelConfig or {}) do
        if star < v.star then
            resultConfig = v
            break
        end
    end

    return resultConfig
end


function QMetalAbyss:getLevelConfigByExp(star)
    local resultConfig = nil
    for i,v in ipairs(self._abyssLevelConfig or {}) do
        if star >= v.star then
            resultConfig = v
        else
            break
        end
    end
    return resultConfig
end

function QMetalAbyss:getLevelInfoByExp(star)
    local resultConfig = nil
    for i,v in ipairs(self._abyssLev or {}) do
        if star >= v.star then
            resultConfig = v
        else
            break
        end
    end
    return resultConfig
end

function QMetalAbyss:getNextLevelInfoByExp(star)
    local resultConfig = nil
    for i,v in ipairs(self._abyssLev or {}) do
        if star < v.star then
            resultConfig = v
            break
        end
    end

    return resultConfig
end

function QMetalAbyss:getLevelConfigByLevel(id)
    local resultConfig = nil
    for i,v in ipairs(self._abyssLevelConfig or {}) do
        if id == v.lev then
            resultConfig = v
            break
        end
    end

    return resultConfig
end

function QMetalAbyss:getLevelInfoByExpLevel(id)
    local resultConfig = nil
    for i,v in ipairs(self._abyssLev or {}) do
        if id == v.lev then
            resultConfig = v
            break
        end
    end

    return resultConfig
end



function QMetalAbyss:getFightLanguage()
    local  configs = db:getStaticByName("abyss_language")
    return configs
end

function QMetalAbyss:getMetalAbyssFinalRewardById(id)
    local  configs = db:getStaticByName("abyss_final_reward")

    for k,v in pairs(configs) do
        if v.id == id then
            return v
        end
    end

    return  nil
end


return QMetalAbyss