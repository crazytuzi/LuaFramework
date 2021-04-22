-- @Author: xurui
-- @Date:   2020-01-17 10:10:20
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-27 16:38:55
local QBaseSecretary = import(".QBaseSecretary")
local QHeroFragmentSecretary = class("QHeroFragmentSecretary", QBaseSecretary)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySettingBuy = import("..ui.widgets.QUIWidgetSecretarySettingBuy")
local QUIViewController = import("..ui.QUIViewController")
local QVIPUtil = import("..utils.QVIPUtil")
local QInvasionArrangement = import("..arrangement.QInvasionArrangement")

function QHeroFragmentSecretary:ctor(options)
	QHeroFragmentSecretary.super.ctor(self, options)

    self._invationItem = db:getConfigurationValue("INTRUSION_TOKEN_ITEM_ID")
end

function QHeroFragmentSecretary:convertSecretaryAwards(itemLog, logNum,info)
    QHeroFragmentSecretary.super:convertSecretaryAwards(itemLog, logNum,info)
    local countTbl = string.split(itemLog.param, ";")

    if self._config.showResource ~= nil then
        info.money = 0
        if tonumber(logNum) == 1 then
            info.token = tonumber(countTbl[4]) or 0
        elseif tonumber(logNum) == 2 then
            info.token = tonumber(countTbl[2]) or 0
        end      
    end
    table.sort(info.awards, function(a, b)
    local configA = db:getItemByID(a.id)
    local configB = db:getItemByID(b.id)
    if configA and configB then
        if configA.type ~= configB.type then
            return configA.type == ITEM_CONFIG_TYPE.SOUL
        else
            return false
        end
    else
        return configA ~= nil
    end
end)
    return info
end

-- 魂师碎片扫荡
function QHeroFragmentSecretary:executeSecretary()
    self._curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    self._invationSetting = self._curSetting["invation"] or {}
    self._energySetting = self._curSetting["energy"] or {}

    self._heroList = {}
    for key, value in pairs(self._curSetting) do
        if tonumber(key) ~= nil and value.selected == true then
            local grade = 0
            local heroInfo = remote.herosUtil:getHeroByID(key)
            if heroInfo then
                grade = heroInfo.grade or 0
            end
            local config = db:getCharacterByID(key)
            table.insert(self._heroList, {actorId = tonumber(key), aptitude = config.aptitude, grade = grade, resetDungeonNum = (value.resetDungeonNum or 0)})
        end
    end

    table.sort(self._heroList, function(a, b)
        if a.aptitude ~= b.aptitude then
            return a.aptitude > b.aptitude
        else
            return a.actorId > b.actorId
        end
    end)

    self:startCheckHero()
end

function QHeroFragmentSecretary:startCheckHero()
    if q.isEmpty(self._heroList) then
        self:endSecretay("魂师扫荡已完成")
        return
    end

    local heroInfo = self._heroList[1]

    local config = db:getGradeByHeroActorLevel(heroInfo.actorId, heroInfo.grade + 1)
    if config == nil then
        config = db:getGradeByHeroActorLevel(heroInfo.actorId, heroInfo.grade)
    end
    local dropInfo = remote.instance:getDropInfoByItemId(config.soul_gem, DUNGEON_TYPE.ELITE)
    local dungeonIdList = {}
    for _, value in ipairs(dropInfo) do
        local resetNum = heroInfo.resetDungeonNum or 0
        local mapInfo = value.map or {}
        if mapInfo.isLock and mapInfo.info and (mapInfo.info.todayReset <= resetNum) then
            -- dungeonIdList[#dungeonIdList+1] = mapInfo.int_dungeon_id
            table.insert(dungeonIdList , mapInfo.int_dungeon_id)
        end
    end
    --排序
    table.sort(dungeonIdList, function (x, y)
        return x > y
    end )
    self:startFightDungeon(dungeonIdList, config.soul_gem, config.soul_gem_count, heroInfo.resetDungeonNum or 0)
end

function QHeroFragmentSecretary:startFightDungeon(dungeonIdList, itemId, itemCount, resetDungeonNum)
    if q.isEmpty(dungeonIdList) or itemId == nil or itemCount == nil or resetDungeonNum == nil then 
        self:endSecretay()
        return
    end

    local useEnergyItem = false
    local invationStop = false
    if self._invationSetting.selected then
        invationStop = true
    end
    local fightCallBack = function()
        remote.robot:dungeonQuickPassRequest(dungeonIdList, itemId, itemCount, invationStop, useEnergyItem, resetDungeonNum, true, function(data)    
            remote.secretary:updateSecretaryMultipleLog(data, 1) 
            local invasionInfo = data.userIntrusionResponse or {}
            if q.isEmpty(invasionInfo) == false and invasionInfo.bossHp > 0 and invationStop then
                -- 有要塞入侵
                invasionInfo.oldInvasionMoney = remote.user.intrusion_money or 0
                invasionInfo.oldAllHurtRank = invasionInfo.allHurtRank or 0
                invasionInfo.oldMaxHurtRank = invasionInfo.maxHurtRank or 0
                invasionInfo.userId = remote.user.userId
                self:startFightInvation(invasionInfo, function ()
                    self:startFightDungeon(dungeonIdList, itemId, itemCount, resetDungeonNum)
                end)
            else
                if data.gfQuickResponse.dungeonQuickPassResponse == nil then 
                    self:endFight()
                    return
                end

                local stopFlag = data.gfQuickResponse.dungeonQuickPassResponse.stopFor
                if stopFlag and stopFlag ~= 0 then
                    if stopFlag == 1 then --钻石不足
                        self:endSecretay("钻石不足，扫荡中断")
                    elseif stopFlag == 2 then  --体力不足
                        self:startFightDungeon(dungeonIdList, itemId, itemCount, resetDungeonNum)
                    end
                else
                    local waveCount = #(data.gfQuickResponse.dungeonQuickPassResponse.dungeonWaveReward or {})
                    if waveCount > 0 then
                        remote.activity:updateLocalDataByType(541, waveCount)
                    end
                    self:endFight()
                end
            end
        end, function()
            self:endSecretay("魂师碎片扫荡失败")
        end)
    end

    if self:_checkEnergy(12) == false then
        local checkEneryItem = function()    --自动使用体力道具
            local energyItemIds = { 25, 26, 27 }
            local haveItem = false
            for _, value in pairs(energyItemIds) do
                local itemNum = remote.items:getItemsNumByID( value )
                if itemNum and itemNum > 0 then
                    haveItem = true
                    break
                end
            end
            if haveItem then
                useEnergyItem = true
                fightCallBack()
            else
                self:endSecretay("魂师大人，体力不足~")
            end
        end

        local buyCount = remote.user.todayEnergyBuyCount or 0
        local setBuyNum = self._energySetting.buyEneryNum or 0
        if self._energySetting.selected then
            if setBuyNum > 0 and setBuyNum > buyCount then   --自动购买体力
                local config = db:getTokenConsume(ITEM_TYPE.ENERGY, buyCount+1)
                if remote.user.token >= (config.money_num or 0) then
                    self:buyEnergy(fightCallBack)
                elseif self._energySetting.firstBuyEnergy then
                    checkEneryItem()
                else
                    self:endSecretay("魂师大人，没有可完成的功能~")
                end
            elseif self._energySetting.firstBuyEnergy then
                checkEneryItem()
            else
                self:endSecretay("魂师大人，没有可完成的功能~")
            end
        else
            self:endSecretay("魂师大人，没有可完成的功能~")
        end
    else
        fightCallBack()
    end
end

function QHeroFragmentSecretary:startFightInvation(invasionInfo, callback,isLog)
    local attackType = self:getDoubleFire( invasionInfo.boss_type )
    local tokenNeeded = remote.robot:tokenNumberRequired( attackType )
    local printLog = function(str)
        if isLog then
            print("【传说魂兽】--------"..str)
        end
    end

    local level = invasionInfo.fightCount + 1
    local invasionArrangement = QInvasionArrangement.new({actorId = invasionInfo.bossId, level = level, type = attackType, invasion = invasionInfo, token = tokenNeeded})
    printLog("开始攻打请求")
    remote.invasion:getInvasionRequest(function(data)
        local isNeedShare = self._invationSetting.shareInvation
        if data.userIntrusionResponse.share then
            isNeedShare = false
        end
    
        if (tokenNeeded or 0) > remote.robot:currentTokenNumber() then 
            if self._invationSetting.useItem and remote.items:getItemsNumByID(self._invationItem) > 0 then
                -- 自动使用征讨令且背包里有征讨令
                printLog("使用令牌")
                remote.robot:openItemPackage(self._invationItem, 1, function() 
                        self:startFightInvation(invasionInfo, callback)
                    end)
                return
            else
                printLog("令牌不够")
                if callback then
                    callback()
                end
                return
            end
        end 
        printLog("战报生成")
        invasionArrangement:makeFightReportData(function(battleFormation, battleVerify)
            printLog("开始扫荡")
            remote.robot:intrusionQuickPassRequest(self._invationSetting.useItem, self:getDoubleFire( invasionInfo.boss_type ), isNeedShare, battleFormation, battleVerify, true, function(data)
                remote.user:update( data.wallet )
                remote.invasion:setAfterBattle(false)

                remote.secretary:updateSecretaryLog(data, 1)
                for key, value in pairs(data.userIntrusionResponse) do
                    if key ~= "bossId" and key ~= "boss_type" then
                        invasionInfo[key] = value
                    end
                end

                local criticalHit = 0
                if data.gfEndResponse.intrusionQuickPassResponse then
                    criticalHit = data.gfEndResponse.intrusionQuickPassResponse.fightCount
                    for i = 1, criticalHit, 1 do
                        remote.activity:updateLocalDataByType(531, 1)
                        remote.user:addPropNumForKey("c_fortressFightCount")
                        remote.user:addPropNumForKey("todayIntrusionFightCount")     

                        app.taskEvent:updateTaskEventProgress(app.taskEvent.INVATION_EVENT, 1, false, true)                                             
                    end
                end
                if data.userIntrusionResponse and data.userIntrusionResponse.bossHp == 0 then
                    remote.activity:updateLocalDataByType(544, 1)
                end

                if invasionInfo.bossHp > 0 then
                    if isNeedShare then
                        -- 真分享
                        remote.robot:shareIntrusionBossRequest()
                    end
                else
                    if isNeedShare and criticalHit then
                        remote.user:addPropNumForKey("todayIntrusionShareCount")
                    end
                end
                printLog("扫荡完成")
                if callback then
                    callback()
                end
            end)
        end)
    end)
end

function QHeroFragmentSecretary:buyEnergy(callBack)
    app:getClient():buyEnergy(1, true, function(data)
            remote.user:addPropNumForKey("addupBuyEnergyCount")
            remote.activity:updateLocalDataByType(506, 1)
            remote.user:update({todayEnergyBuyLastTime = q.serverTime()})

            app.taskEvent:updateTaskEventProgress(app.taskEvent.BUY_ENERGY_EVENT, 1, false, false)

            remote.secretary:updateSecretaryLog(data, 2) 

            if callBack then
                callBack()
            end
        end,function()
            if callBack then
                callBack()
            end
        end)
end

function QHeroFragmentSecretary:getDoubleFire(bossType)
    if bossType == 1 then
        return self._invationSetting.normalFight or 1
    elseif bossType == 2 then
        return self._invationSetting.eliteFight or 1
    elseif bossType == 3 then
        return self._invationSetting.welfareFight or 1
    elseif bossType == 4 then
        return self._invationSetting.legendFight or 1        
    end
end

function QHeroFragmentSecretary:endFight(tip)
    if tip then
        app.tip:floatTip(tip)
    end
    table.remove(self._heroList, 1)
    self:startCheckHero()
end

function QHeroFragmentSecretary:endSecretay(tip)
    -- if tip then
    --     app.tip:floatTip(tip)
    -- end
    print("QHeroFragmentSecretary------sendSecretay")
    self:autoCallSoulBeast(handler(self,self.getScoreAndAwards))
    -- self:openBoxAndGetScore()

    -- remote.secretary:nextTaskRunning()

end

function QHeroFragmentSecretary:_checkEnergy(needEnergy)
    if needEnergy == nil then return false end

    if remote.user.energy >= needEnergy then
        return true
    end

    return false
end

function QHeroFragmentSecretary:checkCallLegendMonster( )
    local invasion = remote.invasion:getSelfInvasion()
    if invasion.bossId ~=0 and not invasion.share then
        print("【传说魂兽】 invasion.bossId ~=0 and not invasion.share")
        return false
    end
    local allinvasions = remote.invasion:getInvasions()
    if #allinvasions >= 3 then
        print("【传说魂兽】 #allinvasions >= 3")
        return false
    end

    local energyConsume = remote.invasion:getEnergyConsume()
    local cost  = db:getConfigurationValue("intrusion_energy_consume") or 1 
    if energyConsume < cost then
        print("【传说魂兽】 energyConsume < cost")
        return false
    end
    local bossSummonCount = remote.invasion:getBossSummonCount()
    local totalCount  = db:getConfigurationValue("intrusion_boss_summon_max_count") or 1 

    if bossSummonCount >= totalCount then
        print("【传说魂兽】 bossSummonCount >= totalCount")
        return false
    end

    return true
end

function QHeroFragmentSecretary:autoCallSoulBeast( callback )
    local finshCallBack = function()
        if callback then
            callback()
        end
    end

    if self._invationSetting.autoCallInvation then
        remote.invasion:getInvasionRequest(function()
            if not self:checkCallLegendMonster() then
                finshCallBack()
            else
                remote.invasion:intrusionGenerateBossRequest(function(data)
                    local invasionInfo = data.userIntrusionResponse or {}
                    QPrintTable(data)
                    if q.isEmpty(invasionInfo) == false and invasionInfo.bossHp > 0 then
                        -- 有要塞入侵
                        invasionInfo.oldInvasionMoney = remote.user.intrusion_money or 0
                        invasionInfo.oldAllHurtRank = invasionInfo.allHurtRank or 0
                        invasionInfo.oldMaxHurtRank = invasionInfo.maxHurtRank or 0
                        invasionInfo.userId = remote.user.userId
                        self:startFightInvation(invasionInfo,function()
                            finshCallBack()
                        end,true)
                    else
                        finshCallBack()                  
                    end                
                end,function( )
                    finshCallBack()
                end)
            end
        end,function()
            finshCallBack()
        end)
    else
        finshCallBack()
    end
end

function QHeroFragmentSecretary:getScoreAndAwards()
    local finshCallBack = function()
        self:autoOpenBox()
    end

    if self._invationSetting.getwardsAndScore then
        local invasion = remote.invasion:getSelfInvasion()
        local dailyRewards = db:getIntrusionReward(1)
        local drawnRewardId = invasion.rewardInfo or ""
        local ids = {}
        local conditionLevel = remote.user.dailyTeamLevel == 0 and 1 or remote.user.dailyTeamLevel
        local maxRewardsLevel = 1
        for k, v in pairs(dailyRewards) do
            local drawn = false
            local _, pos = string.find(drawnRewardId, tostring(v.id))
            if pos then
                drawn = true
            end
            if conditionLevel and conditionLevel >= v.lowest_levels and conditionLevel <= v.maximum_levels then
                if drawn == false and v.meritorious_service <= invasion.allHurt then
                    table.insert(ids, v.id)
                end
            end
            maxRewardsLevel = maxRewardsLevel < v.maximum_levels and v.maximum_levels or maxRewardsLevel
        end
        if q.isEmpty(ids) == false then
            remote.invasion:getInvasionRewardRequest(ids,true,function(data)
                remote.secretary:updateSecretaryLog(data, 1)
            end)  
        end

        if remote.invasion:checkKillAwards() then
            remote.invasion:getIntrusionKillAwardRequest(nil,true,function(data)
                remote.invasion:deleteKillAward(nil)
                remote.secretary:updateSecretaryLog(data, 1)
                finshCallBack()
            end,function()
                finshCallBack()
            end)  
        else
            finshCallBack()
        end 
    else
        finshCallBack()
    end

end

function QHeroFragmentSecretary:autoOpenBox()
    local taskInfo = db:getTaskById("103200")
    local needNum = taskInfo and (taskInfo.num or 5) or 5
    local todayOpenNum =  remote.user:getPropForKey("todayIntrusionBoxOpenCount")

    local chestId = {} 
    local keyId = {} 
    local chestCount = {}
    local keyCount = {}
    local canbeOpenNum = {}
    for ii=1,3 do
        chestId[ii] = remote.invasion.CHEST[ii]
        keyId[ii] = remote.invasion.KEY[ii]
        chestCount[ii] = remote.items:getItemsNumByID(chestId[ii])
        keyCount[ii] = remote.items:getItemsNumByID(keyId[ii])
        canbeOpenNum[ii] = math.min(chestCount[ii],keyCount[ii])
    end
    local taskInfo = db:getTaskById("103200")
    local needNum = taskInfo and (taskInfo.num or 5) or 5
    local openBoxList = {}
    local openNum = 0
    local anylsBox = function(typeIndex)
        if openNum >= needNum then
            return
        end
        if canbeOpenNum[typeIndex] > 0 then
            if canbeOpenNum[typeIndex] >= needNum - openNum then
                table.insert(openBoxList,{boxType=typeIndex,boxCount=needNum - openNum})
                openNum = openNum+needNum
            else
                table.insert(openBoxList,{boxType=typeIndex,boxCount=canbeOpenNum[typeIndex]})
                openNum = openNum + canbeOpenNum[typeIndex]
            end
        end
    end

    if self._invationSetting.openBox == 1 and todayOpenNum < needNum then --默认开5个
        if canbeOpenNum[1] + canbeOpenNum[2] + canbeOpenNum[3] >= needNum then
            anylsBox(1)
            anylsBox(2)
            anylsBox(3)
            remote.invasion:intrusionOpenBossBoxRequest(nil, nil, openBoxList,function (data)
                remote.user:addPropNumForKey("todayIntrusionBoxOpenCount", needNum)
                remote.secretary:updateSecretaryLog(data, 1)
                remote.secretary:nextTaskRunning()
            end,function()
                remote.secretary:nextTaskRunning()
            end)            
        else
             app.tip:floatTip("箱子或者钥匙数量不足，无法完成开箱任务")
             remote.secretary:nextTaskRunning()
        end
    elseif self._invationSetting.openBox == 2 then --全部开启
        openBoxList = {}
        local allOpenNum = 0
        for ii=1,3 do
            if canbeOpenNum[ii] > 0 then
                table.insert(openBoxList,{boxType=ii,boxCount=canbeOpenNum[ii]})
                allOpenNum = allOpenNum + (canbeOpenNum[ii] or 0)
            end
        end
        if q.isEmpty(openBoxList) == false and allOpenNum > 0 then
            remote.invasion:intrusionOpenBossBoxRequest(nil, nil, openBoxList,function (data)
                remote.user:addPropNumForKey("todayIntrusionBoxOpenCount", allOpenNum)
                remote.secretary:updateSecretaryLog(data, 1)
                remote.secretary:nextTaskRunning()
            end,function()
                remote.secretary:nextTaskRunning()
            end)       
        else
            remote.secretary:nextTaskRunning()      
        end
    else
        remote.secretary:nextTaskRunning()
    end

    self:checkInvasionDialogTips()
end

function QHeroFragmentSecretary:checkInvasionDialogTips( )
    remote.invasion:getInvasionRequest(function()
        local energyConsume = remote.invasion:getEnergyConsume()
        local cost  = db:getConfigurationValue("intrusion_energy_consume") or 1 
        local bossSummonCount = remote.invasion:getBossSummonCount()
        local totalCount  = db:getConfigurationValue("intrusion_boss_summon_max_count") or 1 
        local invasion = remote.invasion:getSelfInvasion()
        if (energyConsume >= cost and bossSummonCount < totalCount) or (invasion and invasion.boss_type == 4 and invasion.bossHp > 0 ) then
            app:alert({content="您的传说魂兽还未处理，是否要前往魂兽入侵页面",title="系统提示",btnDesc={"前往"}, callback = function (state)
                app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
                if state == ALERT_TYPE.CONFIRM then
                    if app.unlock:getUnlockInvasion(true) then
                        remote.stores:getShopInfoFromServerById(SHOP_ID.invasionShop)
                        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasion", options = {}})
                    end
                end
            end})
        end
    end)
end

-- 打开宝箱
function QHeroFragmentSecretary:openItemPackageSecretaryRequest(itemId, count, success, fail, status)
    local itemOpenRequest = {itemId = itemId, count = count, isSecretary = true}
    local request = {api = "ITEM_OPEN", itemOpenRequest = itemOpenRequest}
    app:getClient():requestPackageHandler("ITEM_OPEN", request, success, fail)
end

-- 购买宝箱
function QHeroFragmentSecretary:buyShopItemSecretaryRequest(shopId, pos, itemId, count, buyCount, success, fail, status)
    local shopBuyRequest = {shopId = shopId, pos = pos, itemId = itemId, count = count, buyCount = buyCount, isSecretary = true}
    local request = {api = "SHOP_BUY", shopBuyRequest = shopBuyRequest}
    app:getClient():requestPackageHandler("SHOP_BUY", request, success, fail)
end

--刷新widget数据
function QHeroFragmentSecretary:refreshWidgetData(widget, itemData, index)
	QHeroFragmentSecretary.super.refreshWidgetData(self, widget, itemData, index)
	widget:setDescStr("")

    -- local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
end

function QHeroFragmentSecretary:_onTriggerSet()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroFragmentSecretary", 
		options = {secretaryId = self._secretaryId, callback = handler(self, self.saveSecretarySetting)}}, {isPopCurrentDialog = false})
end

function QHeroFragmentSecretary:saveSecretarySetting(setting)
    if setting == nil then return end
    printTable(setting)
	remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QHeroFragmentSecretary
