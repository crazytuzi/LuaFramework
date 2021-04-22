--
-- Author: Kumo.Wang
-- Date: Sat Mar  5 18:30:36 2016
-- 游戏内挂数据管理

local QBaseModel = import("...models.QBaseModel")
local QRobot = class("QRobot", QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QInvasionArrangement = import("...arrangement.QInvasionArrangement")
local QQuickWay = import("...utils.QQuickWay")

local MAX_INVASION_TOKEN = 10

QRobot.SOUL = 1
QRobot.MATERIAL = 2

QRobot.DUNGEON = 1001
QRobot.INVASION = 1002

QRobot.BUY_TYPE = "dungeon_elite" --精英副本

function QRobot:ctor()
    QRobot.super.ctor(self)

    self.waitDungeonId = 0
    self.totalReplayCount = 0
    self.totalReplayPrice = 0
    self.stopType = 0 -- 停止的类型：1，钻石不足。2，体力不足。
end

function QRobot:init()
    -- 灵魂碎片
    self.tmpSoulList = {}
    self.tmpSoulList["autoEnergy"] = false
    self.tmpSoulList["autoInvasion"] = false
    self.tmpSoulList["autoReplayOnce"] = false
    self.tmpSoulList["autoReplayTwice"] = false
    self.tmpSoulList["autoReplayTrible"] = false
    self.settingSoulList = {}
    self.settingSoulList["autoEnergy"] = false
    self.settingSoulList["autoInvasion"] = false
    self.settingSoulList["autoReplayOnce"] = false
    self.settingSoulList["autoReplayTwice"] = false
    self.settingSoulList["autoReplayTrible"] = false
    -- 升星材料
    self.tmpMaterialList = {}
    self.tmpMaterialList["autoEnergy"] = false
    self.tmpMaterialList["autoInvasion"] = false
    self.tmpMaterialList["autoElite"] = false
    self.tmpMaterialList["autoNormal"] = false
    self.settingMaterialList = {}
    self.settingMaterialList["autoEnergy"] = false
    self.settingMaterialList["autoInvasion"] = false
    self.settingMaterialList["autoElite"] = false
    self.settingMaterialList["autoNormal"] = false
    -- 要塞
    self.tmpInvasionList = {}
    self.tmpInvasionList["doubleFires1"] = false
    self.tmpInvasionList["doubleFires2"] = false
    self.tmpInvasionList["doubleFires3"] = false
    self.tmpInvasionList["doubleFires4"] = false
    self.tmpInvasionList["isShare"] = false
    self.tmpInvasionList["autoIntrusionToken"] = false
    self.settingInvasionList = {}
    self.settingInvasionList["doubleFires1"] = false
    self.settingInvasionList["doubleFires2"] = false
    self.settingInvasionList["doubleFires3"] = false
    self.settingInvasionList["doubleFires4"] = false
    self.settingInvasionList["isShare"] = false
    self.settingInvasionList["autoIntrusionToken"] = false

    print("[Kumo] QRobot:init() ", app:getUserOperateRecord():hasRobotSoulSetting(), app:getUserOperateRecord():hasRobotMaterialSetting(), app:getUserOperateRecord():hasRobotInvasionSetting())
end

function QRobot:disappear()
end

function QRobot:loginEnd()
    -- 游戏登入完获取本地设置信息
    -- print("[Kumo] QRobot:loginEnd() ", app:getUserOperateRecord():hasRobotSoulSetting(), app:getUserOperateRecord():hasRobotMaterialSetting(), app:getUserOperateRecord():hasRobotInvasionSetting())
    if app:getUserOperateRecord():hasRobotSoulSetting() then
        for key, _ in pairs(self.settingSoulList) do
            self.tmpSoulList[key] = app:getUserOperateRecord():getRobotSoulSetting( key )
            self.settingSoulList[key] = app:getUserOperateRecord():getRobotSoulSetting( key )
        end
        -- QPrintTable(self.settingSoulList)
    end

    if app:getUserOperateRecord():hasRobotMaterialSetting() then
        for key, _ in pairs(self.settingMaterialList) do
            self.tmpMaterialList[key] = app:getUserOperateRecord():getRobotMaterialSetting( key )
            self.settingMaterialList[key] = app:getUserOperateRecord():getRobotMaterialSetting( key )
        end
        -- QPrintTable(self.settingMaterialList)
    end

    if app:getUserOperateRecord():hasRobotInvasionSetting() then
        for key, _ in pairs(self.settingInvasionList) do
            self.tmpInvasionList[key] = app:getUserOperateRecord():getRobotInvasionSetting( key )
            self.settingInvasionList[key] = app:getUserOperateRecord():getRobotInvasionSetting( key )
        end
        -- QPrintTable(self.settingInvasionList)
    end
end

-- 是否自动吃体力药水（从小到大吃）
function QRobot:setTmpAutoSoulEnergy( boo )
    self.tmpSoulList["autoEnergy"] = boo
end
function QRobot:getTmpAutoSoulEnergy()
    return self.tmpSoulList["autoEnergy"]
end

function QRobot:setAutoSoulEnergy( boo )
    self.settingSoulList["autoEnergy"] = boo
end
function QRobot:getAutoSoulEnergy()
    return self.settingSoulList["autoEnergy"]
end

function QRobot:setTmpAutoMaterialEnergy( boo )
    self.tmpMaterialList["autoEnergy"] = boo
end
function QRobot:getTmpAutoMaterialEnergy()
    return self.tmpMaterialList["autoEnergy"]
end

function QRobot:setAutoMaterialEnergy( boo )
    self.settingMaterialList["autoEnergy"] = boo
end
function QRobot:getAutoMaterialEnergy()
    return self.settingMaterialList["autoEnergy"]
end

-- 是否自动攻打要塞
function QRobot:setTmpAutoSoulInvasion( boo )
    self.tmpSoulList["autoInvasion"] = boo
end
function QRobot:getTmpAutoSoulInvasion()
    return self.tmpSoulList["autoInvasion"]
end

function QRobot:setAutoSoulInvasion( boo )
    self.settingSoulList["autoInvasion"] = boo
end
function QRobot:getAutoSoulInvasion()
    return self.settingSoulList["autoInvasion"]
end

function QRobot:setTmpAutoMaterialInvasion( boo )
    self.tmpMaterialList["autoInvasion"] = boo
end
function QRobot:getTmpAutoMaterialInvasion()
    return self.tmpMaterialList["autoInvasion"]
end

function QRobot:setAutoMaterialInvasion( boo )
    self.settingMaterialList["autoInvasion"] = boo
end
function QRobot:getAutoMaterialInvasion()
    return self.settingMaterialList["autoInvasion"]
end

-- 是否扫荡精英副本
function QRobot:setTmpAutoMaterialElite( boo )
    self.tmpMaterialList["autoElite"] = boo
end
function QRobot:getTmpAutoMaterialElite()
    return self.tmpMaterialList["autoElite"]
end

function QRobot:setAutoMaterialElite( boo )
    self.settingMaterialList["autoElite"] = boo
end
function QRobot:getAutoMaterialElite()
    return self.settingMaterialList["autoElite"]
end

-- 是否扫荡普通副本
function QRobot:setTmpAutoMaterialNormal( boo )
    self.tmpMaterialList["autoNormal"] = boo
end
function QRobot:getTmpAutoMaterialNormal()
    return self.tmpMaterialList["autoNormal"]
end

function QRobot:setAutoMaterialNormal( boo )
    self.settingMaterialList["autoNormal"] = boo
end
function QRobot:getAutoMaterialNormal()
    return self.settingMaterialList["autoNormal"]
end

-- 是否重置关卡一次
function QRobot:setTmpAutoSoulReplayOnce( boo )
    self.tmpSoulList["autoReplayOnce"] = boo
end
function QRobot:getTmpAutoSoulReplayOnce()
    return self.tmpSoulList["autoReplayOnce"]
end

function QRobot:setAutoSoulReplayOnce( boo )
    self.settingSoulList["autoReplayOnce"] = boo
end
function QRobot:getAutoSoulReplayOnce()
    return self.settingSoulList["autoReplayOnce"]
end

-- 是否重置关卡两次
function QRobot:setTmpAutoSoulReplayTwice( boo )
    self.tmpSoulList["autoReplayTwice"] = boo
end
function QRobot:getTmpAutoSoulReplayTwice()
    return self.tmpSoulList["autoReplayTwice"]
end

function QRobot:setAutoSoulReplayTwice( boo )
    self.settingSoulList["autoReplayTwice"] = boo
end
function QRobot:getAutoSoulReplayTwice()
    return self.settingSoulList["autoReplayTwice"]
end

-- 是否重置关卡三次
function QRobot:setTmpAutoSoulReplayTrible( boo )
    self.tmpSoulList["autoReplayTrible"] = boo
end
function QRobot:getTmpAutoSoulReplayTrible()
    return self.tmpSoulList["autoReplayTrible"]
end

function QRobot:setAutoSoulReplayTrible( boo )
    self.settingSoulList["autoReplayTrible"] = boo
end
function QRobot:getAutoSoulReplayTrible()
    return self.settingSoulList["autoReplayTrible"]
end

-- 是否全力一击, 1 绿；2 蓝；3 紫 4橙
function QRobot:setTmpDoubleFire( boo, bossType )
    self.tmpInvasionList["doubleFires"..bossType] = boo
end
function QRobot:getTmpDoubleFire( bossType )
    return self.tmpInvasionList["doubleFires"..bossType]
end

function QRobot:setDoubleFire( boo, bossType )
    self.settingInvasionList["doubleFires"..bossType] = boo
end
function QRobot:getDoubleFire( bossType )
    return self.settingInvasionList["doubleFires"..bossType]
end

-- 是否分享
function QRobot:setTmpIsShare( boo )
    self.tmpInvasionList["isShare"] = boo
end
function QRobot:getTmpIsShare()
    return self.tmpInvasionList["isShare"]
end

function QRobot:setIsShare( boo )
    self.settingInvasionList["isShare"] = boo
end
function QRobot:getIsShare()
    return self.settingInvasionList["isShare"]
end

-- 是否自动使用征讨令
function QRobot:setTmpAutoIntrusionToken( boo )
    self.tmpInvasionList["autoIntrusionToken"] = boo
end
function QRobot:getTmpAutoIntrusionToken()
    return self.tmpInvasionList["autoIntrusionToken"]
end

function QRobot:setAutoIntrusionToken( boo )
    self.settingInvasionList["autoIntrusionToken"] = boo
end
function QRobot:getAutoIntrusionToken()
    return self.settingInvasionList["autoIntrusionToken"]
end

function QRobot:getTotalReplayCount()
    return self.totalReplayCount
end
function QRobot:getTotalReplayPrice()
    return self.totalReplayPrice
end

-----------------------------------------------------

function QRobot:getItemCategoryByID( itemID )
    local config = QStaticDatabase.sharedDatabase():getItemByID( itemID )
    if config then
        return config.category
    else
        return nil
    end
end

function QRobot:getItemTypeByID( itemID )
    local config = QStaticDatabase.sharedDatabase():getItemByID( itemID )
    if config then
        return config.type
    else
        return nil
    end
end

function QRobot:isComposeItemByID( itemID )
    return QStaticDatabase.sharedDatabase():getItemCraftByItemId( itemID )
end

function QRobot:getItemConfigByID( id )
    return QStaticDatabase.sharedDatabase():getItemByID( id )
end

function QRobot:getItemsNumByID( id )
    return remote.items:getItemsNumByID( id )
end

-- 获取下一个奖励的信息
function QRobot:getNextAward()
    local tbl = {}
    self._showKey = self._showKey + 1
    if self._awardList[self._showKey] and table.nums(self._awardList[self._showKey]) > 0 then
        tbl = self._awardList[self._showKey]
    else
        self._showKey = self._showKey - 1
    end

    return tbl
end

-- 获取余下所有的奖励信息列表
function QRobot:getLeftAwardList()
    local tbl = {}
    for key = self._showKey + 1, #self._awardList, 1 do
        table.insert(tbl, self._awardList[key])
    end
    self._showKey = #self._awardList
    return tbl
end

function QRobot:isShowGotoInvasion()
    return self._isShowGotoInvasion
end

function QRobot:getGotoInvasionName()
    return self._gotoInvasionName 
end

function QRobot:getItemId()
    return self._itemId
end

function QRobot:getNeedNum()
    return self._needNum
end

function QRobot:stopRobot()
    -- app.tip:floatTip("【测试用】手动停止扫荡")
    self._stop = true
end

function QRobot:continueRobot()
    self._stop = false
end

function QRobot:isStopRobot()
    return self._stop
end

function QRobot:getAwardShowAtEnd()
    -- QPrintTable(self._awardShowAtEnd)
    -- print(#self._awardShowAtEnd)
    if self._awardShowAtEnd and #self._awardShowAtEnd > 1 then
        table.sort(self._awardShowAtEnd, function(a, b)
                if a.id and b.id then
                    return a.id < b.id
                elseif not a.id then
                    return false
                else
                    return true
                end
            end)
    end
    -- QPrintTable(self._awardShowAtEnd)
    return self._awardShowAtEnd or {}
end

function QRobot:getAllInvasionMoney()
    return self._allInvasionMoney or 0
end

function QRobot:saveSetting( callback )
    for key, value in pairs(self.tmpSoulList) do
        self.settingSoulList[key] = value
    end
    self:needSoulSave()

    for key, value in pairs(self.tmpMaterialList) do
        self.settingMaterialList[key] = value
    end
    self:needMaterialSave()

    for key, value in pairs(self.tmpInvasionList) do
        self.settingInvasionList[key] = value
    end
    self:needInvasionSave()

    if callback ~= nil then
        callback()
    end
end

function QRobot:giveUpSetting( callback )
    for key, value in pairs(self.settingSoulList) do
        self.tmpSoulList[key] = value
    end

    for key, value in pairs(self.settingMaterialList) do
        self.tmpMaterialList[key] = value
    end

    for key, value in pairs(self.settingInvasionList) do
        self.tmpInvasionList[key] = value
    end

    if callback ~= nil then
        callback()
    end
end

function QRobot:needSoulSave()
    -- self.isNeedSoulSave = true
    -- if self.isNeedSoulSave then
        -- QPrintTable(self.settingSoulList)
        for key, value in pairs(self.settingSoulList) do
            app:getUserOperateRecord():setRobotSoulSetting( key, value )
        end
    -- end
end

function QRobot:needMaterialSave()
    -- self.isNeedMaterialSave = true
    -- if self.isNeedMaterialSave then
        -- QPrintTable(self.settingMaterialList)
        for key, value in pairs(self.settingMaterialList) do
            app:getUserOperateRecord():setRobotMaterialSetting( key, value )
        end
    -- end
end

function QRobot:needInvasionSave()
    -- self.isNeedInvasionSave = true
    -- if self.isNeedInvasionSave then
        -- QPrintTable(self.settingInvasionList)
        for key, value in pairs(self.settingInvasionList) do
            app:getUserOperateRecord():setRobotInvasionSetting( key, value )
        end
    -- end
end

function QRobot:checkRobotUnlock(isTips)
    return app.unlock:getUnlockRobot(isTips)
end

function QRobot:checkRobotUnlockForSociety(isTips)
    return app.unlock:getUnlockRobotForSociety(isTips)
end

function QRobot:getResetPriceByID( id, previewReplayCount )
    local refreshTime = q.refreshTime(remote.user.c_systemRefreshTime) * 1000
    local passInfo = remote.instance:getPassInfoForDungeonID( id )
    local todayReset = 0
    if passInfo.lastPassAt > refreshTime then
        todayReset = passInfo.todayReset
    end
    -- QPrintTable(passInfo)
    -- 策划要求，重置不是无限的，而是每个关卡每日最多重置一次或两次
    local maxReplayCount = 0
    if previewReplayCount then
        maxReplayCount = tonumber(previewReplayCount)
    elseif self:getAutoSoulReplayTrible() then
        maxReplayCount = 3
    elseif self:getAutoSoulReplayTwice() then
        maxReplayCount = 2
    elseif self:getAutoSoulReplayOnce() then
        maxReplayCount = 1
    else
        maxReplayCount = 0
    end
    -- print(todayReset, maxReplayCount)
    if tonumber(todayReset) >= tonumber(maxReplayCount) then
        -- 当日重置次数已经用完
        return 0
    end
    
    local config = QStaticDatabase:sharedDatabase():getTokenConsume(self.BUY_TYPE, (previewReplayCount or 1))
    if tonumber(config.consume_times) < tonumber(previewReplayCount or 1) then
        -- 重置次数已经用完
        return 0
    else
        -- print("price = ", config.money_num)
        return config.money_num
    end
end

-- @previewReplayCount 重置次数，用于预算 ： 0，不勾选重置。1，勾选重置一次。2，勾选重置两次
function QRobot:getTotalResetPriceByBaseList( baseList, previewReplayCount )
    -- QPrintTable(baseList)
    local price = 0
    local replaycount = 0
    if previewReplayCount then
        replaycount = tonumber(previewReplayCount)
    elseif self:getAutoSoulReplayTrible() then
        replaycount = 3
    elseif self:getAutoSoulReplayTwice() then
        replaycount = 2
    elseif self:getAutoSoulReplayOnce() then
        replaycount = 1
    else
        replaycount = 0
    end

    for _, value in pairs( baseList ) do
        for i = 1, replaycount, 1 do
            price = price + self:getResetPriceByID( value.dungeonId, i )
        end
    end

    return price
end

-- @previewReplayCount 重置次数，用于预算 ： 0，不勾选重置。1，勾选重置一次。2，勾选重置两次
function QRobot:getTotalEliteAttackListByBaseList( baseList, robotType, previewReplayCount )
    local tbl = {}
    local hasFree = false -- 是否有免费的关卡次数
    local minPrice = 0
    for _, info in pairs(baseList) do
        local tmp, tmpHasFree, tmpMinPrice = self:getOneEliteAttackListByInfo(info, robotType, previewReplayCount)
        for _, value in pairs(tmp) do
            table.insert(tbl, value)
        end
        if tmpHasFree then
            hasFree = true
        end
        if tmpMinPrice ~= 0 then
            if minPrice == 0 or (minPrice > tonumber(tmpMinPrice) and tonumber(tmpMinPrice) ~= 0) then
                minPrice = tonumber(tmpMinPrice)
            end
        end
    end

    return tbl, hasFree, minPrice
end

function QRobot:getCurEliteAttackListByBaseList( baseList, robotType, curReplayCount, callback )
    if self.isWaiting then return nil, baseList end 
    self.isWaiting = false

    local tbl = {}
    local maxReplayCount = 0 -- 最大可重置次数。量表配置可以重置30次，如果在30次内，最大可以重置2次，否则，就可能是1次甚至0次。

    -- print("QRobot:getCurEliteAttackListByBaseList()  ", curReplayCount)
    if robotType == self.MATERIAL or not curReplayCount or curReplayCount == 0 then
        -- 材料
        -- print("QRobot:getCurEliteAttackListByBaseList(1)  ")
        for _, info in pairs(baseList) do
            if not info.replayCount then
                local tmp = self:getOneEliteAttackListByInfo(info, robotType, 0)
                for _, value in pairs(tmp) do
                    table.insert(tbl, value)
                end
                info.replayCount = 0
            end
        end
        -- QPrintTable(tbl)
    else
        -- print("QRobot:getCurEliteAttackListByBaseList(2)  ")
        if self:getAutoSoulReplayTrible() then
            maxReplayCount = 3
        elseif self:getAutoSoulReplayTwice() then
            maxReplayCount = 2
        elseif self:getAutoSoulReplayOnce() then
            maxReplayCount = 1
        else
            maxReplayCount = 0
        end

        for _, info in pairs(baseList) do
            if self.waitDungeonId ~= 0 and self.waitDungeonId == info.dungeonId then
                local tmp = self:getOneEliteAttackListByInfo(info, robotType, 0)
                for _, value in pairs(tmp) do
                    table.insert(tbl, value)
                end
                info.replayCount = info.replayCount + 1
                self.waitDungeonId = 0
                self.waitReplayPrice = 0
                break
            end
            if info.replayCount < maxReplayCount and info.replayCount < curReplayCount and self:getResetPriceByID( info.dungeonId ) ~= 0 then
                if remote.user.token >= self:getResetPriceByID( info.dungeonId ) then
                    self.isWaiting = true
                    self.waitDungeonId = info.dungeonId
                    self.waitReplayPrice = self:getResetPriceByID( info.dungeonId )
                    tbl = nil
                    app:getClient():buyDungeonTicket(info.dungeonId, function ()
                        self.totalReplayCount = self.totalReplayCount + 1
                        self.totalReplayPrice = self.totalReplayPrice + self.waitReplayPrice
                        self.isWaiting = false
                    end,function ()
                        self.isWaiting = false
                    end)
                else
                    app.tip:floatTip("魂师大人，您的钻石不足，无法重置关卡，扫荡结束")
                end
                break
            end
        end
        -- QPrintTable(tbl)
    end

    return tbl, baseList
end

function QRobot:getOneEliteAttackListByInfo( info, robotType, previewReplayCount )
    local tbl = {}
    local hasFree = false
    local minPrice = 0
    local todayPass = 0
    local passInfo = remote.instance:getPassInfoForDungeonID( info.dungeonId )
    if q.refreshTime(remote.user.c_systemRefreshTime) <= (passInfo.lastPassAt/1000) then
        todayPass = passInfo.todayPass
    end

    local replaycount = 0
    local maxReplayCount = 0 -- 最大可重置次数。量表配置可以重置30次，如果在30次内，最大可以重置2次，否则，就可能是1次甚至0次。
    local num = info.totalCount - todayPass

    if robotType == self.MATERIAL then
        -- 材料
        replaycount = 0
    else
        -- 灵魂碎片
        if previewReplayCount then
            maxReplayCount = tonumber(previewReplayCount)
        elseif self:getResetPriceByID(info.dungeonId, 3) ~= 0 then
            maxReplayCount = 3
        elseif self:getResetPriceByID(info.dungeonId, 2) ~= 0 then
            maxReplayCount = 2
        elseif self:getResetPriceByID(info.dungeonId, 1) ~= 0 then
            maxReplayCount = 1
        else
            maxReplayCount = 0
        end

        if previewReplayCount then
            replaycount = tonumber(previewReplayCount)
        else
            if self.settingSoulList["autoReplayOnce"] then
                if maxReplayCount >= 1 then
                    replaycount = 1
                else
                    replaycount = maxReplayCount
                end
            elseif self.settingSoulList["autoReplayTwice"] then
                if maxReplayCount >= 2 then
                    replaycount = 2
                else
                    replaycount = maxReplayCount
                end
            elseif self.settingSoulList["autoReplayTrible"] then
                if maxReplayCount >= 3 then
                    replaycount = 3
                else
                    replaycount = maxReplayCount
                end
            else
                replaycount = 0
            end
        end
    end

    local failReplayCount = 0
    for i = 1, tonumber(replaycount), 1 do
        if self:getResetPriceByID(info.dungeonId, i) == 0 then
            failReplayCount = failReplayCount + 1
        end
    end
    replaycount =  replaycount - failReplayCount

    local totalNum = num + info.totalCount * replaycount
    for i = 1, totalNum, 1 do
        -- local tbl = { id = value.map.id, dungeonId = value.map.dungeon_id, dungeonType = value.map.dungeon_type, itemId = value.targetId, needNum = value.needNum, title = value.map.number, totalCount = value.map.attack_num }
        table.insert(tbl, info)
    end

    if num > 0 then
        hasFree = true
    end
    if replaycount > 0 then
        minPrice = self:getResetPriceByID(info.dungeonId)
    end
    return tbl, hasFree, minPrice
end

function QRobot:getStopType()
    return self.stopType
end

-----------------------------------------------------

function QRobot:startRobot( list, robotType )
    -- QPrintTable(list)
    table.sort(list["Elite"], function(a,b) return a.id < b.id end)
    if not self:_checkEnergy( list, robotType ) then
        -- app.tip:floatTip("【测试用】您没有体力进行扫荡～")
        QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.ENERGY)
        return
    end

    self.totalReplayCount = 0
    self.totalReplayPrice = 0

    if robotType == self.MATERIAL and not self.settingMaterialList["autoElite"] and list["Elite"] and #list["Elite"] > 0 then
        list["Elite"] = {}
    end
    if not self.settingMaterialList["autoNormal"] and list["Normal"] and #list["Normal"] > 0 then
        list["Normal"] = {}
    end
    self._list = list
    self._robotType = robotType
    self._index = 1
    self._showKey = 0
    self._awardList = {}
    self._awardShowAtEnd = {}
    self._allInvasionMoney = 0
    self.stopType = 0

    self._stop = false

    self._itemId = nil
    self._needNum = nil

    self._isShowGotoInvasion = false
    self._gotoInvasionName = ""

    if list["Elite"] and #list["Elite"] > 0 then
        self._itemId = list["Elite"][1].itemId
        self._needNum = list["Elite"][1].needNum
    elseif list["Normal"] and #list["Normal"] > 0 then
        self._itemId = list["Normal"][1].itemId
        self._needNum = list["Normal"][1].needNum
    end

    print("QRobot:startRobot( list, robotType ) ", self._itemId, self._needNum)

    if not self._itemId or not self._needNum then
        return
    end

    if (self._robotType == self.SOUL and self:getAutoSoulInvasion()) or (self._robotType == self.MATERIAL and self:getAutoMaterialInvasion()) then
        self._ifIntrusionStop = true
    else
        self._ifIntrusionStop = false
    end
    if (self._robotType == self.SOUL and self:getAutoSoulEnergy()) or (self._robotType == self.MATERIAL and self:getAutoMaterialEnergy()) then
        self._ifConsumeEnergyToken = true
    else
        self._ifConsumeEnergyToken = false
    end
    if self._robotType == self.SOUL then
        if self:getAutoSoulReplayTrible() then
            self._dungeonResetCount = 3
        elseif self:getAutoSoulReplayTwice() then
            self._dungeonResetCount = 2
        elseif self:getAutoSoulReplayOnce() then
            self._dungeonResetCount = 1
        else
            self._dungeonResetCount = 0
        end
    end
    self._intrusionTokenId = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_TOKEN_ITEM_ID"].value or 201

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRobotInformation",
        options = {list = list, robotType = robotType}})
end

function QRobot:robotForDungeon( callback1, callback2 )
    if not self._itemId then 
        -- app.tip:floatTip("【测试用】没有itemId！")
        self._stop = true
        return 
    end
    local inPackCount = remote.items:getItemsNumByID( self._itemId ) or 0
    local itemCount = 0
    if self._needNum > inPackCount then
        itemCount = self._needNum - inPackCount
    else
        -- app.tip:floatTip("【测试用】物品数量满足！")
        self._stop = true
    end

    if self._stop then
        -- QPrintTable(self._awardList)
        callback2()
        return
    end

    local dungeonIdList = self:_getDungeonIdList()
    self._invasion = nil
    self.stopType = 0

    self:dungeonQuickPassRequest(dungeonIdList, self._itemId, itemCount, self._ifIntrusionStop, self._ifConsumeEnergyToken, self._dungeonResetCount, false, function(data)
            if data.gfQuickResponse.dungeonQuickPassResponse then 
                -- if data.gfQuickResponse.dungeonQuickPassResponse.resetCount > self.totalReplayCount then
                    self.totalReplayCount = self.totalReplayCount + data.gfQuickResponse.dungeonQuickPassResponse.resetCount
                -- end
                -- if data.gfQuickResponse.dungeonQuickPassResponse.tokenConsume > self.totalReplayPrice then
                    self.totalReplayPrice = self.totalReplayPrice + data.gfQuickResponse.dungeonQuickPassResponse.tokenConsume
                -- end
                if data.gfQuickResponse.dungeonQuickPassResponse.dungeonWaveReward and #data.gfQuickResponse.dungeonQuickPassResponse.dungeonWaveReward > 0 then
                    for _, dungeon in pairs(data.gfQuickResponse.dungeonQuickPassResponse.dungeonWaveReward or {}) do
                        local id = self:_getDungeonIdByIntId( dungeon.dungeonId )
                        local dungeonInfo = remote.instance:getDungeonById(id)
                        local dungeonType = dungeonInfo.dungeon_type
                        if dungeonType == DUNGEON_TYPE.NORMAL then
                            remote.activity:updateLocalDataByType(540, 1)
                            remote.union.unionActive:updateActiveTaskProgress(20004, 6)
                        elseif dungeonType == DUNGEON_TYPE.ELITE then
                            remote.activity:updateLocalDataByType(541, 1)
                            remote.union.unionActive:updateActiveTaskProgress(20004, 12)
                        end

                        local awards = dungeon.awardList or {}
                        if dungeon.expAwardList and #dungeon.expAwardList > 0 then
                            for _, value in pairs(dungeon.expAwardList) do
                                table.insert(awards, value)
                            end
                        end
                        for _, award in pairs(awards) do
                            local typeName = remote.items:getItemType(award.type)
                            if typeName ~= ITEM_TYPE.ITEM then
                                -- 金币，经验之类
                                table.insert(self._awardShowAtEnd, award)
                            elseif award.id == 3 or award.id == 4 or award.id == 5 or award.id == 6 then
                                -- 经验药水
                                table.insert(self._awardShowAtEnd, award)
                            else
                                local category = self:getItemCategoryByID(award.id)
                                if category and category == ITEM_CONFIG_CATEGORY.SOUL then
                                    -- 碎片
                                    table.insert(self._awardShowAtEnd, award)
                                end
                            end
                        end

                        table.insert(self._awardList, {info = awards, isInvasion = false, dungeonType = dungeonType, index = self._index})
                        self._index = self._index + 1
                    end

                    -- 转盘活动奖券
                    if data.prizeWheelMoneyGot and data.prizeWheelMoneyGot > 0 then
                        table.insert(self._awardShowAtEnd, {type = ITEM_TYPE.PRIZE_WHEEL_MONEY, count = data.prizeWheelMoneyGot, isActivity = true})
                    end
                else
                    -- app.tip:floatTip("【测试用】后端扫荡无奖励！")
                    if data.gfQuickResponse.dungeonQuickPassResponse.stopFor then
                        if data.gfQuickResponse.dungeonQuickPassResponse.stopFor == 1 then
                            -- 钻石不足
                            self.floatTipStr = "钻石不足，扫荡中断"
                            self.stopType = 1
                        elseif data.gfQuickResponse.dungeonQuickPassResponse.stopFor == 2 then
                            -- 体力不足
                            self.floatTipStr = "体力不足，扫荡中断"
                            self.stopType = 2
                        end
                    end
                    self._stop = true
                end
            end

            if callback1 then
                callback1(data)
            end

            if data.userIntrusionResponse and table.nums(data.userIntrusionResponse) > 0 then
                -- 有要塞入侵
                self._invasion = clone(data.userIntrusionResponse)
                self._invasion.oldInvasionMoney = remote.user.intrusion_money or 0
                self._invasion.oldAllHurtRank = clone(data.userIntrusionResponse.allHurtRank)
                self._invasion.oldMaxHurtRank = clone(data.userIntrusionResponse.maxHurtRank)
                self._invasion.userId = remote.user.userId
            end

            self:robotForInvasion(callback2)
        end)
end

function QRobot:robotForInvasion( callback )
    print("[Kumo] QRobot:robotForInvasion( callback ) ")
    local isPlayCallback = true
    if self._invasion then
        if (self._robotType == self.SOUL and self:getAutoSoulInvasion()) or (self._robotType == self.MATERIAL and self:getAutoMaterialInvasion()) then
            local unlockLevel = app.unlock:getConfigByKey("UNLOCK_FORTRESS").team_level
            if remote.user.level >= unlockLevel then
                local attackType = (self:getDoubleFire( self._invasion.boss_type ) and 2) or 1
                local tokenNeeded = self:tokenNumberRequired( attackType )

                if self._invasion.bossHp == 0 then
                    -- self._invasion = nil
                else
                    isPlayCallback = false
                    local level = self._invasion.fightCount + 1
                    local invasionArrangement = QInvasionArrangement.new({actorId = self._invasion.bossId, level = level, type = attackType, invasion = self._invasion, token = tokenNeeded})
                    remote.invasion:getInvasionRequest(function(data)
                            local isNeedShare = remote.robot:getIsShare() and not data.userIntrusionResponse.share
                        
                            if tokenNeeded > self:currentTokenNumber() then 
                                if self:getAutoIntrusionToken() and remote.items:getItemsNumByID( self._intrusionTokenId ) > 0 then
                                    -- 自动使用征讨令且背包里有征讨令
                                    self:openItemPackage(self._intrusionTokenId, 1, function() 
                                            self:robotForInvasion( callback )
                                        end)
                                    return
                                else
                                    -- app.tip:floatTip("【测试用】扫荡结束，要塞攻击次数不足~")
                                    self._isShowGotoInvasion = true
                                    local level = self._invasion.fightCount + 1
                                    local maxLevel = db:getIntrusionMaximumLevel(self._invasion.bossId)
                                    level = math.min(level, maxLevel)
                                    self._gotoInvasionName = string.format("%s(LV.%d)", QStaticDatabase:sharedDatabase():getCharacterByID(self._invasion.bossId).name, level)
                                    -- self._stop = true
                                    self._invasion = nil
                                    if callback then
                                        callback()
                                    end
                                    -- self.floatTipStr = "魂兽入侵，扫荡中断"
                                    return
                                end
                            end 
                            invasionArrangement:makeFightReportData(function(battleFormation, battleVerify)
                                    self:intrusionQuickPassRequest(self:getAutoIntrusionToken(), self:getDoubleFire( self._invasion.boss_type ), isNeedShare, battleFormation, battleVerify, false, function(data)
                                            -- app.tip:floatTip("【测试用】打死为止")
                                            remote.user:update( data.wallet )
                                            remote.invasion:setAfterBattle(false)
                                            -- 更新self._invasion里的数据
                                            for key, value in pairs(data.userIntrusionResponse) do
                                                if key ~= "bossId" and key ~= "boss_type" then
                                                    self._invasion[key] = value
                                                end
                                            end
                                            -- 记录一共对boss造成的伤害量
                                            if self._invasion.totalDamage then
                                                self._invasion.totalDamage = self._invasion.totalDamage + data.userIntrusionResponse.deltaBossHp
                                            else
                                                self._invasion.totalDamage = data.userIntrusionResponse.deltaBossHp
                                            end
                                            if data.gfEndResponse.intrusionQuickPassResponse then
                                                self._invasion.criticalHit = data.gfEndResponse.intrusionQuickPassResponse.fightCount
                                                -- print("self._invasion.criticalHit = ", data.gfEndResponse.intrusionQuickPassResponse.fightCount, self._invasion.criticalHit)
                                                for i = 1, self._invasion.criticalHit, 1 do
                                                    -- print("i = ", i)
                                                    remote.activity:updateLocalDataByType(531, 1)
                                                    remote.user:addPropNumForKey("c_fortressFightCount")
                                                    remote.user:addPropNumForKey("todayIntrusionFightCount")     

                                                    app.taskEvent:updateTaskEventProgress(app.taskEvent.INVATION_EVENT, 1, false, true)                                             
                                                end
                                            end
                                            if data.userIntrusionResponse and data.userIntrusionResponse.bossHp == 0 then
                                                remote.activity:updateLocalDataByType(544, 1)
                                            end

                                            table.insert(self._awardList, {info = self._invasion, isInvasion = true, index = 0})

                                            if self._invasion.bossHp > 0 then
                                                -- 没有打死
                                                if isNeedShare then
                                                    -- 真分享
                                                    self:shareIntrusionBossRequest()
                                                end
                                                self._isShowGotoInvasion = true
                                                local level = self._invasion.fightCount + 1
                                                local maxLevel = db:getIntrusionMaximumLevel(self._invasion.bossId)
                                                level = math.min(level, maxLevel)
                                                self._gotoInvasionName = string.format("%s(LV.%d)", QStaticDatabase:sharedDatabase():getCharacterByID(self._invasion.bossId).name, level)
                                                -- self._stop = true
                                                -- self.floatTipStr = "魂兽入侵，扫荡中断"
                                            else
                                                if isNeedShare then
                                                    -- 假分享，攻打一次不算，两次以上做假分享
                                                    if self._invasion.criticalHit then
                                                        remote.user:addPropNumForKey("todayIntrusionShareCount")
                                                    end
                                                end
                                            end

                                            self._invasion = nil
                                            if callback then
                                                -- app.tip:floatTip("【测试用】继续扫荡（三）")
                                                callback()
                                            end
                                        end)
                                end)
                        -- end
                    end)

                    local intrusionMoney = remote.user.intrusion_money - (self._invasion.oldInvasionMoney or 0)
                    self._allInvasionMoney = self._allInvasionMoney + intrusionMoney
                end
            -- else
            --     self._invasion = nil
            end
        else
            self._isShowGotoInvasion = true
            local level = self._invasion.fightCount + 1
            local maxLevel = db:getIntrusionMaximumLevel(self._invasion.bossId)
            level = math.min(level, maxLevel)
            self._gotoInvasionName = string.format("%s(LV.%d)", QStaticDatabase:sharedDatabase():getCharacterByID(self._invasion.bossId).name, level)
            -- self._invasion = nil
        --     app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogNpcPrompt", 
        --         options = {content ="发现的要塞怪物未设置自动击杀，是否继续扫荡副本关卡？", comfirmCallback = function ()
        --         end, cancelCallBack = function()
        --         end}})
        end
    end

    if callback and isPlayCallback then
        -- app.tip:floatTip("【测试用】继续扫荡（四）")
        self._invasion = nil
        callback()
    end
end

function QRobot:_getDungeonIdByIntId( int_dungeon_id )
    if self._list["Normal"] and #self._list["Normal"] > 0 and self._list["Normal"][1].id == int_dungeon_id then
        return self._list["Normal"][1].dungeonId
    else
        for _, dungeon in pairs(self._list["Elite"]) do
            if dungeon.id == int_dungeon_id then
                return dungeon.dungeonId
            end
        end
    end
end

function QRobot:_getDungeonIdList()
    local tbl = {}
    local list = self._list["Elite"] or {}

    for _, info in pairs(list) do
        -- print("【测试用】一键扫荡 add id ： ", info.id)
        table.insert(tbl, info.id)
    end
    table.sort(tbl, function(a, b) return a < b end)
    if self._list["Normal"] and #self._list["Normal"] > 0 and self._list["Normal"][1].id then
        -- print("【测试用】一键扫荡 add id ： ", self._list["Normal"][1].id)
        table.insert(tbl, #tbl + 1, self._list["Normal"][1].id)
    end
    return tbl
end

function QRobot:_checkEnergy( list, robotType )
    print("[Kumo] QRobot:_checkEnergy( robotType ) ", self.MATERIAL, self.SOUL)
    local needEnergy = 0
    local energyItemIds = { 25, 26, 27 }
    if robotType == self.MATERIAL then
        if self:getAutoMaterialNormal() and #list["Normal"] > 0 then
            needEnergy = 6
        -- elseif self:getAutoMaterialElite() --[[and #list["Elite"] > 0]] then
        --     local tbl = self:getTotalEliteAttackListByBaseList(list["Elite"], robotType)
        --     if #tbl > 0 then
        --         needEnergy = 12
        --     end
        else
            needEnergy = 12
        end
    else
        needEnergy = 12
    end

    if remote.user.energy >= needEnergy then
        return true
    else
        if (robotType == self.MATERIAL and self:getAutoMaterialEnergy()) or (robotType == self.SOUL and self:getAutoSoulEnergy()) then
            for _, itemId in pairs(energyItemIds) do
                if self:getItemsNumByID( itemId ) > 0 then
                    return true
                end
            end
        end
        return false
    end
end

-----------------------------------------------------

function QRobot:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )

    if successFunc then 
        successFunc(response) 
        self:_dispatchAll()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    self:_dispatchAll()
end

--[[
/**
 * 成功扫荡一个副本
 * required string dungeonId = 1;                                            // 关卡ID
 * required int32  count = 2;                                                // 扫荡次数
 * optional int32 itemId = 3;                                                // 目标物品ID
 * optional int32 itemCount  = 4;                                            // 需要的物品数量（不是需要的物品总数量，值为：需求总数 － 现有数）
 * @param fail
 * @param status
 */
--]]
-- function QRobot:dungeonFightQuick(dungeonId, count, itemId, itemCount, success, fail, status)
--     dungeonId = QStaticDatabase:sharedDatabase():convertDungeonID(dungeonId)
--     local fightQuickRequest = {dungeonId = dungeonId, count = count, itemId = itemId, itemCount = itemCount}
--     local request = {api = "FIGHT_DUNGEON_QUICK", fightQuickRequest = fightQuickRequest}
--     app:getClient():requestPackageHandler("FIGHT_DUNGEON_QUICK", request, function (response)
--         self:responseHandler(response, success)
--     end, function (response)
--         self:responseHandler(response, nil, fail)
--     end)
-- end
function QRobot:dungeonFightQuick(battleType, dungeonId, count, itemId, itemCount, success, fail, status)
    dungeonId = QStaticDatabase:sharedDatabase():convertDungeonID(dungeonId)
    local fightQuickRequest = {dungeonId = dungeonId, count = count, itemId = itemId, itemCount = itemCount}
    local gfQuickRequest = {battleType = battleType, fightQuickRequest = fightQuickRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--分享给好友
function QRobot:shareIntrusionBossRequest(success, fail, status)
    remote.invasion:shareIntrusionBossRequest(
        function (response)
            self:responseHandler(response, success)
        end, 
        function (response)
            self:responseHandler(response, nil, fail)
        end)
end

--[[
/**
 * 打开礼包
    required int32 itemId = 1;
]]
function QRobot:openItemPackage(itemId, count, success, fail, status)
    local itemOpenRequest = {itemId = itemId, count = count}
    local request = {api = "ITEM_OPEN", itemOpenRequest = itemOpenRequest}
    app:getClient():requestPackageHandler("ITEM_OPEN", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
    副本一键扫荡
    repeated int32 dungeonId = 1;                                               // 关卡ID
    optional int32 itemId = 2;                                                  //
    optional int32 itemCount = 3;                                               //
    optional bool  ifIntrusionStop = 4;                                         // 遇到要塞怪物是否停止
    optional bool  ifConsumeEnergyToken = 5;                                    // 是否自动消耗体力药水
    optional int32 dungeonResetCount = 6;                                       // 每个关卡重置次数
]]
-- function QRobot:dungeonQuickPassRequest(dungeonId, itemId, itemCount, ifIntrusionStop, ifConsumeEnergyToken, dungeonResetCount, success, fail, status)
--     local dungeonQuickPassRequest = {dungeonId = dungeonId, itemId = itemId, itemCount = itemCount, ifIntrusionStop = ifIntrusionStop, ifConsumeEnergyToken = ifConsumeEnergyToken, dungeonResetCount = dungeonResetCount}
--     local request = {api = "DUNGEON_QUICK_PASS", dungeonQuickPassRequest = dungeonQuickPassRequest}
--     app:getClient():requestPackageHandler("DUNGEON_QUICK_PASS", request, function (response)
--         self:responseHandler(response, success)
--     end, function (response)
--         self:responseHandler(response, nil, fail)
--     end)
-- end
--[[
repeated int32 dungeonId = 1;                                               //关卡ID
optional int32 itemId = 2;                                                  //
optional int32 itemCount = 3;                                               //
optional bool  ifIntrusionStop = 4;                                         //遇到要塞怪物是否停止
optional bool  ifConsumeEnergyToken = 5;                                    //是否自动消耗体力药水
optional int32 dungeonResetCount = 6;                                       //每个关卡重置次数
optional bool isSecretary = 7 [default = false];                            //是否是小助手
]]
function QRobot:dungeonQuickPassRequest(dungeonId, itemId, itemCount, ifIntrusionStop, ifConsumeEnergyToken, dungeonResetCount, isSecretary, success, fail, status)
    local dungeonQuickPassRequest = {dungeonId = dungeonId, itemId = itemId, itemCount = itemCount, ifIntrusionStop = ifIntrusionStop,
         ifConsumeEnergyToken = ifConsumeEnergyToken, dungeonResetCount = dungeonResetCount, isSecretary = isSecretary}
    local gfQuickRequest = {battleType = BattleTypeEnum.DUNGEON_NORMAL, dungeonQuickPassRequest = dungeonQuickPassRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
    要塞一键扫荡
    optional bool autoConsumeToken = 1;                                         // 是否自动恢复次数
    optional bool isAllOut = 2;                                                 // 是否全力一击
    optional string fightReportData = 3;                                        // 战报内容
    optional BattleFormation battleFormation      = 4;                        // 阵容信息
]]
-- function QRobot:intrusionQuickPassRequest(autoConsumeToken, isAllOut, battleFormation, success, fail, status)
--     local intrusionQuickPassRequest = {autoConsumeToken = autoConsumeToken, isAllOut = isAllOut, battleFormation = battleFormation}
--     local content = readFromBinaryFile("last.reppb")
--     intrusionQuickPassRequest.fightReportData = crypto.encodeBase64(content)
--     local request = {api = "INTRUSION_QUICK_PASS", intrusionQuickPassRequest = intrusionQuickPassRequest}
--     app:getClient():requestPackageHandler("INTRUSION_QUICK_PASS", request, function (response)
--         self:responseHandler(response, success)
--     end, function (response)
--         self:responseHandler(response, nil, fail)
--     end)
-- end

--[[
optional bool autoConsumeToken = 1;                                         // 是否自动恢复次数
optional bool isAllOut = 2;                                                 // 是否全力一击
optional string fightReportData = 3;                                        // 战报内容
optional BattleFormation battleFormation = 4;                               // 阵容信息
optional bool autoShare = 5;                                                // 是否自动分享 如果魂兽被攻击二次或以上死亡则后端做假分享完成每日任务,如果未死亡则前端另外发送分享请求
optional bool isSecretary = 6 [default = false];                            //是否是小助手
]]
function QRobot:intrusionQuickPassRequest(autoConsumeToken, isAllOut, autoShare, battleFormation, battleKey, isSecretary, success, fail, status)
    local intrusionQuickPassRequest = {autoConsumeToken = autoConsumeToken, isAllOut = isAllOut, autoShare = autoShare,
         battleFormation = battleFormation, isSecretary = isSecretary}
    local content = readFromBinaryFile("last.reppb")
    local battleVerify = q.battleVerifyHandler(battleKey)
    
    local gfEndRequest = {battleType = BattleTypeEnum.INTRUSION, intrusionQuickPassRequest = intrusionQuickPassRequest, battleFormation = battleFormation, battleVerify = battleVerify}
    gfEndRequest.fightReportData = crypto.encodeBase64(content)
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QRobot:_dispatchAll()
    if not self._dispatchTBl or table.nums(self._dispatchTBl) == 0 then return end
    local tbl = {}
    for _, name in pairs(self._dispatchTBl) do
        if not tbl[name] then
            self:dispatchEvent({name = name})
            tbl[name] = 0
        end
    end
    self._dispatchTBl = {}
end

--------------------------要塞入侵--------------------------

-- There will be discount at special time
-- Pass in token needed and return discounted token number
function QRobot:tokenNumberRequired(tokenNumber)
    if self:_specialMoment(1) then
        return math.ceil(tokenNumber/2)
    end

    return tokenNumber
end

function QRobot:_specialMoment(type)
    local hour = q.date("%H", q.serverTime())
    if type == 1 then
        if tonumber(hour) == 11 or tonumber(hour) == 12 or tonumber(hour) == 13 then
            return true
        end
    else
        local value = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_HURT_DOUBLE"].value
        local minHours = string.split(value,"#")
        return tonumber(hour) >= tonumber(minHours[1]) and tonumber(hour) < tonumber(minHours[2])
    end

    return false
end

-- Invasion token grows every hour
-- Return the current token
function QRobot:currentTokenNumber()
    local token = remote.user.intrusion_token or 0
    if token < MAX_INVASION_TOKEN then
        local timeDiff = (q.serverTime() * 1000 - remote.user.intrusion_token_refresh_at)/1000
        local interval = (QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_TOKEN_REPLY_TIME"].value or TOKEN_REFRESH) * 60
        local tokenGrown = math.floor(timeDiff/interval)
        return (token + tokenGrown > MAX_INVASION_TOKEN) and MAX_INVASION_TOKEN or (token + tokenGrown)
    end

    return token
end


return QRobot
