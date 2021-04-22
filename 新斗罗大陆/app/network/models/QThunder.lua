--雷电王座
--wkwang
local QBaseModel = import("...models.QBaseModel")
local QThunder = class("QThunder",QBaseModel)
local QUIViewController = import("...ui.QUIViewController")

local QStaticDatabase = import("...controllers.QStaticDatabase")

QThunder.LEVEL_WAVE = "LEVEL_WAVE"
QThunder.ELITE_WAVE = "ELITE_WAVE"

QThunder.EVENT_UPDATE_INFO = "EVENT_UPDATE_INFO"
QThunder.EVENT_UPDATE_NPC_LEVEL = "EVENT_UPDATE_NPC_LEVEL"
QThunder.BOX_GOTTEN = "BOX_GOTTEN"
QThunder.EVENT_UPDATE_ELITE_BUY_COUNT = "EVENT_UPDATE_ELITE_BUY_COUNT"

function QThunder:ctor(options)
    QThunder.super.ctor(self)

    self.isArrivalMaxLayer = false
    self.thunderMyRank = 0
    self.thunderFormerStar = 0
    self.battleType = 1 --可以进行战力压制时是否直接跳过战斗（1，进入战斗；2，跳过战斗）
    self.forceNoEnoughTip = 0  --本次登录是否弹过战力不足tip
end

function QThunder:didappear()
    QThunder.super.didappear(self)
    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self,self.refreshTimeAtFiveHandler))
end

function QThunder:disappear()
    QThunder.super.disappear(self)
    if self._userEventProxy ~= nil then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end
    self.battleType = 1
    self.forceNoEnoughTip = 0
end

--五点重置刷新次数
function QThunder:refreshTimeAtFiveHandler(event)
    if event.time == nil or event.time == 5 then
        if self.thunderInfo ~= nil then
            self.thunderInfo.thunderResetCount = 0
            self:dispatchEvent({name = QThunder.EVENT_UPDATE_INFO})
        end
    end
end


function QThunder:getThunderInfoWhenLogin( success, fail )
    -- body
    if app.unlock:getUnlockThunder() then
        self:thunderInfoRequest(success, fail)
    else
        if success then
            success()
        end
    end
end

function QThunder:openDilaog()
    if self.thunderInfo == nil then
        self:thunderInfoRequest(function ()
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunder"})
        end)
    else
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunder"})
    end
end

function QThunder:openChooseDilaog(index, config, passStar)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogThunderChoose",
        options = {index = index, config = config, passStar = passStar}})
end

function QThunder:openAwardDialog()
    local awards = self:getLuckDraw()
    if not awards or self.isFastState == true then  
        self._isBoxGotten = false
        return 
    end
    local items = {}
    if awards.prizes ~= nil then
        for _,item in pairs(awards.prizes) do
            local typeName = remote.items:getItemType(item.type)
            table.insert(items, {typeName = typeName, id = item.id, count = item.count})
        end
    end
    self._isBoxGotten = true
    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = items, callBack = function ()
            remote.thunder:setIsBattle(false)
            -- self:dispatchEvent({name = QThunder.BOX_GOTTEN})
        end}},{isPopCurrentDialog = false} )
    dialog:setTitle("恭喜您获得杀戮之都奖励")
end

function QThunder:setThunderFighter(fighter)
    self.thunderInfo = fighter
    -- 记录任务完成进度
    app.taskEvent:updateTaskEventProgress(app.taskEvent.THUNDER_ACTIVE_EVENT, 1, false, false, {compareNum = self.thunderInfo.thunderHistoryMaxFloor})
    
    if self.thunderInfo.thunderHistoryEveryWaveStar == nil then
        self.thunderInfo.thunderHistoryEveryWaveStar = {}
    end
    --更新历史最高星星
    if self.thunderInfo.thunderHistoryMaxStar > (remote.user.thunderHistoryMaxStar or 0) then
        remote.user:update({thunderHistoryMaxStar = self.thunderInfo.thunderHistoryMaxStar})
    end
    --计算最后一次通关的dungenID
    self._lastIndex = self.thunderInfo.thunderLastWinWave
    self._lastLayer = self.thunderInfo.thunderLastWinFloor
    if self._lastLayer == 0 then
        self._lastLayer = 1
    end
    self._layerConfig = QStaticDatabase:sharedDatabase():getThunderConfigByLayer(self._lastLayer)
    --计算buff
    self._buffs = {}
    self._allBuffs = {}
    local buffs = self.thunderInfo.thunderBuffs
    if #buffs > 0 then
        buffs = string.split(buffs, ";")
        for _,buff in pairs(buffs) do
            if buff ~= "" then
                local buff = string.split(buff, ",")
                self._buffs[tonumber(buff[1])] = buff[2]
            end
        end
    end
    if self._buffs[self._lastLayer] ~= nil and self._lastIndex == 3 then
        self._lastLayer = self._lastLayer + 1
        self._layerConfig = QStaticDatabase:sharedDatabase():getThunderConfigByLayer(self._lastLayer)
        self._lastIndex = 0
    end
    -- 防止最后一层
    self.isArrivalMaxLayer = false
    if self._layerConfig == nil then
        self._layerConfig = QStaticDatabase:sharedDatabase():getThunderConfigByLayer(self._lastLayer-1)
        self._lastIndex = 2
        self.isArrivalMaxLayer = true
    end
    -- precious
    self._preciousAward = self.thunderInfo.thunderPreciousAward
    self._buyPreciousTimes = self.thunderInfo.thunderBuyPreciousTimes
    self:setPreciousTimes(self.thunderInfo.thunderBuyPreciousInfo)

    self:dispatchEvent({name = QThunder.EVENT_UPDATE_INFO})
end

function QThunder:getThunderFighter()
    return self.thunderInfo, self._layerConfig, self._lastIndex, self._buyPreciousTimes, self.isArrivalMaxLayer
end

function QThunder:getThunderPreciousAward()
    return self._preciousAward
end

function QThunder:setPreciousTimes(thunderBuyPreciousInfo)
    self._preciousTimes = {}
    if thunderBuyPreciousInfo == nil then return end
    local thunderBuyPreciousInfos = string.split(thunderBuyPreciousInfo,";")
    for _,value in ipairs(thunderBuyPreciousInfos) do
        if value ~= "" then
            local values = string.split(value,",")
            table.insert(self._preciousTimes, {layer = tonumber(values[1]), count = tonumber(values[2])})
        end
    end
end

function QThunder:getPreciousTimes(layer)
    return self._preciousTimes
end

function QThunder:setFastResult(info)
    self.fastResult = info
end

function QThunder:getFastResult()
    return self.fastResult
end

function QThunder:setFastActivityYeild(yeild)
    self.fastActivityYield = yeild
end

function QThunder:getFastActivityYeild()
    return self.fastActivityYield or 1
end

function QThunder:setFastUserComeBackRatio(userComeBackRatio)
    self.fastUserComeBackRatio = userComeBackRatio
end

function QThunder:getFastUserComeBackRatio()
    return self.fastUserComeBackRatio or 1
end

--[[
    optional Fighter fighter = 1;
    optional int32 thunderMoney = 2;
    optional LuckyDrawResponse luckyDraw = 3;
    optional int32 token = 4;
]]
function QThunder:setFighterResult(info)
    if info.fighter ~= nil then
        self:setThunderFighter(info.fighter)
    end
    remote.user:update(info)
    if info.luckyDraw ~= nil and info.luckyDraw.items then
        local items = {}
        for _,value in ipairs(info.luckyDraw) do
            table.mergeForArray(items, value.item)
        end
        remote.items:setItems(items)
    end
end

function QThunder:setLuckDraw(luckyDraw)
    self._luckyDraw = luckyDraw
end

function QThunder:getLuckDraw()
    return self._luckyDraw
end

--通过层级和层级小关转化为关卡层级
function QThunder:getIndexByLayer(layer, index)
    if layer == 0 and index == 0 then
        return 0
    end
    return (layer-1)*3+index
end

--通过关卡层级转化为层级和层级小关
function QThunder:getLayerByIndex(index)
    local _index = index%3
    if _index == 0 then
        _index = 3
    end
    return math.ceil(index/3), _index
end

--获取能快速扫荡的层级
function QThunder:getFastBattleLayer()
    local index = 1

    local currentIndex = self:getIndexByLayer(self._lastLayer, self._lastIndex)
    local currentMaxStar = currentIndex * 3
    while true do
        if self.thunderInfo.thunderHistoryEveryWaveStar[index] ~= 3 or (self.thunderInfo.thunderCurrentStar < currentMaxStar)  then
            return math.ceil(index/3) - 1
        end
        index = index + 1
    end
end

--开始战斗
function QThunder:startBattle()
    self._luckyDraw = nil
    self.isStartBattle = true
end

--判断是否是从战斗中出来的
function QThunder:getIsBattle()
    return self.isStartBattle
end

--判断是否是从战斗中出来的
function QThunder:setIsBattle(b,isdispatch)
    self.isStartBattle = b
    if isdispatch ~= false then
     self:dispatchEvent({name = QThunder.EVENT_UPDATE_INFO})
    end
end

--判断是否扫荡
function QThunder:getIsFast()
    return self.isFast
end

--判断是否扫荡
function QThunder:setIsFast(b,isdispatch)
    self.isFast = b
    if isdispatch ~= false then
        self:dispatchEvent({name = QThunder.EVENT_UPDATE_INFO})
    end
end

--获取指定关卡的BUFF
function QThunder:getBuffByLayer(layer)
    return self._buffs[layer]
end

--获取指定关卡的BUFF
function QThunder:getAllBuff()
    return self._buffs
end

function QThunder:getShowSkipBattle( )
    return self._showSkipBattle or false
end

function QThunder:setShowSkipBattle(b )
    print("跳关设置--QThunder:setShowSkipBattle",b)
    self._showSkipBattle = b
end
function QThunder:setEliteBattleInfo(eliteLevel, winNpc) 
    self._currentEliteLevel = eliteLevel
    self._eliteHisNpcInfo = winNpc
end

function QThunder:getEliteBattleInfo() 
    return self._currentEliteLevel, self._eliteHisNpcInfo
end

function QThunder:checkThunderRedTips()
    if self.thunderInfo == nil then return true end

    if remote.stores:checkFuncShopRedTips(SHOP_ID.thunderShop) then
        return true
    else
        return false
    end
end

function QThunder:checkThunderEliteFightCount( ... )
    if self.thunderInfo == nil then return true end
    
    local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
    if self.thunderInfo ~= nil and tonumber(configuration["THUNDER_ELITE_DEFAULT"].value) + tonumber(self.thunderInfo.thunderEliteChallengeBuyCount) - tonumber(self.thunderInfo.thunderEliteChallengeTimes) > 0 and 
        self.thunderInfo.thunderHistoryMaxFloor >= 1 then
        return true
    end

    return false
end

function QThunder:updateEliteBuyCount()
    self:dispatchEvent({name = QThunder.EVENT_UPDATE_ELITE_BUY_COUNT})
end

function QThunder:isLastFloor()
    if self.thunderInfo then
        if self.thunderInfo.thunderLastWinFloor and self.thunderInfo.thunderLastWinWave == 3 then
            local config = QStaticDatabase:sharedDatabase():getThunderConfigByLayer(self.thunderInfo.thunderLastWinFloor+1)
            if config == nil then
                return true
            end
        end
    end
    return false
end

-------------------------------response area------------------------------

function QThunder:responseHandler(response,success)
    if response.apiThunderInfoResponse ~= nil then --查询雷电王座信息
        remote.user:update(response.apiThunderInfoResponse)
        self.thunderMyRank = response.apiThunderInfoResponse.thunderMyRank
        self.thunderFormerStar = response.apiThunderInfoResponse.thunderFormerStar
        self:setThunderFighter(response.apiThunderInfoResponse.fighter)
    end
    if response.apiThunderBuyEliteCountResponse ~= nil then --购买雷电王座精英关卡次数
        if response.apiThunderBuyEliteCountResponse.token ~= nil then 
            remote.user:update({token = (response.apiThunderBuyEliteCountResponse.token)})
        end
        self:setThunderFighter(response.apiThunderBuyEliteCountResponse.fighter)
    end
    if response.apiThunderFightEndResponse ~= nil then --雷电王座战斗结束
        if response.apiThunderFightEndResponse ~= nil and response.apiThunderFightEndResponse.luckyDraw ~= nil and response.apiThunderFightEndResponse.luckyDraw.items ~= nil then
            remote.items:setItems(response.apiThunderFightEndResponse.luckyDraw.items)
        end
        if response.apiThunderFightEndResponse.thunderMoney ~= nil then
            remote.user:update({thunderMoney = (response.apiThunderFightEndResponse.thunderMoney)})
        end
        self.thunderMyRank = response.apiThunderFightEndResponse.thunderMyRank
        self.thunderFormerStar = response.apiThunderFightEndResponse.thunderFormerStar
        self:setLuckDraw(response.apiThunderFightEndResponse.luckyDraw)
        self:setFighterResult(response.apiThunderFightEndResponse)
    end
    if response.apiThunderBuyBuffResponse ~= nil then --雷电王座购买buff
        self:setThunderFighter(response.apiThunderBuyBuffResponse.fighter)
    end
    if response.apiThunderResetResponse ~= nil then --雷电王座重置
        remote.user:update(response.apiThunderResetResponse)
        self:setThunderFighter(response.apiThunderResetResponse.fighter)
    end
    if response.apiThunderBuyFailureAwardResponse ~= nil then --雷电王座购买失败奖励
        self:setThunderFighter(response.apiThunderBuyFailureAwardResponse.fighter)
        remote.user:update(response.apiThunderBuyFailureAwardResponse)
        if response.apiThunderBuyFailureAwardResponse ~= nil and response.apiThunderBuyFailureAwardResponse.luckyDraw ~= nil and response.apiThunderBuyFailureAwardResponse.luckyDraw.items ~= nil then
            remote.items:setItems(response.apiThunderBuyFailureAwardResponse.luckyDraw.items)
        end
    end
    if response.gfQuickResponse ~= nil and response.gfQuickResponse.apiThunderLevelWaveFastFightResponse ~= nil then --雷电王座扫荡
        -- if response.api ~= "THUNDER_ELITE_WAVE_FAST_FIGHT" then
        if response.gfQuickResponse.battleType ~= BattleTypeEnum.THUNDER_ELITE then
            self:setIsFast(true, false)
            local count = #response.gfQuickResponse.apiThunderLevelWaveFastFightResponse.awards
            if count ~= nil then
                remote.user:addPropNumForKey("todayThunderFightCount", count)
                remote.user:addPropNumForKey("thunderFightCount", count)
                remote.activity:updateLocalDataByType(542, count)

                app.taskEvent:updateTaskEventProgress(app.taskEvent.THUNDER_EVENT, count, false, true)
            end
        end
        --节日奖励
        if type(response.extraExpItem) == "table" then
            if not response.gfQuickResponse.apiThunderLevelWaveFastFightResponse.awards then
                local temp = {}
                temp.yield = 1
                temp.prize = response.extraExpItem
                response.gfQuickResponse.apiThunderLevelWaveFastFightResponse.awards = {}
                table.insert(response.gfQuickResponse.apiThunderLevelWaveFastFightResponse.awards, temp)
            else
                local prizeTbl = response.gfQuickResponse.apiThunderLevelWaveFastFightResponse.awards[1]
                if prizeTbl and prizeTbl.prize then
                    for k, v in pairs(response.extraExpItem) do
                        table.insert(prizeTbl.prize, 1, v)
                    end
                end
            end
        end
        
        self:setFastResult(response.gfQuickResponse.apiThunderLevelWaveFastFightResponse.awards)
        self:setFastActivityYeild(response.gfQuickResponse.apiThunderLevelWaveFastFightResponse.activity_yield)
        self:setFastUserComeBackRatio(response.userComeBackRatio)
        self:setLuckDraw(response.gfQuickResponse.apiThunderLevelWaveFastFightResponse.luckyDraw)
        self:setFighterResult(response.gfQuickResponse.apiThunderLevelWaveFastFightResponse)
    end
    -- if response.apiThunderLevelWaveFastFightResponse ~= nil then --雷电王座扫荡
    --     -- if response.api ~= "THUNDER_ELITE_WAVE_FAST_FIGHT" then
    --     --     self:setIsFast(true, false)
    --     --     local count = #response.apiThunderLevelWaveFastFightResponse.awards
    --     --     if count ~= nil then
    --     --         remote.user:addPropNumForKey("todayThunderFightCount", count)
    --     --         remote.user:addPropNumForKey("thunderFightCount", count)
    --     --         remote.activity:updateLocalDataByType(542, count)
    --     --     end
    --     -- end
    --     --节日奖励
    --     if type(response.extraExpItem) == "table" then
    --         if not response.apiThunderLevelWaveFastFightResponse.awards then
    --             local temp = {}
    --             temp.yield = 1
    --             temp.prize = response.extraExpItem
    --             response.apiThunderLevelWaveFastFightResponse.awards = {}
    --             table.insert(response.apiThunderLevelWaveFastFightResponse.awards, temp)
    --         else
    --             local prizeTbl = response.apiThunderLevelWaveFastFightResponse.awards[1]
    --             if prizeTbl and prizeTbl.prize then
    --                 for k, v in pairs(response.extraExpItem) do
    --                     table.insert(prizeTbl.prize, 1, v)
    --                 end
    --             end
    --         end
    --     end
        
    --     self:setFastResult(response.apiThunderLevelWaveFastFightResponse.awards)
    --     self:setFastActivityYeild(response.apiThunderLevelWaveFastFightResponse.activity_yield)
    --     self:setLuckDraw(response.apiThunderLevelWaveFastFightResponse.luckyDraw)
    --     self:setFighterResult(response.apiThunderLevelWaveFastFightResponse)
    -- end
    if response.apiThunderBuyPreciousResponse ~= nil then --雷电王座购买宝箱
        self:setThunderFighter(response.apiThunderBuyPreciousResponse.fighter)
        remote.user:update(response.apiThunderBuyPreciousResponse)
        if response.apiThunderBuyPreciousResponse ~= nil and response.apiThunderBuyPreciousResponse.luckyDraw ~= nil then
            remote:updateData(response.apiThunderBuyPreciousResponse.luckyDraw)
        end
        remote.thunder:setIsBattle(false)
    end
    if success ~= nil then success(response) end
end

-------------------------------request area------------------------------

-- 获取用户雷电王座信息   无参数
-- 同时获取雷电王座商店信息
function QThunder:thunderInfoRequest(success, fail, status)
    local request = {api = "THUNDER_INFO"}
    local successCallback = function (response)
        self:responseHandler(response,success)
    end
    app:getClient():requestPackageHandler("THUNDER_INFO", request, successCallback, fail)
    -- app:getClient():getStores(SHOP_ID.thunderShop, function(data)end)
end

--[[
	雷电王座战斗开始处理
	@param rivalUserId 对手ID
	@param waveType enum THUNDER_WAVE_TYPE
	@param floor 第几层(从1开始)
	@param wave 第几关(从1开始)
]]
function QThunder:thunderFightStartRequest( waveType, floor, wave, battleFormation, success, fail, status)
	local apiThunderFightStartRequest = {waveType = waveType, floor = floor, wave = wave}
    local gfStartRequest = {battleType = BattleTypeEnum.THUNDER, battleFormation = battleFormation, apiThunderFightStartRequest = apiThunderFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    local successCallback = function (response)
        self:responseHandler(response,success)
    end
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, successCallback, fail)
end

--[[
	雷电王座战斗结束处理
	@param rivalUserId 对手ID
	@param waveType enum THUNDER_WAVE_TYPE
	@param win 战斗是否成功
	@param waveStar 将要获取的星级数
	@param difficult 关卡难度系数(1-easy 2-normal 3-hard)
    @param eliteWave 当前挑战的精英关卡
]]
function QThunder:thunderFightEndRequest(rivalUserId, waveType, win, waveStar, difficult, eliteWave, battleKey, success, fail, status)
	local apiThunderFightEndRequest = {rivalUserId = rivalUserId, waveType = waveType, win = win, waveStar = waveStar, difficult = difficult, eliteWave = eliteWave}
    apiThunderFightEndRequest.battleVerify = q.battleVerifyHandler(battleKey)
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)

    local gfEndRequest = {battleType = BattleTypeEnum.THUNDER, battleVerify = apiThunderFightEndRequest.battleVerify, isQuick = false, isWin = win
                                , fightReportData = fightReportData, apiThunderFightEndRequest = apiThunderFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    
    local successCallback = function (response)
        self:responseHandler(response,success)
        if win == true and eliteWave == nil then
            remote.user:addPropNumForKey("thunderFightCount")
            remote.user:addPropNumForKey("todayThunderFightCount")
            remote.activity:updateLocalDataByType(542, 1)

        end
        if eliteWave == nil then
            app.taskEvent:updateTaskEventProgress(app.taskEvent.THUNDER_EVENT, 1, false, win)
        end
    end
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, successCallback, fail)
end

--[[
	购买雷电王座BUFF 
	@param id BUFF ID
]]
function QThunder:thunderBuyBuffRequest(id, success, fail, status)
    local thunderBuff = {id = id}
    local request = {api = "THUNDER_BUY_BUFF", thunderBuff = thunderBuff}
    local successCallback = function (response)
        self:responseHandler(response,success)
    end
    app:getClient():requestPackageHandler("THUNDER_BUY_BUFF", request, successCallback, fail)
end

--[[
	重置雷电王座关卡 
]]
function QThunder:thunderResetRequest(isSecretary, success, fail, status)
    local apiThunderResetRequest = {isSecretaryGet = isSecretary}
    local request = {api = "THUNDER_RESET", apiThunderResetRequest = apiThunderResetRequest}
    local successCallback = function (response)
        self:responseHandler(response,success)
        app.taskEvent:updateTaskEventProgress(app.taskEvent.THUNDER_RESET_COUNT_EVENT, 1)
    end
    app:getClient():requestPackageHandler("THUNDER_RESET", request, successCallback, fail)
end

--[[
	购买雷电王座精英试炼关卡挑战次数
]]
function QThunder:thunderBuyEliteRequest(success, fail, status)
    local request = {api = "THUNDER_BUY_ELITE_COUNT"}
    local successCallback = function (response)
        self:responseHandler(response,success)
    end
    app:getClient():requestPackageHandler("THUNDER_BUY_ELITE_COUNT", request, successCallback, fail)
end

--[[
	购买雷电王座失败奖励 
]]
function QThunder:thunderBuyFailAwardRequest(success, fail, status)
    local request = {api = "THUNDER_BUY_FAIL_AWARD"}
    local successCallback = function (response)
        self:responseHandler(response,success)
    end
    app:getClient():requestPackageHandler("THUNDER_BUY_FAIL_AWARD", request, successCallback, fail)
end

--[[
    扫荡雷电王座关卡 
    optional int32 type                         =   1;//一键扫荡类型：1.三星 2.全部
    optional bool isSecretaryGet                =   小舞助手
]]
function QThunder:thunderLevelWaveFastFight(type, isSecretary, success, fail, status)
    local apiThunderLevelWaveFastFightRequest = {type = type, isSecretaryGet = isSecretary}
    local gfQuickRequest = {battleType = BattleTypeEnum.THUNDER, apiThunderLevelWaveFastFightRequest = apiThunderLevelWaveFastFightRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK",gfQuickRequest = gfQuickRequest}
    local successCallback = function (response)
        self:responseHandler(response,success)
    end
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, successCallback, fail)
end

--[[
    扫荡雷电王座关卡 
]]
function QThunder:thunderFastFightRequest(waveStar, difficult, skipflag,success, fail, status)
    local apiThunderFastFightRequest = {waveStar = waveStar, difficult = difficult}
    local gfQuickRequest = {battleType = BattleTypeEnum.THUNDER, apiThunderFastFightRequest = apiThunderFastFightRequest,isSkip = skipflag}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    local successCallback = function (response)
        self:responseHandler(response,success)
    end
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, successCallback, fail)
end

--[[
    购买隐藏宝箱 precious
    optional bool  isSecretaryGet = 4;  // 是否是小秘书
]]
function QThunder:thunderBuyPreciousRequest(isBuy, floor, isSecretary, success, fail, status)
    local apiThunderBuyPreciousRequest = {isBuy = isBuy, floor = floor, isSecretaryGet = isSecretary}
    local request = {api = "THUNDER_BUY_PRECIOUS", apiThunderBuyPreciousRequest = apiThunderBuyPreciousRequest}
    local successCallback = function (response)
            self:responseHandler(response,success)
        end
    app:getClient():requestPackageHandler("THUNDER_BUY_PRECIOUS", request, successCallback, fail)

    if isBuy == false then
        self:dispatchEvent({name = QThunder.EVENT_UPDATE_INFO})
    end
end

--[[
    购买所有的隐藏宝箱 precious
]]
function QThunder:thunderBuyAllPreciousRequest(isBuy, times, isSecretary, success, fail, status)
    local apiThunderBuyPreciousRequest = {isBuy = isBuy, times = times, isSecretaryGet = isSecretary}
    local request = {api = "THUNDER_BUY_PRECIOUS_ALL", apiThunderBuyPreciousRequest = apiThunderBuyPreciousRequest}
    local successCallback = function (response)
            self:responseHandler(response,success)
        end
    app:getClient():requestPackageHandler("THUNDER_BUY_PRECIOUS_ALL", request, successCallback, fail)

    if isBuy == false then
        self:dispatchEvent({name = QThunder.EVENT_UPDATE_INFO})
    end
end

--[[
    扫荡雷电王座精英关卡 precious
]]
function QThunder:thunderEliteQuickFight(battleType, rivalUserId, waveType, win, waveStar, difficult, eliteWave, battleKey, isSecretary, success, fail, status)
    local apiThunderFightEndRequest = {rivalUserId = rivalUserId, waveType = waveType, win = win, waveStar = waveStar, difficult = difficult, eliteWave = eliteWave, isSecretaryGet = isSecretary}
    local gfQuickRequest = {battleType = battleType,apiThunderFightEndRequest = apiThunderFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    local successCallback = function (response)
            self:responseHandler(response,success)
        end
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, successCallback, fail)
end

--[[
    雷电王座快速结束失败
]]
function QThunder:thunderQuickEnd(success, fail, status)
    local request = {api = "THUNDER_QUICK_END"}
    local successCallback = function (response)
            self:responseHandler(response,success)
        end
    app:getClient():requestPackageHandler("THUNDER_QUICK_END", request, successCallback, fail)
end

return QThunder