--
-- Author: Kumo.Wang
-- 仙品养成数据管理
--

local QBaseModel = import("...models.QBaseModel")
local QMagicHerb = class("QMagicHerb", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QActorProp = import("...models.QActorProp")

QMagicHerb.NEW_DAY = "QMagicHerb_NEW_DAY"
QMagicHerb.UPDATE_USER_COMEBACK = "QMagicHerb_UPDATE_USER_COMEBACK"

QMagicHerb.EVENT_REFRESH_MAGIC_HERB = "EVENT_REFRESH_MAGIC_HERB"
QMagicHerb.EVENT_SELECTED_MAGIC_HERB = "EVENT_SELECTED_MAGIC_HERB"
QMagicHerb.EVENT_MAGIC_HERB_ACHIEVE_UPDATE = "EVENT_MAGIC_HERB_ACHIEVE_UPDATE"
QMagicHerb.EVENT_REFRESH_MAGIC_HERB_BREED_SUCCESS = "EVENT_REFRESH_MAGIC_HERB_BREED_SUCCESS"
QMagicHerb.STATE_LOCK = "STATE_LOCK"
QMagicHerb.STATE_NO_WEAR = "STATE_NO_WEAR" 
QMagicHerb.STATE_CAN_CHANGE = "STATE_CAN_CHANGE"
QMagicHerb.STATE_IS_BEST = "STATE_IS_BEST"


QMagicHerb.EVENT_MAGIC_HERB_TEAM_PROP_UPDATE = "EVENT_MAGIC_HERB_TEAM_PROP_UPDATE"  --全局属性刷新事件
QMagicHerb.EVENT_SS_MAGIC_HERB_UPDATE_HERO = "EVENT_SS_MAGIC_HERB_UPDATE_HERO"  --全局属性刷新事件


QMagicHerb.BREED_LV_MAX = 5


QMagicHerb._uiProps = {} -- 记录仙品显示使用的数据

table.insert(QMagicHerb._uiProps, {fieldName = "team_attack_value", longName = "全队攻击", shortName = "全队攻击", isPercent = false })
table.insert(QMagicHerb._uiProps, {fieldName = "team_hp_value", longName = "全队生命", shortName = "全队生命", isPercent = false })
table.insert(QMagicHerb._uiProps, {fieldName = "team_armor_physical", longName = "全队物防", shortName = "全队物防", isPercent = false })
table.insert(QMagicHerb._uiProps, {fieldName = "team_armor_magic", longName = "全队法防", shortName = "全队法防", isPercent = false })
table.insert(QMagicHerb._uiProps, {fieldName = "attack_value", longName = "攻     击", shortName = "攻击", isPercent = false })
table.insert(QMagicHerb._uiProps, {fieldName = "hp_value", longName = "生    命", shortName = "生命", isPercent = false })
table.insert(QMagicHerb._uiProps, {fieldName = "armor_physical", longName = "物理防御", shortName = "物防", isPercent = false })
table.insert(QMagicHerb._uiProps, {fieldName = "armor_magic", longName = "法术防御", shortName = "法防", isPercent = false })

table.insert(QMagicHerb._uiProps, {fieldName = "team_attack_percent", longName = "全队攻击", shortName = "全队攻击", isPercent = true })
table.insert(QMagicHerb._uiProps, {fieldName = "team_hp_percent", longName = "全队生命", shortName = "全队生命", isPercent = true })
table.insert(QMagicHerb._uiProps, {fieldName = "team_armor_physical_percent", longName = "全队物防", shortName = "全队物防", isPercent = true })
table.insert(QMagicHerb._uiProps, {fieldName = "team_armor_magic_percent", longName = "全队法防", shortName = "全队法防", isPercent = true })
table.insert(QMagicHerb._uiProps, {fieldName = "attack_percent", longName = "攻    击", shortName = "攻击", isPercent = true })
table.insert(QMagicHerb._uiProps, {fieldName = "hp_percent", longName = "生    命", shortName = "生命", isPercent = true })
table.insert(QMagicHerb._uiProps, {fieldName = "armor_physical_percent", longName = "物理防御", shortName = "物防", isPercent = true })
table.insert(QMagicHerb._uiProps, {fieldName = "armor_magic_percent", longName = "法术防御", shortName = "法防", isPercent = true })


table.insert(QMagicHerb._uiProps, {fieldName = "physical_penetration_value", shortName = "物穿" , longName = "物理穿透", isPercent = false})
table.insert(QMagicHerb._uiProps, {fieldName = "magic_penetration_value", shortName = "法穿" , longName = "法术穿透", isPercent = false})
table.insert(QMagicHerb._uiProps, {fieldName = "hit_rating", shortName = "命中", longName = "命中" , isPercent = false})
table.insert(QMagicHerb._uiProps, {fieldName = "dodge_rating", shortName = "闪避", longName = "闪避", isPercent = false})
table.insert(QMagicHerb._uiProps, {fieldName = "block_rating", shortName = "格挡", longName = "格挡", isPercent = false})
table.insert(QMagicHerb._uiProps, {fieldName = "critical_rating", shortName = "暴击", longName = "暴击", isPercent = false})
table.insert(QMagicHerb._uiProps, {fieldName = "critical_chance", shortName = "暴击", longName = "暴击", isPercent = false})
table.insert(QMagicHerb._uiProps, {fieldName = "cri_reduce_rating", shortName = "抗暴", longName = "抗暴", isPercent = false})
table.insert(QMagicHerb._uiProps, {fieldName = "cri_reduce_chance", shortName = "抗暴", longName = "抗暴", isPercent = false})
table.insert(QMagicHerb._uiProps, {fieldName = "haste_rating", shortName = "攻速" , longName = "攻速" , isPercent = false})
table.insert(QMagicHerb._uiProps, {fieldName = "wreck_rating", shortName = "破击" , longName = "破击" , isPercent = false})


table.insert(QMagicHerb._uiProps, {fieldName = "physical_damage_percent_attack", shortName = "物伤提升",longName = "物理加伤", isPercent = true })
table.insert(QMagicHerb._uiProps, {fieldName = "magic_damage_percent_attack", shortName = "法伤提升", longName = "法术加伤", isPercent = true  })
table.insert(QMagicHerb._uiProps, {fieldName = "physical_damage_percent_beattack_reduce", shortName = "物理免伤", longName = "物理减伤", isPercent = true  })
table.insert(QMagicHerb._uiProps, {fieldName = "magic_damage_percent_beattack_reduce", shortName = "法术免伤", longName = "法术减伤", isPercent = true  })
table.insert(QMagicHerb._uiProps, {fieldName = "magic_treat_percent_beattack", shortName = "受疗提升", longName = "受疗提升", isPercent = true  })
table.insert(QMagicHerb._uiProps, {fieldName = "magic_treat_percent_attack", shortName = "治疗提升", longName = "治疗提升", isPercent = true  })


function QMagicHerb:ctor()
    QMagicHerb.super.ctor(self)
end

function QMagicHerb:init()
    self._dispatchTBl = {}
    self._isUnlock = false -- isUnlock作为登入后首次解锁的标记，然后做一个首次解锁的处理，拉取一次数据。修改且唯一修改于QUnlock类，该值不要作为功能解锁的判断依据，它只是一个标记。
    self._isShow = false -- _isShow功能与isUnlock类似，只是他的解锁在configration.MAGIC_HERB_SHOW
    self._magicHerbItemList = {} -- 仙品的道具信息(包括item信息)，该信息首次拉取，在QUnlock类里首次判断解锁后拉取。
    self._magicHerbItemDic = {} -- key：sid，value：self._magicHerbItemList的index
    self._maigcHerbSketchItemList = {} --key1：仙品type, key2:仙品品质, value：仙品的虚拟模型（包括item信息和magicHerb基本信息）
    self._maigcHerbWildItemDic = {} -- 破碎仙草map。key：品質，value：破碎仙草itemconfig

    self.donotShowSuit = false

    self._magicHerbConfigs = db:getStaticByName("magic_herb")
    self._magicHerbGradeConfigs = db:getStaticByName("magic_herb_grade")
    self._magicHerbSuitConfigs = db:getStaticByName("magic_herb_suit_kill")
    self._magicHerbEnchantConfigs = db:getStaticByName("magic_herb_enhance")
    self._magicHerbRefineConfigs = db:getStaticByName("magic_herb_attributes")

    self._masterConfigListWithAptitude ={}
end

function QMagicHerb:loginEnd(success)
    self:checkMagicHerbUnlock(nil, nil, success)
end

function QMagicHerb:disappear()
    QMagicHerb.super.disappear(self)
    self:_removeEvent()
end

function QMagicHerb:_addEvent()
    self:_removeEvent()
end

function QMagicHerb:_removeEvent()
end

--打开界面
function QMagicHerb:openDialog(callback)
end

--------------数据储存.KUMOFLAG.--------------

function QMagicHerb:getMagicHerbItemList()
    return self._magicHerbItemList
end

function QMagicHerb:getMaigcHerbItemBySid( sid )
    local returnTbl = {}
    if not sid then return returnTbl end
    return self._magicHerbItemDic[sid]
end

function QMagicHerb:getMaigcHerbSketchItemByType( magicHerbType, aptitude )
    local returnTbl = {}
    if magicHerbType == nil or aptitude == nil then return returnTbl end

    if self._maigcHerbSketchItemList[magicHerbType] and self._maigcHerbSketchItemList[magicHerbType][aptitude] then
        return self._maigcHerbSketchItemList[magicHerbType][aptitude]
    end

    for _, config in pairs(self._magicHerbConfigs) do
        if config.type == magicHerbType and config.aptitude == aptitude then
            local itemConfig = db:getItemByID(config.id)
            if itemConfig then
                table.insert(returnTbl, itemConfig)
            end
        end
    end

    if #returnTbl > 0 then
        if self._maigcHerbSketchItemList[magicHerbType] == nil then
            self._maigcHerbSketchItemList[magicHerbType] = {}
        end
        self._maigcHerbSketchItemList[magicHerbType][aptitude] = returnTbl
    end
    return returnTbl
end

--------------调用素材.KUMOFLAG.--------------

--------------便民工具.KUMOFLAG.--------------

function QMagicHerb:checkMagicHerbUnlock(isTips, tips, success)
    if ENABLE_MAGIC_HERB and not self._isUnlock and app.unlock:getUnlockMagicHerb(isTips, tips) then
        -- isUnlock作为登入后首次解锁的标记，然后做一个首次解锁的处理，拉取一次数据。
        self._isUnlock = true
        self:magicHerbGetInfoRequest(success)
        self:_addEvent()
    elseif ENABLE_MAGIC_HERB and not self._isShow then
        local showLevel = db:getConfigurationValue("MAGIC_HERB_SHOW") or 9999
        if remote.user.level >= showLevel then
            self._isShow = true
            self:magicHerbGetInfoRequest(success)
        end
    else
        if success then
            success()
        end
    end
    return self._isUnlock, self._isShow
end

--获取仙品配置通过ItemID
function QMagicHerb:getMagicHerbConfigByItemnId(itemId)
    local itemConfig = db:getItemByID(itemId)
    return self:getMagicHerbConfigByid(itemConfig.id)
end

function QMagicHerb:getMagicHerbConfigByid( id )
    if not id then return {} end
    return self._magicHerbConfigs[tostring(id)] or {}
end

function QMagicHerb:getMagicHerbGradeConfigByIdAndGrade( id, grade )
    local returnConfig = {}
    if not id or not grade then return returnConfig end
    local tbl = self._magicHerbGradeConfigs[tostring(id)] or {}
    for _, value in ipairs(tbl) do
        if value.grade == grade then
            returnConfig = value
            break
        end
    end
    return returnConfig
end

function QMagicHerb:getUnlockTeamLevel()
    local unlockConfigs = db:getStaticByName("unlock")
    local unlockConfig = unlockConfigs["UNLOCK_MAGIC_HERB"]
    return unlockConfig.team_level
end

function QMagicHerb:getMagicHerbSuitConfigByTypeAndAptitude( magicHerbType, aptitude ,breedLv )
    local returnConfig = {}
    if not magicHerbType or not aptitude or not breedLv then return returnConfig end
    local tbl = self._magicHerbSuitConfigs[tostring(magicHerbType)] or {}
    for _, value in pairs(tbl) do
        if value.aptitude == aptitude and value.breed <= breedLv then
            returnConfig = value
        end
    end
  

    return returnConfig
end

function QMagicHerb:getMagicHerbSuitConfigsByType( magicHerbType )
    local returnConfig = {}
    if not magicHerbType then return returnConfig end
    local returnConfig = self._magicHerbSuitConfigs[tostring(magicHerbType)] or {}

    table.sort(returnConfig, function(a, b)
                if  a.breed ~= b.breed then
                    return a.breed < b.breed
                else
                    return a.aptitude < b.aptitude
                end
            end)

    return returnConfig
end

function QMagicHerb:getRefineItemIdAndPriceByAptitude( aptitude ,islock )
    if not aptitude then return nil end

    local key = ""
    if islock then
        key = "MAGIC_HERB_REFINE_CONSUM_3"
    elseif aptitude >= 20 then
        key = "MAGIC_HERB_REFINE_CONSUM_1"
    else
        key = "MAGIC_HERB_REFINE_CONSUM_2"
    end
    local str = db:getConfigurationValue(key)
    local tbl = string.split(str, "^")

    return tonumber(tbl[1]), tonumber(tbl[2])
end

function QMagicHerb:getMagicHerbUpLevelConfigByIdAndLevel( id, level )
    local returnConfig = {}
    if not id or not level then return returnConfig end

    returnConfig = self._magicHerbEnchantConfigs[tostring(id)][tonumber(level)]
    return returnConfig or {}
end

function QMagicHerb:getRefineValueColorAndMax(key, value, refineId)
    local returnColor = "B"
    local isMax = false
    local score = 0
    if not key or not value or not refineId then return returnColor, isMax , score end

    local refineConfig = self:getRefineConfigByRefineId(refineId)
    local convertValue = math.floor(value*10000+0.5)/10000
    local index = 1
    local total = table.nums(refineConfig)
    while true do
        if refineConfig["attribute_id_"..index] then
            if refineConfig["attribute_id_"..index] == key then
                local tbl = string.split(refineConfig["value_"..index], ";")
                if tbl and #tbl == 2 then
                    if convertValue >= tonumber(tbl[1]) and convertValue <= tonumber(tbl[2]) then 
                        returnColor = refineConfig["color_"..index]
                        -- isMax = convertValue == tonumber(tbl[2])
                        -- break
                    end
                    isMax = convertValue >= tonumber(tbl[2])
                    score = math.ceil(convertValue * 100 / (tonumber(tbl[2]) or 1) )
                end
            end
        else
            break
        end
        index = index + 1
        if index > total then
            break
        end
    end

    return returnColor, isMax , score
end

function QMagicHerb:getRefineConfigByRefineId( refineId )
    local refineConfig = {}
    if not refineId then return refineConfig end

    local refineConfig = self._magicHerbRefineConfigs[tostring(refineId)] or {}
    return refineConfig
end

function QMagicHerb:getActorIdWithMagicHerb()
    local heroInfos = remote.herosUtil:getMaxForceHeros()
    for i = 1, #heroInfos do
        local heroModel = remote.herosUtil:getUIHeroByID(heroInfos[i].id)
        if heroModel:isTakenMagicHerb() then
            return heroInfos[i].id
        end
    end
    return nil
end

function QMagicHerb:getActorIdWithMagicHerbAptitudeS()
    local heroInfos = remote.herosUtil:getMaxForceHeros()
    for i = 1, #heroInfos do
        local heroModel = remote.herosUtil:getUIHeroByID(heroInfos[i].id)
        if heroModel:isTakenMagicHerbAptitudeS() then
            return heroInfos[i].id
        end
    end
    return nil
end



function QMagicHerb:getActorIdWithoutMagicHerb()
    local heroInfos = remote.herosUtil:getMaxForceHeros()
    for i = 1, #heroInfos do
        local heroModel = remote.herosUtil:getUIHeroByID(heroInfos[i].id)
        if heroModel:checkCanWearMagicHerb() then
            return heroInfos[i].id
        end
    end
    return nil
end

function QMagicHerb:getAptitudeSetByAptitude(aptitude)
    for _, value in ipairs(HERO_SABC) do
        if value.aptitude == tonumber(aptitude) then
            return value
        end
    end

    return nil
end

function QMagicHerb:getMagicHerbAttributeTypeName(attributeType)
    if attributeType == 1 then
        return "攻击"
    elseif attributeType == 2 then
        return "生命"
    elseif attributeType == 3 then
        return "防御"
    else
        return ""
    end
end

function QMagicHerb:getWildMagicHerbByAptitude(aptitude)
    local aptitude = tonumber(aptitude)
    if self._maigcHerbWildItemDic[aptitude] then
        return self._maigcHerbWildItemDic[aptitude]
    end

    local itemConfigList = db:getItemsByCategory(ITEM_CONFIG_CATEGORY.MAGICHERB)
    for _, itemConfig in ipairs(itemConfigList) do
        if itemConfig.type == ITEM_CONFIG_TYPE.MAGICHERB_WILD then
            local _wildAptitude = itemConfig.magic_herb_grade
            if _wildAptitude and not self._maigcHerbWildItemDic[_wildAptitude] then
                self._maigcHerbWildItemDic[_wildAptitude] = itemConfig
            end
            if _wildAptitude == aptitude then
                return itemConfig
            end
        end
    end

    return nil
end

function QMagicHerb:getAllWildMagicHerbConfigList(aptitude)
    local returnList = {}
    local itemConfigList = db:getItemsByCategory(ITEM_CONFIG_CATEGORY.MAGICHERB)
    for _, itemConfig in ipairs(itemConfigList) do
        if itemConfig.type == ITEM_CONFIG_TYPE.MAGICHERB_WILD then
            local _wildAptitude = itemConfig.magic_herb_grade
            if _wildAptitude and not self._maigcHerbWildItemDic[_wildAptitude] then
                self._maigcHerbWildItemDic[_wildAptitude] = itemConfig
            end
            table.insert(returnList, itemConfig)
        end
    end

    return returnList
end

--检查仙品背包里面是否有东西
function QMagicHerb:checkMagicHerbBackPackItemNum()
    local isUnlock, isShowBag = self:checkMagicHerbUnlock()
    if not isUnlock and not isShowBag then return false end

    -- 检查仙品道具
    local items = db:getItemsByCategory(ITEM_CONFIG_CATEGORY.MAGICHERB)
    for _, value in pairs(items) do
        if remote.items:getItemsNumByID(value.id) > 0 then
            return true
        end
    end
    --检查仙品
    local magicHerbItemList = self:getMagicHerbItemList()
    if #magicHerbItemList > 0 then
        return true
    end

    return false
end

function QMagicHerb:checkBackPackTips()
    return false
end

function QMagicHerb:getAllItemIds()
    local allItemIds = self:getConsumItemIds()

    local magicHerbItemList = self:getMagicHerbItemList()
    for _, magicHerbItem in ipairs(magicHerbItemList) do
        table.insert(allItemIds, magicHerbItem.sid)
    end

    return allItemIds
end

function QMagicHerb:getConsumItemIds()
    local consumItemIds = {}
    local _itemList = remote.items:getItemsByCategory(ITEM_CONFIG_CATEGORY.MAGICHERB)
    -- QPrintTable(_itemList)
    local tbl = {} -- 用於檢測重複的itemId
    for _, item in ipairs(_itemList) do
        local itemConfig = db:getItemByID(item.type)
        if itemConfig.type ~= ITEM_CONFIG_TYPE.MAGICHERB then
            if not tbl[itemConfig.id] then
                table.insert(consumItemIds, itemConfig.id)
                tbl[itemConfig.id] = true
            end
        end
    end

    return consumItemIds
end

function QMagicHerb:getMagicHerbItemIds()
    local magicHerbItemIds = {}
    local magicHerbItemList = self:getMagicHerbItemList()
    for _, magicHerbItem in ipairs(magicHerbItemList) do
        table.insert(magicHerbItemIds, magicHerbItem.sid)
    end

    return magicHerbItemIds
end

--获取对应品质仙品的强化大师数据列表
function QMagicHerb:getMasterConfigListByAptitude(aptitude)
    local aptitude = tostring(aptitude)
    if self._masterConfigListWithAptitude[aptitude] then
        return self._masterConfigListWithAptitude[aptitude]
    end

    local masterConfigs = db:getStaticByName("magic_herb_master")
    local masterConfigList = masterConfigs[aptitude]
    if not masterConfigList or tostring(masterConfigList[1].aptitude) ~= aptitude then
    masterConfigList = {}
     for _, masterConfig in pairs(masterConfigs) do
         for _, value in ipairs(masterConfig) do
             if value.aptitude == aptitude then
                 table.insert(masterConfigList, value)
             end
         end
     end
     table.sort(masterConfigList, function(a, b)
             return a.master_level < b.master_level
         end)
    end    

    self._masterConfigListWithAptitude[aptitude] = masterConfigList
    return masterConfigList
end

--获取仙品对应品质与强化大师等级数据
function QMagicHerb:getMasterConfigByAptitudeAndMasterLevel(aptitude, masterLevel)
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

--获取仙品对应品质与仙品强化等级数据
function QMagicHerb:getMasterConfigByAptitudeAndMagicHerbLevel(aptitude, magicHerbLevel)
    local level = tonumber(magicHerbLevel)
    local _masterConfigListWithAptitude = self:getMasterConfigListByAptitude(aptitude)
    local returnConfig = nil
    for _, config in ipairs(_masterConfigListWithAptitude) do
        if config.condition <= level then
            returnConfig = config
        else
            break
        end
    end

    return returnConfig
end

--返回数据 replaceIndex 用作传给服务器的属性编号 从0计数， value 处理过的属性列表 ，sortValue 排序用的属性比较
--{replaceIndex ， value , sortValue}
function QMagicHerb:_getOldNewPropTable(sid)
    local magicHerbItemInfo = self:getMaigcHerbItemBySid(sid)
    if not magicHerbItemInfo then return {},{} end
    local nowProp = magicHerbItemInfo.attributes
    local oldPropList = {}
    local newPropList = {}

    local attrNum = 1
    local additional_attributes = self:getMagicHerbAdditionalAttributes(magicHerbItemInfo)

    if nowProp and not q.isEmpty(nowProp) then
        local propList = self:_getPropList(nowProp,  additional_attributes)
        attrNum = #propList
        table.insert(oldPropList, { value = propList })
    end

    local newProp = magicHerbItemInfo.replaceAttributes or {}
    if newProp and not q.isEmpty(newProp) then
        local propList = self:_getPropList(newProp,  additional_attributes)
        local totalNum = #propList
        if totalNum > attrNum then

            local countColorTable = { A = 1 ,B = 2 ,C = 3 ,D = 4 ,E = 5 ,F = 6 ,G = 7 }
            local mod = math.fmod( totalNum, attrNum ) 
        
            local count = math.ceil(totalNum / attrNum)

            for i=1,count do
                local sortValue = 0
                local valueTable = {}
                for k =1,attrNum do
                    local dataIndex = (i - 1)  * attrNum + k
                    local propValue = propList[dataIndex]

                    table.insert(valueTable,propValue)      
                    if propValue then
                        local curValue = propValue.score or 0
                        sortValue = sortValue + curValue
                    end
                end
                -- table.sort(valueTable, function (x, y)
                --     return countColorTable[x.color] > countColorTable[y.color]
                -- end )
                table.sort(valueTable, function (x, y)
                    return x.score > y.score
                end )
                QPrintTable(valueTable)
                table.insert(newPropList, {replaceIndex = i - 1 , value = valueTable , sortValue = sortValue })     
            end
            table.sort(newPropList, function (x, y)
                return x.sortValue > y.sortValue
            end )

        else
            table.insert(newPropList, {replaceIndex = 0 , value = propList })               
        end
    end

    return oldPropList , newPropList
end
-- 显示用的属性数据列表
function QMagicHerb:_getPropList( prop, refineId )
    local tbl = {}
    if prop then
        for _, value in ipairs(prop) do
            local key = value.attribute
            local num = value.refineValue--math.floor(value.refineValue*1000)/1000
            local idx= value.index
            if QActorProp._field[key] then
                local color, isMax ,score = remote.magicHerb:getRefineValueColorAndMax(key, num, refineId)
                local name = QActorProp._field[key].uiName or QActorProp._field[key].name
                num = q.getFilteredNumberToString(num, QActorProp._field[key].isPercent, 2)     
                table.insert(tbl, {name = name, num = num, color = color, isMax = isMax ,idx = idx , score = score})
            end
        end
    end

    return tbl
end

--------------数据处理.KUMOFLAG.--------------

function QMagicHerb:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )
    if (response.api == "MAGIC_HERB_UP_GRADE" 
        -- or response.api == "MAGIC_HERB_SUMMON"
        or response.api == "MAGIC_HERB_GET"
        or response.api == "MAGIC_HERB_RETURN"
        or response.api == "MAGIC_HERB_RECOVER") and response.error == "NO_ERROR" then
        table.insert(self._dispatchTBl, QMagicHerb.EVENT_MAGIC_HERB_ACHIEVE_UPDATE)
    end

    if response.api == "MAGIC_HERB_REPLACE" and response.error == "NO_ERROR" then
        if response.magicHerbs then
            self:_addMagicHerbItems(response.magicHerbs)
        end
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

function QMagicHerb:pushHandler( data )
    -- QPrintTable(data)
end

-- //仙品API定义
-- MAGIC_HERB_GET                              = 9730;                     // 获取用户仙品信息
-- MAGIC_HERB_ENCHANCE                         = 9731;                     // 仙品强化 参数参考: MagicHerbEnhanceRequest
-- MAGIC_HERB_REFINE                           = 9732;                     // 仙品洗练 参数参考: MagicHerbRefineRequest
-- MAGIC_HERB_RETURN                           = 9734;                     // 仙品重生 参考参数:  MagicHerbReturnRequest
-- MAGIC_HERB_LOAD                             = 9736;                     // 仙品装卸 参考参数：MagicHerbLoadRequest
-- MAGIC_HERB_SUMMON                           = 9737;                     // 仙草商城抽奖 参考参数：MagicHerbSummonRequest
-- MAGIC_HERB_UP_GRADE                         = 9738;                     // 仙草升星 参考参数：MagicHerbUpGradeRequest
-- MAGIC_HERB_LOCK                             = 9739;                     // 仙草加锁 参考参数：MagicHerbLockRequest
-- MAGIC_HERB_RECOVER                          = 9740;                     // 仙草分解 参考参数：MagicHerbRecoverRequest
-- MAGIC_HERB_REPLACE                          = 9741;                     // 仙草附加属性替换 参考参数：MagicHerbReplaceAttributesRequest
-- MAGIC_HERB_EXCHANGE                         = 9742;                     // 仙品一键转换     参考参数：MagicHerbReplaceAttributesRequest
-- MAGIC_HERB_ONE_KEY_ENCHANCE                 = 9743;                     // 仙品一键强化     参考参数：MagicHerbOneKeyEnhanceRequest

-- 仙品一键强化 
-- optional int32 heroId = 1;  // 一键强化仙草的英雄
-- optional bool toTop = 2;    // 是否强顶化到
function QMagicHerb:magicHerbQuickEnhanceRequest(heroId, toTop, success, fail, status)
    local magicHerbOneKeyEnhanceRequest = {heroId = heroId, toTop = toTop}
    local request = { api = "MAGIC_HERB_ONE_KEY_ENCHANCE", magicHerbOneKeyEnhanceRequest = magicHerbOneKeyEnhanceRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_ONE_KEY_ENCHANCE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QMagicHerb:magicHerbGetInfoRequest(success, fail, status)
    local request = { api = "MAGIC_HERB_GET"}
    app:getClient():requestPackageHandler("MAGIC_HERB_GET", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string sid = 1;                                             // 要强化的物品ID
-- optional int32 count = 2;                                            // 要强化的次数 1次或者 5次  其他会报错
function QMagicHerb:magicHerbEnhanceRequest(sid, count, success, fail, status)
    local magicHerbEnhanceRequest = {sid = sid, count = count}
    local request = { api = "MAGIC_HERB_ENCHANCE", magicHerbEnhanceRequest = magicHerbEnhanceRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_ENCHANCE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string sid = 1;                                                // 物品id
-- optional int32 lockIndex = 2;                                           // 锁定的属性 index
function QMagicHerb:magicHerbRefineRequest(sid, lockIndex, multi , success, fail, status)
    local magicHerbRefineRequest = {sid = sid, lockIndex = lockIndex , multi = multi}
    local request = { api = "MAGIC_HERB_REFINE", magicHerbRefineRequest = magicHerbRefineRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_REFINE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string sid = 1;                                                // 物品id
function QMagicHerb:magicHerbReturnRequest(sid, success, fail, status)
    local magicHerbReturnRequest = {sid = sid}
    local request = { api = "MAGIC_HERB_RETURN", magicHerbReturnRequest = magicHerbReturnRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_RETURN", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string sid = 1;                                                  //仙草ID
-- optional int32 type = 2;                                                  // 类型（1安装，2拆卸）
-- optional int32 actorId = 3;                                               //英雄ID（安装需要）
-- optional int32 position = 4;                                              //位置 （安装需要）
function QMagicHerb:magicHerbLoadRequest(sid, type, actorId, position, success, fail, status)
    local magicHerbLoadRequest = {sid = sid, type = type, actorId = actorId, position = position}
    local request = { api = "MAGIC_HERB_LOAD", magicHerbLoadRequest = magicHerbLoadRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_LOAD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional bool isTen = 1;                           //是否是十连抽
function QMagicHerb:magicHerbSummonRequest(isTen, success, fail, status)
    local magicHerbSummonRequest = {isTen = isTen}
    local request = { api = "MAGIC_HERB_SUMMON", magicHerbSummonRequest = magicHerbSummonRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_SUMMON", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string sid = 1;                                             // 要升星的物品ID
-- repeated string ids = 2;                                             // 升星消耗的仙品Id集合
-- optional string itemId = 3;                                          // 升星消耗的道具id
-- optional int32 itemNum = 4;                                          // 升星消耗的道具数量                                                   //购买次数
function QMagicHerb:magicHerbUpGradeRequest(sid, ids, itemId, itemNum, success, fail, status)
    local magicHerbUpGradeRequest = {sid = sid, ids = ids, itemId = itemId, itemNum = itemNum}
    local request = { api = "MAGIC_HERB_UP_GRADE", magicHerbUpGradeRequest = magicHerbUpGradeRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_UP_GRADE", request, function (response)
        self:_removeMagicHerbItemBySids(ids)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string sid = 1;                                             // 要锁住或者解锁的物品ID
-- optional bool isLock = 2;                                            // true 加锁 false 解锁
function QMagicHerb:magicHerbLockRequest(sid, isLock, success, fail, status)
    local magicHerbLockRequest = {sid = sid, isLock = isLock}
    local request = { api = "MAGIC_HERB_LOCK", magicHerbLockRequest = magicHerbLockRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_LOCK", request, function (response)
        if isLock then
            app.tip:floatTip("当前仙品已经被保护，无法分解、重生和用于升星")
        else
            app.tip:floatTip("仙品保护状态已经解除")
        end
        self:responseHandler(response, success)
    end, function (response)
        if isLock then
            app.tip:floatTip("锁定失败")
        else
            app.tip:floatTip("解锁失败")
        end
        self:responseHandler(response, nil, fail)
    end)
end

-- repeated string sid = 1;                                             // 仙品id集合
-- repeated Item items = 2;                                             // 破碎仙品集合
function QMagicHerb:magicHerbRecoverRequest(sid, items, success, fail, status)
    local magicHerbRecoverRequest = {sid = sid, items = items}
    local request = { api = "MAGIC_HERB_RECOVER", magicHerbRecoverRequest = magicHerbRecoverRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_RECOVER", request, function (response)
        self:_removeMagicHerbItemBySids(sid)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string sid = 1;                                                    // 物品id
-- optional bool isReplace = 2;                                                // 是否替换属性,true 替换属性 false 保持原属性   
function QMagicHerb:magicHerbReplaceAttributesRequest(sid, isReplace , replaceIndex, success, fail, status)
    local magicHerbReplaceAttributesRequest = {sid = sid, isReplace = isReplace , position = replaceIndex or 0}
    local request = { api = "MAGIC_HERB_REPLACE", magicHerbReplaceAttributesRequest = magicHerbReplaceAttributesRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_REPLACE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- /**
--  * 英雄仙品一键交换
--  */
-- message MagicHerbExchangeRequest {
--     optional int32 actorId = 1;                                             //英雄ID1
--     optional int32 actorId2 = 2;                                            //英雄ID2
-- }
function QMagicHerb:magicHerbExchangeRequest(actorId , actorId2 , success, fail, status)
    local magicHerbExchangeRequest = {actorId = actorId, actorId2 = actorId2}
    local request = { api = "MAGIC_HERB_EXCHANGE", magicHerbExchangeRequest = magicHerbExchangeRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_EXCHANGE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


-- /**
--  * 仙草培育
--  */
-- message MagicHerbBreedRequest {
--     optional string sid = 1;                                             // 仙品id
-- }
function QMagicHerb:magicHerbBreedRequest(sid, success, fail, status )
    local magicHerbBreedRequest = {sid = sid}
    local request = { api = "MAGIC_HERB_BREED", magicHerbBreedRequest = magicHerbBreedRequest}
    app:getClient():requestPackageHandler("MAGIC_HERB_BREED", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end



--------------本地工具.KUMOFLAG.--------------

function QMagicHerb:_dispatchAll()
    if not self._dispatchTBl or table.nums(self._dispatchTBl) == 0 then return end
    local tbl = {}
    for _, name in pairs(self._dispatchTBl) do
        if not tbl[name] then
            -- print("QMagicHerb:_dispatchAll() name = ", name)
            self:dispatchEvent({name = name})
            tbl[name] = 0
        end
    end
    self._dispatchTBl = {}
end

function QMagicHerb:_analysisConfig()
    
end

-- 将秒为单位的数字转换成 00：00：00格式
function QMagicHerb:_formatSecTime( sec )
    local d = math.floor(sec/DAY)
    local h = math.floor((sec/HOUR)%24)
    local m = math.floor((sec/MIN)%60)
    local s = math.floor(sec%60)

    return d, h, m, s
end

-- message MagicHerb {
--     optional string sid = 1;                            // 序列号
--     optional int32 itemId = 2;                          // 物品编号
--     optional int32 level = 3;                           // 强化等级
--     optional int32 exp =4;                              // 经验
--     optional int32 grade = 5;                           // 星级
--     optional int32 actorId = 6;                         // 穿戴英雄
--     optional int32 position = 7;                        // 穿戴位置
--     repeated MagicHerbAttr attributes = 8;              // 附加属性
--     optional bool isLock = 9;                           // 是否加锁
--     repeated MagicHerbAttr replaceAttributes = 10;      // 可替换的附加属性
--     optional int32 attributesRefineConsume = 11;        // 洗练消耗的道具数量
--     optional int32 extendsAttributesRefineConsume = 12; // 升星继承的道具数量
--     optional int32 breedLevel = 13;                     //培育等级
-- }
function QMagicHerb:setMagicHerbs( magicHerbs )
    self:_updateMagicHerbItems(magicHerbs)
end

function QMagicHerb:_addMagicHerbItems( magicHerbList )
    for _, value in pairs(magicHerbList) do
        self._magicHerbItemDic[value.sid] = value
    end
    -- QPrintTable(self._magicHerbItemDic)

    local tempTable = {}
    for k,v in pairs(self._magicHerbItemDic or {}) do
        if v ~=nil then
            table.insert(tempTable , v)
        end
    end
    self._magicHerbItemList = tempTable

    if #magicHerbList > 0 then
        self:dispatchEvent({name = QMagicHerb.EVENT_MAGIC_HERB_ACHIEVE_UPDATE})
    end

    self:_checkChangeBreedMagicHerb()
end

function QMagicHerb:_removeMagicHerbItemBySids( sidList )
    for _, sid in ipairs(sidList or {}) do
        self._magicHerbItemDic[sid] = nil
    end
    -- QPrintTable(self._magicHerbItemDic)
    local tempTable = {}
    for k,v in pairs(self._magicHerbItemDic or {}) do
        if v ~=nil then
            table.insert(tempTable , v)
        end
    end
    self._magicHerbItemList = tempTable
    self:_checkChangeBreedMagicHerb()

end

function QMagicHerb:_updateMagicHerbItems( magicHerbList )
    self:_addMagicHerbItems(magicHerbList)
    self:dispatchEvent({name = remote.magicHerb.EVENT_REFRESH_MAGIC_HERB})
end

--判断是否刷新全局属性
function QMagicHerb:_checkChangeBreedMagicHerb()
    local magicHerbList = self:getTopBreedMagicHerbList()
    local extraProp = app.extraProp:getSelfExtraProp() or {}
    local bRefrehs = not q.isEmpty(magicHerbList)  or (q.isEmpty(magicHerbList) and not q.isEmpty(extraProp) 
        and extraProp[app.extraProp.MAGICHERB_PROP] and not q.isEmpty(extraProp[app.extraProp.MAGICHERB_PROP]))
    if bRefrehs  then
        self:dispatchEvent({name = QMagicHerb.EVENT_MAGIC_HERB_TEAM_PROP_UPDATE , magicHerbList = magicHerbList})
        self:dispatchEvent({name = QMagicHerb.EVENT_SS_MAGIC_HERB_UPDATE_HERO })
    end
end

--获得培育等级最高的三种类型的16个仙品
function QMagicHerb:getTopBreedMagicHerbList()
    if q.isEmpty(self._magicHerbItemDic) then
        return {}
    end

    local magicHerbList = {}
    local magicHerbTypeList = {}
    magicHerbTypeList[1]={}
    magicHerbTypeList[2]={}
    magicHerbTypeList[3]={}

    for k,magicHerb in pairs(self._magicHerbItemDic) do
        if magicHerb and magicHerb.breedLevel and magicHerb.breedLevel > 0 then
            local magicHerbConfig = self:getMagicHerbConfigByid(magicHerb.itemId)
            if magicHerbConfig and magicHerbConfig.attribute_type then
                local typeIdx = tonumber(magicHerbConfig.attribute_type)
                table.insert(magicHerbTypeList[typeIdx], magicHerb)
            end
        end
    end
    local maxNum = 16   --单个仙品类型最多取
    for _,magicHerbTypeTbl in ipairs(magicHerbTypeList) do
        table.sort(magicHerbTypeTbl,function(a, b) 
            if a.breedLevel ~= b.breedLevel then
                return a.breedLevel > b.breedLevel 
            else
                return a.itemId > b.itemId 
            end
        end)
        for i,magicHerb in ipairs(magicHerbTypeTbl) do
            if i > maxNum then
                break
            end
            table.insert(magicHerbList, {itemId = magicHerb.itemId , breedLevel = magicHerb.breedLevel})
        end
    end
    QPrintTable(magicHerbList)
    return magicHerbList
end


function QMagicHerb:getColorStrList(magicHerb)

    local magicHerbConfig = self:getMagicHerbConfigByid(magicHerb.itemId)
    local returnTBl = {}
    if magicHerbConfig ==nil then return {} end

    local additional_attributes = self:getMagicHerbAdditionalAttributes(magicHerb)

    for _, value in ipairs(magicHerb.attributes or {}) do
        local key = value.attribute
        if key and QActorProp._field[key] then
            local colorStr = self:getRefineValueColorAndMax(key, value.refineValue, additional_attributes)
            table.insert(returnTBl, colorStr)
        end
    end

    table.sort(returnTBl, function(a, b)
            return a > b
        end)
    
    return returnTBl
end

function QMagicHerb:getAptitudeByIdAndBreedLv(magicId , breedlv)
    
    if not breedlv or breedlv < QMagicHerb.BREED_LV_MAX  then
        local magicHerbConfig = self:getMagicHerbConfigByid(magicId)
        return magicHerbConfig.aptitude
    end
    return APTITUDE.SS
end

function QMagicHerb:getAptitudeByAptitudeAndBreedLv(aptitude , breedlv)

    if breedlv and breedlv >= QMagicHerb.BREED_LV_MAX  then
        return APTITUDE.SS
    end
    return aptitude
end


function QMagicHerb:getMagicHerbAdditionalAttributes(magicHerb)
    local magicHerbConfig = self:getMagicHerbConfigByid(magicHerb.itemId)
    local additional_attributes = magicHerbConfig.additional_attributes
    if self:getAptitudeByIdAndBreedLv(magicHerb.itemId,magicHerb.breedLevel) == APTITUDE.SS then
        additional_attributes = magicHerbConfig.ss_additional_attributes
    end
    return additional_attributes
end



function QMagicHerb:setPropInfo(config , short ,isPercentFirst ,isMergeArmor)
    local prop = {}
    local backProp = {}
    if not config then return prop end 
    --fieldName = "attack_value", longName = "攻    击", shortName = "攻击", isPercent = false 
    local mergeTbl = {}
    if isMergeArmor then
        if config["armor_physical"] and config["armor_magic"] then
            mergeTbl["armor_physical"]= "双防"
            mergeTbl["armor_magic"]= ""
        end
        if config["armor_physical_percent"] and config["armor_magic_percent"] then
            mergeTbl["armor_physical_percent"]= "双防"
            mergeTbl["armor_magic_percent"]= ""
        end
        if config["team_armor_physical"] and config["team_armor_magic"] then
            mergeTbl["team_armor_physical"]= "全队双防"
            mergeTbl["team_armor_magic"]= ""
        end
        if config["team_armor_physical_percent"] and config["team_armor_magic_percent"] then
            mergeTbl["team_armor_physical_percent"]= "全队双防"
            mergeTbl["team_armor_magic_percent"]= ""
        end
    end

    for i,v in ipairs(QMagicHerb._uiProps) do
        if config[v.fieldName] ~= nil then
            local name = v.longName
            if short then
                name = v.shortName
            end

            if q.isEmpty(mergeTbl) or mergeTbl[v.fieldName] ~= "" then

                name = mergeTbl[v.fieldName] or name

                local value = config[v.fieldName]
                if v.isPercent then
                    value = q.PropPercentHanderFun(value)
                end
                local data_ = {value = value , name = name , key = v.fieldName}
                if isPercentFirst and not v.isPercent   then
                    table.insert( backProp ,data_ )
                else
                    table.insert( prop, data_)
                end                
            end

  
        end
    end
    for i,v in ipairs(backProp) do
        table.insert( prop,v)
    end
    -- 注意，这里只有仙品的基础属性（非附加属性）才做双防合并显示的处理。

    return prop 
end 

function QMagicHerb:isBreedUpRedTipsBySid(sid)
    local magicHerbInfo = self:getMaigcHerbItemBySid(sid)
    local breedLevel = 0
    if magicHerbInfo then
        breedLevel = magicHerbInfo.breedLevel or 0
        breedLevel = breedLevel + 1
    end
    local nextBreedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(magicHerbInfo.itemId, breedLevel)
    if nextBreedConfig then
        local count = remote.items:getItemsNumByID(nextBreedConfig.breed_item)
        local maxBreedCount = nextBreedConfig.breed_num or 1
        if count >= maxBreedCount then
            return true
        end 
    end
    return false
end
-----




-- function QMagicHerb:_addMagicHerbItems( magicHerbList )
--     print("QMagicHerb:_addMagicHerbItems()", #magicHerbList)
--     for _, value in ipairs(magicHerbList) do
--         -- 来自量表的仙品对应模版Item数据
--         local itemInfo = clone(QStaticDatabase:sharedDatabase():getItemByID(value.itemId))
--         assert(itemInfo, string.format("Item %s can't be found in item table", value.itemId))
--         itemInfo.count = 1 

--         -- 来自服务器的仙品专属属性（包括附加属性）
--         itemInfo.magicHerbInfo = value

--         -- 来自量表的仙品基本数据
--         local magicHerbConfig = self:getMagicHerbConfigByid(itemInfo.id)
--         itemInfo.magicHerbConfig = magicHerbConfig

--         -- 来自量表的升星数据（包括仙品属性）
--         local magicHerbGradeConfig = self:getMagicHerbGradeConfigByIdAndGrade(magicHerbConfig.id, value.grade or 1)
--         itemInfo.magicHerbGradeConfig = magicHerbGradeConfig

--         -- 来自量表的升级数据（包括仙品属性）
--         local magicHerbUpLevelConfig = self:getMagicHerbUpLevelConfigByIdAndLevel(magicHerbConfig.id, value.level or 1)
--         itemInfo.magicHerbUpLevelConfig = magicHerbUpLevelConfig

--         -- 用於排序的附加屬性顏色
--         -- local colorStrList = self:_getColorStrList(value.attributes, magicHerbConfig.additional_attributes)
--         -- itemInfo.colorStrList = colorStrList

--         -- 来自量表的培育数据（只有仙品属性不包括全局属性）与强化等级相关



--         if not self._magicHerbItemDic[value.sid] then
--             local index = #self._magicHerbItemList + 1
--             self._magicHerbItemList[index] = itemInfo
--         end
--         self._magicHerbItemDic[value.sid] = itemInfo
--     end

--     if #magicHerbList > 0 then
--         self:dispatchEvent({name = QMagicHerb.EVENT_MAGIC_HERB_ACHIEVE_UPDATE})
--     end

-- end

-- function QMagicHerb:_removeMagicHerbItemBySids( sidList )
--     local sidList = sidList or {}
--     local removeIndexList = {}
--     for _, sid in ipairs(sidList or {}) do
--         self._magicHerbItemDic[sid] = nil
--     end

--     local tempTbl = {}
--     for index, value in ipairs(self._magicHerbItemList) do
--         if self._magicHerbItemDic[value.magicHerbInfo.sid] ~= nil then
--             table.insert(tempTbl, value)
--         end
--     end
--     self._magicHerbItemList = tempTbl
-- end



-- function QMagicHerb:_updateMagicHerbItems( magicHerbList )
--     local tbl = {}
--     for _, value in ipairs(magicHerbList or {}) do
--         local magicHerbItemInfo = self._magicHerbItemDic[value.sid] or nil
--         if magicHerbItemInfo then
--             if magicHerbItemInfo.magicHerbInfo.grade ~= value.grade then
--                 -- 更新升星数据（包括仙品属性）
--                 local magicHerbGradeConfig = self:getMagicHerbGradeConfigByIdAndGrade(magicHerbItemInfo.magicHerbConfig.id, value.grade or 1)
--                 magicHerbItemInfo.magicHerbGradeConfig = magicHerbGradeConfig
--             end
--             if magicHerbItemInfo.magicHerbInfo.level ~= value.level then
--                 -- 更新升级数据（包括仙品属性）
--                 local magicHerbUpLevelConfig = self:getMagicHerbUpLevelConfigByIdAndLevel(magicHerbItemInfo.magicHerbConfig.id, value.level or 1)
--                 magicHerbItemInfo.magicHerbUpLevelConfig = magicHerbUpLevelConfig
--             end
--             magicHerbItemInfo.magicHerbInfo = value
--         else
--             table.insert(tbl, value)
--         end
--     end

--     self:_addMagicHerbItems(tbl)

--     self:dispatchEvent({name = remote.magicHerb.EVENT_REFRESH_MAGIC_HERB})
-- end

-- function QMagicHerb:_updateColorStrList( magicHerbList )
--     local tbl = {}
--     for _, value in ipairs(magicHerbList or {}) do
--         local magicHerbItemInfo = self._magicHerbItemDic[value.sid] or nil
--         if magicHerbItemInfo then
--             local colorStrList = self:_getColorStrList(value.attributes, magicHerbItemInfo.magicHerbConfig.additional_attributes)
--             magicHerbItemInfo.colorStrList = colorStrList
--         else
--             table.insert(tbl, value)
--         end
--     end

--     self:_addMagicHerbItems(tbl)
-- end

-- function QMagicHerb:_getColorStrList(attributes, additional_attributes)
--     local returnTBl = {}

--     for _, value in ipairs(attributes) do
--         local key = value.attribute
--         if key and QActorProp._field[key] then
--             local colorStr = self:getRefineValueColorAndMax(key, value.refineValue, additional_attributes)
--             table.insert(returnTBl, colorStr)
--         end
--     end

--     table.sort(returnTBl, function(a, b)
--             return a > b
--         end)
    
--     return returnTBl
-- end

return QMagicHerb
