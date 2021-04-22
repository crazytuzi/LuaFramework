-- 武魂真身数据类
-- Author: zxs
-- Date: 2018-11-10
--

local QBaseModel = import("...models.QBaseModel")
local QArtifact = class("QArtifact", QBaseModel)
local QActorProp = import("...models.QActorProp")

QArtifact.STATE_LOCK = "STATE_LOCK"
QArtifact.STATE_CAN_WEAR = "STATE_CAN_WEAR"
QArtifact.STATE_NO_WEAR = "STATE_NO_WEAR"
QArtifact.STATE_CAN_BREAK = "STATE_CAN_BREAK"
QArtifact.STATE_NO = "STATE_NO"
QArtifact.EVENT_WEAR = "EVENT_WEAR"

function QArtifact:ctor(options)
	QArtifact.super.ctor(self)

    self._skillConfigs = {}
    self.artifactWearShow = true               --本次登录是否提示真身合成
    self.artifactGradeShow = true              --本次登录是否显示真身升星
end

function QArtifact:didappear()
	QArtifact.super.didappear(self)
end

function QArtifact:disappear()
	QArtifact.super.disappear(self)
end

function QArtifact:loginEnd()
end

function QArtifact:getArtiactByActorId(actorId)
    local characher = db:getCharacterByID(actorId) or {}
    return characher.artifact_id
end

function QArtifact:getActorIdByArtifactId(artifactId)
    local charachers = db:getCharacter()
    for _, characher in pairs(charachers) do
        if characher.artifact_id == artifactId then
            return characher.id
        end
    end
    return nil
end

function QArtifact:getGradeByArtifactLevel(id, level)
    local levelConfig = db:getGradeByArtifactLevel(id, level)
    if not levelConfig then
        return
    end

    local itemTbl = string.split(levelConfig.consume_item_str, ",")
    for i, item in pairs(itemTbl) do
        local tbl = string.split(item, ";")
        if tbl[1] == "money" or tbl[1] == ITEM_TYPE.SUPER_STONE then
            levelConfig[tbl[1]] = tonumber(tbl[2])
        else
            levelConfig.soul_gem = tonumber(tbl[1])
            levelConfig.soul_gem_count = tonumber(tbl[2])
        end
    end
    return levelConfig
end

--获取拥有神器的ID组合--不管有没有激活
function QArtifact:getHerosAndPos(selectId)
    local herosID = remote.herosUtil:getHaveHero()
    local heros = {}
    local selectPos = 1
    for _, actorId in ipairs(herosID) do
        if self:getArtiactByActorId(actorId) then
            table.insert(heros, actorId)
            if actorId == selectId then
                selectPos = #heros
            end
        end
    end
    return heros, selectPos
end

--计算武魂真身属性
function QArtifact:getArtifactPropById(actorId)
    local artifactProp = {}
    local artifactInfo = remote.herosUtil:getHeroByID(actorId).artifact
    local character = db:getCharacterByID(actorId)
    local artifactId = character.artifact_id
    if not artifactId or not artifactInfo then
        return artifactProp
    end

    local analysisFun = function (propTbl, info)
        for name,filed in pairs(QActorProp._field) do
            if info[name] ~= nil then
                propTbl[name] = info[name] + (propTbl[name] or 0)
            end
        end
    end

    -- 武魂本身属性
    local itemConfig = db:getItemByID(artifactId)
    analysisFun(artifactProp, itemConfig)

    -- 强化属性
    local levelConfig = db:getArtifactLevelConfigBylevel(character.aptitude, artifactInfo.artifactLevel) or {}
    analysisFun(artifactProp, levelConfig)

    -- 突破属性
    local gradeConfig = db:getGradeByArtifactLevel(artifactId, artifactInfo.artifactBreakthrough) or {}
    analysisFun(artifactProp, gradeConfig)

    --技能属性
    local skillsProp = {}
    local artifactSkillList = artifactInfo.artifactSkillList or {}
    for _, artifactSkill in pairs(artifactSkillList) do
        local skillData = db:getSkillDataByIdAndLevel(artifactSkill.skillId, artifactSkill.skillLevel) or {}
        local count = 1
        while true do
            local key = skillData["addition_type_"..count]
            local value = skillData["addition_value_"..count]
            if key == nil then
                break
            end
            if skillsProp[key] == nil then
                skillsProp[key] = value
            else
                skillsProp[key] = skillsProp[key] + value
            end
            count = count + 1
        end
    end
    analysisFun(artifactProp, skillsProp)

    return artifactProp
end

--获取技能配置
function QArtifact:getSkillByArtifactId(artifactId)
    if artifactId == nil then return nil end
    if self._skillConfigs[artifactId] == nil then
        local skill = {}
        local skillConfig = db:getArtifactSkillConfigById(artifactId) or {}
        for _, config in ipairs(skillConfig) do
            skill[config.skill_order] = config
        end
        self._skillConfigs[artifactId] = skill
    end
    return self._skillConfigs[artifactId]
end

--获取技能信息通过魂师ID和魂师技能
function QArtifact:getSkillByHeroSkillId(actorId, skillId)
    local skills = {}
    if app.unlock:checkLock("UNLOCK_ARTIFACT", false) == false then
        return skills
    end
    local artifactId = self:getArtiactByActorId(actorId)
    if artifactId == nil then
        return skills
    end
    local skillConfig = self:getSkillByArtifactId(artifactId)
    for _, skill in pairs(skillConfig) do
        local config = db:getSkillByID(skill.skill_id)
        if config.enhance_display_skill_id == skillId then
            table.insert(skills, skill)
        end
    end
    return skills
end

-- 获取突破颜色
function QArtifact:getArtifactColor(gradeLevel)
    local grade, index = self:getBreakThroughLevel(gradeLevel)
    local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[index]] or COLORS.b
    return fontColor
end

--获取颜色根据ID
function QArtifact:getColorByActorId(actorId)
    local characher = db:getCharacterByID(actorId)
    local sabcInfo = db:getSABCByQuality(characher.aptitude)
    local fontColor = QIDEA_QUALITY_COLOR[string.upper(sabcInfo.color)]
    return fontColor
end

-- 获取突破颜色等级
function QArtifact:getBreakThroughLevel(gradeLevel)
    if not gradeLevel then gradeLevel = 0 end
    local breakLevel = {1,2,3,4,5,6} --whilte,green,blue,purple,orange,red,yellow
    local perNum = 0
    for index, value in pairs(breakLevel) do
        if gradeLevel <= value then
            local offsetLevel = gradeLevel-perNum
            if offsetLevel < 0 then offsetLevel = 0 end
            return offsetLevel, index
        end
        perNum = value
    end
    return 0, 1
end

-- 强化材料，写死
function QArtifact:getArtifactLevelMaterials()
    return {14000002, 14000003, 14000004}
end

-- 界面展示方式
function QArtifact:getUIPropInfo(props, isTotal)
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
    if isTotal then
        if props.armor_physical or props.armor_physical then
            prop[index] = {}
            prop[index].value = props.armor_physical or props.armor_physical
            prop[index].name = "物      防："
            index = index + 1
        end
        if props.armor_magic or props.armor_magic then
            prop[index] = {}
            prop[index].value = props.armor_magic or props.armor_magic
            prop[index].name = "法      防："
            index = index + 1
        end
    else
        if props.armor_physical or props.armor_physical then
            prop[index] = {}
            prop[index].value = props.armor_physical or props.armor_physical
            prop[index].name = "物防、法防："
            index = index + 1
        end
    end

    return prop
end

-- 背包不需要红点
function QArtifact:checkBackPackTips()
    return false
end

-- 更新英雄处理
function QArtifact:artifactResponseHandler(heroInfo)
    if not heroInfo then
        return
    end
    remote.herosUtil:updateHeros({heroInfo}, true)
    remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
end

--[[
    升级到指定的强化等级
    statusCode: 1 到最大等级 2 物品不足
]]
function QArtifact:strengthToLevel(actorId, level)
    local character = db:getCharacterByID(actorId)
    local aptitude = character.aptitude
    local artifactInfo = remote.herosUtil:getHeroByID(actorId).artifact
    local levelConfigs = db:getArtifactLevelConfigBylevel(aptitude)
    local maxLevel = math.min(remote.user.level * 2, #levelConfigs)
    local targetLevel = math.min(level + artifactInfo.artifactLevel, maxLevel)
    if targetLevel == artifactInfo.artifactLevel then --已经到最大等级
        return {statusCode = 1}
    end
    local needExp = -artifactInfo.artifactExp
    for i=artifactInfo.artifactLevel,(targetLevel-1) do
        local strengthConfig = db:getArtifactLevelConfigBylevel(aptitude, i)
        if strengthConfig ~= nil then
            needExp = needExp + (strengthConfig.artifact_exp or 0)
        end
    end
    if needExp <= 0 then
        return {statusCode = 1}
    end

    local materials = self:getArtifactLevelMaterials()
    local eatItems = {}
    local dropItemId = nil
    local eatTotalExp = 0
    for i = 1, 3, 1 do
        local itemId = tonumber(materials[i])
        if itemId ~= nil then
            dropItemId = itemId
            local itemConfig = db:getItemByID(itemId)
            local haveCount = remote.items:getItemsNumByID(itemId)
            local needEatCount = math.ceil(needExp/itemConfig.exp_num)
            local eatCount = math.min(haveCount, needEatCount)
            if eatCount > 0 then
                table.insert(eatItems, {id = itemId, typeName = ITEM_TYPE.ITEM, count = eatCount})
                local eatExp = eatCount * itemConfig.exp_num
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
    eatTotalExp = eatTotalExp + artifactInfo.artifactExp
    for i = artifactInfo.artifactLevel, targetLevel do
        local strengthConfig = db:getArtifactLevelConfigBylevel(aptitude, i)
        if strengthConfig ~= nil then
            if eatTotalExp >= (strengthConfig.artifact_exp or 0) then
                addLevel = addLevel + 1
                eatTotalExp = eatTotalExp - (strengthConfig.artifact_exp or 0)
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


-- 获取一键升星能升到的最高等级
function QArtifact:getAutoAddGradeInfo(artifactId, currentGrade)
    local addGrade = 0
    local needMoney = 0
    local needItems = {}
    local tempSoulCount = 0
    local tempSuperCount = 0
    local tempNeedMoeny = 0

    while true do
        local gradeConfig = self:getGradeByArtifactLevel(artifactId, currentGrade + addGrade + 1)
        if not gradeConfig then
            break
        end

        -- 阶段1材料判断
        needItems[gradeConfig.soul_gem] = needItems[gradeConfig.soul_gem] or 0
        tempSoulCount = needItems[gradeConfig.soul_gem] + gradeConfig.soul_gem_count
        local soulCount = remote.items:getItemsNumByID(gradeConfig.soul_gem)
        if soulCount < tempSoulCount then
            break
        end

        -- 阶段2材料判断
        if gradeConfig[ITEM_TYPE.SUPER_STONE] then
            needItems[ITEM_TYPE.SUPER_STONE] = needItems[ITEM_TYPE.SUPER_STONE] or 0
            tempSuperCount = needItems[ITEM_TYPE.SUPER_STONE] + gradeConfig[ITEM_TYPE.SUPER_STONE]
            local superCount = remote.items:getItemsNumByID(tonumber(ITEM_TYPE.SUPER_STONE))
            if superCount < tempSuperCount then
                break
            end
        end

        -- 金币判断
        tempNeedMoeny = needMoney + gradeConfig.money
        if remote.user.money < tempNeedMoeny then
            break
        end


        needItems[gradeConfig.soul_gem] = tempSoulCount
        needItems[ITEM_TYPE.SUPER_STONE] = tempSuperCount
        needMoney = tempNeedMoeny
        addGrade = addGrade + 1
    end

    return { addGrade = addGrade, needMoney = needMoney, needItems = needItems}
end

--------------------------proto part-------------------------------
--请求武魂真身合成
function QArtifact:artifactCombineRequest(actorId, isOneKeyTop, success, fail)
    local artifactCombineRequest = {actorId = actorId, isOneKeyTop = isOneKeyTop}
    local request = {api = "ARTIFACT_COMBINE", artifactCombineRequest = artifactCombineRequest}
    app:getClient():requestPackageHandler("ARTIFACT_COMBINE", request, function (response)
        local heroInfo = response.artifactCombineResponse.heroInfo
        self:artifactResponseHandler(heroInfo)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求武魂真身突破升星
function QArtifact:artifactGradeRequest(actorId, isOneKeyTop, success, fail)
	local artifactBreakthroughRequest = {actorId = actorId, isOneKeyTop = isOneKeyTop}
    local request = {api = "ARTIFACT_BREAKTHROUGH", artifactBreakthroughRequest = artifactBreakthroughRequest}
    app:getClient():requestPackageHandler("ARTIFACT_BREAKTHROUGH", request, function (response)
        local heroInfo = response.artifactBreakthroughResponse.heroInfo
        self:artifactResponseHandler(heroInfo)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求武魂真身强化
function QArtifact:artifactEnchantRequest(actorId, materialItemIds, success, fail)
    local artifactEnchantRequest = {actorId = actorId, materialItemIds = materialItemIds}
    local request = {api = "ARTIFACT_ENCHANT", artifactEnchantRequest = artifactEnchantRequest}
    app:getClient():requestPackageHandler("ARTIFACT_ENCHANT", request, function (response)
        local heroInfo = response.artifactEnchantResponse.heroInfo
        self:artifactResponseHandler(heroInfo)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求武魂真身技能
function QArtifact:artifactImproveSkillRequest(actorId, skillId, success, fail)
	local artifactImproveSkillRequest = {actorId = actorId, skillId = skillId}
    local request = {api = "ARTIFACT_IMPROVE_SKILL", artifactImproveSkillRequest = artifactImproveSkillRequest}
    app:getClient():requestPackageHandler("ARTIFACT_IMPROVE_SKILL", request, function (response)
        local heroInfo = response.artifactImproveSkillResponse.heroInfo
        self:artifactResponseHandler(heroInfo)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--技能重置
function QArtifact:artifactSkillResetRequest(actorId, success, fail)
    local artifactSkillResetRequest = {actorId = actorId}
    local request = {api = "ARTIFACT_SKILL_RESET", artifactSkillResetRequest = artifactSkillResetRequest}
    app:getClient():requestPackageHandler("ARTIFACT_SKILL_RESET", request, function (response)
        local heroInfo = response.artifactSkillResetResponse.heroInfo
        self:artifactResponseHandler(heroInfo)
        self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--武魂真身剥离
function QArtifact:artifactRecoverRequest(actorId, success, fail)
    local artifactRecoverRequest = {actorId = actorId}
    local request = {api = "ARTIFACT_RECOVER", artifactRecoverRequest = artifactRecoverRequest}
    app:getClient():requestPackageHandler("ARTIFACT_RECOVER", request, function (response)
        local heroInfo = response.artifactRecoverResponse.heroInfo
        self:artifactResponseHandler(heroInfo)
        self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


--武魂真身精华分解
function QArtifact:artifactPieceRecoverRequest(consumeItems, success, fail)
    local artifactPieceRecoverRequest = {consumeItems = consumeItems}
    local request = {api = "ARTIFACT_PIECE_RECOVER", artifactPieceRecoverRequest = artifactPieceRecoverRequest}
    app:getClient():requestPackageHandler("ARTIFACT_PIECE_RECOVER", request, function (response)
        self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QArtifact:canAutoAddAndGrade(id)
    local isUnlock = app.unlock:checkLock("UNLOCK_ARTIFACT_QUICK_UPGRADE")
    if not isUnlock then return false end
    
    local gradeConfig1 = self:getGradeByArtifactLevel(id, 1)
    local gradeConfig2 = self:getGradeByArtifactLevel(id, 2)
    local superCount = 0
    local count = 0
    local money = 0
    if gradeConfig1 and gradeConfig2 then
        count = (gradeConfig1.soul_gem_count or 0) + (gradeConfig2.soul_gem_count or 0)
        money = (gradeConfig1.money or 0) + (gradeConfig2.money or 0)
        superCount = (gradeConfig1[ITEM_TYPE.SUPER_STONE] or 0) + (gradeConfig2[ITEM_TYPE.SUPER_STONE] or 0)

        local isSuperFull = true
        if superCount > 0 then
            local superCount = remote.items:getItemsNumByID(tonumber(ITEM_TYPE.SUPER_STONE))
            if superCount < superCount then
                isSuperFull = false
            end
        end
        local soulCount = remote.items:getItemsNumByID(gradeConfig1.soul_gem or gradeConfig2.soul_gem)
        if soulCount >= count and isSuperFull and remote.user.money >= money then
            return true
        end
    end

    return false
end

return QArtifact
