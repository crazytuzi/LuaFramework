--
-- 暗器数据类
-- zxs
--

local QBaseModel = import("...models.QBaseModel")
local QMount = class("QMount", QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QMountProp = import("...models.QMountProp")

QMount.EVENT_UNWEAR = "EVENT_UNWEAR"
QMount.EVENT_WEAR = "EVENT_WEAR"
QMount.EVENT_WEAR_MOUNT = "EVENT_WEAR_MOUNT"
QMount.EVENT_UNWEAR_MOUNT = "EVENT_UNWEAR_MOUNT"
QMount.EVENT_UPDATE = "QMOUNT_EVENT_UPDATE"
QMount.EVENT_REFRESH_FORCE = "EVENT_REFRESH_FORCE"
QMount.EVENT_MOUNT_GRADE_UPDATE = "EVENT_MOUNT_GRADE_UPDATE"

QMount.STATE_NO_WEAR = "STATE_NO_WEAR"
QMount.STATE_CAN_WEAR = "STATE_CAN_WEAR"
QMount.STATE_WEAR = "STATE_WEAR"
QMount.STATE_LOCK = "STATE_LOCK"

--SS+暗器全局属性更新
QMount.EVENT_SSRMOUNT_EXTRAPROP_UPDATE = "EVENT_SSRMOUNT_EXTRAPROP_UPDATE"
QMount.EVENT_SSRMOUNT_EXTRAPROP_UPDATE_HERO = "EVENT_SSRMOUNT_EXTRAPROP_UPDATE_HERO"

function QMount:ctor(options)
	QMount.super.ctor(self)

    self._mountList = {}    -- 已合成的
    self._mountMap = {}     -- 暗器map
    self._allMount = {}     -- 所有暗器
    self._mountProp = {}    -- 暗器属性

    self.mountHeroShow = true               --本次登录是否提示暗器选英雄
    self.heroMountShow = true               --本次登录是否显示英雄选暗器
    self.mountMountShow = true              --本次登录是否显示暗器选暗器
end

function QMount:didappear()
	QMount.super.didappear(self)
    if app.unlock:getUnlockMount() then
        self:init()
    end
end

function QMount:disappear()
	QMount.super.disappear(self)
end

function QMount:loginEnd()
    if app.unlock:getUnlockMount() then
        self:mountListRequest()
    end
end

--获取所有暗器id
function QMount:init()
    self._allMount = {}
    local characterConfig = db:getCharacter() or {}
    for _,value in pairs(characterConfig) do
        if value.npc_type == NPC_TYPE.MOUNT then
            local gradeInfo = db:getGradeByHeroActorLevel(value.id, 0)
            if gradeInfo then
                table.insert(self._allMount, value.id)
            end
        end
    end
end

function QMount:getGraveItemConfig( )
    local items = {"4200001","4200002"}
    local itemConfig = {}
    for _,v in pairs(items) do
        local cofig = db:getItemByID(v)
        if q.isEmpty(cofig) == false then
            table.insert(itemConfig,cofig)
        end
    end

    return itemConfig
end

function QMount:getGraveInfoByAptitudeLv(aptitude,level)
    if aptitude == nil or level == nil then
        return nil
    end
    local graveConfig = db:getStaticByName("zuoqi_diaoke") or {}
    for _,value in pairs(graveConfig[tostring(aptitude)] or {}) do
        if value.quality == aptitude and value.grave_level == level then
            return value
        end
    end
    return nil
end

--根据暗器雕刻等级获取雕刻大师
function QMount:getGraveTalantMasterInfo(aptitude, level)
    if aptitude == nil or level == nil then
        return nil,0
    end    
    local graveTalantConfig = db:getStaticByName("zuoqi_diaoke_tianfu")
    local infos = graveTalantConfig[tostring(aptitude)] or {}
    local maxLevel = 0
    local masterInfos = {}

    for _, value in pairs(infos) do
        if (value.condition or 0) <= level and maxLevel < (value.level or 0) then
            maxLevel = value.level
            table.insert(masterInfos, value)
        end
    end
    return masterInfos, maxLevel
end

--根据雕刻大师等级获取雕刻大师信息
function QMount:getGraveTalantMasterInfoByLevel(aptitude, masterLevel)
    local graveTalantConfig = db:getStaticByName("zuoqi_diaoke_tianfu")
    local infos = graveTalantConfig[tostring(aptitude)] or {}    
    if masterLevel == nil then
        return nil
    end
    for _, value in pairs(infos) do
        if value.level == masterLevel then
            return value
        end
    end
    return nil
end

function QMount:getMountGraveMaster( mountId )
    local talents = {}
    if not mountId then return talents end
    local mountConfig = db:getCharacterByID(mountId)
    if q.isEmpty(mountConfig) then return talents end
    local graveTalantConfig = db:getStaticByName("zuoqi_diaoke_tianfu")
    local infos = graveTalantConfig[tostring(mountConfig.aptitude)] or {} 
    for i,v in ipairs(infos) do
        if v.level > 0 then
            table.insert(talents,v)
        end
    end
    return talents
end

function QMount:getMountStrengthMaster( mountId )
    local talents = {}
    if not mountId then return talents end
    local mountConfig = db:getCharacterByID(mountId)
    local dbTalents = db:getMountMasterInfo(mountConfig.aptitude) or {}
    for i,v in ipairs(dbTalents) do
        if v.level > 0 then
            table.insert(talents,v)
        end
    end
    return talents
end
--获取所有暗器列表
function QMount:getAllMounts()
    if next(self._allMount) == nil then
        self:init()
    end
    return self._allMount
end

--获取暗器列表
function QMount:getMountList()
    return self._mountList
end

--根据ID获取暗器信息
function QMount:getMountById(mountId)
    return self._mountMap[mountId]
end

--获取所有已经获得的暗器信息
function QMount:getMountMap()
    return self._mountMap
end

--创建暗器的属性对象
function QMount:countMountProp(mountInfo, isForce)
    if mountInfo == nil then return nil end

    local mount = nil
    if not isForce and self._mountProp[mountInfo.zuoqiId] then
        mount = self._mountProp[mountInfo.zuoqiId]
    else
        mount = QMountProp.new(mountInfo)
        self._mountProp[mountInfo.zuoqiId] = mount
    end
    return mount
end

function QMount:getMountPropById(zuoqiId)
    return self._mountProp[zuoqiId] or {}
end

--获取没有魂师和不是配件的暗器
function QMount:getMountByNoWearAndNoDress()
    local tbl = {}
    for _,mount in ipairs(self._mountList) do
        local characher = db:getCharacterByID(mount.zuoqiId)
        if (mount.actorId or 0) == 0 and (mount.superZuoqiId or 0) == 0 and not characher.zuoqi_pj then
            table.insert(tbl, mount)
        end
    end
    return tbl
end

--获取暗器类型
function QMount:getTypeDesc(func, attackType)
    if func == "t" then
        return "坦克暗器"
    elseif func == "health" then
        return "辅助暗器"
    elseif func == "dps" then
        if attackType == 1 then
            return "物攻暗器"
        elseif attackType == 2 then
            return "法攻暗器"
        end
    end
    return ""
end

--获取颜色根据暗器ID
function QMount:getColorByMountId(mountId)
    local characher = db:getCharacterByID(mountId)
    local sabcInfo = db:getSABCByQuality(characher.aptitude)
    return string.upper(sabcInfo.color)
end

--获取暗器
function QMount:getIsSuperMount(mountId)
    local characher = db:getCharacterByID(mountId)
    return characher.aptitude >= APTITUDE.SS
end

function QMount:getIsSSRMount(mountId)
    local characher = db:getCharacterByID(mountId)
    return characher.aptitude == APTITUDE.SSR
end

--获取s暗器
function QMount:getSuperMountIds()
    local tbl = {}
    for i, mountId in pairs(self._allMount) do
        local characher = db:getCharacterByID(mountId)
        if characher.aptitude >= APTITUDE.S and not db:checkHeroShields(mountId) then
            table.insert(tbl, mountId)
        end
    end
    return tbl
end

function QMount:getPropInfo(props, coefficient)
    if props == nil then return {} end
    coefficient = coefficient or 1

    local prop = {}
    local index = 1
    for _, v in ipairs(QActorProp._uiFields) do
        if props[v.fieldName] > 0 then
            local value = props[v.fieldName]
            prop[index] = {}
            prop[index].value = math.floor(value*coefficient)
            prop[index].name = v.name
            index = index + 1
        end
    end

    return prop
end

function QMount:getUIPropInfo(props)
    if props == nil then return {} end
    local prop = {}
    local index = 1
    if props.attack_percent or props.hp_percent then
        prop[index] = {}
        prop[index].value = ((props.attack_percent or props.hp_percent)*100).."%"
        prop[index].name = "生命、攻击："
        index = index + 1
    end
    if props.armor_physical_percent or props.armor_magic_percent then
        prop[index] = {}
        prop[index].value = ((props.armor_physical_percent or props.armor_magic_percent)*100).."%"
        prop[index].name = "物防、法防："
        index = index + 1
    end
    if props.attack_value then
        prop[index] = {}
        prop[index].value = props.attack_value
        prop[index].name = "攻      击："
        index = index + 1
    end
    if props.hp_value then
        prop[index] = {}
        prop[index].value = props.hp_value
        prop[index].name = "生      命："
        index = index + 1
    end
    if props.armor_physical or props.armor_physical then
        prop[index] = {}
        prop[index].value = props.armor_physical or props.armor_physical
        prop[index].name = "物防、法防："
        index = index + 1
    end

    if props.team_attack_percent or props.team_hp_percent then
        prop[index] = {}
        prop[index].value = ((props.team_attack_percent or props.team_hp_percent)*100).."%"
        prop[index].name = "全队生命、攻击："
        index = index + 1
    end
    if props.team_armor_physical_percent or props.team_armor_magic_percent then
        prop[index] = {}
        prop[index].value = ((props.team_armor_physical_percent or props.team_armor_magic_percent)*100).."%"
        prop[index].name = "全队物防、法防："
        index = index + 1
    end
    if props.team_attack_value then
        prop[index] = {}
        prop[index].value = props.team_attack_value
        prop[index].name = "全队攻      击："
        index = index + 1
    end
    if props.team_hp_value then
        prop[index] = {}
        prop[index].value = props.team_hp_value
        prop[index].name = "全队生      命："
        index = index + 1
    end
    if props.team_armor_physical or props.team_armor_physical then
        prop[index] = {}
        prop[index].value = props.team_armor_physical or props.team_armor_physical
        prop[index].name = "全队物防、法防："
        index = index + 1
    end

    return prop
end

function QMount:getUISinglePropInfo(props)
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
    if props.armor_physical_percent then
        prop[index] = {}
        prop[index].value = (props.armor_physical_percent*100).."%"
        prop[index].name = "物    防："
        index = index + 1
    end
    if props.armor_magic_percent then
        prop[index] = {}
        prop[index].value = (props.armor_magic_percent*100).."%"
        prop[index].name = "法    防："
        index = index + 1
    end

    if props.attack_value then
        prop[index] = {}
        prop[index].value = math.floor(props.attack_value)
        prop[index].name = "攻    击："
        index = index + 1
    end
    if props.hp_value then
        prop[index] = {}
        prop[index].value = math.floor(props.hp_value)
        prop[index].name = "生    命："
        index = index + 1
    end
    if props.armor_physical then
        prop[index] = {}
        prop[index].value = math.floor(props.armor_physical)
        prop[index].name = "物    防："
        index = index + 1
    end
    if props.armor_magic then
        prop[index] = {}
        prop[index].value = math.floor(props.armor_magic)
        prop[index].name = "法    防："
        index = index + 1
    end

    if props.team_attack_percent then
        prop[index] = {}
        prop[index].value = (props.team_attack_percent*100).."%"
        prop[index].name = "全队攻击："
        index = index + 1
    end
    if props.team_hp_percent then
        prop[index] = {}
        prop[index].value = (props.team_hp_percent*100).."%"
        prop[index].name = "全队生命："
        index = index + 1
    end
    if props.team_armor_physical_percent then
        prop[index] = {}
        prop[index].value = (props.team_armor_physical_percent*100).."%"
        prop[index].name = "全队物防："
        index = index + 1
    end
    if props.team_armor_magic_percent then
        prop[index] = {}
        prop[index].value = (props.team_armor_magic_percent*100).."%"
        prop[index].name = "全队法防："
        index = index + 1
    end

    if props.team_attack_value then
        prop[index] = {}
        prop[index].value = math.floor(props.team_attack_value)
        prop[index].name = "全队攻击："
        index = index + 1
    end
    if props.team_hp_value then
        prop[index] = {}
        prop[index].value = math.floor(props.team_hp_value)
        prop[index].name = "全队生命："
        index = index + 1
    end
    if props.team_armor_physical then
        prop[index] = {}
        prop[index].value = math.floor(props.team_armor_physical)
        prop[index].name = "全队物防："
        index = index + 1
    end
    if props.team_armor_magic then
        prop[index] = {}
        prop[index].value = math.floor(props.team_armor_magic)
        prop[index].name = "全队法防："
        index = index + 1
    end

    return prop
end

--更新暗器列表
function QMount:setMountList(mounts)
    for _, mount in ipairs(mounts or {}) do
        if self._mountMap[mount.zuoqiId] == nil then
            table.insert(self._mountList, mount)
        else
            for index, v in ipairs(self._mountList) do
                if v.zuoqiId == mount.zuoqiId then
                    -- v = mount
                    self._mountList[index] = mount
                    break
                end
            end
        end
        self._mountMap[mount.zuoqiId] = mount

        -- 暗器不算战斗力了
        self:countMountProp(self._mountMap[mount.zuoqiId], true)

        local mountConfig = db:getCharacterByID(mount.zuoqiId)
        mount.aptitude = mountConfig.aptitude
    end
    self:dispatchEvent({name = QMount.EVENT_UPDATE})
    self:_checkChangeSSRMount()
end

--删除暗器
function QMount:removeMountList(mountIds)
    for _, mountId in ipairs(mountIds or {}) do
        if self._mountMap[mountId] ~= nil then
            self._mountMap[mountId] = nil
            for index,mount in ipairs(self._mountList) do
                if mount.zuoqiId == mountId then
                    table.remove(self._mountList, index)
                    break
                end
            end
        end
    end
end

function QMount:getSSRMountList( )
    local mountList = {}
    for _,mount in pairs(self._mountList) do
        if mount.aptitude == APTITUDE.SSR then
            table.insert(mountList,mount)
        end
    end

    return mountList
end

function QMount:_checkChangeSSRMount()
    local mountSSRList = self:getSSRMountList()
    local extraProp = app.extraProp:getSelfExtraProp() or {}
    local bRefrehs = not q.isEmpty(mountSSRList)  or (q.isEmpty(mountSSRList) and not q.isEmpty(extraProp) 
        and extraProp[app.extraProp.MOUNT_SSP_PROP] and not q.isEmpty(extraProp[app.extraProp.MOUNT_SSP_PROP]))

    if bRefrehs  then
        self:dispatchEvent({name = QMount.EVENT_SSRMOUNT_EXTRAPROP_UPDATE , mountList = mountSSRList})
        self:dispatchEvent({name = QMount.EVENT_SSRMOUNT_EXTRAPROP_UPDATE_HERO })       
    end
end

-- 检查暗器背包小红点
function QMount:checkBackPackTips()
    if app.unlock:getUnlockMount() == false then
        return false
    end

    if self:checkPieceRedTip() then 
        return true
    end

    if self:checkMaterialRedTip() then 
        return true
    end

    if self:checkUpgradeRedTip() then 
        return true
    end

    if self:checkReformRedTip() then 
        return true
    end

    if self:checkSoulGuideRedTip() then 
        return true
    end

    if self:checkHaveCanGrave() then
        return true
    end

    return false
end

function QMount:checkSoulGuideRedTip()
    local soulGuideLevel = remote.user:getPropForKey("soulGuideLevel") or 0
    local newConfig = db:getSoulGuideConfigByLevel(soulGuideLevel+1)
    if newConfig ~= nil then
        local gradeConfig = db:getSoulGuideConfigByLevel(1)
        local soulCount = remote.items:getItemsNumByID(gradeConfig.item_id)
        return soulCount >= newConfig.num
    end
    return false
end

function QMount:checkReformRedTip()
    for _, mount in pairs(self._mountList) do
        if mount.actorId ~= 0 then
            local UIHeroModel = remote.herosUtil:getUIHeroByID(mount.actorId)
            if UIHeroModel and UIHeroModel:getMountReformTip() then
                return true
            end
        end
    end
    return false
end

function QMount:checkHaveCanGrave( )
    for _, mount in pairs(self._mountList) do
        if self:checkCanGrave(mount.zuoqiId) then
            return true
        end
    end

    return false
end

function QMount:checkUpgradeRedTip()
    for _, mount in pairs(self._mountList) do
        if mount.actorId ~= 0 then
            local UIHeroModel = remote.herosUtil:getUIHeroByID(mount.actorId)
            if UIHeroModel and UIHeroModel:getMountGradeTip() then
                return true
            end
        else
            if self:checkMountCanGrade(mount) then
                return true
            end
        end
    end
    return false
end

function QMount:checkPieceRedTip()
    local pieceInfo = db:getItemsByProp("type", ITEM_CONFIG_TYPE.ZUOQI)
    for i = 1, #pieceInfo do
        local mountId = db:getActorIdBySoulId(pieceInfo[i].id, 0) or 0
        local info = db:getGradeByHeroActorLevel(mountId, 0)
        local haveCount = remote.items:getItemsNumByID(pieceInfo[i].id)
        if info and haveCount >= (info.soul_gem_count or 0) and self:getMountById(mountId) == nil then
            return true
        end
    end
    return false
end

function QMount:checkMaterialRedTip()
    if remote.items:checkItemRedTipsByCategory(ITEM_CONFIG_CATEGORY.MOUNT_MATERIAL) then
        return true
    end
    return false
end

--检查暗器图鉴是否激活
function QMount:checkMountCombination(combination)
    local mounts = string.split(combination.condition, ";")
    if mounts == nil and next(mounts) == nil then 
        return false
    end
    local isTwice = combination.condition_num or 2
    if isTwice == 2 then
        if self:checkMountHavePast(tonumber(mounts[1])) and mounts[2] and self:checkMountHavePast(tonumber(mounts[2])) then
            return true
        end
    else
        if self:checkMountHavePast(tonumber(mounts[1])) then
            return true
        end
    end
    return false
end

function QMount:checkNoEquipMountS()
    for _, mount in pairs(self._mountList) do
        if mount.aptitude == APTITUDE.S and mount.actorId == 0 and (mount.superZuoqiId or 0) == 0 then
            return true
        end
    end
    return false
end

--检查暗器是否可以雕刻
function QMount:checkCanGrave(mountId)
    if not mountId then return false end
    local costItemInfo = self:getGraveItemConfig()
    local mountConfig = db:getCharacterByID(mountId)
    local mountInfo = self:getMountById(mountId)
    if q.isEmpty(mountConfig) == false and q.isEmpty(mountInfo) == false and mountConfig.aptitude == APTITUDE.SSR then
        local nextLevelConfig = remote.mount:getGraveInfoByAptitudeLv(mountConfig.aptitude, (mountInfo.grave_level or 0) + 1)
        local allexp,curExp = self:getCostItemExp(mountId)
        for _,costItem in pairs(costItemInfo) do
            local itemCount = remote.items:getItemsNumByID(costItem.id)
            curExp = curExp + (costItem.exp_num or 0)*itemCount
        end

        if nextLevelConfig and nextLevelConfig.grave_exp and curExp >= nextLevelConfig.grave_exp then
            return true
        end
    end

    return false
end

-- xurui
-- 检查暗器是否曾经获得
function QMount:checkMountHavePast(mountId, isUpdate)
    local teams = remote.user.collectedZuoqis or {}
    local isHave = false
    for i = 1, #teams do
        if teams[i] == mountId then
            isHave = true
            break
        end
    end
    if isHave == false and isUpdate then
        teams[#teams+1] = mountId
        remote.user:update({collectedZuoqis = teams})

        --历史暗器发生变化时刷新魂师战力
        self:refreshCombinationProp()
    end
    return isHave
end

function QMount:refreshCombinationProp( ... )
    remote.herosUtil:validate()
    remote.herosUtil:updateHeros(remote.herosUtil.heros)
    remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})

    remote.herosUtil:updataMountCombinationProp()
end

-- 检查暗器是否被装备
function QMount:checkMountHaveActor(mountId)
    if self._mountMap[mountId] == nil then return false end

    local actorId = self._mountMap[mountId].actorId
    local isWear = actorId ~= 0
    return isWear, actorId
end

--xurui: 检查暗器背包里面是否有物品
function QMount:checkMountBackPackItemNum()
    -- 检查暗器碎片和暗器消耗品
    local items = db:getItemsByCategory(ITEM_CONFIG_CATEGORY.MOUNT_PIECE, ITEM_CONFIG_CATEGORY.MOUNT_MATERIAL)
    for _, value in pairs(items) do
        if remote.items:getItemsNumByID(value.id) > 0 then
            return true
        end
    end
    --检查暗器
    local mountInfo = self:getMountList()
    if next(mountInfo) ~= nil then
        return true
    end

    return false
end

function QMount:checkMountCanGrade(mountInfo)
    if mountInfo == nil then return false end

    local mountConfig = db:getGradeByHeroActorLevel(mountInfo.zuoqiId, mountInfo.grade+1)
    if mountConfig ~= nil then
        local wearZuoqiSoulCount = remote.items:getItemsNumByID(mountConfig.soul_gem)
        if wearZuoqiSoulCount >= mountConfig.soul_gem_count then
            return true
        end
    end
    return false
end


--获取已经拥有暗器的ID组合
function QMount:getHeros(selectId)
    local herosID = remote.herosUtil:getHaveHero()
    local heros = {}
    local selectPos = 1
    for _,actorId in ipairs(herosID) do
        local heroInfo = remote.herosUtil:getHeroByID(actorId)
        if heroInfo.zuoqi ~= nil then
            table.insert(heros, actorId)
            if actorId == selectId then
                selectPos = #heros
            end
        end
    end
    return heros,selectPos
end

--[[
    升级到指定的强化等级
    statusCode: 1 到最大等级 2 物品不足
]]
function QMount:strengthToLevel(mountId, level)
    local mountInfo = self:getMountById(mountId)
    local maxLevel = math.min(remote.user.level * 2 , db:getConfiguration().MOUNT_MAX_LEVEL.value)
    local targetLevel = math.min(level + mountInfo.enhanceLevel, maxLevel)
    if targetLevel == mountInfo.enhanceLevel then --已经到最大等级
        return {statusCode = 1}
    end
    local needExp = -mountInfo.enhanceExp
    local db = QStaticDatabase:sharedDatabase()
    local mountConfig = db:getCharacterByID(mountInfo.zuoqiId)
    local aptitude = mountConfig.aptitude
    for i=mountInfo.enhanceLevel,(targetLevel-1) do
        local strengthConfig = db:getMountStrengthenBylevel(aptitude, i)
        if strengthConfig ~= nil then
            needExp = needExp + (strengthConfig.strengthen_zuoqi or 0)
        end
    end
    if needExp <= 0 then
        return {statusCode = 1}
    end

    local materialConfig = db:getMountMaterialById(mountId)
    local materials = string.split(materialConfig.shengji_daoju, "^")
    local eatItems = {}
    local dropItemId = nil
    local eatTotalExp = 0
    for i = 1, 3, 1 do
        local itemId = tonumber(materials[i])
        if itemId ~= nil then
            dropItemId = itemId
            local itemConfig = db:getItemByID(itemId)
            local haveCount = remote.items:getItemsNumByID(itemId)
            local needEatCount = math.ceil(needExp/itemConfig.zuoqi_exp)
            local eatCount = math.min(haveCount, needEatCount)
            if eatCount > 0 then
                table.insert(eatItems, {id = itemId, typeName = ITEM_TYPE.ITEM, count = eatCount})
                local eatExp = eatCount * itemConfig.zuoqi_exp
                eatTotalExp = eatTotalExp + eatExp
            end
            if needExp <= eatTotalExp then
                break
            end
        end
    end
    if q.isEmpty(eatItems) then
        return {statusCode = 2, dropItemId = dropItemId}
    end
    local addLevel = 0
    eatTotalExp = eatTotalExp + mountInfo.enhanceExp
    for i=mountInfo.enhanceLevel,targetLevel do
        local strengthConfig = db:getMountStrengthenBylevel(aptitude, i)
        if strengthConfig ~= nil then
            if eatTotalExp >= (strengthConfig.strengthen_zuoqi or 0) then
                addLevel = addLevel + 1
                eatTotalExp = eatTotalExp - (strengthConfig.strengthen_zuoqi or 0)
            else
                break
            end
        else
            break
        end
    end
    if addLevel == 0 then
        return {statusCode = 2, dropItemId = dropItemId}
    end
    return {eatItems = eatItems, addLevel = addLevel}
end

function QMount:getCostItemExp(mountId)
    local mountInfo = self:getMountById(mountId)
    local mountConfig = db:getCharacterByID(mountId)

    if mountInfo.grave_consume == nil or mountInfo.grave_consume == "" then 
        return 0,0
    end
    local graveLevel = mountInfo.grave_level or 0
    local allexp = 0
    local curLevExp = 0
    local tblCusume = string.split(mountInfo.grave_consume,";")
    for k,v in pairs(tblCusume or {}) do
        local tbl = string.split(v,"^")
        local itemId = tbl[1]
        local itemCount = tonumber(tbl[2] or 0)
        local itemConfig = db:getItemByID(itemId)
        if q.isEmpty(itemConfig) == false then
            allexp = allexp + (itemConfig.exp_num or 0) * itemCount
        end
    end
    for ii = 1,graveLevel do
        local graveConfig = self:getGraveInfoByAptitudeLv(mountConfig.aptitude, ii)
        if q.isEmpty(graveConfig) == false then
            curLevExp = curLevExp + graveConfig.grave_exp
        end
    end

    return allexp,allexp-curLevExp
end

function QMount:checkMountIsSS(mountId)
    local mountConfig = db:getCharacterByID(mountId)
    if mountConfig and mountConfig.aptitude >= APTITUDE.SS then
        return true
    end

    return false
end


-------------------------------------------协议请求-----------------------------------------------

function QMount:responseHandler(data, success, fail, succeeded)
    if data.zuoqis ~= nil then
        self:setMountList(data.zuoqis)
    end
    if data.zuoqiUpdateResponse ~= nil then
        if data.zuoqiUpdateResponse.deleteZuoqiId then
            self:removeMountList({data.zuoqiUpdateResponse.deleteZuoqiId})
        end
        if data.zuoqiUpdateResponse.modifyZuoqis then
            self:setMountList(data.zuoqiUpdateResponse.modifyZuoqis)
        end
        if data.zuoqiUpdateResponse.modifyHeros then
            remote.herosUtil:updateHeros(data.zuoqiUpdateResponse.modifyHeros)
        end
        remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
    end
    if data.api ~= "ZUOQI_GRADE" or data.api ~= "ZUOQI_COMBINE" then
        self:dispatchEvent({name = QMount.EVENT_MOUNT_GRADE_UPDATE})
    end

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

--请求暗器列表
function QMount:mountListRequest(success, fail)
    local request = {api = "ZUOQI_GET_ALL"}
    app:getClient():requestPackageHandler("ZUOQI_GET_ALL", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求装备暗器
function QMount:mountWareRequest(zuoqiId, actorId, success, fail)
    local zuoqiWareRequest = {zuoqiId = zuoqiId, actorId = actorId}
    local request = {api = "ZUOQI_WARE", zuoqiWareRequest = zuoqiWareRequest}
    app:getClient():requestPackageHandler("ZUOQI_WARE", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求卸下暗器
function QMount:mountTakeOffRequest(actorId, success, fail)
    local zuoqiTakeOffRequest = {actorId = actorId}
    local request = {api = "ZUOQI_TAKE_OFF", zuoqiTakeOffRequest = zuoqiTakeOffRequest}
    app:getClient():requestPackageHandler("ZUOQI_TAKE_OFF", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求装备暗器
function QMount:superMountWearRequest(chooseZuoqiId, wearZuoqiId, isWear, success, fail)
    local superZuoqiWearRequest = {chooseZuoqiId = chooseZuoqiId, wearZuoqiId = wearZuoqiId, isWear = isWear}
    local request = {api = "SUPER_ZUOQI_WEAR", superZuoqiWearRequest = superZuoqiWearRequest}
    app:getClient():requestPackageHandler("SUPER_ZUOQI_WEAR", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求暗器强化
function QMount:mountEnhanceRequest(zuoqiId, consumeItems, success, fail)
    local zuoqiEnhanceRequest = {zuoqiId = zuoqiId, consumeItems = consumeItems}
    local request = {api = "ZUOQI_ENHANCE", zuoqiEnhanceRequest = zuoqiEnhanceRequest}
    app:getClient():requestPackageHandler("ZUOQI_ENHANCE", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求暗器进阶
function QMount:mountGradeRequest(zuoqiId, success, fail)
    local zuoqiGradeRequest = {zuoqiId = zuoqiId}
    local request = {api = "ZUOQI_GRADE", zuoqiGradeRequest = zuoqiGradeRequest}
    app:getClient():requestPackageHandler("ZUOQI_GRADE", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求暗器进阶
function QMount:mountChangeRequest(zuoqiId, success, fail)
    local zuoqiReformRequest = {zuoqiId = zuoqiId}
    local request = {api = "ZUOQI_REFORM", zuoqiReformRequest = zuoqiReformRequest}
    app:getClient():requestPackageHandler("ZUOQI_REFORM", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求合成暗器
function QMount:mountCombineRequest(zuoqiId, success, fail, succeeded)
    local zuoqiCombineRequest = {zuoqiId = tonumber(zuoqiId)}
    local request = {api = "ZUOQI_COMBINE", zuoqiCombineRequest = zuoqiCombineRequest}
    app:getClient():requestPackageHandler("ZUOQI_COMBINE", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求暗器召唤
function QMount:mountSummonRequest(isFree, isTen, success, fail, succeeded)
    local zuoqiSummonRequest = {isFree = isFree, isTen = isTen}
    local request = {api = "ZUOQI_SUMMON", zuoqiSummonRequest = zuoqiSummonRequest}
    app:getClient():requestPackageHandler("ZUOQI_SUMMON", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--暗器重生--
function QMount:mountReborn(zuoqId, success, fail, status)
    local zuoqiRebornRequest = {zuoqId = zuoqId}
    local request = {api = "ZUOQI_REBORN", zuoqiRebornRequest = zuoqiRebornRequest}
    app:getClient():requestPackageHandler("ZUOQI_REBORN", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--暗器回收--
function QMount:zuoqiRecoverRequest(zuoqId, success, fail, status)
    local zuoqiRecoverRequest = {zuoqId = zuoqId}
    local request = {api = "ZUOQI_RECOVER", zuoqiRecoverRequest = zuoqiRecoverRequest}
    app:getClient():requestPackageHandler("ZUOQI_RECOVER", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--暗器碎片分解
function QMount:zuoqiPieceRecoverRequest(items, success, fail, succeeded)
    local zuoqiPieceRecoverRequest = {consumeItems = items}
    local request = {api = "ZUOQI_PIECE_RECOVER", zuoqiPieceRecoverRequest = zuoqiPieceRecoverRequest}
    app:getClient():requestPackageHandler("ZUOQI_PIECE_RECOVER", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--魂导升级
function QMount:mountSoulGuideLevelUpRequest(success, fail, succeeded)
    local request = {api = "SOUL_GUIDE_LEVEL_UP"}
    app:getClient():requestPackageHandler("SOUL_GUIDE_LEVEL_UP", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


-- optional int32 zuoqiId = 1;                                                 //暗器ID
function QMount:zuoqiReformResetRequest(zuoqiId, success, fail, succeeded)
    local zuoqiReformResetRequest = {zuoqiId = zuoqiId}
    local request = {api = "ZUOQI_REFORM_RECOVER", zuoqiReformResetRequest = zuoqiReformResetRequest}
    app:getClient():requestPackageHandler("ZUOQI_REFORM_RECOVER", request, function (response)
        self:responseHandler(response, success, nil, true)
        remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--暗器雕刻
function QMount:zuoqiGraveRequest(zuoqiId,eatItems,success, fail, succeeded)
    local zuoqiGraveRequest = {zuoqiId = zuoqiId,consumeItems = eatItems}
    local request = {api = "ZUOQI_GRAVE", zuoqiGraveRequest = zuoqiGraveRequest}
    app:getClient():requestPackageHandler("ZUOQI_GRAVE", request, function (response)
        self:responseHandler(response, success, nil, true)
        remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--暗器雕刻摘除
function QMount:zuoqiCancelGraveRequest(zuoqiId, success, fail, succeeded)
    local zuoqiCancelGraveRequest = {zuoqiId = zuoqiId}
    local request = {api = "ZUOQI_CANCEL_GRAVE", zuoqiCancelGraveRequest = zuoqiCancelGraveRequest}
    app:getClient():requestPackageHandler("ZUOQI_CANCEL_GRAVE", request, function (response)
        self:responseHandler(response, success, nil, true)
        remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

return QMount