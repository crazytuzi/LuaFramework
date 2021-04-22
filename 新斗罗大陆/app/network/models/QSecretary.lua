--
-- zxs
-- 小舞助手
--

local QBaseModel = import("...models.QBaseModel")
local QSecretary = class("QSecretary", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QSecretary.SECRETARY_LOG_INFO = "SECRETARY_LOG_INFO"
QSecretary.SECRETARY_FINISH = "SECRETARY_FINISH"
QSecretary.SECRETARY_SET_UPDATE = "SECRETARY_SET_UPDATE"

QSecretary.SECRETARY_NEXT_RUNNING = "SECRETARY_NEXT_RUNNING"
QSecretary.SECRETARY_UPDATE_LOG = "SECRETARY_UPDATE_LOG"

QSecretary.TYPE_DAYLY = 1               -- 每日玩法
QSecretary.TYPE_SYSTEM = 2              -- 系统玩法
QSecretary.TYPE_RANK = 3                -- 排名玩法
QSecretary.TYPE_SOCIETY = 4                -- 宗门玩法
QSecretary.TYPE_SHOP = 5                -- 商店购买

QSecretary.SETTING_SHOP = 0             -- 商店设置
QSecretary.SETTING_BUY = 1              -- 购买次数设置
QSecretary.SETTING_CHOOSE = 2           -- 选一设置--排名玩法
QSecretary.SETTING_MULTI_CHOOSE = 3     -- 多选一设置

QSecretary.SETTING_LEVEL = {"Ⅰ","Ⅱ","Ⅲ","Ⅳ","Ⅴ","Ⅵ","Ⅶ","Ⅷ","Ⅸ","Ⅹ","Ⅺ","Ⅻ"}

function QSecretary:ctor()
    QSecretary.super.ctor(self)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()


    --id:小秘书id，对应 secretary 量表的id
    --needSet: 需要显示设置
    --isLimit: 兑换商店
    --minEnery: 需要最小体力
    --changeDescName: 1, secretary 量表中的 describe 字段中的 name 替换为副本名称
    --showResource: 是否在日志中显示消耗货币
    self._secretaryConfigs = {
        --每日玩法
        ["100"] = {id = 100, dataProxy = "QAutoEnergySecretary"},       -- 自动体力药水
        ["101"] = {id = 101, dataProxy = "QLuckDrawSecretary"},         -- 免费长老令招募   
        ["102"] = {id = 102, dataProxy = "QLuckAdvanceDrawSecretary"},      -- 免费教皇令招募
        ["103"] = {id = 103, dataProxy = "QBuyMoneySecretary"},     -- 免费金魂币购买
        ["104"] = {id = 104, dataProxy = "QEnchantBoxSecretary"},       -- 免费觉醒宝箱
        ["105"] = {id = 105, dataProxy = "QGemStoneBoxSecretary", needSet = true, resourceType = ITEM_TYPE.TOKEN_MONEY},        -- 免费魂骨宝箱
        ["106"] = {id = 106, dataProxy = "QMountBoxSecretary"},     -- 免费暗器宝箱
        ["107"] = {id = 107, dataProxy = "QMagicHerbSecretary"},        -- 免费仙品宝箱

        -- 系统玩法
        ["201"] = {id = 201, dataProxy = "QTreasueBarSecretary", minEnery = 6, changeDescName = 1},      -- 金币宝屋
        ["202"] = {id = 202, dataProxy = "QBlackIronSecretary", minEnery = 6, changeDescName = 1},      -- 经验宝屋
        ["203"] = {id = 203, dataProxy = "QStrengthChallengeSecretary", needSet = true, minEnery = 6, changeDescName = 1},      -- 力量试炼
        ["204"] = {id = 204, dataProxy = "QWisdomChallengeSecretary", needSet = true, minEnery = 6, changeDescName = 1},        -- 智慧试炼
        ["205"] = {id = 205, dataProxy = "QThunderFastFightSecretary", needSet = true, resourceType = ITEM_TYPE.TOKEN_MONEY},     -- 杀戮之都
        ["206"] = {id = 206, dataProxy = "QThunderEliteSecretary", needSet = true, resourceType = ITEM_TYPE.TOKEN_MONEY},     -- 杀戮之都精英试炼
        ["207"] = {id = 207, linkId = 205}, --杀戮宝箱
        ["208"] = {id = 208, dataProxy = "QSunWarSecretary", needSet = true, showResource = true, isSunWar = true, resourceType = ITEM_TYPE.TOKEN_MONEY},     -- 海神岛
        ["209"] = {id = 209, dataProxy = "QHeroFragmentSecretary", needSet = true, isHeroFragment = true, showResource = true},     -- 魂师一键扫荡
        ["210"] = {id = 210, linkId = 209},     -- 魂师一键扫荡魂兽入侵
        ["211"] = {id = 211, linkId = 209},     -- 魂师一键扫荡补充体力
        ["212"] = {id = 212, dataProxy = "QMetalCitySecretary", needSet = true, resourceType = ITEM_TYPE.TOKEN_MONEY},     -- 金属之城一键扫荡
        ["213"] = {id = 213, linkId = 209},     -- 魂兽入侵
 
        -- 排名玩法
        ["301"] = {id = 301, dataProxy = "QArenaFastFightSecretary", needSet = true},       -- 斗魂场扫荡
        ["302"] = {id = 302, dataProxy = "QArenaWorshipSecretary"},     -- 斗魂场膜拜
        ["303"] = {id = 303, dataProxy = "QStormArenaWorshipSecretary"},        -- 索坨斗魂场膜拜
        ["304"] = {id = 304, dataProxy = "QStormArenaFastFightSecretary", needSet = true},       -- 索坨斗魂场扫荡
        ["305"] = {id = 305, dataProxy = "QSotoTeamFastFightSecretary", needSet = true},       -- 云顶扫荡
        ["306"] = {id = 306, dataProxy = "QSotoTeamWorshipSecretary"},     -- 云顶膜拜

        -- 一键购买
        ["401"] = {id = 401, dataProxy = "QShopBuySecretary", needSet = true, shopId = SHOP_ID.arenaShop, showResource = true, resourceType = ITEM_TYPE.ARENA_MONEY},        -- 斗魂场商店
        ["402"] = {id = 402, dataProxy = "QShopBuySecretary", needSet = true, shopId = SHOP_ID.sunwellShop, showResource = true, resourceType = ITEM_TYPE.SUNWELL_MONEY},        -- 海神岛商店
        ["403"] = {id = 403, dataProxy = "QShopBuySecretary", needSet = true, shopId = SHOP_ID.thunderShop, showResource = true, resourceType = ITEM_TYPE.THUNDER_MONEY},        -- 杀戮商店
        ["404"] = {id = 404, dataProxy = "QUnionShopBuySecretary", needSet = true, shopId = SHOP_ID.consortiaShop, showResource = true, resourceType = ITEM_TYPE.CONSORTIA_MONEY},       -- 宗门商店
        ["405"] = {id = 405, dataProxy = "QShopBuySecretary", needSet = true, shopId = SHOP_ID.gloryTowerShop, showResource = true, resourceType = ITEM_TYPE.TOWER_MONEY},       -- 大魂师商店
        ["406"] = {id = 406, dataProxy = "QShopBuySecretary", needSet = true, shopId = SHOP_ID.artifactShop, showResource = true, resourceType = ITEM_TYPE.MARITIME_MONEY},      -- 索托商店
        ["407"] = {id = 407, dataProxy = "QShopBuySecretary", needSet = true, shopId = SHOP_ID.invasionShop, showResource = true, resourceType = ITEM_TYPE.INTRUSION_MONEY},     -- 魂兽商店
        ["408"] = {id = 408, dataProxy = "QDragonWarShopBuySecretary", needSet = true, isLimit = true, shopId = SHOP_ID.dragonWarShop, showResource = true, resourceType = ITEM_TYPE.DRAGON_WAR_MONEY},      -- 争霸商店 
        ["409"] = {id = 409, dataProxy = "QLimitShopBuySecretary", needSet = true, isLimit = true, shopId = SHOP_ID.sanctuaryShop, showResource = true, resourceType = ITEM_TYPE.SANCTUARY_MONEY},       -- 精英商店
        ["410"] = {id = 410, dataProxy = "QLimitShopBuySecretary", needSet = true, isLimit = true, shopId = SHOP_ID.blackRockShop, showResource = true, resourceType = ITEM_TYPE.TEAM_MONEY},       -- 传灵塔商店
        ["411"] = {id = 411, dataProxy = "QShopBuySecretary", needSet = true, shopId = SHOP_ID.soulShop, showResource = true, resourceType = ITEM_TYPE.SOULMONEY},        -- 魂师商店
        ["412"] = {id = 412, dataProxy = "QMallBuySecretary", needSet = true, isLimit = true, shopId = SHOP_ID.itemShop, showResource = true, resourceType = ITEM_TYPE.TOKEN_MONEY},        -- 商城

        ["501"] = {id = 501, dataProxy = "QSocietySacrificeSecretary", needSet = true, isSocietySacrifice = true, showResource = true, resourceType = ITEM_TYPE.MONEY},
        ["502"] = {id = 502, dataProxy = "QSocietyDungeonSecretary", needSet = true, isSocietyDungeon = true, showResource = true, resourceType = ITEM_TYPE.TOKEN_MONEY, defaultCount = 9},
        ["503"] = {id = 503, dataProxy = "QSocietyDragonTrainSecretary", needSet = true, isSocietyDragonTrain = true, showResource = true},
        ["504"] = {id = 504, dataProxy = "QSocietyQuestionSecretary"},      -- 宗门答题
    }
    self._secretaryProxyList ={}

    self._secretaryInfo = {}        -- 助手信息
    self._secretary = {}            -- 所有配置
    self._secretarySet = {}         -- 所有设置
    self._secretaryAllLog = {}      -- 总日志
    self._taskList = {}             -- 任务表
    self._totalAwards = {}          -- 总奖励

end

function QSecretary:didappear()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_USER_TEAM_UP, self._teamUpEvent, self)
end

function QSecretary:disappear()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_USER_TEAM_UP, self._teamUpEvent, self)
end

function QSecretary:loginEnd()
    if app.unlock:checkLock("UNLOCK_SECRETARY") then
        self:setSecretaryConfig()
    end
end

function QSecretary:_teamUpEvent(event)
    if app.unlock:checkLock("UNLOCK_SECRETARY") then
        self:setSecretaryConfig()
    end
end

function QSecretary:openDialog(callback)
    if self:checkSecretaryRedTip() then
        app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.SECRETARY)
    end

    self:secretaryGetMainInfoRequest(function(data)
        self._secretaryInfo = data.secretaryGetMainInfoResponse
        self:updateSecretaryComplete()
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSecretary"})
        if callback then
            callback()
        end
    end)
end

function QSecretary:updateDialog(callback)
    self:secretaryGetMainInfoRequest(function(data)
        self._secretaryInfo = data.secretaryGetMainInfoResponse
        self:updateSecretaryComplete()
        if callback then
            callback()
        end
    end)
end

function QSecretary:getMySecretaryConfigById(id)
    return self._secretaryConfigs[tostring(id)] or {}
end

function QSecretary:getSecretaryDataProxyById(id)
    if self._secretaryProxyList[id] == nil then
        local config = self:getMySecretaryConfigById(id)
        if config.dataProxy then
            local class = import(app.packageRoot .. ".secretary." .. config.dataProxy)
            self._secretaryProxyList[id] = class.new({id = id, config = config})
        elseif config.linkId then
            return self:getSecretaryDataProxyById(config.linkId)
        end
    end
    return self._secretaryProxyList[id]
end

function QSecretary:setSecretaryConfig()
    self._secretary = {}
    self._secretarySet = {}

    -- 量表配置
    local level = remote.user.level
    local secretaryConfigs = db:getStaticByName("secretary")
    for i, config in pairs(secretaryConfigs) do
        if level >= (config.show_level or 1) then
            self._secretary[config.id] = config
        end
    end

    -- 上次设置
    local secratarySetting = app:getUserOperateRecord():getSecretarySetting()
    if secratarySetting then
        local settings = json.decode(secratarySetting) or {}
        for id, setting in pairs(settings) do
            self._secretarySet[id] = setting
        end
    end
end

-- 根据左边按钮配置
function QSecretary:getSecretaryTabConfigs()
    local tabConfigs = {
        {tabId = QSecretary.TYPE_DAYLY, name = "每日奖励", icon = "icon/activity/meiri_bt.png"},
        {tabId = QSecretary.TYPE_SYSTEM, name = "系统玩法", icon = "icon/activity/xitong_bt.png"},
        {tabId = QSecretary.TYPE_RANK, name = "排名玩法", icon = "icon/activity/paiming_bt.png"},
        {tabId = QSecretary.TYPE_SOCIETY, name = "宗门玩法", icon = "icon/activity/zongmen.png"},
        {tabId = QSecretary.TYPE_SHOP, name = "商店购买", icon = "icon/activity/shangdian_bt.png"},
    }
    return tabConfigs
end

-- 
function QSecretary:getSecretaryInfo()
    return self._secretaryInfo
end

-- 根据ID获取配置
function QSecretary:getSecretaryConfigById(id)
    return self._secretary[id] or {}
end

-- 根据ID获取设置
function QSecretary:getSettingBySecretaryId(id)
    local savaId = tostring(id)
    return self._secretarySet[savaId] or {}
end

function QSecretary:composeSettingKey(a, b)
    return tostring(a).."-"..tostring(b)
end

-- 更新完成状态
function QSecretary:updateSecretaryComplete()
    for i, value in pairs(self._secretaryConfigs) do
        local dataProxy = self:getSecretaryDataProxyById(value.id)
        local config = self:getSecretaryConfigById(value.id)
        if dataProxy then
            config.isComplete = dataProxy:checkSecretaryIsComplete()
            config.isNotActive = dataProxy:checkSecretaryIsNotActive()
        end
    end
end

-- 根据类型获取秘书集合
function QSecretary:getSecretaryByType(tabType)
    local secretarys = {}
    local unlockSecretarys = {}
    for i, config in pairs(self._secretary) do
        local secretaryConfig = self._secretaryConfigs[tostring(config.id)]
        if remote.user.level >= config.min_level and config.type_id == tabType and secretaryConfig and secretaryConfig.dataProxy then
            table.insert(secretarys, config)
        end
        if remote.user.level < config.min_level and config.type_id == tabType and secretaryConfig and secretaryConfig.dataProxy then
            table.insert(unlockSecretarys, config)
        end
    end
    table.sort(secretarys, function(a, b)
        if a.min_level > remote.user.level then
            a.is_new = 0
        end
        if b.min_level > remote.user.level then
            b.is_new = 0
        end        
        if a.isNotActive ~= b.isNotActive then
            return b.isNotActive == true
        elseif a.isComplete ~= b.isComplete then
            return b.isComplete == true
        elseif a.is_new ~= b.is_new then
            return a.is_new == 1
        else
            return a.id < b.id
        end
    end)
    table.sort(unlockSecretarys, function(a, b)
        if a.min_level ~= b.min_level then
            return a.min_level < b.min_level
        end
    end)
    for _,v in pairs(unlockSecretarys) do
        table.insert(secretarys, v)
    end
    return secretarys
end

function QSecretary:clearnSecretarySetting(id)
    local savaId = tostring(id)
    self._secretarySet[savaId] = {}
    -- 保存设置记录
    local secratarySetting = json.encode(self._secretarySet)
    app:getUserOperateRecord():setSecretarySetting(secratarySetting)

    self:dispatchEvent({name = QSecretary.SECRETARY_SET_UPDATE})    
end
-- 设置开启状态
function QSecretary:updateSecretarySetting(id, setting, dispatchEvent)
    local savaId = tostring(id)
    local curSetting = self._secretarySet[savaId] or {}
    for k, v in pairs(setting) do
        curSetting[k] = v
    end
    self._secretarySet[savaId] = curSetting
    
    -- 保存设置记录
    local secratarySetting = json.encode(self._secretarySet)
    app:getUserOperateRecord():setSecretarySetting(secratarySetting)

    if dispatchEvent == nil then dispatchEvent = true end
    
    if dispatchEvent then
        self:dispatchEvent({name = QSecretary.SECRETARY_SET_UPDATE})
    end
end

-- 根据ID获取设置是否开启
function QSecretary:getIsSettingOpen(id)
    local setting = self:getSettingBySecretaryId(id)
    return setting.isOpen or false
end

-- 所有日志
function QSecretary:getSecretaryAllLog()
    return self._secretaryAllLog
end

-- 总奖励
function QSecretary:getSecretaryTotalAwards()
    return self._totalAwards
end

function QSecretary:setSoulResfresh(nums)
    self.soulRefreshNum = nums
end

function QSecretary:getSoulResfresh()
    return self.soulRefreshNum
end

-- 检查体力
function QSecretary:checkEnergy()
    local noEnoughEnery = false
    -- 体力不足时所有用体力的都不执行了
    for i, value in pairs(self._secretaryConfigs) do
        if self._taskList[value.id] and value.minEnery and remote.user.energy < value.minEnery then
            noEnoughEnery = true
            self._taskList[value.id] = false
        end
    end

    if noEnoughEnery then
        if not self._showTips then
            self._showTips = true
            app.tip:floatTip("体力不足~")
        end
        return false
    end

    return true
end

-------- shop onekey buy --------------

--检查购买的物品
function QSecretary:recheckChooseItem( shopId, chooseItem )
    if chooseItem == nil then return end
    
    local isMaxSale = function(shopItems, choose)
        local maxNum = 0
        for j, itemInfo in pairs(shopItems) do
            if itemInfo.id == choose.id and itemInfo.moneyType == choose.moneyType and (itemInfo.sale or 1) == 1 then
                maxNum = itemInfo.moneyNum
                break
            end
        end
        return maxNum
    end

    local chooseItems = chooseItem
    local shopItems = remote.stores:getShopAllItemsByShopId2(shopId)
    for _,value in pairs(chooseItems) do
        for i, chooseItemInfo in pairs(value) do
            local maxNum = isMaxSale(shopItems, chooseItemInfo)
            for j, itemInfo in pairs(shopItems) do
                if itemInfo.id == chooseItemInfo.id and itemInfo.moneyType == chooseItemInfo.moneyType and (itemInfo.sale or 1) ~= 1 then
                    if tonumber(chooseItemInfo.moneyNum) ~= maxNum then
                        chooseItemInfo.moneyNum = itemInfo.moneyNum
                        break
                    end
                end
            end
        end
    end
    return chooseItems
end

function QSecretary:recheckChooseItem2(shops, chooseItems )
    if not next(chooseItems) then 
        return chooseItems
    end
    
    for i = #chooseItems, 1, -1 do
        local choose = chooseItems[1]
        for j, itemInfo in pairs(shops) do
            if itemInfo.grid_id == choose.grid_id and itemInfo.item_id ~= choose.itemId then
                table.remove(chooseItems, i)
            end
        end
    end
    return chooseItems
end

function QSecretary:resetDate()
    self._secretaryAllLog = {}  -- 总日志
    self._taskList = {}         -- 任务表
    self._totalAwards = {}      -- 总奖励

    -- 判断有没有可执行任务
    self._hasActions = false
    self._secretaryLog = false
    self._showTips = false
end

-- 开始执行
function QSecretary:requestSecretary(tabId)
    self:resetDate()

    if tabId == 0 then
        local secretaryTbl = self._secretary
        for _, v in ipairs(secretaryTbl) do
            self._taskList[v.id] = self:getIsSettingOpen(v.id)
        end
    else
        local secretaryTbl = self:getSecretaryByType(tabId)
        for _, v in ipairs(secretaryTbl) do
            self._taskList[v.id] = self:getIsSettingOpen(v.id)
        end
    end

    QPrintTable(self._taskList)
    self:nextTaskRunning()
end

-- 循环递归
function QSecretary:nextTaskRunning()
    local isFind = false
    local limitId = 9999
    for _, value in pairs(self._secretaryConfigs) do
        if self._taskList[value.id] then
            if tonumber(limitId) > tonumber(value.id) then
                limitId = tonumber(value.id)
            end
            -- self._taskList[value.id] = false
            -- local dataProxy = self:getSecretaryDataProxyById(value.id)
            -- dataProxy:executeSecretary()
            -- isFind = true
            -- break
        end
    end
    if limitId ~= 9999 then
        self._taskList[limitId] = false
        local dataProxy = self:getSecretaryDataProxyById(limitId)
        print("~~~~~~~~dataProxy:executeSecretary~~~~~")
        dataProxy:executeSecretary()
        isFind = true
        -- QPrintTable({task =limitId})
    end 

    if isFind == false then
        if self._hasActions then
            self:updateSecretaryComplete()
            self:addTotalAwards()
            remote.user:checkTeamUp()
        elseif not self._showTips then
            self._showTips = true
            app.tip:floatTip("魂师大人，没有可完成的功能~")
            self:dispatchEvent({name = QSecretary.SECRETARY_FINISH, info = info})
        end
    end
end

function QSecretary:setShowTips(state)
    if state == nil then return end

    self._showTips = state
end

function QSecretary:isShowTips()
    return self._showTips
end

function QSecretary:featuresNotOpen( )
    self:dispatchEvent({name = QSecretary.SECRETARY_FINISH})
end

--服务器返回错误码中断操作
function QSecretary:executeInterruption()
    local info = {}
    info.title1 = "执行失败"
    info.title2 = "执行终止"
    info.awards = {}
    self:dispatchEvent({name = QSecretary.SECRETARY_FINISH, info = info})
end


function QSecretary:tokenNoEnough()
    local info = {}
    info.title1 = "执行失败"
    info.title2 = "钻石不足"
    info.awards = {}
    self:dispatchEvent({name = QSecretary.SECRETARY_FINISH, info = info})
end

-- 添加所有奖励
function QSecretary:addTotalAwards()
    local info = {}
    info.title1 = "累计奖励"
    info.title2 = ""
    info.isFinish = true
    info.awards = self._totalAwards
    self:dispatchEvent({name = QSecretary.SECRETARY_FINISH, info = info, isFinish = true})
end

-- 检测英雄是否曾经获得
function QSecretary:checkHeroHavePast(info)
    local awards = info.awards or {}
    for i, v in pairs(awards) do
        local typeName = remote.items:getItemType(v.typeName)
        if typeName == ITEM_TYPE.HERO then
            remote.herosUtil:checkHeroHavePast(tonumber(v.id), true)
        end
    end
end

-- 多条日志
function QSecretary:updateSecretaryMultipleLog(data, logNum)
    if data == nil or data.secretaryGetLogsResponse == nil then return end
    local response = data.secretaryGetLogsResponse.secretaryLog or {}
    
    for _, value in ipairs(response) do
        self:updateSecretaryLog({secretaryItemsLogResponse = {secretaryLog = value}}, logNum)
    end
end

-- 单个日志
function QSecretary:updateSecretaryLog(data, logNum)
    if not data then return end
    
    local response = data.secretaryItemsLogResponse
    if not response or not response.secretaryLog then
        return
    end
    local itemLog = response.secretaryLog
    local info = {}
    local dataProxy = self:getSecretaryDataProxyById(itemLog.taskType)
    if dataProxy then
        dataProxy:convertSecretaryAwards(itemLog, logNum,info)
    end

    self._hasActions = true
    self:checkHeroHavePast(info)

    -- 汇总奖励
    for i, award in pairs(info.awards or {}) do
        local id = string.lower(award.id)
        if self._totalAwards[id] then
            self._totalAwards[id].count = self._totalAwards[id].count + award.count
        else
            self._totalAwards[id] = clone(award)
        end
    end

    if not self._secretaryLog then
        self._secretaryLog = true
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass= "QUIDialogSecretaryLog"}, {isPopCurrentDialog = false})
    end

    self:dispatchEvent({name = QSecretary.SECRETARY_LOG_INFO, info = info})
end

-- 更新所有日志
function QSecretary:updateSecretaryAllLog(response)
    local secretaryLog = response.secretaryLog or {}
    self._secretaryAllLog = {}
    self._totalAwards = {}

    for i, itemLog in pairs(secretaryLog) do
        local info = {}
        local dataProxy = self:getSecretaryDataProxyById(itemLog.taskType)
        if dataProxy then
            dataProxy:convertSecretaryAwards(itemLog, logNum,info)
        end
        if info.isShow == 1 then 
            table.insert(self._secretaryAllLog, info)
        end
    end

    -- 汇总奖励
    for i, log in pairs(self._secretaryAllLog) do
        local awards = log.awards or {}
        for j, award in pairs(awards) do
            local id = string.lower(award.id)
            if self._totalAwards[id] then
                self._totalAwards[id].count = self._totalAwards[id].count + award.count
            else
                self._totalAwards[id] = clone(award)
            end
        end
    end

    local totalInfo = {}
    totalInfo.title1 = "累计奖励"
    totalInfo.title2 = ""
    totalInfo.isFinish = true
    totalInfo.isEmpty = (#self._secretaryAllLog == 0)
    totalInfo.awards = self._totalAwards

    table.insert(self._secretaryAllLog, totalInfo)
end

--检查小秘书小红点
function QSecretary:checkSecretaryRedTip()
    if app.unlock:checkLock("UNLOCK_SECRETARY") == false then
        return false
    end

    if app:getUserOperateRecord():checkNewDayCompareWithRecordeTime(DAILY_TIME_TYPE.SECRETARY, 5) then
        return true
    end

    return false
end

-- 获取主要信息
function QSecretary:secretaryGetMainInfoRequest(success)
    local request = {api = "SECRETARY_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler("SECRETARY_GET_MAIN_INFO", request, success, fail)
end

-- 获取日志
function QSecretary:secretaryAllLogsRequest(groupId, success)
    local callback = function(data)
        self:updateSecretaryAllLog(data.secretaryGetLogsResponse)
        if success then
            success()
        end
    end

    local secretaryGetLogsRequest = {groupId = groupId}
    local request = {api = "SECRETARY_GET_LOGS", secretaryGetLogsRequest = secretaryGetLogsRequest}
    app:getClient():requestPackageHandler("SECRETARY_GET_LOGS", request, callback, fail)
end

function QSecretary:makeDelegate( delegateFunc )
    if type(delegateFunc) == "function" then
        self._delegateFunc = delegateFunc
    end
end

function QSecretary:delDelegate()
    self._delegateFunc = nil
end

function QSecretary:doDelegate(...)
    if self._delegateFunc and type(self._delegateFunc) == "function" then
        self._delegateFunc(...)
    end
end

return QSecretary