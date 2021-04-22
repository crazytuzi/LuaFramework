--
-- Author: Kumo.Wang
-- 大富翁数据管理
--

local QBaseModel = import("...models.QBaseModel")
local QMonopoly = class("QMonopoly", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QMonopoly.NEW_DAY = "QMONOPOLY_NEW_DAY"
QMonopoly.UPDATE_INFO = "QMONOPOLY_UPDATE_INFO"
QMonopoly.EVENT_COMPLETED = "QMONOPOLY_EVENT_COMPLETED"
QMonopoly.AUTO_GO = "QMONOPOLY_AUTO_GO"
QMonopoly.MOVE_END = "QMONOPOLY_MOVE_END"
QMonopoly.NEW_MAP = "QMONOPOLY_NEW_MAP"
QMonopoly.ONE_AUTO_GO = "QMONOPOLY_ONE_AUTO_GO"

QMonopoly.Event_State_Start = 0
QMonopoly.Event_State_Goon = 1
QMonopoly.Event_State_End = 2

QMonopoly.moneyEventId = 1 -- 1为金币奖励，数据来自binghuoliangyiyan_shijian表
QMonopoly.expEventId = 2 -- 2为经验药水奖励，数据来自binghuoliangyiyan_shijian表
QMonopoly.tokenEventId = 3 -- 3为钻石奖励，数据来自binghuoliangyiyan_shijian表
QMonopoly.flowerEventId = 4 -- 4为仙品，数据来自binghuoliangyiyan_shijian表
QMonopoly.buyEventId = 5 -- 5为购买，数据来自binghuoliangyiyan_shijian表
QMonopoly.luckyEventId = 6 -- 6为奇遇，数据来自binghuoliangyiyan_shijian表
QMonopoly.fingerEventId = 7 -- 7为猜拳，数据来自binghuoliangyiyan_shijian表
QMonopoly.refineMedicineEventId = 8 -- 8为炼药炉，数据来自binghuoliangyiyan_shijian表
QMonopoly.bonusEventId = 9 -- 9为Bonus奖励，数据来自binghuoliangyiyan_shijian表
-- QMonopoly.answerEventId = 10 -- 10为答题，数据来自binghuoliangyiyan_shijian表

-- 仙品管家设置相关
QMonopoly.ZIDONG_OPEN = "ZIDONG_OPEN"
QMonopoly.ZIDONG_LEVELUP = "ZIDONG_LEVELUP"
QMonopoly.ZIDONG_CAIQUAN = "ZIDONG_CAIQUAN"
QMonopoly.ZIDONG_LIANYAO = "ZIDONG_LIANYAO"

QMonopoly.MONOPOLY_SET_UPDATE = "MONOPOLY_SET_UPDATE"

QMonopoly.xianPingConfigList = {
    {id = 1,name = "幽香绮罗仙品",icon = "icon/equipment/magicherb/xp_hua12.jpg",oneSetId = 5},
    {id = 2,name = "奇茸通天菊",icon = "icon/equipment/magicherb/xp_hua8.jpg",oneSetId = 6},
    {id = 3,name = "八角玄冰草",icon = "icon/equipment/magicherb/xp_hua10.jpg",oneSetId = 7},
    {id = 4,name = "绮罗郁金香",icon = "icon/equipment/magicherb/xp_hua9.jpg",oneSetId = 8},
    {id = 5,name = "八瓣仙兰",icon = "icon/equipment/magicherb/xp_hua11.jpg",oneSetId = 10,unlock = "UNLOCK_MARITIME"},
}

QMonopoly.setTableConfigList = {
    {tabId = QMonopoly.ZIDONG_OPEN, name = "自动开箱", icon = "icon/item/sp_bh_box.jpg",havesetbtn = true,oneSetId = 3},
    {tabId = QMonopoly.ZIDONG_LEVELUP, name = "自动升级", icon = "icon/item/sp_bh_flower.jpg",havesetbtn = true},
    {tabId = QMonopoly.ZIDONG_CAIQUAN, name = "自动猜拳", icon = "icon/item/sp_bh_hand.jpg",havesetbtn = true,oneSetId = 4},
    {tabId = QMonopoly.ZIDONG_LIANYAO, name = "自动炼药", icon = "icon/item/sp_bh_ldl.jpg",havesetbtn = false,oneSetId = 9},    
}

--一键投掷设置相关
QMonopoly.MONOPOLY_GETAWARS = "MONOPOLY_GETAWARS"
QMonopoly.MONOPOLY_BUYNUM_CHEAST = "MONOPOLY_BUYNUM_CHEAST"
QMonopoly.MONOPOLY_ONESET_UPDATE = "MONOPOLY_ONESET_UPDATE"

QMonopoly.oneSetTableConfigList = {
    {tabId = 1, name = "自动领取解毒大奖", icon = "icon/head/dugubo_head.jpg",havesetbtn = true, haveContent = false},
    {tabId = 2, name = "自动购买骰子次数", icon = "icon/item/baoxiangputong.jpg",havesetbtn = true, haveContent = false},
    {tabId = 3, type = QMonopoly.ZIDONG_OPEN,name = "消耗遥控骰子，前往宝箱", icon = "icon/item/sp_bh_box.jpg",havesetbtn = false, haveContent = true},
    {tabId = 4, type = QMonopoly.ZIDONG_CAIQUAN,name = "消耗遥控骰子，前往猜拳", icon = "icon/item/sp_bh_hand.jpg",havesetbtn = false, haveContent = true},
    {tabId = 5, type = QMonopoly.ZIDONG_LEVELUP,name = "消耗遥控骰子，前往幽香绮罗仙品", icon = "icon/equipment/magicherb/xp_hua12.jpg",havesetbtn = false, haveContent = true,xianpingId = 1},
    {tabId = 6, type = QMonopoly.ZIDONG_LEVELUP,name = "消耗遥控骰子，前往奇茸通天菊", icon = "icon/equipment/magicherb/xp_hua8.jpg",havesetbtn = false, haveContent = true,xianpingId = 2},
    {tabId = 7, type = QMonopoly.ZIDONG_LEVELUP,name = "消耗遥控骰子，前往八角玄冰草", icon = "icon/equipment/magicherb/xp_hua10.jpg",havesetbtn = false, haveContent = true,xianpingId = 3},
    {tabId = 8, type = QMonopoly.ZIDONG_LEVELUP,name = "消耗遥控骰子，前往绮罗郁金香", icon = "icon/equipment/magicherb/xp_hua9.jpg",havesetbtn = false, haveContent = true,xianpingId = 4},
    {tabId = 10, type = QMonopoly.ZIDONG_LEVELUP,name = "消耗遥控骰子，前往八瓣仙兰", icon = "icon/equipment/magicherb/xp_hua11.jpg",havesetbtn = false, haveContent = true,xianpingId = 5,unlock = "UNLOCK_MARITIME"},
    {tabId = 9, type = QMonopoly.ZIDONG_LIANYAO,name = "自动炼药", icon = "icon/item/sp_bh_ldl.jpg",havesetbtn = false, haveContent = true},     
}

function QMonopoly:ctor()
    QMonopoly.super.ctor(self)
end

function QMonopoly:init()
    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.refreshTimeHandler))

    self._cheatItemIds = {13300006, 13300007, 13200000} -- 目前写死
    self.mainHeroItemId = 13300000 -- 目前写死
    self.cheatItemInfo = {}

    self.maxGridId = 0
    self.fingerGuessWinCount = 0  --猜拳胜利场次

    self.monopolyInfo = {}
    self.materialTbl = {} -- key是代表格子颜色的数字，value为药材的itemid
    self.tmpMaterialNumTbl = {} -- key药材的itemid, value为药材的数量
    self.formulaTbl = {} --key是毒的id，value是一个{colorId, rateForOne}
    self._allFlowerConfigsList = {} 
    self._clockForPickFlower = {} --保存采集仙品的闹钟
    self._materialTouchRegion = {} -- 保存主界面药材的点击区域
    self._gridTouchRegion = {} -- 保存地图中格子的点击区域
    self.avatarWords = {
        "这老毒物，怎么就毒不死呢？",
        "这里正是玄天宝录中三大聚宝盆之一！",
        "这是冬虫夏草中的极品，雪蚕！",
        "这是朱砂莲，居然能长这么大！",
        "这才是真正的仙品，“幽香绮罗仙品”！",
        "采集的对应的药材，能大幅度提升炼药几率！",
        "必须要解完6种毒，才能获得独孤博的奖励！",
        "每走一步都能获得一个药材！",
        "炼药失败也不会消耗药材！",
        "每次走完整张地图都会有奖励！",
    }
    self.pickFlowerRedTips = false

    self._dispatchTBl = {}

    self._monoplySet = {}         -- 所有设置
    self._monoplyOneSet = {}      -- 一键投掷设置

    self._settingConfig = {}
    self._oneSettingConfig = {}   

    self.beginOneCheatState = false
    self.notEnoughToken = false   -- 一键投掷钻石不足标志
    self.buyDiceNumFlag = false   -- 一键投掷已购买标志
    self.oneQuickOpenCheatFlag = false

    self._totalNum = QStaticDatabase.sharedDatabase():getConfigurationValue("buy_dice_count_limit")

    self:_analysisConfig()
    self:_initCheatItemInfo()
end

function QMonopoly:disappear()
    if self._remoteProexy ~= nil then
        self._remoteProexy:removeAllEventListeners()
        self._remoteProexy = nil
    end

    if self._userEventProxy ~= nil then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end
end

function QMonopoly:loginEnd(callback)
    if self:_checkMonopolyUnlock() then
        self:monopolyGetMyInfoRequest(callback, callback)
    else
        if callback then
            callback()
        end
    end
end

function QMonopoly:setMonopolySetConfig()

    self._monoplySet = {}
    self._monoplyOneSet = {}

    self._settingConfig = {}
    self._oneSettingConfig = {}
    -- 上次设置
    local monopolySetting = app:getUserOperateRecord():getMonoplySetting()
    if monopolySetting then
        local settings = json.decode(monopolySetting) or {}
        for id, setting in pairs(settings) do
            self._monoplySet[id] = setting
        end
    end    

    for i, config in pairs(QMonopoly.setTableConfigList) do
        self._settingConfig[config.tabId] = config
    end

    local oneSetting = app:getUserOperateRecord():getMonoplyOneSetting()

    if oneSetting ~= "" then
        local oneSet = json.decode(oneSetting) or {}
        for id,oneSetValue in pairs(oneSet) do
            self._monoplyOneSet[id] = oneSetValue
        end
    end
    for i,oneConfig in pairs(QMonopoly.oneSetTableConfigList) do
        self._oneSettingConfig[oneConfig.tabId] = oneConfig
    end
end

function QMonopoly:openDialog()
    if self:_checkMonopolyUnlock(true) then  
        self:monopolyGetMyInfoRequest(function()
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonopoly", options = {isShowAwards = true}})
            end)
    end
end

function QMonopoly:refreshTimeHandler(event)
    if event.time == nil or event.time == 0 then
        self._mainHeroId = nil -- 清掉数据，新的一天，重新计算一次
        self:dispatchEvent( { name = QMonopoly.NEW_DAY } )
    end

    if event.time == nil or event.time == 5 then
        if self:_checkMonopolyUnlock() then
            self:monopolyGetMyInfoRequest()
        end
    end
end
--------------快捷设置--------------
function QMonopoly:getMonpolyXianPingConfigList()
    local setConfig = {}
    for _,v in pairs(QMonopoly.xianPingConfigList) do
        if app.unlock:checkLock(v.unlock,false) then
            table.insert(setConfig,v)
        end
    end
    
    return setConfig
end

function QMonopoly:getMonoplyOneSetTableConfigList( )
    local setConfig = {}
    for _,v in pairs(QMonopoly.oneSetTableConfigList) do
        if app.unlock:checkLock(v.unlock,false) then
            table.insert(setConfig,v)
        end
    end
    
    return setConfig    
end

function QMonopoly:getMonpolyXianPingOneSetIDById(id)
    for _,config in pairs(QMonopoly.xianPingConfigList) do
        if config.id == tonumber(id) then
            return config.oneSetId
        end
    end
    return 0
end
-- 设置开启状态
function QMonopoly:updateMonoplySetting(id, setting)
    local savaId = tostring(id)
    local curSetting = self._monoplySet[savaId] or {}
    for k, v in pairs(setting) do
        curSetting[k] = v
    end
    self._monoplySet[savaId] = curSetting

    -- 保存设置记录
    local monoplySetting = json.encode(self._monoplySet)
    app:getUserOperateRecord():setMonoplySetting(monoplySetting)

    self:dispatchEvent({name = QMonopoly.MONOPOLY_SET_UPDATE})
end

--设置一键投掷状态
function QMonopoly:updateMonoplyOneSetting(id, setting)

    local savaId = tostring(id)
    local curSetting = self._monoplyOneSet[savaId] or {}
    for k, v in pairs(setting) do
        curSetting[k] = v
    end
    self._monoplyOneSet[savaId] = curSetting

    -- 保存设置记录
    local monoplyOneSetting = json.encode(self._monoplyOneSet)
    app:getUserOperateRecord():setMonoplyOneSetting(monoplyOneSetting)

    -- local monopolySet = app:getUserOperateRecord():getMonoplyOneSetting()

    self:dispatchEvent({name = QMonopoly.MONOPOLY_ONESET_UPDATE})  

end

function QMonopoly:checkUpLevel(flowerId)
    if not flowerId then return false end
    local levelupConfig = remote.monopoly:getSelectByMonopolyId(remote.monopoly.ZIDONG_LEVELUP)
    local swichId = tonumber(flowerId)
    if levelupConfig and levelupConfig.flowerUp then
        return levelupConfig.flowerUp[swichId]
    else
        return true
    end
    return false
end

-- 根据ID获取设置
function QMonopoly:getSettingByMonoplyId(id)
    local savaId = tostring(id)
    return self._settingConfig[savaId] or {}
end

function QMonopoly:getOneSettingByMonoplyId(id)
    -- local savaId = tostring(id)
    return self._oneSettingConfig[id] or {}
end

function QMonopoly:getSelectByMonopolyId(id)
    local savaId = tostring(id)
    return self._monoplySet[savaId] or {}    
end
-- 根据ID获取设置是否开启
function QMonopoly:getIsSettingOpen(id)
    local setting = self:getSelectByMonopolyId(id)
    return setting.isOpen or false
end

function QMonopoly:getOneSetMonopolyId(id)
    local savaId = tostring(id)
    return self._monoplyOneSet[savaId] or {}    
end

function QMonopoly:getIsOneSettiongOpen(id)
    local setting = self:getSelectByMonopolyId(id)
    return setting.isOpen or false
end
function QMonopoly:getOpenRealNum(num)
    if num <= 1 then
        return 1
    end
    local myMoney = remote.user.token
    local costMoney = 0
    local realNum = 1
    for i=1,num-1 do
        local consumeConfig, isFinal = QStaticDatabase:sharedDatabase():getTokenConsume("monopoly_buy_good_times", i)
        costMoney = costMoney + consumeConfig.money_num
        if costMoney > myMoney then
            return realNum
        else
            realNum = realNum + 1
        end
    end 
    return realNum
end

function QMonopoly:checkCanBuyDices(num)
    local buyCount = self.monopolyInfo.buyDiceCount or 0
    local leftBuyCount = num - buyCount
    if leftBuyCount <= 0 then
        return false, 0
    end 
    local maxNum = math.min(tonumber(self._totalNum), num)
    local index = 0
    local myMoney = remote.user.token
    local costMoney = 0
    for i=buyCount+1, maxNum do
        local consumeConfig, isFinal = QStaticDatabase:sharedDatabase():getTokenConsume("monopoly_buy_times", i)
        costMoney = costMoney + consumeConfig.money_num
        if myMoney < costMoney then
            return true,index
        else
            index = index +1
        end
    end
    if myMoney >= costMoney then
        return true,index
    else
        return false,index
    end
end
-----------------------------------

--------------数据储存--------------

function QMonopoly:setMaterialTouchRegionByColour(colour, tbl)
    self._materialTouchRegion[colour] = tbl
end

function QMonopoly:getMaterialTouchRegionByColour(colour)
    return self._materialTouchRegion[colour]
end

function QMonopoly:setGridTouchRegionByGridId(gridId, tbl)
    self._gridTouchRegion[gridId] = tbl
end

function QMonopoly:getGridTouchRegionByGridId(gridId)
    return self._gridTouchRegion[gridId]
end

--------------调用素材--------------

function QMonopoly:getPoisonImgById( id )
    if id then
        if id > #self.formulaTbl then
            return nil
        end
        local path = QResPath("monopoly_poison")[id]
        -- if QCheckFileIsExist(path) then
            local img = CCSprite:create(path) 
            return img
        -- end
    end
    return nil
end

function QMonopoly:getNikeAnimation()
    return "ccb/Widget_monopoly_gou.ccbi"
end

function QMonopoly:getNikeImg()
    local path = "ui/common/lable_choose.png"
    local img = CCSprite:create(path) 
    return img
end

function QMonopoly:getDiceImgByNum( num )
    if num then
        local path = QResPath("shaizi")[num]
        -- if QCheckFileIsExist(path) then
            local img = CCSprite:create(path) 
            return img
        -- end
    end
    return nil
end

function QMonopoly:getNoColorMapIcon()
    local path = "ui/monopoly/Monopoly_floor.png"
    local img = CCSprite:create(path) 
    return img
end

function QMonopoly:getFlowerEffectPathById( id )
    local id = tonumber(id)
    if id then
        -- print("id = ", id)
        local index
        if id == 1 then
            index = 2
        elseif id == 2 then
            index = 3
        elseif id == 3 then
            index = 5
        elseif id == 4 then
            index = 1
        elseif id == 5 then
            index = 4
        end
        -- local path = "fca/xiancao/xiancao_"..index.."/xiancao_"..index
        local path = "ccb/Widget_monopoly_plan"..index..".ccbi"
        if QCheckFileIsExist(path) then
            return path
        end
    end
    return nil
end

function QMonopoly:getActorAwardEffectPath()
    local path = "ccb/Widget_monopoly_award.ccbi"
    if QCheckFileIsExist(path) then
        return path
    end
    return nil
end

function QMonopoly:getMaterialEffectPath()
    local path = "effects/Monopoly_jiantou.ccbi"
    if QCheckFileIsExist(path) then
        return path
    end
    return nil
end

--------------便民工具--------------

function QMonopoly:checkRedTips()
    if not self:_checkMonopolyUnlock() then  
        return false
    end

    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MONOPOLY) then
        return true
    end

    if self.pickFlowerRedTips then
        return true
    end

    if self:getCurDiceCount() > 0 then
        return true
    end

    return false
end

function QMonopoly:getBaseDiceCount()
    local baseDiceCount = QStaticDatabase.sharedDatabase():getConfigurationValue("free_dice_count")
    return baseDiceCount or 15
end

function QMonopoly:getCurDiceCount()
    local curDiceCount = self:getBaseDiceCount() + (self.monopolyInfo.buyDiceCount or 0) - (self.monopolyInfo.usedDiceCount or 0)
    return curDiceCount or 0
end

-- {
    -- sec: 40
    -- min: 27
    -- day: 28
    -- isdst: false
    -- wday: 7
    -- yday: 149
    -- year: 2016
    -- month: 5
    -- hour: 16
-- }
function QMonopoly:getCurMainHeroId()
    if self._mainHeroId then return self._mainHeroId end -- 不需要每次调用都计算，每天5点会清楚数据，计算一次
    self._mainHeroId = 1009
    local nowTime = q.serverTime()
    -- local timeTbl = q.date("*t", nowTime)
    local mainHeroDic = QStaticDatabase.sharedDatabase():getMonopolyMainHeroConfig()
    -- QPrintTable(mainHeroDic)
    for _, mainHeroInfo in pairs(mainHeroDic) do
        local startEndTBl = string.split(mainHeroInfo.date, ";")
        local startStr = startEndTBl[1]
        local endStr = startEndTBl[2]

        local startDateTimeTbl = string.split(startStr, " ")
        local startDateTbl = string.split(startDateTimeTbl[1], "-")
        local startTimeTbl = string.split(startDateTimeTbl[2], ":")

        local endDateTimeTbl = string.split(endStr, " ")
        local endDateTbl = string.split(endDateTimeTbl[1], "-")
        local endTimeTbl = string.split(endDateTimeTbl[2], ":")
        -- print("[QMonopoly:getCurMainHeroId()] : ", mainHeroInfo.id, mainHeroInfo.name, "日期：", 
        --     startDateTbl[1], startDateTbl[2], startDateTbl[3], startTimeTbl[1], startTimeTbl[2], startTimeTbl[3], "到", 
        --     endDateTbl[1], endDateTbl[2], endDateTbl[3], endTimeTbl[1], endTimeTbl[2], endTimeTbl[3])
        -- print("[QMonopoly:getCurMainHeroId()] 日期：", timeTbl.year, timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min, timeTbl.sec)

        local sTime = q.getTimeForYMDHMS(startDateTbl[1], startDateTbl[2], startDateTbl[3], startTimeTbl[1], startTimeTbl[2], startTimeTbl[3]) * 1000
        local eTime = q.getTimeForYMDHMS(endDateTbl[1], endDateTbl[2], endDateTbl[3], endTimeTbl[1], endTimeTbl[2], endTimeTbl[3]) * 1000
        local cTime = nowTime * 1000

        -- print(sTime, nowTime, cTime, eTime)
        if sTime <= cTime and cTime <= eTime then
            self._mainHeroId = mainHeroInfo.id
        end
    end

    return self._mainHeroId
end

function QMonopoly:getMainHeroSoulItemId()
    local config = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(self:getCurMainHeroId(), 1)
    return config.soul_gem
end

function QMonopoly:getCurMainHeroInfo( heroId )
    local heroConfig = QStaticDatabase.sharedDatabase():getCharacterByID(heroId)
    if heroConfig then
        return heroConfig.name, heroConfig.role_definition
    end

    return "", ""
end

function QMonopoly:getGridColorConfig( id )
    local colorConfig = QStaticDatabase.sharedDatabase():getMonopolyGridColorConfig()
    if id then
        return colorConfig[tostring(id)]
    end

    return nil
end

function QMonopoly:getMaxGridId()
    if not self.maxGridId or self.maxGridId == 0 then
        self.maxGridId = #self.monopolyInfo.gridInfos or 0
    end
    return self.maxGridId
end

function QMonopoly:getStepList()
    local nowFootIndex = self.monopolyInfo.nowFootIndex
    if not self.monopolyInfo.everyFootCount or #self.monopolyInfo.everyFootCount < nowFootIndex + 1 then return end
    local totalStep = self.monopolyInfo.everyFootCount[nowFootIndex + 1]

    local stepList = {}
    local step = 1
    local index = 1
    local lastSaveStep = 0 -- 最后保存的步数
    local maxStep = self:getMaxGridId() - self.monopolyInfo.nowGridId
    -- print("QMonopoly:getStepList()", nowFootIndex, totalStep, maxStep, QMonopoly.refineMedicineEventId)
    while true do 
        if step >= maxStep then
            -- 走到终点，一切终结，刷新新地图
            stepList[index] = step - lastSaveStep
            lastSaveStep = step
            index = index + 1
            if totalStep - lastSaveStep > 0 then
                stepList[index] = totalStep - lastSaveStep
            end
            break
        end

        if step >= totalStep then
            stepList[index] = step - lastSaveStep
            break
        end

        local gridId = self.monopolyInfo.nowGridId + step
        if self.monopolyInfo.gridInfos[gridId] then
            -- 判断接下来是否经过炼药炉
            if self.monopolyInfo.gridInfos[gridId].eventId == QMonopoly.refineMedicineEventId then
                stepList[index] = step - lastSaveStep
                lastSaveStep = step
                index = index + 1
            end
            step = step + 1
        else
            stepList[index] = step - lastSaveStep
            break
        end
    end
    printTable(stepList)

    return stepList, totalStep
end

function QMonopoly:getCurRefineMedicineRate()
    local curDebuffIndex = self.monopolyInfo.removePoisonCount + 1
    local curRefineMedicineRate = 0
    -- print("QMonopoly:getCurRefineMedicineRate()", curDebuffIndex)
    -- QPrintTable(self.formulaTbl)
    -- QPrintTable(self.materialTbl)
    for id, rate in pairs(self.formulaTbl[curDebuffIndex] or {}) do
        local itemId = self.materialTbl[tonumber(id)]
        local itemNum = 0
        if self.tmpMaterialNumTbl[itemId] then
            itemNum = self.tmpMaterialNumTbl[itemId]
            local curGridInfo = self.monopolyInfo.gridInfos[self.monopolyInfo.nowGridId]
            if curGridInfo and curGridInfo.colour == id then
                itemNum = itemNum + 1
            end
        else
            itemNum = remote.items:getItemsNumByID(itemId)
        end
        curRefineMedicineRate = curRefineMedicineRate + itemNum * rate
        -- print(id, itemId, itemNum, rate, curRefineMedicineRate)
    end
    if curRefineMedicineRate > 100 then
        curRefineMedicineRate = 100
    end

    return curRefineMedicineRate
end

function QMonopoly:getPoisonConfigById(id)
    local poisonConfigs = QStaticDatabase.sharedDatabase():getMonopolyPoisonConfig()
    return poisonConfigs[tostring(id)]
end

function QMonopoly:getCurPoisonConfig()
    local curDebuffId = self.monopolyInfo.removePoisonCount + 1
    local curConfig = self:getPoisonConfigById(curDebuffId)
    -- QPrintTable(curConfig)
    return curConfig
end

function QMonopoly:getItemConfigByID(id)
    return QStaticDatabase.sharedDatabase():getItemByID(id)
end

function QMonopoly:getFlowerConfigs()
    return self._allFlowerConfigsList
end

function QMonopoly:getFlowerCurAndNextConfigById(id)
    local allFlowerConfigs = self:getFlowerConfigs()
    local curConfig, nextConfig, preConfig
    local flowerConfigs = allFlowerConfigs[tonumber(id)]
    if flowerConfigs then
        local index = (self.monopolyInfo.immortalInfos and self.monopolyInfo.immortalInfos[tonumber(id)]) and (self.monopolyInfo.immortalInfos[tonumber(id)].level + 1) or 1
        curConfig = flowerConfigs[index]
        nextConfig = flowerConfigs[index + 1] -- nil就是顶级
        if index > 0 then
            preConfig = flowerConfigs[index - 1] -- nil就是顶级
        end
    end
    return curConfig, nextConfig, preConfig
end

function QMonopoly:getFlowerConfigByIdAndLevel(id, level)
    local allFlowerConfigs = self:getFlowerConfigs()
    local flowerConfigs = allFlowerConfigs[tonumber(id)]
    if flowerConfigs then
        return flowerConfigs[level+1] or {}
    end

    return {}
end

function QMonopoly:getLuckyDrawByKey(key)
    return QStaticDatabase.sharedDatabase():getLuckyDraw(key)
end

function QMonopoly:getFinalRewardLuckyDrawKey()
    if self._finalRewardTbl and #self._finalRewardTbl > 0 then return self._finalRewardTbl end
    local finalRewardStr = QStaticDatabase.sharedDatabase():getConfigurationValue("monopoly_final_win_reward")
    self._finalRewardTbl = string.split(finalRewardStr, ";")
    return self._finalRewardTbl
end

function QMonopoly:getMonopolyEventConfigByEventId( id )
    local eventConfigs = QStaticDatabase.sharedDatabase():getMonopolyEventConfig()
    return eventConfigs[tostring(id)]
end

function QMonopoly:getPickFlowerTimeSpan(flowerId)
    local flowerId = tonumber(flowerId)
    local timeSpanForMin = 0
    local timeSpanForMsec = 0
    local maxTimeSpanForMsec = DAY * 1000
    local isRedTips = false
    -- QPrintTable(self.monopolyInfo.immortalInfos[flowerId])
    if self.monopolyInfo.immortalInfos and self.monopolyInfo.immortalInfos[flowerId] and self.monopolyInfo.immortalInfos[flowerId].startAt then
        timeSpanForMsec = (q.serverTime() * 1000 - self.monopolyInfo.immortalInfos[flowerId].startAt) -- 毫秒
    end
    -- 可累计采集总量为一天的量
    if timeSpanForMsec >= maxTimeSpanForMsec then
        timeSpanForMsec = maxTimeSpanForMsec
        isRedTips = true
    end
    timeSpanForMin = math.floor(timeSpanForMsec / 1000 / 60) -- 分钟
    return timeSpanForMin, timeSpanForMsec, isRedTips
end

function QMonopoly:showRewardForTips(prizes, beginStr)
    if not prizes then return end

    local tbl = {}
    for _, value in ipairs(prizes) do
        local rewardType = remote.items:getItemType(value.type)
        local name
        if rewardType == ITEM_TYPE.ITEM then
            local config = self:getItemConfigByID(value.id)
            name = config.name
        else
            local config = remote.items:getWalletByType(rewardType)
            name = config.nativeName
        end
        table.insert(tbl, {name = name, count = value.count})
    end
    local str = beginStr or "恭喜获得："
    for i, reward in ipairs(tbl) do
        if i == 1 then
            str = str..reward.name.."x"..reward.count
        else
            str = str.."、"..reward.name.."x"..reward.count
        end
    end
    app.tip:floatAward(str)
end

function QMonopoly:getFingerAwards(awardCount)
    local awards = {}
    if awardCount then
        awards = QStaticDatabase:sharedDatabase():getluckyDrawById("finger_win"..awardCount)
    else
        for i = 1, remote.monopoly.fingerGuessWinCount do
            local data = QStaticDatabase:sharedDatabase():getluckyDrawById("finger_win"..i)
            for _, value in ipairs(data) do
                awards[#awards+1] = value
            end
        end
    end

    --去重
    local finalAwards = {}
    for _, value in ipairs(awards) do
        local index = value.id
        if index == nil then
            index = value.typeName
        end
        if finalAwards[index] then
            finalAwards[index].count = finalAwards[index].count + value.count
        else
            finalAwards[index] = value
        end
    end

    return finalAwards
end

function QMonopoly:showFinalRewardForDialog(prizes)
    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", options = {awards = prizes, callBack = function()
            self:dispatchEvent( { name = QMonopoly.EVENT_COMPLETED } )
        end}})
    dialog:setTitle("恭喜您获得最终大奖")
end

function QMonopoly:showRefineMedicineSuccessForDialog()
    app.taskEvent:updateTaskEventProgress(app.taskEvent.MONOPOLY_REFINE_MEDICINE_SUCCESS_EVENT, 1)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolySuccess", options = {callBack = function()
            self:dispatchEvent( { name = QMonopoly.EVENT_COMPLETED } )
        end}})
end

function QMonopoly:continueSuccessToGo()
    self:dispatchEvent( { name = QMonopoly.EVENT_COMPLETED } )
end
function QMonopoly:getClockKeyByFlowerId(flowerId)
    return "clockForPickFlower"..flowerId
end

function QMonopoly:tmpSaveMaterialNumTbl()
    self.tmpMaterialNumTbl = {}
    for index, itemId in pairs(remote.monopoly.materialTbl) do
        self.tmpMaterialNumTbl[itemId] = remote.items:getItemsNumByID(itemId)
    end
end

function QMonopoly:getMaterialSpriteFrameByColourId(id)
    local itemId = self.materialTbl[tonumber(id)]
    local config = remote.monopoly:getItemConfigByID(itemId)
    if config and config.icon then
        local sf = QSpriteFrameByPath(config.icon)
        return sf
    end
    return nil
end

function QMonopoly:getMonopolySpriteFrameByItemId(id)
    local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(id)
    if itemConfig and itemConfig.icon then
        local sf = QSpriteFrameByPath(itemConfig.icon)
        return sf
    end

    return nil
end

function QMonopoly:beginOneTriggerGo()
    self.beginOneCheatState = true
    self:dispatchEvent({name = QMonopoly.ONE_AUTO_GO})
end

function QMonopoly:getLastBuyDiceNum()
    -- local totalNum = QStaticDatabase.sharedDatabase():getConfigurationValue("buy_dice_count_limit")
    local buyCount = self.monopolyInfo.buyDiceCount or 0

    return tonumber(self._totalNum)  - tonumber(buyCount)
end
--------------数据处理--------------

function QMonopoly:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )
    if response.monopolyResponse then
        self:_saveMonopolyInfo(response)
        table.insert(self._dispatchTBl, QMonopoly.UPDATE_INFO)
    end

    if (response.api == "MONOPOLY_PLANT" 
        or response.api == "MONOPOLY_GET_FINGER_REWARD"
        or response.api == "MONOPOLY_BUY_GOOD")  and response.error == "NO_ERROR" then
        -- 特殊事件交互完成，发消息，继续游戏进程。
        table.insert(self._dispatchTBl, QMonopoly.EVENT_COMPLETED)
    end

    if response.api == "MONOPOLY_REFINE_MEDICINE" and response.monopolyResponse and not response.monopolyResponse.removePoisonCount and response.error == "NO_ERROR" then
        -- 炼药失败直接发事件继续流程
        local lianyaoConfig = remote.monopoly:getIsSettingOpen(remote.monopoly.ZIDONG_LIANYAO)
        if not lianyaoConfig then
            table.insert(self._dispatchTBl, QMonopoly.EVENT_COMPLETED)
        end
    end

    if response.api == "MONOPOLY_MAP_CHANGE" and response.error == "NO_ERROR" then
        table.insert(self._dispatchTBl, QMonopoly.NEW_MAP)
    end

    if response.api == "MONOPOLY_MOVE_EVENT" and response.error == "NO_ERROR" then
        table.insert(self._dispatchTBl, QMonopoly.MOVE_END)
    end

    if response.api == "MONOPOLY_CHEAT" and response.error == "NO_ERROR" then
        table.insert(self._dispatchTBl, QMonopoly.AUTO_GO)
    end

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

function QMonopoly:pushHandler( data )
    -- QPrintTable(data)
end

--[[
    //大富翁
    MONOPOLY_GET_MAIN_INFO                      = 9601;                     // 大富翁--进入主建筑
    MONOPOLY_MOVE_EVENT                         = 9602;                     // 大富翁--事件接口 MonopolyMoveEventRequest
    MONOPOLY_CHEAT                              = 9603;                     // 大富翁--使用作弊道具 MonopolyCheatRequest
    MONOPOLY_BUY_DICE                           = 9604;                     // 大富翁--购买骰子
    MONOPOLY_PLANT                              = 9605;                     // 大富翁--种植仙品 MonopolyPlantRequest
    MONOPOLY_GET_IMMORTAL_REWARD                = 9606;                     // 大富翁--领取仙品产出 MonopolyGetImmortalRewardRequest
    MONOPOLY_GET_FINGER_REWARD                  = 9607;                     // 大富翁--领取石头剪刀布对应奖励 MonopolyGetFingerGuessRewardRequest
    MONOPOLY_GET_FINAL_REWARD                   = 9608;                     // 大富翁--领取最终的大奖 MonopolyGetFinalRewardRequest
    MONOPOLY_REFINE_MEDICINE                    = 9609;                     // 大富翁--炼药逻辑 MonopolyRefineMedicineRequest
    MONOPOLY_MAP_CHANGE                         = 9610;                     // 大富翁--地图改变
    MONOPOLY_BUY_GOOD                           = 9611;                     // 大富翁--购买商品
]]

function QMonopoly:monopolyGetMyInfoRequest(success, fail, status)
    local request = { api = "MONOPOLY_GET_MAIN_INFO" }
    app:getClient():requestPackageHandler("MONOPOLY_GET_MAIN_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32  gridId  = 1;//格子Id
function QMonopoly:monopolyGridEventRequest(gridId, success, fail, status)
    local monopolyMoveEventRequest = {gridId = gridId}
    local request = { api = "MONOPOLY_MOVE_EVENT", monopolyMoveEventRequest = monopolyMoveEventRequest }
    app:getClient():requestPackageHandler("MONOPOLY_MOVE_EVENT", request, function (response)
        remote.user:addPropNumForKey("todayMonopolyMoveCount")
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 itemId = 1;              //使用的道具Id
-- optional int32 footCount = 2;           //移动的步数
function QMonopoly:monopolyCheatRequest(itemId, footCount, success, fail, status)
    local monopolyCheatRequest = {itemId = itemId, footCount = footCount}
    local request = { api = "MONOPOLY_CHEAT", monopolyCheatRequest = monopolyCheatRequest }
    app:getClient():requestPackageHandler("MONOPOLY_CHEAT", request, function (response)
        app.taskEvent:updateTaskEventProgress(app.taskEvent.MONOPOLY_CHEAT_EVENT, 1)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--购买次数
function QMonopoly:monopolyBuyDiceRequest(buyCount,success, fail, status)
    local monopolyBuyDiceRequest = {buyCount = buyCount}
    local request = { api = "MONOPOLY_BUY_DICE",monopolyBuyDiceRequest = monopolyBuyDiceRequest }
    app:getClient():requestPackageHandler("MONOPOLY_BUY_DICE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 immortalItemId = 1;       //仙品道具Id id等于0就是拒绝种植的
-- immortalItemId == 0 的时候，说明玩家放弃仙品种植或者升级
function QMonopoly:monopolyPlantRequest(immortalItemId, success, fail, status)
    local monopolyPlantRequest = {immortalItemId = immortalItemId}
    local request = { api = "MONOPOLY_PLANT", monopolyPlantRequest = monopolyPlantRequest }
    app:getClient():requestPackageHandler("MONOPOLY_PLANT", request, function (response)
        if immortalItemId ~= 0 then
            app.taskEvent:updateTaskEventProgress(app.taskEvent.MONOPOLY_PLANT_SUCCESS_EVENT, 1)
        end
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- repeated int32 immortalItemId = 1;       //仙品Id
function QMonopoly:monopolyGetImmortalRewardRequest(immortalItemId, success, fail, status)
    local monopolyGetImmortalRewardRequest = {immortalItemId = immortalItemId}
    local request = { api = "MONOPOLY_GET_IMMORTAL_REWARD", monopolyGetImmortalRewardRequest = monopolyGetImmortalRewardRequest }
    app:getClient():requestPackageHandler("MONOPOLY_GET_IMMORTAL_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32  winCount  = 1;//胜利的次数
function QMonopoly:monopolyGetFingerRewardRequest(winCount, success, fail, status)
    local monopolyGetFingerGuessRewardRequest = {winCount = winCount}
    local request = { api = "MONOPOLY_GET_FINGER_REWARD", monopolyGetFingerGuessRewardRequest = monopolyGetFingerGuessRewardRequest }
    app:getClient():requestPackageHandler("MONOPOLY_GET_FINGER_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string index = 1; //多选1索引, lucky_draw索引字段
function QMonopoly:monopolyGetFinalRewardRequest(index, success, fail, status)
    local monopolyGetFinalRewardRequest = {index = index}
    local request = { api = "MONOPOLY_GET_FINAL_REWARD", monopolyGetFinalRewardRequest = monopolyGetFinalRewardRequest }
    app:getClient():requestPackageHandler("MONOPOLY_GET_FINAL_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional bool isRefineMedicine      = 1;  //是否需要炼药
-- optional int32 gridId  = 2;                //格子Id
function QMonopoly:monopolyRefineMedicineRequest(isRefineMedicine, gridId, success, fail, status)
    local monopolyRefineMedicineRequest = {isRefineMedicine = isRefineMedicine, gridId = gridId}
    local request = { api = "MONOPOLY_REFINE_MEDICINE", monopolyRefineMedicineRequest = monopolyRefineMedicineRequest }
    app:getClient():requestPackageHandler("MONOPOLY_REFINE_MEDICINE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QMonopoly:monopolyMapChangeRequest(success, fail, status)
    local request = { api = "MONOPOLY_MAP_CHANGE" }
    app:getClient():requestPackageHandler("MONOPOLY_MAP_CHANGE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- //购买宝箱
-- optional bool isBuyGood = 1; //是否购买商品 count 购买次数
function QMonopoly:monopolyBuyChestRequest(isBuyGood, count,success, fail, status)
    local monopolyBuyGoodRequest = {isBuyGood = isBuyGood,count = count,}
    local request = { api = "MONOPOLY_BUY_GOOD", monopolyBuyGoodRequest = monopolyBuyGoodRequest}
    app:getClient():requestPackageHandler("MONOPOLY_BUY_GOOD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--------------本地工具--------------

function QMonopoly:_checkMonopolyUnlock(isTips)
    return app.unlock:getUnlockMonopoly(isTips)
end

function QMonopoly:_dispatchAll()
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

-- optional string userId                          = 1;   //玩家Id
-- optional int32 mapId                            = 2;   //地图Id
-- optional int32 usedDiceCount                    = 3;   //用掉的骰子的数量 每日五点重置
-- optional int32 buyDiceCount                     = 4;   //购买的骰子的数量 每日五点重置
-- optional bool lastRewardIsExist                 = 5;   //最终大奖励是否存在
-- repeated int32 everyFootCount                   = 6;   //每次移动步数的集合
-- optional int32 nowFootIndex                     = 7;   //当前走了多少次的索引
-- optional int32 nowGridId                        = 8;   //当前所在的格子Id
-- repeated MonopolyGridInfo gridInfos             = 9;   //每个格子的信息
-- repeated ImmortalInfo immortalInfos             = 10;   //每个仙品的信息
-- optional bool hiddenRewardExist                 = 11;  //隐藏奖励
-- repeated MedicineInfo medicineInfo              = 12;  //炼药信息
-- optional int32 removePoisonCount                = 13;  //解毒的数量
-- optional string randomFootGroup                 = 14;  //每日服务器生成的随机步数组合 8_2_3
function QMonopoly:_saveMonopolyInfo( data )
    for key, value in pairs(data.monopolyResponse) do
        self.monopolyInfo[key] = value
    end
    if self.monopolyInfo.immortalInfos then
        local tbl = {}
        for _, flower in pairs(self.monopolyInfo.immortalInfos) do
            tbl[flower.itemId] = flower
        end
        self.monopolyInfo.immortalInfos = tbl
        self:_checkPickFlowerRedTips()
        -- QPrintTable(self.monopolyInfo.immortalInfos)
    end
end

function QMonopoly:_checkPickFlowerRedTips()
    local tmpRedTips = false
    for _, flowerInfo in ipairs(self.monopolyInfo.immortalInfos) do
        local _, _, redTips = remote.monopoly:getPickFlowerTimeSpan(flowerInfo.itemId)
        local key = self:getClockKeyByFlowerId(flowerInfo.itemId)
        if redTips then
            tmpRedTips = redTips
            if self._clockForPickFlower[key] then
                app:getAlarmClock():deleteAlarmClock(key)
                self._clockForPickFlower[key] = nil
            end
        end
        local clockTimeForMsec = flowerInfo.startAt + 24 * 60 * 60 * 1000
        if not self._clockForPickFlower[key] or self._clockForPickFlower[key] ~= clockTimeForMsec then
           self._clockForPickFlower[key] = clockTimeForMsec
           app:getAlarmClock():createNewAlarmClock(key, self._clockForPickFlower[key], function() remote.monopoly.pickFlowerRedTips = true end)
        end
    end
    self.pickFlowerRedTips = tmpRedTips
end

function QMonopoly:_analysisConfig()
    local colorConfigs = QStaticDatabase.sharedDatabase():getMonopolyGridColorConfig()
    for _, colorConfig in pairs(colorConfigs) do
        self.materialTbl[colorConfig.id] = colorConfig.item_id
    end

    local poisonConfigs = QStaticDatabase.sharedDatabase():getMonopolyPoisonConfig()
    for _, poisonConfig in pairs(poisonConfigs) do
        self.formulaTbl[poisonConfig.id] = {}
        if poisonConfig and poisonConfig.effect then
            local tbl = string.split(poisonConfig.effect, ";")
            for _, value in ipairs(tbl) do
                local tbl1 = string.split(value, ",")
                self.formulaTbl[poisonConfig.id][tbl1[1]] = tbl1[2]
            end
        end
    end

    local allFlowerConfigs = QStaticDatabase.sharedDatabase():getMonopolyFlowerConfig()
    for _, flowerConfig in pairs(allFlowerConfigs) do
        table.insert(self._allFlowerConfigsList, flowerConfig)
    end
    table.sort(self._allFlowerConfigsList, function(a, b)
            return a[1].id < b[1].id
        end)
end

function QMonopoly:_getCheatSelectViewNum(itemId)
    if itemId == 13300006 then
        return "ui/monopoly/touzi_small.png"
    elseif itemId == 13300007 then
        return "ui/monopoly/touzi_large.png"
    elseif itemId == 13200000 then
        return "ui/monopoly/touzi_super.png"
    else
        return "ui/monopoly/touzi_small.png"
    end
end

function QMonopoly:_getCheatSelectViewName(itemId)
    if itemId == 13300006 then
        return "ui/monopoly/xiaotouzi_zi.png"
    elseif itemId == 13300007 then
        return "ui/monopoly/datouzi_zi.png"
    elseif itemId == 13200000 then
        return "ui/monopoly/chaojitouzi_zi.png"
    else
        return "ui/monopoly/xiaotouzi_zi.png"
    end
end

function QMonopoly:_initCheatItemInfo()
    for index, itemId in ipairs(self._cheatItemIds) do
        local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(itemId)
        local selectViewIcon = self:_getCheatSelectViewNum(itemId)
        local selectViewName = self:_getCheatSelectViewName(itemId)
        table.insert(self.cheatItemInfo, {itemId = itemId, config = itemConfig, selectViewIcon = selectViewIcon, selectViewName = selectViewName})
    end
end

return QMonopoly
