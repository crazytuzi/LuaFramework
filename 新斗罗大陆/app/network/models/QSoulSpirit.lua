
--
-- Author: Kumo.Wang
-- 魂灵养成数据管理
--

local QBaseModel = import("...models.QBaseModel")
local QSoulSpirit = class("QSoulSpirit", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QActorProp = import("...models.QActorProp")
local QSoulSpiritProp = import("...models.QSoulSpiritProp")
local QUserData = import("...utils.QUserData")

QSoulSpirit.STATE_NO_WEAR = "STATE_NO_WEAR"
QSoulSpirit.STATE_CAN_WEAR = "STATE_CAN_WEAR"
QSoulSpirit.STATE_WEAR = "STATE_WEAR"
QSoulSpirit.STATE_CAN_GRADE = "STATE_CAN_GRADE"
QSoulSpirit.STATE_LOCK = "STATE_LOCK"

QSoulSpirit.FIRE_TATE_UNLOCK = 1 --未解锁
QSoulSpirit.FIRE_TATE_LOCKED = 2 --解锁未点亮
QSoulSpirit.FIRE_TATE_ACTIVITE = 3 --点亮
QSoulSpirit.SMALLPOINT_MAX_NUM = 10 --子魂火最多10个
QSoulSpirit.BIGPOINT_MAX_NUM = 16 --大魂火节点最大15个

QSoulSpirit.EVENT_UPDATE = "QSOULSPIRIT.EVENT_UPDATE"
QSoulSpirit.EVENT_WEAR = "QSOULSPIRIT.EVENT_WEAR"
QSoulSpirit.EVENT_UNWEAR = "QSOULSPIRIT.EVENT_UNWEAR"

QSoulSpirit.EVENT_WEAR_INHERIT_ONE = "QSOULSPIRIT.EVENT_WEAR_INHERIT_ONE"


QSoulSpirit.EVENT_REFRESH_SOUL_SPIRIT = "SOULSPIRIT.EVENT_REFRESH_SOUL_SPIRIT"
QSoulSpirit.EVENT_SELECTED_SOULSPIRIT = "SOULSPIRIT.EVENT_SELECTED_SOULSPIRIT"

QSoulSpirit.EVENT_SOUL_SPIRIT_ACHIEVE_UPDATE = "SOULSPIRIT.EVENT_SOUL_SPIRIT_ACHIEVE_UPDATE"


QSoulSpirit.EVENT_INHERIT_SUCCESS = "SOULSPIRIT.EVENT_INHERIT_SUCCESS"


function QSoulSpirit:ctor()
    QSoulSpirit.super.ctor(self)
end

function QSoulSpirit:init()
    self._dispatchTBl = {}
    
    self.maxFoodCount = 6 -- 升級可選擇的吞噬食物的最大數量
    self.selectedFoodDic = {} -- 储存选中的食物, key是itemid（number）

    self._isUnlock = false -- isUnlock作为登入后首次解锁的标记，然后做一个首次解锁的处理，拉取一次数据。修改且唯一修改于QUnlock类，该值不要作为功能解锁的判断依据，它只是一个标记。
    self._isAutoLevelUpUnlock = false -- 是否解锁自动连续吞噬功能
    self._autoPutInFoodState = 0 -- 是否勾選記錄吞噬（升級）消耗的道具組合: 0，未勾選。1，已勾選未吞噬過。2，已勾選已吞噬過
    self._autoLevelUpState = false  -- 是否勾選自动连续吞噬

    self._allSoulSpiritIdList = {} -- 量表配置的所有魂靈id列表
    self._soulSpiritInfoList = {} -- 玩家擁有的魂靈信息
    self._soulSpiritIdDic = {} -- 是否保存过有這個id的魂靈信息
    self._soulSpiritHistoryInfoList = {} -- 玩家的魂靈历史信息
    self._soulSpiritHandBookInfoList = {} -- 玩家擁有的魂靈圖鑒信息
    self._masterConfigListWithAptitude = {} -- 緩存統一品質的大師量表信息
    self._levelConfigListWithAptitude = {} -- 緩存統一品質的等级量表信息
    self._soulSpiritIdAndFragmentIdDic = {} -- 魂灵碎片id和魂灵id的map
    self._soulSpiritIdAndLevelUpConsumeDic = {} -- 魂灵id和升级消耗的map
    self._soulSpiritIdAndDecourConsumeDic = {} -- 魂灵id和传承消耗的map


    self._soulSpiritAwakenMaxLevelDic = {} -- 魂灵品质对应最大的觉醒等级
    self._soulSpiritInheritMaxLevelDic = {} -- 魂灵最大的传承等级


    self._allBigPointInfo = {}
    self._soulSpritOccultTreeNum = 0
    self._soulSpiritOccultMapInfo = {}            --魂灵秘术加点情况

    self._teamTwoSoulSpritsMarkTbl = {}             --上阵魂灵+1标志表
    self._teamTwoSoulSpritsMarkTbl[1] = false       --1小队上阵魂灵+1标志
    self._teamTwoSoulSpritsMarkTbl[2] = false       --2小队上阵魂灵+1标志
    self._teamTwoSoulSpritsMarkTbl[3] = false       --3小队上阵魂灵+1标志

    self.soulSpiritHeroShow = true               --本次登录是否提示魂灵选英雄
    self.heroSoulSpiritShow = true               --本次登录是否显示英雄选魂灵

    self.isWarningForCritNotEnough = false       -- 自动吞噬是否弹出提示
end

function QSoulSpirit:loginEnd(success)
    self._allBigPointInfo = self:getAllSoulFireBigPointConfig()
    self._soulSpritOccultTreeNum = self:getAllSoulFireTreeNum()
    
    self:checkSoulSpiritUnlock()
    self:_analysisConfig()

    
    if success then
        success()
    end
end

function QSoulSpirit:getAllSoulFireBigPointConfig()
    local lockAllFireBigPoints = db:getAllSoulFireBigPoint() or {}
    local allBigPointInfo = {}
    for _, v in pairs(lockAllFireBigPoints) do
        if app.unlock:checkLock(v.unlock, false) then
            table.insert(allBigPointInfo, v)
        end
    end

    return allBigPointInfo
end

function QSoulSpirit:disappear()
    QSoulSpirit.super.disappear(self)
    self:_removeEvent()
end

function QSoulSpirit:_addEvent()
    self:_removeEvent()
end

function QSoulSpirit:_removeEvent()
end

--打开界面
function QSoulSpirit:openDialog(callback)
end

--------------数据储存.KUMOFLAG.--------------

-- 魂靈信息的保存更新
function QSoulSpirit:updateSoulSpirit( dataList )
    for _, data in ipairs(dataList) do
        if self._soulSpiritIdDic[data.id] then
            self:_coverSoulSpirit( data )
        else
            self:_addSoulSpirit( data )
        end
    end
    -- 由于历史信息只有在登入的时候从后端拿一次，之后游戏中的更新在这里维护
    self:updateSoulSpiritHistory(dataList)
    -- self:updateExtraPropBySoulSpiritInfoList()
end

-- //魂灵秘术结构
-- message UserSoulSpiritOccult{
--     repeated UserSoulSpiritMapInfo mapInfo = 1;
-- }

-- message UserSoulSpiritMapInfo{
--     optional int32 mapId = 1;
--     repeated UserSoulSpiritDetail detailInfo = 2;
-- }

-- message UserSoulSpiritDetail{
--     optional int32 bigPointId = 1;
--     repeated int32 smallPointId = 2;
-- }

--魂灵秘术更新
function QSoulSpirit:updateSoulSpiritOccult(soulSpiritOccultInfo)
    if q.isEmpty(soulSpiritOccultInfo) then
        self._soulSpiritOccultMapInfo = {}
        self._teamTwoSoulSpritsMarkTbl[1] = false
        self._teamTwoSoulSpritsMarkTbl[2] = false
        self._teamTwoSoulSpritsMarkTbl[3] = false
        return
    end
    self._soulSpiritOccultMapInfo = soulSpiritOccultInfo.mapInfo or {}
    for _,v in pairs(self._soulSpiritOccultMapInfo) do
        for _,k in pairs(v.detailInfo) do
            local childInfo = db:getChildSoulFireInfo(v.mapId,k.bigPointId,k.smallPointId)
            if childInfo.soul_num_team == 1 then

                self._teamTwoSoulSpritsMarkTbl[1] = true
            end
            if childInfo.soul_num_team == 2 then

                self._teamTwoSoulSpritsMarkTbl[2] = true
            end
            if childInfo.soul_num_team == 3 then
                self._teamTwoSoulSpritsMarkTbl[3] = true
            end            
        end        
    end
end

function QSoulSpirit:refreshHeroUtils( )
    remote.herosUtil:validate()
    remote.herosUtil:updateHeros(remote.herosUtil.heros)
    remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

function QSoulSpirit:getAllSoulFireNum( )
    if self._soulSpritOccultTreeNum == 0 then
        self._soulSpritOccultTreeNum = self:getAllSoulFireTreeNum()
    end
    return self._soulSpritOccultTreeNum * (QSoulSpirit.BIGPOINT_MAX_NUM) * (QSoulSpirit.SMALLPOINT_MAX_NUM)
end
function QSoulSpirit:getActiviteFireNum( )
    local num = 0
    for _,v in pairs(self._soulSpiritOccultMapInfo) do
        for _,k in pairs(v.detailInfo) do
            num = num + k.smallPointId
        end
    end

    return num
end
-- 魂靈历史信息的保存更新
function QSoulSpirit:updateSoulSpiritHistory( dataList )
    local isEvent = false
    for _, data in ipairs(dataList) do
        local isFind = false
        for i, historyInfo in ipairs(self._soulSpiritHistoryInfoList) do
            if historyInfo.id == data.id then
                if data.grade > historyInfo.grade then
                    historyInfo.grade = data.grade
                end
                if data.level > historyInfo.level then
                    isEvent = true
                    historyInfo.level = data.level
                end
                isFind = true
                break
            end
        end
        if not isFind then
            local info = {
                id = data.id,
                grade = data.grade,
                level = data.level,
            }
            table.insert(self._soulSpiritHistoryInfoList, info)
            isEvent = true
        end
    end

    if isEvent then
        self:dispatchEvent({name = QSoulSpirit.EVENT_SOUL_SPIRIT_ACHIEVE_UPDATE})
    end
end

-- 魂靈圖鑒信息的保存更新
function QSoulSpirit:updateSoulSpiritHandBook( dataList )
    for _, data in ipairs(dataList) do
        local isFind = false
        for i, handBookInfo in ipairs(self._soulSpiritHandBookInfoList) do
            if handBookInfo.id == data.id then
                handBookInfo.grade = data.grade
                isFind = true
                break
            end
        end
        if not isFind then
            local info = {
                id = data.id,
                grade = data.grade,
            }
            table.insert(self._soulSpiritHandBookInfoList, info)
        end
    end
end

-- 每次登入的時候，從後端拿一次數據，建立升級消耗的數據基礎，之後每次SOUL_SPIRIT_LEVEL_UPDATE回調的時候，在數據類內部更新。
function QSoulSpirit:updateSoulSpiritLevelUpConsume( dataList )
    for _, data in ipairs(dataList) do
        if not self._soulSpiritIdAndLevelUpConsumeDic[data.spiritId] then
            self._soulSpiritIdAndLevelUpConsumeDic[data.spiritId] = {}
        end
        for _, value in ipairs(data.consume or {}) do
            self._soulSpiritIdAndLevelUpConsumeDic[data.spiritId][value.type] = value.count
        end
        for _, value in ipairs(data.devourConsume or {}) do
            self._soulSpiritIdAndLevelUpConsumeDic[data.spiritId][value.type] = value.count
        end
    end
    QPrintTable(self._soulSpiritIdAndLevelUpConsumeDic)
end

function QSoulSpirit:updateSoulSpiritDevourConsume( dataList )
    QPrintTable(dataList)
   for _, data in ipairs(dataList) do
        if not self._soulSpiritIdAndDecourConsumeDic[data.spiritId] then
            self._soulSpiritIdAndDecourConsumeDic[data.spiritId] = {}
        end
        for _, value in ipairs(data.devourConsume or {}) do
            self._soulSpiritIdAndDecourConsumeDic[data.spiritId][value.type] = value.count
        end
    end
    QPrintTable(self._soulSpiritIdAndDecourConsumeDic)
end

--升星
function QSoulSpirit:getLevelUpConsumeDicById(id)
    return self._soulSpiritIdAndLevelUpConsumeDic[id]
end

--传承
function QSoulSpirit:getDevourConsumeDicById(id)
    return self._soulSpiritIdAndDecourConsumeDic[id]
end

-- 重置传承历史
function QSoulSpirit:resetDevourConsumeDicById(id)
    self._soulSpiritIdAndDecourConsumeDic[id] = {}
end

function QSoulSpirit:getAwakenConsumeByData(soulSpirit)

    local characterConfig = db:getCharacterByID(soulSpirit.id)
    local quality = characterConfig.aptitude
    local gradeConfigs = remote.soulSpirit:getSoulSpiritAwakenAllConfigValue(quality)or {}

    local gradeItemId = 0
    local gradeItemNum = 0
    local items = {}
    for _, config in pairs(gradeConfigs ) do
        if soulSpirit.awaken_level >= config.level then
            local items_2 = {}
            remote.items:analysisServerItem(config.item, items_2)
            table.insert(items,items_2)
        end
    end

    return items
end

function QSoulSpirit:getAllSoulSpiritIdList()
    if next(self._allSoulSpiritIdList) == nil then
        self:_analysisConfig()
    end
    return self._allSoulSpiritIdList
end

function QSoulSpirit:getMySoulSpiritInfoList()
    return self._soulSpiritInfoList
end

function QSoulSpirit:getMySoulSpiritInfoById(id)
    local id = tonumber(id)
    for _, info in ipairs(self._soulSpiritInfoList) do
        if info.id == id then
            return info
        end
    end

    return nil
end


function QSoulSpirit:getSoulSpritOccultMapInfo()
    return self._soulSpiritOccultMapInfo
end

function QSoulSpirit:getTeamSpiritsMaxCount(isTwo)
    if isTwo then
        return self._teamTwoSoulSpritsMarkTbl[2] and 2 or 1
    else
        return self._teamTwoSoulSpritsMarkTbl[1] and 2 or 1
    end
end

function QSoulSpirit:getTeamSpiritsMaxCountByTeamNum(totalTeamNum)
    return self._teamTwoSoulSpritsMarkTbl[totalTeamNum] and 2 or 1
end


-- //魂灵秘术结构
-- message UserSoulSpiritOccult{
--     repeated UserSoulSpiritMapInfo mapInfo = 1;
-- }

-- message UserSoulSpiritMapInfo{
--     optional int32 mapId = 1;
--     repeated UserSoulSpiritDetail detailInfo = 2;
-- }

-- message UserSoulSpiritDetail{
--     optional int32 bigPointId = 1;
--     repeated int32 smallPointList = 2;
-- }

function QSoulSpirit:getMaxBigPointByTreeType( treeType )
    local maxBigPoint = 4
    local isUlock = self:checkBigPointCanUpgrade(treeType,bigPoint)
    for ii=1,QSoulSpirit.BIGPOINT_MAX_NUM do
        local isUlock = self:checkBigPointCanUpgrade(treeType,ii)
        if isUlock then
            maxBigPoint = ii
            break
        end
    end

    for _,v in pairs(self._soulSpiritOccultMapInfo) do
        if v.mapId == treeType then
            for _,k in pairs(v.detailInfo) do
                if k.smallPointId < QSoulSpirit.SMALLPOINT_MAX_NUM then
                    return k.bigPointId
                end
            end
        end
    end

    return maxBigPoint
end

function QSoulSpirit:getSoulFireActiviteByBigPoint( treeType,bigPointId )
    for _,v in pairs(self._soulSpiritOccultMapInfo) do
        if v.mapId == treeType then
            for _,k in pairs(v.detailInfo) do
                if bigPointId == k.bigPointId then
                    return k.smallPointId
                end
            end
        end
    end
    return 0
end

function QSoulSpirit:getPreconditionName( treeType, bigPoint )
    local bigpoinInfo = db:getMianSoulFireInfo(treeType,bigPoint) or {}
    local cellUnlock = bigpoinInfo.cell_unlock or ""
    local cellUnlockIds = string.split(cellUnlock, ";")
    local unlockId = tonumber(cellUnlockIds[1])
    if unlockId then
        local unlockInfo = db:getMianSoulFireInfo(treeType,unlockId) or {}
        if unlockInfo then
            return unlockInfo.cell_name or ""
        end
    end

    return ""
end

function QSoulSpirit:getNextBigPointBycellunlock( treeType, cellunlock )
    for jj = 1,QSoulSpirit.BIGPOINT_MAX_NUM do
        local bigpoinInfo = db:getMianSoulFireInfo(treeType,jj) or {}
        local cellUnlock = bigpoinInfo.cell_unlock or ""
        local cellUnlockIds = string.split(cellUnlock, ";")
        local unlockId = tonumber(cellUnlockIds[1])
        if tonumber(unlockId) == tonumber(cellunlock) then
            return bigpoinInfo
        end
    end

    return nil
end

function QSoulSpirit:checkBigPointCanUpgrade(treeType, bigPoint)
    local bigpoinInfo = db:getMianSoulFireInfo(treeType,bigPoint) or {}
    local cellUnlock = bigpoinInfo.cell_unlock or ""
    local cellUnlockIds = string.split(cellUnlock, ";")
    local isActivie = false
    for _,id in pairs(cellUnlockIds) do
        if tonumber(id) == 0 then
            return true
        end
        local cellState = self:getMainSoulSpiritFireState(treeType,tonumber(id))
        if self:getMainSoulSpiritFireState(treeType,tonumber(id)) == QSoulSpirit.FIRE_TATE_ACTIVITE then
            isActivie = true
            break
        end
    end

    return isActivie
end

function QSoulSpirit:getMainSoulSpiritFireState(treeType,bigPointId)
    
    if bigPointId == 0 then
        return QSoulSpirit.FIRE_TATE_ACTIVITE
    end

    for _,v in pairs(self._soulSpiritOccultMapInfo) do
        if v.mapId == treeType then
            for _,k in pairs(v.detailInfo) do
                if k.bigPointId == bigPointId then
                    if k.smallPointId >= QSoulSpirit.SMALLPOINT_MAX_NUM then
                        return QSoulSpirit.FIRE_TATE_ACTIVITE
                    elseif k.smallPointId > 0 and k.smallPointId < QSoulSpirit.SMALLPOINT_MAX_NUM then
                        return QSoulSpirit.FIRE_TATE_LOCKED
                    end
                end
            end
        end
    end

    return QSoulSpirit.FIRE_TATE_UNLOCK
end

function QSoulSpirit:checkChildSoulSpiritFire(treeType,bigPointId,smallPoint)
    for _v in pairs(self._soulSpiritOccultMapInfo) do
        if v.mapId == treeType then
            for _,k in pairs(v.detailInfo) do
                if k.bigPointId == bigPointId then
                    if k.smallPointId >= QSoulSpirit.SMALLPOINT_MAX_NUM then
                        return QSoulSpirit.FIRE_TATE_ACTIVITE
                    else
                        return QSoulSpirit.FIRE_TATE_LOCKED
                    end
                end
            end
        end
    end

    return false
end

function QSoulSpirit:getOneTeamTwoSoulSprit( )
    return self._teamTwoSoulSpritsMarkTbl[1]
end

function QSoulSpirit:getTwoTeamTwoSoulSprit( )
    return self._teamTwoSoulSpritsMarkTbl[2]
end


function QSoulSpirit:getThreeTeamTwoSoulSprit( )
    return self._teamTwoSoulSpritsMarkTbl[3]
end


function QSoulSpirit:getMySoulSpiritHandBookInfoList()
    return self._soulSpiritHandBookInfoList
end

function QSoulSpirit:getMyHandBookInfoByHandBookId(handBookId)
    local handBookId = tonumber(handBookId)
    for _, info in ipairs(self._soulSpiritHandBookInfoList) do
        if info.id == handBookId then
            return info
        end
    end

    return nil
end

function QSoulSpirit:getMySoulSpiritHistoryList()
    return self._soulSpiritHistoryInfoList
end

function QSoulSpirit:getMySoulSpiritHistoryInfoById(id)
    local id = tonumber(id)
    for _, info in ipairs(self._soulSpiritHistoryInfoList) do
        if info.id == id then
            return info
        end
    end

    -- 當魂靈的歷史信息裡沒有，則說明玩家不曾擁有過該魂靈，即初始狀態
    return {id = id, level = 0, grade = 0}
end

function QSoulSpirit:getSelectedFoodList()
    local tbl = {}
    for itemId, count in pairs(self.selectedFoodDic) do
        table.insert(tbl, {type = itemId, count = count})
    end

    return tbl
end

function QSoulSpirit:getSelectedFoodIdList()
    local tbl = {}
    for itemId, count in pairs(self.selectedFoodDic) do
        for i = 1, count, 1 do
            table.insert(tbl, itemId)
        end
    end
    table.sort(tbl, function(a, b)
            local aItemConfig = QStaticDatabase.sharedDatabase():getItemByID(a)
            local bItemConfig = QStaticDatabase.sharedDatabase():getItemByID(b)
            if aItemConfig.colour ~= bItemConfig.colour then
                return aItemConfig.colour > bItemConfig.colour
            elseif aItemConfig.exp ~= bItemConfig.exp then
                return aItemConfig.exp > bItemConfig.exp
            elseif aItemConfig.crit ~= bItemConfig.crit then
                return aItemConfig.crit > bItemConfig.crit
            else
                return a < b
            end
        end)


    return tbl
end

function QSoulSpirit:setAutoPutInFoodState( int )
    if self:checkAutoLevelUpUnlock() then return end

    self._autoPutInFoodState = int
end

function QSoulSpirit:getAutoPutInFoodState()
    return self._autoPutInFoodState
end

function QSoulSpirit:cleanSelectedFoodDic()
    self.selectedFoodDic = {}
end

function QSoulSpirit:setAutoLevelUpState( boo )
    self._autoLevelUpState = boo
end

function QSoulSpirit:getAutoLevelUpState()
    return self._autoLevelUpState
end

-- 设置魂灵吞噬本周不再显示
function QSoulSpirit:setDevourUpGradeShowState()
    app:getUserOperateRecord():recordeCurrentTime("UNLOCK_BLACKSCREEN_NO_PROMPT_DEVOUR")
end

-- 检查魂灵吞噬本周是否显示
function QSoulSpirit:checkDevourUpGradeShowState()
    local isShow = false
    if app.unlock:checkLock("UNLOCK_BLACKSCREEN_NO_PROMPT_DEVOUR") then
        isShow = app:getUserOperateRecord():checkNewWeekCompareWithRecordeTime("UNLOCK_BLACKSCREEN_NO_PROMPT_DEVOUR")
	end
	return isShow
end

--------------调用素材.KUMOFLAG.--------------

--------------便民工具.KUMOFLAG.--------------

function QSoulSpirit:checkAutoLevelUpUnlock(isTips, tips)
    if not self._isAutoLevelUpUnlock and app.unlock:checkLock("UNLOCK_QUICK_DEVOUR", isTips, tips) then
        self._isAutoLevelUpUnlock = true
        if self._autoPutInFoodState == 0 then
            self._autoPutInFoodState = 1
        end
    end
    return self._isAutoLevelUpUnlock
end



function QSoulSpirit:checkAutoLevelUpUnlockTips()
    local strMark = "UNLOCK_QUICK_DEVOUR"..tostring(remote.user.userId)
    local isMark = app:getUserData():getUserValueForKey(strMark) 
    if not isMark or isMark =="" then
        app:getUserData():setUserValueForKey(strMark, QUserData.STRING_TRUE)
        app.tip:floatTip("现在你可以一次点击连续吞噬了，快试试吧～")
    end
end


--[[
    By Kumo
    由於策劃的合併顯示屬性的要求太多了，合併的規則也是五花八門，大部分都是手動處理。這裡做一個統一的標記

    @dic：key，QActorProp._field的key；value，屬性值（number）
]]
function QSoulSpirit:markMergePropListByDic(dic)
    if not dic or type(dic) ~= "table" or next(dic) == nil then return end

    local propList = {}
    local tmpPropDic = {}
    local propDic = QActorProp:getPropFields()
    for key, value in pairs(dic) do
        if propDic[key] and propDic[key].uiMergeName then
            local mark = propDic[key].uiMergeName..tostring(propDic[key].isPercent)..value
            if tmpPropDic[mark] then
                -- 合併處理
                if not tmpPropDic[mark].isInsert then
                    tmpPropDic[mark].isInsert = true
                    table.insert(propList, {key = tmpPropDic[mark].key, num = value, mark = mark})
                end
                table.insert(propList, {key = key, num = value, mark = mark})
            else
                tmpPropDic[mark] = {key = key, num = value, isInsert = false}
            end
        else
            table.insert(propList, {key = key, num = value})
        end
    end

    return propList
end

function QSoulSpirit:checkRedTips()
    if not self:checkSoulSpiritUnlock() then
        return false
    end

    local allSoulSpiritIdList = self:getAllSoulSpiritIdList()

    for _, id in ipairs(allSoulSpiritIdList) do
        if self:isCommonRedTipsById(id) then
            return true
        end
        if self:isGradeRedTipsById(id) then
            return true
        end
        if self:isInheritRedTipsById(id) then
            return true
        end
        if self:isAwakenRedTipsById(id) then
            return true
        end
        
    end
    
    return false
end

function QSoulSpirit:checkCombinationRedTips()
    if not self:checkSoulSpiritUnlock() then
        return false
    end
    for id, info in pairs(self._soulSpiritCombinationConfig or {}) do
        if self:checkCombinationCanUpgrade(id) then
            return true
        end
    end
    return false
end


function QSoulSpirit:checkSoulSpiritOccultRedTips( )
    local historyBigpoint = app:getUserData():getUserValueForKey(QUserData.SOULSPIRIT_OCCULT_POINT)
    historyBigpoint = tonumber(historyBigpoint)
    local checkResEnough =  function( nextChildInfo )
        if nextChildInfo and nextChildInfo.active_item then
            local activeItem = string.split(nextChildInfo.active_item, "^")
            local itemId = activeItem[1]
            local itemNum = activeItem[2]
            local currentCount = remote.items:getItemsNumByID(itemId)
            if currentCount >= tonumber(itemNum) then
                return true
            end
        end 

        return false 
    end
    for ii = 1,self._soulSpritOccultTreeNum do
        if historyBigpoint then
            local smallPoint = self:getSoulFireActiviteByBigPoint(ii,historyBigpoint)
            if smallPoint == QSoulSpirit.SMALLPOINT_MAX_NUM then
                local nextBigPoint = self:getNextBigPointBycellunlock(ii,historyBigpoint)
                if nextBigPoint then
                    historyBigpoint = nextBigPoint.cell_id
                    smallPoint = self:getSoulFireActiviteByBigPoint(ii,historyBigpoint)
                end
            end
            local nextChildInfo = db:getChildSoulFireInfo(ii,historyBigpoint,smallPoint+1)
            local isEnough =  checkResEnough(nextChildInfo) 
            return isEnough
        else
            for jj = QSoulSpirit.BIGPOINT_MAX_NUM,1,-1 do
                local isUnlock = self:checkBigPointCanUpgrade(ii,jj)
                if isUnlock then
                    local smallPoint = self:getSoulFireActiviteByBigPoint(ii,jj)
                    local nextChildInfo = db:getChildSoulFireInfo(ii,jj,smallPoint+1)
                    local isEnough =  checkResEnough(nextChildInfo) 
                    if isEnough then
                        return true
                    end      
                end
            end
        end
    end
    return false
end

function QSoulSpirit:isCommonRedTipsById(id)
    local mySoulSpirit = self:getMySoulSpiritInfoById(id)
    if mySoulSpirit then return false end

    local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(id, 0)
    if gradeConfig then
        local haveNum = remote.items:getItemsNumByID(gradeConfig.soul_gem)
        if haveNum >= gradeConfig.soul_gem_count then
            return true
        end
    end
    -- local config =  db:getCharacterByID(id)
    -- if soulSpiritInfo and config then
    --     local quality = config.aptitude
    --     local curLv = soulSpiritInfo.awaken_level or 0
    --     curLv = curLv + 1
    --     local awakenConfig = self:getSoulSpiritAwakenConfig(curLv,quality)
    --     if awakenConfig ~= nil then

    --         local items = {}
    --         local isEnough = true
    --         remote.items:analysisServerItem(awakenConfig.item, items)
    --         for index,item in ipairs(items) do
    --             if remote.items:getItemsNumByID(item.id) < item.count then
    --                 isEnough = false
    --                 break
    --             end
    --         end
    --         if isEnough then
    --             return isEnough
    --         end
    --     end
    -- end
    return false
end

function QSoulSpirit:isGradeRedTipsById(id)
    local soulSpiritInfo = self:getMySoulSpiritInfoById(id)
    if soulSpiritInfo then
        local gradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(id, soulSpiritInfo.grade+1)
        if gradeConfig ~= nil then
            local soulCount = remote.items:getItemsNumByID(gradeConfig.soul_gem)
            if soulCount >= gradeConfig.soul_gem_count then
                return true
            end
        end
    end
    return false
end

function QSoulSpirit:isInheritRedTipsById(id)
    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.SOUL_SPIRIT_INHERIT) then
        local soulSpiritInfo = self:getMySoulSpiritInfoById(id)
        local config =  db:getCharacterByID(id)
        if soulSpiritInfo and config and config.aptitude and config.aptitude == APTITUDE.SS then
            local nextInheritLv = soulSpiritInfo.devour_level or 0
            nextInheritLv = nextInheritLv + 1
            local nextInheritMod = self:getSoulSpiritInheritConfig(nextInheritLv,id)
            if nextInheritMod then
                local needExp =  tonumber(nextInheritMod.exp)
                local haveExp = 0
                local expItem = db:getItemByID(ITEM_TYPE.INHERIT_PIECE) -- 传承碎片
                if expItem then
                    local soulNum = remote.items:getItemsNumByID(expItem.id)
                    local exp = expItem.devour_exp or 0
                    haveExp = haveExp + exp * soulNum
                end
                if haveExp >= needExp then
                    return true
                end
                local dataPiece= remote.items:getItemsByCategory(ITEM_CONFIG_CATEGORY.SOULSPIRIT_PIECE)
                for i,v in ipairs(dataPiece or {}) do
                    local itemInfo = db:getItemByID(v.type)
                    if itemInfo and itemInfo.devour_exp and itemInfo.devour_exp > 0 then 
                        local exp = itemInfo.devour_exp * v.count
                        haveExp = haveExp + exp
                        if haveExp >= needExp then
                            return true
                        end                 
                    end

                end
            end
        end
    end

    return false
end


function QSoulSpirit:isAwakenRedTipsById(id)
    if app.unlock:checkLock("UNLOCK_SOUL_AWAKEN") == false then return false end

    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.SOUL_SPIRIT_AWAKEN) then
        local soulSpiritInfo = self:getMySoulSpiritInfoById(id)
        local config =  db:getCharacterByID(id)
        if soulSpiritInfo and config then
            local quality = config.aptitude
            local curLv = soulSpiritInfo.awaken_level or 0
            curLv = curLv + 1
            local awakenConfig = self:getSoulSpiritAwakenConfig(curLv,quality)
            if awakenConfig ~= nil then

                local items = {}
                local isEnough = true
                remote.items:analysisServerItem(awakenConfig.item, items)
                for index,item in ipairs(items) do
                    if remote.items:getItemsNumByID(item.id) < item.count then
                        isEnough = false
                        break
                    end
                end
                return isEnough
            end
        end
    end

    return false
end



function QSoulSpirit:isFreeSoulSpirit()
    local mySoulSpiritInfoList = self:getMySoulSpiritInfoList()
    for _, soulSpiritInfo in ipairs(mySoulSpiritInfoList) do
        if not soulSpiritInfo.heroId or soulSpiritInfo.heroId == 0 then
            return true
        end
    end

    return false
end

function QSoulSpirit:getMaxForceSkill()
    local soulSpiritInfoList = self:getMySoulSpiritInfoList()
    local maxForce = 0
    local maxForceSkillId = 0
    local maxForceSkillLevel = 0
    local teamSoulCount = 1
    local soulSpritForce = {}
    for _, info in ipairs(soulSpiritInfoList or {}) do
        local force = self:countForceBySpirit(info)

        table.insert(soulSpritForce, {id = info.id, force = force})
    end
    table.sort(soulSpritForce, function(a, b) 
            if a.force ~= b.force then
                return a.force > b.force 
            end
            return a.id  > b.id
        end)
    if self._teamTwoSoulSpritsMarkTbl[1] then
        teamSoulCount = 2 
    end
    for i=1,teamSoulCount do
        if soulSpritForce[i] ~= nil then
            maxForce = maxForce + soulSpritForce[i].force
        end
    end
    return maxForce
end


function QSoulSpirit:checkSoulSpiritPackItemNum()
    local configs = app.unlock:getConfigByKey("UNLOCK_SOUL_SPIRIT")
    if configs.team_level == nil then
        return false
    else
        local unlockLevel = configs.team_level
        if unlockLevel - 5 > remote.user.level then
            return false
        end 
    end

    local items = QStaticDatabase:sharedDatabase():getItemsByCategory(ITEM_CONFIG_CATEGORY.SOULSPIRIT_PIECE, ITEM_CONFIG_CATEGORY.SOULSPIRIT_CONSUM,ITEM_CONFIG_CATEGORY.SOULSPIRIT_BOX)
    for _, value in pairs(items) do
        if remote.items:getItemsNumByID(value.id) > 0 then
            return true
        end
    end
    return false
end

function QSoulSpirit:getSoulSpiritIdByFragmentId(fragmentId)
    local fragmentId = tonumber(fragmentId)
    if self._soulSpiritIdAndFragmentIdDic[fragmentId] then
        return self._soulSpiritIdAndFragmentIdDic[fragmentId]
    end

    for _, id in ipairs(self._allSoulSpiritIdList) do
        local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(id, 0)
        if gradeConfig then
            if gradeConfig.soul_gem == fragmentId then
                self._soulSpiritIdAndFragmentIdDic[fragmentId] = id
                return id
            end
        end
    end

    return nil
end

function QSoulSpirit:getNumForUnSelectedFood()
    local selectedCount = 0
    for _, count in pairs(self.selectedFoodDic) do
        selectedCount = selectedCount + count
    end

    return self.maxFoodCount - selectedCount
end

function QSoulSpirit:getAddExpAndAddCrit()
    local exp = 0
    local crit = 0
    for itemId, count in pairs(self.selectedFoodDic) do
        local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(itemId)
        exp = exp + (itemConfig.exp * count)
        crit = crit + (itemConfig.crit * count)
    end

    return exp, crit
end

function QSoulSpirit:getMasterConfigListByAptitude(aptitude)
    local aptitude = tostring(aptitude)
    if self._masterConfigListWithAptitude[aptitude] then
        return self._masterConfigListWithAptitude[aptitude]
    end

    local allMasterConfigs = QStaticDatabase.sharedDatabase():getStaticByName("soul_tianfu")
    local masterConfigs = allMasterConfigs[aptitude] or {}
    local tbl = {}
    for _, config in pairs(masterConfigs) do
        table.insert(tbl, config)
    end
    table.sort(tbl, function(a, b)
            return a.level < b.level
        end)
    self._masterConfigListWithAptitude[aptitude] = tbl

    return tbl
end

function QSoulSpirit:getMasterConfigByAptitudeAndMasterLevel(aptitude, masterLevel)
    local level = tonumber(masterLevel)
    local _masterConfigListWithAptitude = self:getMasterConfigListByAptitude(aptitude)
    if _masterConfigListWithAptitude[level].level == level then
        return _masterConfigListWithAptitude[level]
    end

    for _, config in ipairs(_masterConfigListWithAptitude) do
        if config.level == level then
            return config
        end
    end

    return nil
end

function QSoulSpirit:getMasterConfigByAptitudeAndSoulSpiritLevel(aptitude, soulSpiritLevel)
    local level = tonumber(soulSpiritLevel)
    local _masterConfigListWithAptitude = self:getMasterConfigListByAptitude(aptitude)
    local returnConfig

    for _, config in ipairs(_masterConfigListWithAptitude) do
        if config.condition <= level then
            returnConfig = config
        else
            break
        end
    end

    return returnConfig
end

function QSoulSpirit:getLevelConfigListByAptitude(aptitude)
    local aptitude = tostring(aptitude)
    if self._levelConfigListWithAptitude[aptitude] then
        return self._levelConfigListWithAptitude[aptitude]
    end

    local allLevelConfigs = QStaticDatabase.sharedDatabase():getStaticByName("soul_level")
    local levelConfigs = allLevelConfigs[aptitude] or {}
    local tbl = {}
    for _, config in pairs(levelConfigs) do
        table.insert(tbl, config)
    end
    table.sort(tbl, function(a, b)
            return a.chongwu_level < b.chongwu_level
        end)
    self._levelConfigListWithAptitude[aptitude] = tbl

    return tbl
end

function QSoulSpirit:getLevelConfigByAptitudeAndLevel(aptitude, level)
    local level = tonumber(level)
    local _levelConfigListWithAptitude = self:getLevelConfigListByAptitude(aptitude)
    if _levelConfigListWithAptitude[level] and _levelConfigListWithAptitude[level].chongwu_level == level then
        return _levelConfigListWithAptitude[level]
    end

    for _, config in ipairs(_levelConfigListWithAptitude) do
        if config.chongwu_level == level then
            return config
        end
    end

    return nil
end

function QSoulSpirit:getHandBookIdById(id)
    local soulSpiritInfo = self:getMySoulSpiritInfoById(id)
    if soulSpiritInfo and soulSpiritInfo.handBookId then
        return soulSpiritInfo.handBookId
    end

    local id = tostring(id)
    for handBookId, configList in pairs(self._soulSpiritCombinationConfig or {}) do
        local handBookId = tonumber(handBookId)
        local _, config = next(configList)
        local strTbl = string.split(config.condition, ";")
        local soulSpiritTbl1 = string.split(strTbl[1], "^")
        local soulSpiritInfo1 = self:getMySoulSpiritInfoById(soulSpiritTbl1[1])
        if soulSpiritInfo1 then
            soulSpiritInfo1.handBookId = handBookId
        end

        local soulSpiritTbl2 = string.split(strTbl[2], "^")
        local soulSpiritInfo2 = self:getMySoulSpiritInfoById(soulSpiritTbl2[1])
        if soulSpiritInfo2 then
            soulSpiritInfo2.handBookId = handBookId
        end

        if soulSpiritTbl1[1] == id or soulSpiritTbl2[1] == id then
            return handBookId
        end
    end

    return 0
end

function QSoulSpirit:getHandBookIdsByHandBookId(combinationId)
    local configList = self._soulSpiritCombinationConfig[tostring(combinationId)]
    if configList and configList[1] then
        local strTbl = string.split(configList[1].condition, ";")
        local soulSpiritTbl1 = string.split(strTbl[1], "^")
        local soulSpiritTbl2 = string.split(strTbl[2], "^")
        return soulSpiritTbl1[1], soulSpiritTbl2[1]
    end
    return 0, 0
end

function QSoulSpirit:getHandBookConfigByHandBookIdAndLevel(combinationId, grade)
    local configList = self._soulSpiritCombinationConfig[tostring(combinationId)]
    for _, config in pairs(configList or {}) do
        if config.grade == grade then
            return config
        end
    end
    return nil
end

function QSoulSpirit:checkCombinationCanUpgrade(combinationId)
    local combinationInfo = self:getMyHandBookInfoByHandBookId(combinationId) or {}
    local grade = (combinationInfo.grade or 0) + 1
    local combination = self:getHandBookConfigByHandBookIdAndLevel(combinationId, grade)
    if not combination then
        return false
    end
    
    local strTbl = string.split(combination.condition, ";")
    if combination.condition_num == 1 then
        local soulSpiritTbl1 = string.split(strTbl[1], "^")
        local soulSpiritInfo1 = self:getMySoulSpiritHistoryInfoById(soulSpiritTbl1[1])
        if soulSpiritInfo1.level > 0 and soulSpiritInfo1.grade >= tonumber(soulSpiritTbl1[2]) then
            return true
        end 
    else
        if #strTbl < 2 then
            return false
        end
        local soulSpiritTbl1 = string.split(strTbl[1], "^")
        local soulSpiritTbl2 = string.split(strTbl[2], "^")
        local soulSpiritInfo1 = self:getMySoulSpiritHistoryInfoById(soulSpiritTbl1[1])
        local soulSpiritInfo2 = self:getMySoulSpiritHistoryInfoById(soulSpiritTbl2[1])
        if soulSpiritInfo1.level > 0 and soulSpiritInfo1.grade >= tonumber(soulSpiritTbl1[2]) and 
            soulSpiritInfo2.level > 0 and soulSpiritInfo2.grade >= tonumber(soulSpiritTbl2[2]) then
            return true
        end
    end

    return false
end

function QSoulSpirit:getColorByCharacherId(characherId)
    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(characherId)
    local sabcInfo = QStaticDatabase.sharedDatabase():getSABCByQuality(characterConfig.aptitude)
    return string.upper(sabcInfo.color)
end


function QSoulSpirit:getPropDicByConfig(config, propDic)
    local returnTbl = propDic or {}
    for key, value in pairs(config or {}) do
        if QActorProp._field[key] then
            if returnTbl[key] then
                returnTbl[key] = returnTbl[key] + value
            else
                returnTbl[key] = value
            end
        end
    end

    return returnTbl
end

function QSoulSpirit:getUiPropListByConfig(config, isLinkUp, isNotTwo, isUiModel)
    local tbl = {}
    for key, value in pairs(config or {}) do
        if QActorProp._field[key] then
            local index = QActorProp:getPropIndexByKey(key)
            table.insert(tbl, {key = key, num = value, index = index})
        end
    end

    table.sort(tbl, function(a, b)
        if a.index ~= b.index then
            return a.index < b.index
        elseif a.num ~= b.num then
            return a.num < b.num
        else
            return string.len(a.key) < string.len(b.key)
        end
    end)

    if isLinkUp or isUiModel then
        tbl = self:_formatTbl(tbl, isLinkUp, isNotTwo, isUiModel)
    end

    return tbl
end

function QSoulSpirit:getPropListById(id, grade, level)
    local propDic = {}
    local soulSpiritInfo = self:getMySoulSpiritInfoById(id)
    local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(id, grade or soulSpiritInfo.grade)
    propDic = self:getPropDicByConfig(gradeConfig, propDic)
    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(id)
    local levelConfig = self:getLevelConfigByAptitudeAndLevel(characterConfig.aptitude, level or soulSpiritInfo.level)
    propDic = self:getPropDicByConfig(levelConfig, propDic)
    if soulSpiritInfo and soulSpiritInfo.devour_level and soulSpiritInfo.devour_level > 0 then
        local inheritConfig = db:getSoulSpiritInheritConfig(soulSpiritInfo.devour_level , soulSpiritInfo.id)
        if inheritConfig then
            propDic = self:getPropDicByConfig(inheritConfig, propDic)
        end
    end


    local returnTbl = {}
    for key, value in pairs(propDic) do
        if QActorProp._field[key] then
            local name = QActorProp._field[key].uiName or QActorProp._field[key].name
            local isPercent = QActorProp._field[key].isPercent
            local str = q.getFilteredNumberToString(value, isPercent, 2)
            local index = QActorProp:getPropIndexByKey(key)
            table.insert(returnTbl, {name = name, key = key, num = value, value = str, index = index})
        end
    end

    table.sort(returnTbl, function(a, b)
            if a.index ~= b.index then
                return a.index < b.index
            elseif a.num ~= b.num then
                return a.num < b.num
            else
                return string.len(a.key) < string.len(b.key)
            end
        end)

    return returnTbl
end

function QSoulSpirit:getUIPropInfo(props)
    if props == nil then return {} end
    local prop = {}

    local index = 1
    if props.attack_percent then
        prop[index] = {}
        prop[index].value = (props.attack_percent*100).."%"
        prop[index].name = "攻    击："
        index = index + 1
    end  
    if props.hp_percent then
        prop[index] = {}
        prop[index].value = (props.hp_percent*100).."%"
        prop[index].name = "生    命："
        index = index + 1
    end       
    if props.attack_value then
        prop[index] = {}
        prop[index].value = props.attack_value
        prop[index].name = "攻    击："
        index = index + 1
    end

    if props.hp_value then
        prop[index] = {}
        prop[index].value = props.hp_value
        prop[index].name = "生    命："
        index = index + 1
    end   

    if props.armor_physical then
        prop[index] = {}
        prop[index].value = props.armor_physical
        prop[index].name = "物    防："
        index = index + 1
    end
    if props.armor_magic then
        prop[index] = {}
        prop[index].value = props.armor_magic 
        prop[index].name = "法    防："
        index = index + 1
    end
    
    if props.armor_physical_percent then
        prop[index] = {}
        prop[index].value = ((props.armor_physical_percent)*100).."%"
        prop[index].name = "物    防："
        index = index + 1
    end

    if props.armor_magic_percent then
        prop[index] = {}
        prop[index].value = ((props.armor_magic_percent)*100).."%"
        prop[index].name = "法    防："
        index = index + 1
    end


    if props.physical_penetration_value then
        prop[index] = {}
        prop[index].value = props.physical_penetration_value
        prop[index].name = "物理穿透："
        index = index + 1
    end

    if props.magic_penetration_value then
        prop[index] = {}
        prop[index].value = props.magic_penetration_value
        prop[index].name = "法术穿透："
        index = index + 1
    end

    if props.physical_damage_percent_attack then
        prop[index] = {}
        prop[index].value = ((props.physical_damage_percent_attack)*100).."%"
        prop[index].name = "物伤提升："
        index = index + 1
    end

    if props.magic_damage_percent_attack then
        prop[index] = {}
        prop[index].value = ((props.magic_damage_percent_attack)*100).."%"
        prop[index].name = "法伤提升："
        index = index + 1
    end

    if props.magic_treat_percent_beattack then
        prop[index] = {}
        prop[index].value = ((props.magic_treat_percent_beattack)*100).."%"
        prop[index].name = "受疗提升："
        index = index + 1
    end 

    if props.physical_damage_percent_beattack_reduce then
        prop[index] = {}
        prop[index].value = ((props.physical_damage_percent_beattack_reduce)*100).."%" 
        prop[index].name = "物伤减免："
        index = index + 1
    end 

    if props.magic_damage_percent_beattack_reduce then
        prop[index] = {}
        prop[index].value = ((props.magic_damage_percent_beattack_reduce)*100).."%"
        prop[index].name = "法伤减免："
        index = index + 1
    end

    return prop
end

function QSoulSpirit:getSoulFirePropList()
    local returnTbl = {}
    local propDic = {}

    for _,mapInfo in pairs(self._soulSpiritOccultMapInfo) do
        for _,detailInfo in pairs(mapInfo.detailInfo) do
            local childConfig = db:getChildSoulFireInfo(mapInfo.mapId,detailInfo.bigPointId,detailInfo.smallPointId)
            propDic = self:getPropDicByConfig(childConfig, propDic)
        end
    end
    
    returnTbl = self:getUIPropInfo(propDic)

    return returnTbl
end

function QSoulSpirit:getFightCoefficientByAptitude(aptitude)
    local constantCoefficient = 0.25
    local aptitudeCoefficient = 0
    local sabcInfo = QStaticDatabase.sharedDatabase():getSABCByQuality(aptitude)
    if sabcInfo then
        local key = sabcInfo.qc.."_SOUL_COMBAT_SUCCESSION"
        print("QSoulSpirit:getFightCoefficientByAptitude() key = ", key)
        aptitudeCoefficient = QStaticDatabase.sharedDatabase():getConfigurationValue(key) or 0
    end
    local num = constantCoefficient * aptitudeCoefficient

    return q.getFilteredNumberToString(tonumber(num), true, 2), num
end

function QSoulSpirit:getFightAddCoefficientAptitudeByData(data)
   local result = 0
    if not data then
        return result
    end
    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(data.id)
    local str,num = self:getFightCoefficientByAptitude(characterConfig.aptitude)
    result = result + num

    return result
    
end


function QSoulSpirit:getFightAddCoefficientGradeByData(data)
    local result = 0
    if not data then
        return result
    end
    local curGradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(data.id, data.grade)
    if curGradeConfig and curGradeConfig.soul_combat_succession then
        result = result + curGradeConfig.soul_combat_succession
    end

    return result
end


function QSoulSpirit:getFightAddCoefficientByData(data)
    local result = 0
    if not data then
        return result
    end
    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(data.id)
    local str,num = self:getFightCoefficientByAptitude(characterConfig.aptitude)
    result = result + num

    local curGradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(data.id, data.grade)
    if curGradeConfig and curGradeConfig.soul_combat_succession then
        result = result + curGradeConfig.soul_combat_succession
    end
    local awaken_level = data.awaken_level or 0

    local curAwakenConfig = self:getSoulSpiritAwakenConfig(awaken_level,characterConfig.aptitude)
    if curAwakenConfig and curAwakenConfig.conmbat_succession then
        result = result + curAwakenConfig.conmbat_succession
    end
    
    return result
end

function QSoulSpirit:getAddLevelNumByIdAndAddExp(id, addExp, maxLevel, curLevel)
    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(id)
    local soulSpiritInfo = self:getMySoulSpiritInfoById(id)
    if not curLevel then
        curLevel = soulSpiritInfo.level
    end
    local totalExp = soulSpiritInfo.exp + addExp
    local addLevelNum = 0
    local leftExp = 0
    if not maxLevel then
        local levelConfigList = self:getLevelConfigListByAptitude(characterConfig.aptitude)
        local maxLevelByConfig = levelConfigList[#levelConfigList].chongwu_level
        maxLevel = math.min(remote.user.level * 2, maxLevelByConfig)
    end

    for i = curLevel + 1, maxLevel, 1 do
        local levelConfig = self:getLevelConfigByAptitudeAndLevel(characterConfig.aptitude, i)
        if totalExp >= levelConfig.strengthen_chongwu then
            addLevelNum = addLevelNum + 1
            totalExp = totalExp - levelConfig.strengthen_chongwu
        else
            break
        end
    end
    leftExp = totalExp

    return addLevelNum, leftExp
end

function QSoulSpirit:checkSoulSpiritUnlock(isTips, tips)
    if not self._isUnlock and app.unlock:getUnlockSoulSpirit(isTips, tips) then
        -- isUnlock作为登入后首次解锁的标记，然后做一个首次解锁的处理，拉取一次数据。
        self._isUnlock = true
        -- self:magicHerbGetInfoRequest()
        self:_addEvent()
    end
    return self._isUnlock
end

function QSoulSpirit:checkBackPackTips()
    if not self:checkSoulSpiritUnlock() then
        return false
    end
    if self:checkRedTips() then
        return true
    end
    if self:checkCombinationRedTips() then
        return true
    end

    if self:checkSoulSpiritOccultRedTips() then
        return true
    end
    
    return false
end

function QSoulSpirit:countForceBySpiritIds(soulSpiritIds)
    local force = 0
    for i, soulSpiritId in pairs(soulSpiritIds) do
        local soulSpirit = self:getMySoulSpiritInfoById(soulSpiritId)
        if soulSpirit then
            force = force + self:countForceBySpirit(soulSpirit)
        end
    end
    return force
end

function QSoulSpirit:countForceBySpirit(soulSpirit)
    if not soulSpirit then
        return 0
    end
    local force = 0
    local gradeConfig = db:getGradeByHeroActorLevel(soulSpirit.id, soulSpirit.grade) or {}
    local soulSpiritPGs = string.split(gradeConfig.soulspirit_pg,";")
    for _, soulSpiritPG in ipairs(soulSpiritPGs) do
        local skillIds = string.split(soulSpiritPG,":")
        local skillData = db:getSkillDataByIdAndLevel(tonumber(skillIds[1]), tonumber(skillIds[2])) or {}
        force = force + (skillData.battle_force or 0)
    end
    local soulSpiritDZs = string.split(gradeConfig.soulspirit_dz,";")
    for _, soulSpiritDZ in ipairs(soulSpiritDZs) do
        local skillIds = string.split(soulSpiritDZ,":")
        local skillData = db:getSkillDataByIdAndLevel(tonumber(skillIds[1]), tonumber(skillIds[2])) or {}
        force = force + (skillData.battle_force or 0)
    end

    local inheritConfig = remote.soulSpirit:getSoulSpiritInheritConfig(soulSpirit.devour_level or 0,soulSpirit.id) or {}
    local soulSpiritInheritSkills = string.split(inheritConfig.skill,";")
    for _, soulSpiritSkill in ipairs(soulSpiritInheritSkills) do
        local skillIds = string.split(soulSpiritSkill,":")
        local skillData = db:getSkillDataByIdAndLevel(tonumber(skillIds[1]), tonumber(skillIds[2])) or {}
        force = force + (skillData.battle_force or 0)
    end

    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(soulSpirit.id)
    local awakenConfig = remote.soulSpirit:getSoulSpiritAwakenConfig(soulSpirit.awaken_level,characterConfig.aptitude)
    if awakenConfig then
        force = force + (awakenConfig.battle_force or 0)
    end

    return force
end

--检查图鉴等级
function QSoulSpirit:getCombinationGradeById(combinationId)
    for i, v in pairs(self._soulSpiritHandBookInfoList) do
        if v.id == tonumber(combinationId) then
            return v.grade
        end
    end
    return 0
end

--检查图鉴等级
function QSoulSpirit:getCombinationByIdAndGrade(combinationId, grade)
    local combinationInfo = self._soulSpiritCombinationConfig[tostring(combinationId)]
    for i, combination in pairs(combinationInfo) do
        if grade == combination.grade then
            return combination
        end
    end
    return nil
end

function QSoulSpirit:updateExtraPropBySoulSpiritInfoList()--改为给上阵魂师加个人属性，全局属性刷新暂时舍弃
    -- local  soulSpiritList = {}
    -- for k,soulSpirit in pairs(self._soulSpiritInfoList or {}) do
    --     if soulSpirit and soulSpirit.devour_level and soulSpirit.devour_level > 0 and soulSpirit.heroId and soulSpirit.heroId > 0 then
    --         table.insert(soulSpiritList ,soulSpirit )
    --     end
    -- end
    -- QPrintTable(soulSpiritList)
    -- table.insert(self._dispatchTBl, {name = QSoulSpirit.EVENT_WEAR_INHERIT_ONE, soulSpiritList = soulSpiritList })
    -- self:_dispatchAll()
end

--------------数据处理.KUMOFLAG.--------------

function QSoulSpirit:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )
    if response.api == "SOUL_SPIRIT_LEVEL_UPDATE" and response.error == "NO_ERROR" then
        if response._id then
            self:_updateLevelUpConsume(response._id)
        end
        
        table.insert(self._dispatchTBl, {name = QSoulSpirit.EVENT_UPDATE})
        table.insert(self._dispatchTBl, {name = QSoulSpirit.EVENT_SOUL_SPIRIT_ACHIEVE_UPDATE})
    end

    if response.api == "SOUL_SPIRIT_GRADE_UPDATE" and response.error == "NO_ERROR" then
        table.insert(self._dispatchTBl, {name = QSoulSpirit.EVENT_UPDATE})
    end

    if response.api == "SOUL_SPIRIT_RECOVER" and response.error == "NO_ERROR" then
        if response._id then
            self:_removeSoulSpirit({response._id})
            self:_removeLevelUpConsume(response._id)
            self:_removeDevourConsume(response._id)


        end
        table.insert(self._dispatchTBl, {name = QSoulSpirit.EVENT_SOUL_SPIRIT_ACHIEVE_UPDATE})
    end

    if response.api == "SOUL_SPIRIT_GRADE_UPDATE" or response.api == "SOUL_SPIRIT_LEVEL_UPDATE" or
        response.api == "SOUL_SPIRIT_RECOVER" then 
        table.insert(self._dispatchTBl, {name = QSoulSpirit.EVENT_REFRESH_SOUL_SPIRIT})
    end

    if response.api == "SOUL_SPIRIT_OCCULT_LEVEL_UP" or response.api == "SOUL_SPIRIT_OCCULT_RESET" then
        self:updateSoulSpiritOccult(response.userSoulSpiritOccultResponse)
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

function QSoulSpirit:pushHandler( data )
    -- QPrintTable(data)
end

-- SOUL_SPIRIT_GRADE_UPDATE                    = 9780;                     // 魂灵升星（合成0星） SoulSpiritGradeUpdateRequest
-- SOUL_SPIRIT_LEVEL_UPDATE                    = 9781;                     // 魂灵升级 SoulSpiritLevelUpdateRequest
-- SOUL_SPIRIT_RECOVER                         = 9782;                     // 魂灵重生 SoulSpiritRecoverRequest
-- SOUL_SPIRIT_DECOMPOSE                       = 9783;                     // 魂灵碎片分解 SoulSpiritDecomposeRequest
-- SOUL_SPIRIT_EQUIP                           = 9784;                     // 魂灵护佑 SoulSpiritEquipRequest
-- SOUL_SPIRIT_COLLECT_ACTIVE                  = 9785;                     // 魂灵图鉴升级 SoulSpiritCollectActiveRequest, SoulSpiritCollectActiveResponse


-- required int32 spiritId = 1; // 魂灵id
function QSoulSpirit:soulSpiritGradeUpdateRequest(spiritId, success, fail, status)
    local soulSpiritGradeUpdateRequest = {spiritId = spiritId}
    local request = { api = "SOUL_SPIRIT_GRADE_UPDATE", soulSpiritGradeUpdateRequest = soulSpiritGradeUpdateRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_GRADE_UPDATE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- required int32 spiritId = 1; // 魂灵id
-- repeated Item items = 2; // 吞噬道具
--[[
    message Item {
        required int32 type = 1; // 物品编号
        required int32 count = 2; // 数量
        optional int64 expireTime = 3; // 过期时间
    }
]]
function QSoulSpirit:soulSpiritLevelUpdateRequest(spiritId, items, success, fail, status)
    local soulSpiritLevelUpdateRequest = {spiritId = spiritId, items = items}
    local request = { api = "SOUL_SPIRIT_LEVEL_UPDATE", soulSpiritLevelUpdateRequest = soulSpiritLevelUpdateRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_LEVEL_UPDATE", request, function (response)
        response._id = spiritId
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- required int32 spiritId = 1; // 魂灵id
-- optional bool dispose = 2 [default = false]; // 是否分解
function QSoulSpirit:soulSpiritRecoverRequest(spiritId, dispose, success, fail, status)
    local soulSpiritRecoverRequest = {spiritId = spiritId, dispose = dispose}
    local request = { api = "SOUL_SPIRIT_RECOVER", soulSpiritRecoverRequest = soulSpiritRecoverRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_RECOVER", request, function (response)
        response._id = spiritId
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- repeated Item items = 1; // 魂灵碎片
function QSoulSpirit:soulSpiritDecomposeRequest(items, success, fail, status)
    local soulSpiritDecomposeRequest = {items = items}
    local request = { api = "SOUL_SPIRIT_DECOMPOSE", soulSpiritDecomposeRequest = soulSpiritDecomposeRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_DECOMPOSE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- required int32 heroId = 1; // 英雄id
-- optional int32 spiritId = 2; // 魂灵id
-- optional bool equip = 3 [default = false]; // 是否穿戴
function QSoulSpirit:soulSpiritEquipRequest(heroId, spiritId, equip, success, fail, status)
    local soulSpiritEquipRequest = {heroId = heroId, spiritId = spiritId, equip = equip}
    local request = { api = "SOUL_SPIRIT_EQUIP", soulSpiritEquipRequest = soulSpiritEquipRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_EQUIP", request, function (response)
        if equip then
            table.insert(self._dispatchTBl, {name = QSoulSpirit.EVENT_WEAR, id = spiritId, heroId = heroId})
        
        else
            table.insert(self._dispatchTBl, {name = QSoulSpirit.EVENT_UNWEAR, id = spiritId, heroId = heroId})
        end
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- required int32 collectId = 1;
function QSoulSpirit:soulSpiritCollectActiveRequest(collectId, success, fail, status)
    local soulSpiritCollectActiveRequest = {collectId = collectId}
    local request = { api = "SOUL_SPIRIT_COLLECT_ACTIVE", soulSpiritCollectActiveRequest = soulSpiritCollectActiveRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_COLLECT_ACTIVE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- SOUL_SPIRIT_OCCULT_LEVEL_UP
function QSoulSpirit:soulSpiritOccultLevelUpRequest(mapId,bigPoint,smallPointId,success, fail)
    local userSoulSpiritOccultLevelUpRequest = {mapId = mapId,bigPointId = bigPoint,smallPointId = smallPointId}
    local request = { api = "SOUL_SPIRIT_OCCULT_LEVEL_UP", userSoulSpiritOccultLevelUpRequest = userSoulSpiritOccultLevelUpRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_OCCULT_LEVEL_UP", request, function (response)
        self:refreshHeroUtils()
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- SOUL_SPIRIT_OCCULT_RESET
function QSoulSpirit:soulSpiritOccultResetRequest(mapId,success, fail)
    local userSoulSpiritOccultResetRequest = {mapId = mapId}
    local request = { api = "SOUL_SPIRIT_OCCULT_RESET", userSoulSpiritOccultResetRequest = userSoulSpiritOccultResetRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_OCCULT_RESET", request, function (response)
        self:refreshHeroUtils()
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


-- /**
--  * 请求魂灵传承    SOUL_SPIRIT_DEVOUR soulSpiritDevourRequest
--  */
-- message SoulSpiritDevourRequest {
--     required int32 spiritId = 1; // 魂灵id
--     repeated Item items = 2; // 道具
-- }

-- /**
--  * 请求魂灵觉醒    SOUL_SPIRIT_INHERIT soulSpiritInheritRequest
--  */
-- message SoulSpiritInheritRequest {
--     required int32 spiritId = 1; // 魂灵id
--     repeated Item items = 2; // 道具
-- }


-- SOUL_SPIRIT_DEVOUR
function QSoulSpirit:soulSpiritDevourRequest(spiritId,items,success, fail)
    local soulSpiritDevourRequest = {spiritId = spiritId,items=items}
    local request = { api = "SOUL_SPIRIT_DEVOUR", soulSpiritDevourRequest = soulSpiritDevourRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_DEVOUR", request, function (response)
        self:refreshHeroUtils()
        self:_updateDevourConsume(spiritId,items)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- SOUL_SPIRIT_AWAKEN
function QSoulSpirit:soulSpiritAwakenRequest(spiritId,success, fail)
    local soulSpiritAwakenRequest = {spiritId = spiritId}
    local request = { api = "SOUL_SPIRIT_AWAKEN", soulSpiritAwakenRequest = soulSpiritAwakenRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_AWAKEN", request, function (response)
        self:refreshHeroUtils()
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 觉醒摘除
function QSoulSpirit:resetSoulSpiritAwakenRequest(spiritId,success, fail)
    local soulSpiritAwakenReturnRequest = {spiritId = spiritId}
    local request = { api = "SOUL_SPIRIT_AWAKEN_RETURN", soulSpiritAwakenReturnRequest = soulSpiritAwakenReturnRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_AWAKEN_RETURN", request, function (response)
        self:refreshHeroUtils()
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 传承摘除
function QSoulSpirit:resetSoulSpiritInheritRequest(spiritId,success, fail)
    local soulSpiritDevourReturnRequest = {spiritId = spiritId}
    local request = { api = "SOUL_SPIRIT_DEVOUR_RETURN", soulSpiritDevourReturnRequest = soulSpiritDevourReturnRequest}
    app:getClient():requestPackageHandler("SOUL_SPIRIT_DEVOUR_RETURN", request, function (response)
        self:refreshHeroUtils()
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具.KUMOFLAG.--------------

function QSoulSpirit:_dispatchAll()
    if not self._dispatchTBl or table.nums(self._dispatchTBl) == 0 then return end
    local tbl = {}
    for _, eventTbl in pairs(self._dispatchTBl) do
        if not tbl[eventTbl.name] or table.nums(eventTbl) > 1 then
            QPrintTable(eventTbl)
            self:dispatchEvent(eventTbl)
            tbl[eventTbl.name] = true
        end
    end
    self._dispatchTBl = {}
end

function QSoulSpirit:_analysisConfig()
    local characterConfig = QStaticDatabase.sharedDatabase():getCharacter()
    for _, config in pairs(characterConfig or {}) do
        if config.npc_type == 4 and not db:checkHeroShields(config.id,SHIELDS_TYPE.SOUL_SPIRIT) then
            table.insert(self._allSoulSpiritIdList, config.id)
        end
    end
    self._soulSpiritCombinationConfig = db:getStaticByName("soul_tujian")
end

function QSoulSpirit:getSoulFireBigPointByTreeType(treeType)
    if not treeType then return {} end
    local bigPoints = {}
    if q.isEmpty(self._allBigPointInfo) == true then
        self._allBigPointInfo = self:getAllSoulFireBigPointConfig()
    end
    for _,v in pairs(self._allBigPointInfo) do
        if treeType == v.tree_type then
            table.insert(bigPoints,v)
        end
    end 
    table.sort(bigPoints, function(a, b)
        return a.id < b.id
    end)

    return bigPoints
end

function QSoulSpirit:getAllSoulFireTreeNum()
    local allSoulSpiritOccultList = {}
    local treeNum = 0

        if q.isEmpty(self._allBigPointInfo) == true then
        self._allBigPointInfo = self:getAllSoulFireBigPointConfig()
    end
    for _,v in pairs(self._allBigPointInfo) do
        if not allSoulSpiritOccultList[v.tree_type] then
            allSoulSpiritOccultList[v.tree_type] = {}
            treeNum = treeNum + 1
        end
        -- table.insert(allSoulSpiritOccultList[v.tree_type],v)
    end

    return treeNum
end

-- 将秒为单位的数字转换成 00：00：00格式
function QSoulSpirit:_formatSecTime( sec )
    local d = math.floor(sec/DAY)
    local h = math.floor((sec/HOUR)%24)
    local m = math.floor((sec/MIN)%60)
    local s = math.floor(sec%60)

    return d, h, m, s
end

function QSoulSpirit:_addSoulSpirit( data )
    print("魂灵添加：", data.id)
    data.force = self:countForceBySpirit(data)
    table.insert(self._soulSpiritInfoList, data)
    self._soulSpiritIdDic[data.id] = true
end

function QSoulSpirit:_removeSoulSpirit( idList )
    local idList = idList or {}
    local removeIndexList = {}

    for _, id in ipairs(idList) do
        for index, soulSpirit in ipairs(self._soulSpiritInfoList) do
            if id == soulSpirit.id then
                table.insert(removeIndexList, index)
            end
        end
    end

    table.sort(removeIndexList, function(a, b)
            return a > b
        end)

    for _, index in ipairs(removeIndexList) do
        print("魂灵删除：", self._soulSpiritInfoList[index].id)
        self._soulSpiritIdDic[self._soulSpiritInfoList[index].id] = nil
        self._soulSpiritInfoList[index] = {}
        table.remove(self._soulSpiritInfoList, index)
    end

    -- self:updateExtraPropBySoulSpiritInfoList()
end

function QSoulSpirit:_coverSoulSpirit( data )
    data.force = self:countForceBySpirit(data)
    for _, soulSpirit in ipairs(self._soulSpiritInfoList) do
        if data.id == soulSpirit.id then
            print("魂灵更新：", data.id)
            for key, value in pairs(data) do
                print("魂灵更新：", key, value)
                soulSpirit[key] = value
            end
            -- QPrintTable(soulSpirit)
        end
    end
end

--每次SOUL_SPIRIT_LEVEL_UPDATE回調的時候，在數據類內部更新。
function QSoulSpirit:_updateLevelUpConsume( id )
    -- print("QSoulSpirit:_updateLevelUpConsume( id ) ", id)
    if not id then 
        self.selectedFoodDic = {}
        return 
    end
    -- QPrintTable(self.selectedFoodDic)
    if not self._soulSpiritIdAndLevelUpConsumeDic[id] then
        -- print("【新建】table ", id)
        self._soulSpiritIdAndLevelUpConsumeDic[id] = {}
    end
    for itemId, itemCount in pairs(self.selectedFoodDic) do
        if not self._soulSpiritIdAndLevelUpConsumeDic[id][itemId] then
            -- print("【负值】 ", itemId, itemCount)
            self._soulSpiritIdAndLevelUpConsumeDic[id][itemId] = itemCount
        else
            -- print("【累加】 ", self._soulSpiritIdAndLevelUpConsumeDic[id][itemId], itemCount)
            self._soulSpiritIdAndLevelUpConsumeDic[id][itemId] = self._soulSpiritIdAndLevelUpConsumeDic[id][itemId] + itemCount
        end
    end
    -- QPrintTable(self._soulSpiritIdAndLevelUpConsumeDic)
    if self._autoPutInFoodState == 1 or self._autoPutInFoodState == 2 then
        self._autoPutInFoodState = 2
        self:_autoChangeFood()
    else
        self.selectedFoodDic = {}
    end
    -- print("====== END =======")
end

function QSoulSpirit:_updateDevourConsume( id ,items)
    -- QPrintTable(items)
    print(id)
    if not self._soulSpiritIdAndDecourConsumeDic[id] then
        -- print("【新建】table ", id)
        self._soulSpiritIdAndDecourConsumeDic[id] = {}
    end

    for i, value in pairs(items or {}) do
        if not self._soulSpiritIdAndDecourConsumeDic[id][value.type] then
            self._soulSpiritIdAndDecourConsumeDic[id][value.type] = value.count
        else
            self._soulSpiritIdAndDecourConsumeDic[id][value.type] = self._soulSpiritIdAndDecourConsumeDic[id][value.type] + value.count
        end
        QPrintTable(self._soulSpiritIdAndDecourConsumeDic[id][value.type] )
    end
end


-- 如果記錄的food裡面，物品用完了，自動降品替代，如果一直都沒有，則清楚這個物品
function QSoulSpirit:_autoChangeFood()
    -- QPrintTable(self.selectedFoodDic)
    printTableWithColor(PRINT_FRONT_COLOR_RED, nil, self.selectedFoodDic)
    local demoteConfig = {
        {4300009, 4300008, 4300007},
        {4300006, 4300005, 4300004},
        {4300003, 4300002, 4300001},
    }
    printTableWithColor(PRINT_FRONT_COLOR_YELLOW, nil, demoteConfig)
    local addTbl = {}
    local changeTbl = {}
    for id, count in pairs(self.selectedFoodDic) do
        print("id = ", id)
        local _id = tonumber(id)
        local _count = tonumber(count)
        local haveNum = remote.items:getItemsNumByID(_id)
        if haveNum < _count then
            changeTbl[_id] = haveNum
            print("QSoulSpirit:_autoChangeFood() 修改：".._id.."數量："..haveNum)
            for i, group in ipairs(demoteConfig) do
                print("i = ", i)
                for index, itemId in ipairs(group) do
                    print("inde = ", index)
                    if itemId == _id then
                        if index < #group then
                            local newId = group[index+1]
                            local newCount = _count - haveNum
                            local newHaveNum = remote.items:getItemsNumByID(newId)
                            local newSelectNum = self.selectedFoodDic[newId] or 0
                            if (newHaveNum - newSelectNum) >= newCount then
                                addTbl[newId] = newCount
                                print("1 QSoulSpirit:_autoChangeFood() 替換：".._id.." to "..newId.."數量："..newCount)
                            else
                                newId = group[index+2]
                                newHaveNum = remote.items:getItemsNumByID(newId)
                                newSelectNum = self.selectedFoodDic[newId] or 0
                                if newId and (newHaveNum - newSelectNum) >= newCount then
                                    addTbl[newId] = newCount
                                    print("2 QSoulSpirit:_autoChangeFood() 替換：".._id.." to "..newId.."數量："..newCount)
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
    end

    if not q.isEmpty(changeTbl) or not q.isEmpty(addTbl) then
        self.isWarningForCritNotEnough = true
    end

    for id, count in pairs(changeTbl) do
        if count == 0 then
            self.selectedFoodDic[id] = nil
            print("QSoulSpirit:_autoChangeFood() 刪除："..id)
        else
            self.selectedFoodDic[id] = count
            print("QSoulSpirit:_autoChangeFood() 减量："..id.."当前數量："..count)
        end
    end

    for id, count in pairs(addTbl) do
        self.selectedFoodDic[id] = (self.selectedFoodDic[id] or 0) + count
        local haveNum = remote.items:getItemsNumByID(id)
        if haveNum < (self.selectedFoodDic[id] or 0) then
            self.selectedFoodDic[id] = haveNum
        end
        print("QSoulSpirit:_autoChangeFood() 新增："..id.."數量："..count.." 实际拥有："..haveNum)
    end
    -- QPrintTable(self.selectedFoodDic)
    printTableWithColor(PRINT_FRONT_COLOR_BLUE, nil, self.selectedFoodDic)
end


--每次SOUL_SPIRIT_RECOVER回調的時候，在數據類內部更新。
function QSoulSpirit:_removeLevelUpConsume( id )
    if not id then return end

    if self._soulSpiritIdAndLevelUpConsumeDic[id] then
        self._soulSpiritIdAndLevelUpConsumeDic[id] = nil
    end
end

function QSoulSpirit:_removeDevourConsume( id )
    if not id then return end

    if self._soulSpiritIdAndDecourConsumeDic[id] then
        self._soulSpiritIdAndDecourConsumeDic[id] = nil
    end
end

function QSoulSpirit:_formatTbl(tbl, isLinkUp, isNotTwo, isUiModel)
    local exchangeTbl = {}
    if isLinkUp then
        local preNum = 0
        local keyList = {}
        for _, value in ipairs(tbl) do
            if preNum == 0 then
                preNum = value.num
            elseif #keyList == 2 and not isNotTwo then
                table.insert(exchangeTbl, {num = preNum, keys = keyList})
                keyList = {}
                if preNum ~= value.num then
                    preNum = value.num
                end
            else
                if preNum ~= value.num then
                    table.insert(exchangeTbl, {num = preNum, keys = keyList})
                    preNum = value.num
                    keyList = {}
                end
            end
            table.insert(keyList, value.key)
        end
        if #keyList > 0 then
            table.insert(exchangeTbl, {num = preNum, keys = keyList})
        end
    else
        exchangeTbl = tbl
    end

    if isUiModel then
        -- 自適應改變屬性名字的長度，以適合最長的那個屬性名字。
        local maxLenForName = 0
        for _, tbl in ipairs(exchangeTbl) do
            local name = ""
            for i, key in ipairs(tbl.keys) do
                if name == "" then
                    name = QActorProp._field[key].uiName or QActorProp._field[key].name
                else
                    name = name.."、"..(QActorProp._field[key].uiName or QActorProp._field[key].name)
                end
            end
            tbl.nameStr = name
            local LenForName = string.len(name)
            -- print(name, LenForName, maxLenForName)
            if LenForName > maxLenForName then
                maxLenForName = LenForName
            end
        end

        for _, tbl in ipairs(exchangeTbl) do
            if string.len(tbl.nameStr) < maxLenForName then
                local len = maxLenForName - string.len(tbl.nameStr)
                local _, count = string.gsub(tbl.nameStr, "、", "、")
                if not count or count == 0 then 
                    local index = 1
                    local count = 1
                    local nameList = {}
                    local name = ""
                    while string.len(name) <= maxLenForName do
                        if index >= string.len(tbl.nameStr) then
                            name = ""
                            index = 1
                            count = count + 1
                        else
                            local c = string.sub(tbl.nameStr, index, index + 1)
                            local b = string.byte(c) or 0
                            local str = c
                            if b > 128 then
                                str = string.sub(tbl.nameStr, index, index + 2)
                                index = index + 2
                            else
                                index = index + 1
                            end
                            index = index + 1
                            name = name..str
                            if index >= string.len(tbl.nameStr) then
                                table.insert(nameList, name)
                            end
                            for i = 1, count, 1 do
                                name = name.." "
                            end
                        end
                    end
                    if #nameList > 0 then
                        tbl.nameStr = nameList[#nameList]
                    end
                end
            end
        end
    end

    -- QPrintTable(exchangeTbl)
    return exchangeTbl
end

    -- self._soulSpiritAwakenMaxLevelDic = {} -- 魂灵品质对应最大的觉醒等级
    -- self._soulSpiritInheritMaxLevel = nil -- 魂灵最大的传承等级
--db
function QSoulSpirit:getSoulSpiritAwakenConfig(awakenLevel_ , quality_)
    -- local  soulSpiritAwaken =  db:getStaticByName("soul_awaken")
    -- for _,value in pairs(soulSpiritAwaken or {}) do
    --     if value.level == awakenLevel_ and quality_ == value.quality then
    --         return value
    --     end
    -- end
    -- return nil

    return db:getSoulSpiritAwakenConfig(awakenLevel_ , quality_)
end

function QSoulSpirit:getSoulSpiritAwakenAllConfigValue(quality_ , lower)
    lower = lower or 1

    local result = {}
    local  soulSpiritAwaken =  db:getStaticByName("soul_awaken")
    for _,value in pairs(soulSpiritAwaken or {}) do
        if value.level >= lower and quality_ == value.quality then
            result[value.level] = value
        end
    end
    return result
end


function QSoulSpirit:getSoulSpiritAwakenConfigMaxLevel(quality_)
    if self._soulSpiritAwakenMaxLevelDic[quality_] ~= nil then
        return self._soulSpiritAwakenMaxLevelDic[quality_]
    end
    local maxNum = 0

    local  soulSpiritAwaken =  db:getStaticByName("soul_awaken")
    for _,value in pairs(soulSpiritAwaken or {}) do
        if tonumber(quality_) == tonumber(value.quality) then
            if tonumber(value.level) > tonumber(maxNum) then
                maxNum = tonumber(value.level)
            end
        end
    end
    self._soulSpiritAwakenMaxLevelDic[quality_] = maxNum

    return self._soulSpiritAwakenMaxLevelDic[quality_] 
end


function QSoulSpirit:getSoulSpiritInheritConfig(inheritLevel_ , characterId_ )
    -- local  soulSpiritInherit =  db:getStaticByName("soul_inherit")
    -- for _,value in pairs(soulSpiritInherit or {}) do
    --     if value.level == inheritLevel_ and characterId_ == value.character then
    --         return value
    --     end
    -- end
    -- return nil
    return db:getSoulSpiritInheritConfig(inheritLevel_ , characterId_ )
end

function QSoulSpirit:getSoulSpiritInheritAllConfigValue(characterId_ , lower)
    lower = lower or 0

    local  soulSpiritInherit =  db:getStaticByName("soul_inherit")
    local result = {}
    for _,value in pairs(soulSpiritInherit or {}) do
        if  characterId_ == value.character and value.level >= lower then
            result[value.level] = value
        end
    end
    return result
end

function QSoulSpirit:getSoulSpiritInheritConfigMaxLevel( characterId_)
    if self._soulSpiritInheritMaxLevelDic[characterId_] ~= nil then
        return self._soulSpiritInheritMaxLevelDic[characterId_] 
    end
    local maxNum = 0

    local  soulSpiritInherit =  db:getStaticByName("soul_inherit")
    for _,value in pairs(soulSpiritInherit or {}) do
        if value.level > maxNum and characterId_ == value.character  then
            maxNum = value.level
        end
    end
    self._soulSpiritInheritMaxLevelDic[characterId_] = maxNum
    return self._soulSpiritInheritMaxLevelDic[characterId_]
end

function QSoulSpirit:getPropStrList(config)
    if not config then return {} end
    local propDesc = {}
    for _,v in ipairs(QActorProp._uiFields) do
        if config[v.fieldName] ~= nil then
            local value = config[v.fieldName]
            if v.handlerFun ~= nil then
                value = v.handlerFun(value)
            end
            local propMod = {fieldName = v.fieldName , name = v.name ,value = value}

            table.insert(propDesc, propMod)
        end
    end
    return propDesc
end

--为战斗处理魂灵数据,新增2个战斗用数据，不允许处理别的数据
function QSoulSpirit:updateSoulSpiritData( data )
    --additionSkills 额外技能 key value, addCoefficient战斗加成系数
    if not data then return data end

    data.additionSkills = {}
    data.addCoefficient = self:getFightAddCoefficientByData(data)

    local devourLv = data.devour_level or 0
    local inheritMod = remote.soulSpirit:getSoulSpiritInheritConfig(devourLv ,data.id)
    if inheritMod and inheritMod.skill then
        local  skillIdVec = string.split(inheritMod.skill, ";")
        for i,v in ipairs(skillIdVec or {}) do
            local  skillIdValue = string.split(inheritMod.skill, ":")
            if skillIdValue[1] and skillIdValue[2] then
                local skill = {key = skillIdValue[1] , value=skillIdValue[2]}
                table.insert(data.additionSkills ,skill)
            end
        end
    end

end

return QSoulSpirit
