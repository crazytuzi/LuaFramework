--
-- Author: qinyuanji
-- Date: 2015-04-02 17:14:49
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroRecycle = class("QUIWidgetHeroRecycle", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetHeroFrame = import("..widgets.QUIWidgetHeroFrame")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogHeroOverview = import("..dialogs.QUIDialogHeroOverview")
local QUIDialogHeroRebornCompensation = import("..dialogs.QUIDialogHeroRebornCompensation")
local QUIWidgetShopTap = import("..widgets.QUIWidgetShopTap")
local QRichText = import("...utils.QRichText")

QUIWidgetHeroRecycle.REBORN_NA = "不能分解初始状态的魂师"
QUIWidgetHeroRecycle.HERO_NA = "请先选择一个需要分解的魂师"

QUIWidgetHeroRecycle.ARENA_NA = "魂师在斗魂场防守阵容中，暂不能分解"
QUIWidgetHeroRecycle.GLORY_NA = "魂师在大魂师赛防守阵容中，暂不能分解"
QUIWidgetHeroRecycle.SILVERMINE_NA = "魂师在魂兽森林防守阵容中，暂不能分解"
QUIWidgetHeroRecycle.PLUNDER_NA = "魂师在跨服狩猎防守阵容中，暂不能分解"
QUIWidgetHeroRecycle.SUNWELL_NA = "魂师在海神岛防守中，暂不能分解"
QUIWidgetHeroRecycle.STORMARENA_NA = "魂师在风暴斗魂场防守中，暂不能分解"
QUIWidgetHeroRecycle.MARITIME_NA = "魂师在海商防守中，暂不能分解"
QUIWidgetHeroRecycle.MOUNT_NA = "魂师拥有暗器，暂不能分解"

QUIWidgetHeroRecycle.TITLE = "魂师分解后将返还以下资源，是否确认分解该魂师"
QUIWidgetHeroRecycle.ELITE_TITLE = "(该魂师为稀有魂师）"
QUIWidgetHeroRecycle.NOTENOUNG_NA = "当前魂师数量太少，不支持分解"

local tipOffsetX = 135

function QUIWidgetHeroRecycle:ctor(options)
	local ccbFile = "ccb/Widget_HeroRecover_client3.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, QUIWidgetHeroRecycle.onTriggerSelect)},
		{ccbCallbackName = "onTriggerPreview", callback = handler(self, QUIWidgetHeroRecycle.onTriggerPreview)},
		{ccbCallbackName = "onTriggerRecycle", callback = handler(self, QUIWidgetHeroRecycle.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIWidgetHeroRecycle.onTriggerClose)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetHeroRecycle.onTriggerRule)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, QUIWidgetHeroRecycle.onTriggerExchange)},
	}

	QUIWidgetHeroRecycle.super.ctor(self,ccbFile,callBacks,options)
	-- app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()

    -- self._recycleMoney = QUIWidgetShopTap.new({money = remote.user.soulMoney, type = "soulMoney"})
    -- self._recycleMoney:setScale(0.7)
    -- self._ccbOwner.tap:addChild(self._recycleMoney)

	self._heroId = nil 
	self:update(self._heroId)
    self:initExplainTTF()
end

--创建底部说明文字
function QUIWidgetHeroRecycle:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "50%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "灵魂石，100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还养成道具、金魂币、材料，",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "融合技和宿命保留",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetHeroRecycle:onEnter()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogHeroOverview.SELECT_CLICK, self.onHeroSelected, self)
end

function QUIWidgetHeroRecycle:onExit()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogHeroOverview.SELECT_CLICK, self.onHeroSelected, self)
end

function QUIWidgetHeroRecycle:update(heroId)
	self._ccbOwner.node_heroinformation:removeAllChildren()
    self._ccbOwner.starNode:removeAllChildren()
	if heroId then
		local hero = remote.herosUtil:getHeroByID(heroId)
		if hero then
		    local avatar = QUIWidgetHeroInformation.new({isSmall = true})
            avatar:setBackgroundVisible(false)
			avatar:setAvatar(hero.actorId, 1.2)
            avatar:changeStarNodeParent(self._ccbOwner.starNode)
            avatar:setStarPositionOffset(-70, -220)
            avatar:setNamePositionOffset(0, -27)
            avatar:setSabcVisible(false)
		    self._ccbOwner.node_heroinformation:addChild(avatar:getView())
			self._ccbOwner.level:setString("LV."..hero.level)

            local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(hero.actorId))
            local profession = heroInfo.func or "dps"
            avatar:setProfession(profession)
            avatar:setProfessionPositionOffset(-293, 8)
            
		else
			heroId = nil
		end
	end

	self._ccbOwner.heroUnselected:setVisible(not heroId)
	self._ccbOwner.heroSelected:setVisible(not (not heroId))
    self._ccbOwner.heroUnselected_foreground:setVisible(not heroId)
    self._ccbOwner.heroSelected_foreground:setVisible(not (not heroId))
    -- self._recycleMoney:setMoney(remote.user.soulMoney)
end

function QUIWidgetHeroRecycle:compensations(heroId)
    self._compensations = {}
    self._tempCompensations = {}
    self._tempSpecialCompensations = {}
    self._totalMoney = 0
 
	if not heroId then
		return 
	end

	local hero = remote.herosUtil:getHeroByID(heroId)
    -- QPrintTable(hero)
	if not hero then 
		return 
	end
    self:compensationForHeroStatus(hero.level, hero.exp)
    self:compensationForHeroBreakthrough(hero.actorId, hero.breakthrough)
    self:compensationForHeroFragment(hero.actorId, hero.grade)
    self:compensationForRefine( hero.actorId )
 
    if hero.slots then
        for k, v in pairs(hero.slots) do
            self:compensationForSkill(hero.actorId, v.slotId, v.slotLevel)
        end
    end
       
    if hero.equipments then
        for k, v in pairs(hero.equipments) do
            self:compensationForOneEquipment(hero.actorId, v.itemId)
        end
    end

    if hero.glyphs then
        -- self:compensationForGlyphSkill(hero)
    end

    if hero.artifact then
        self:compensationForArtifact(hero)
    end
end

function QUIWidgetHeroRecycle:compensationForHeroStatus(heroLevel, heroExp)
    local expIdAdv = 6
    local expIdLow = 3
    local materialAdvancedExp = QStaticDatabase:sharedDatabase():getItemByID(expIdAdv).exp
    local materialLowExp = QStaticDatabase:sharedDatabase():getItemByID(expIdLow).exp
    local exp = QStaticDatabase:sharedDatabase():getTotalExperienceByLevel(heroLevel) + heroExp
    local expAdvancedNum = math.modf(exp/materialAdvancedExp)
    local expLowNum = math.modf(math.fmod(exp, materialAdvancedExp)/materialLowExp)

    if self._tempCompensations[expIdAdv] then
        self._tempCompensations[expIdAdv] = self._tempCompensations[expIdAdv] + expAdvancedNum
    elseif expAdvancedNum > 0 then
        self._tempCompensations[expIdAdv] = expAdvancedNum
    end
    if self._tempCompensations[expIdLow] then
        self._tempCompensations[expIdLow] = self._tempCompensations[expIdLow] + expLowNum
    elseif expLowNum > 0 then
        self._tempCompensations[expIdLow] = expLowNum
    end

    print("hero exp is " .. exp .. " compensation " .. expAdvancedNum .. " " .. expLowNum)
end

function QUIWidgetHeroRecycle:compensationForHeroBreakthrough(heroId, level)
    local talentId = QStaticDatabase:sharedDatabase():getBreakthroughByActorId(heroId)
 
    for _, v in ipairs(talentId) do
        if v.breakthrough_level <= level then
            self._totalMoney = self._totalMoney + v.money
        end
    end
end

function QUIWidgetHeroRecycle:compensationForHeroFragment(heroId, gradeLevel)
    local grade = QStaticDatabase:sharedDatabase():getGradeByHeroId(heroId)
    local minGrade = QStaticDatabase:sharedDatabase():getCharacterByID(heroId).grade

    local fragment = 0
    local fragmentId = 0
    for k, v in pairs(grade) do
        if v.grade_level <= gradeLevel then
            if v.grade_level > minGrade then
                self._totalMoney = self._totalMoney + (v.money or 0)
            end
            fragment = fragment + v.soul_return_count
            fragmentId = v.soul_gem
        end
    end

    if fragment > 0 then
        local soul = fragment * QStaticDatabase:sharedDatabase():getItemByID(fragmentId).soul_recycle
        self._tempCompensations["soulMoney"] = soul

        print("Souls are " .. soul .. " fragment " .. fragment)
    end
end

function QUIWidgetHeroRecycle:compensationForTrainingEnhance(actorId, callback)
    app:getClient():heroTrainingCompensationRequest(actorId, function (data)
        if data.heroGetInfoResponse then
            local trainMoney, enhanceCost, glyphCost, soulCost, tokenCost, moneyCost = 0, 0, 0, 0, 0, 0
            for k, v in ipairs(data.heroGetInfoResponse.heroInfo) do
                trainMoney = trainMoney + v.trainMoneyConsume --QStaticDatabase:sharedDatabase():getTrainingCost("1").train_money
                enhanceCost = enhanceCost + v.enhanceTotalCost
                glyphCost = glyphCost + v.glyphStoneConsume
                soulCost = soulCost + v.soulMoneyConsume
                tokenCost = tokenCost + (v.trainConsumeToken or 0)
                moneyCost = moneyCost + (v.trainConsumeMoney or 0)
            end

            local trainMoneyId = "trainMoney"
            if trainMoney > 0 then
                self._tempCompensations[trainMoneyId] = trainMoney
            end
            self._totalMoney = self._totalMoney + enhanceCost + moneyCost

            if self._totalMoney > 0 then
                self._tempCompensations["money"] = self._totalMoney
            end
            
            local tokenId = "token"
            if tokenCost > 0 then
                self._tempCompensations[tokenId] = (self._tempCompensations[tokenId] or 0) + tokenCost
            end
            print("Total money is " .. self._totalMoney)  

            local glyphId = "glyphMoney"
            if glyphCost > 0 then
                self._tempCompensations[glyphId] = (self._tempCompensations[glyphId] or 0) + glyphCost
            end

            local soulId = "soulMoney"
            if soulCost > 0 then
                self._tempCompensations[soulId] = (self._tempCompensations[soulId] or 0) + soulCost
            end

            callback()
        end
    end)
end

function QUIWidgetHeroRecycle:compensationForSkill(actorId, slotId, slotLevel)
    local skillId = QStaticDatabase.sharedDatabase():getSkillByActorAndSlot(actorId, slotId)
    local skillGroup = QStaticDatabase:sharedDatabase():getSkillGroupBySkillId(skillId)
    --local glyphId = "glyphs"
    local totalGlyphsMoney = 0

    for _, v in ipairs(skillGroup) do
        if v.level > slotLevel then
            break
        end
        if v.item_cost then
            totalGlyphsMoney = totalGlyphsMoney + v.item_cost
        end
    end

    self._totalMoney = self._totalMoney + totalGlyphsMoney

    print("compensation glyphs are " .. totalGlyphsMoney)
end

function QUIWidgetHeroRecycle:compensationForOneEquipment(heroId, equipmentId)
    local itemConfig = remote.herosUtil:getWearByItem(heroId, equipmentId)

    if not itemConfig then
        assert(false, "No item config for " .. equipmentId)
        return
    end

    local enchantMaterials = {}
    local evolveMaterials = {}
    -- Get the compensation for evolvment
    if itemConfig.itemId then
        local evolveTotalMoney = 0
        local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(equipmentId)
        local prevItemId = nil
        while itemCraftConfig and itemCraftConfig.item_before_id do 
            prevItemId = itemCraftConfig.item_before_id
            evolveTotalMoney = evolveTotalMoney + itemCraftConfig.price 
            for i = 1, itemCraftConfig.component_num_1 or 0 do
                table.insert(evolveMaterials, itemCraftConfig.component_id_1)
            end
            for i = 1, itemCraftConfig.component_num_2 or 0 do
                table.insert(evolveMaterials, itemCraftConfig.component_id_2)
            end
            for i = 1, itemCraftConfig.component_num_3 or 0 do
                table.insert(evolveMaterials, itemCraftConfig.component_id_3)
            end

            if itemCraftConfig.money_type then
                self._tempCompensations[itemCraftConfig.money_type] = (self._tempCompensations[itemCraftConfig.money_type] or 0) + (itemCraftConfig.money_num or 0)
            end

            itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(itemCraftConfig.item_before_id)
        end
        -- QPrintTable(self._tempCompensations)
        table.insert(evolveMaterials, prevItemId)
        self._totalMoney = self._totalMoney + evolveTotalMoney
    end

    -- Get the compensation for enhance
    -- Normal equipment has only money to return, jewelry has material to return
    local equipmentType = remote.herosUtil:getUIHeroByID(heroId):getEquipmentPosition(equipmentId)
    if equipmentType ~= EQUIPMENT_TYPE.JEWELRY1 and equipmentType ~= EQUIPMENT_TYPE.JEWELRY2 then
        if itemConfig.level then
            -- local enhanceLevel = itemConfig.level
            -- local enhanceTotalMoney = QStaticDatabase:sharedDatabase():getStrengthenReturnMoney(enhanceLevel)
            -- self._totalMoney = self._totalMoney + enhanceTotalMoney
        end
    else
        local returnMaterial = equipmentType == EQUIPMENT_TYPE.JEWELRY1 and {33, 31} or {38, 36} -- It is hardcoded to return material
        local expIndex = equipmentType == EQUIPMENT_TYPE.JEWELRY1 and 1 or 2 -- JEWELRY1 <> enhance_exp1, JEWELRY2 <> enhance_exp2
        if itemConfig.level then
            local exp = (itemConfig.enhance_exp or 0) + QStaticDatabase:sharedDatabase():getJewelryStrengthenTotalExpByLevel(itemConfig.level, 1, "enhance_exp")
            local advancedMaterialExp = QStaticDatabase:sharedDatabase():getItemByID(returnMaterial[1])["enhance_exp" .. expIndex]
            local cheapMaterialExp = QStaticDatabase:sharedDatabase():getItemByID(returnMaterial[2])["enhance_exp" .. expIndex]

            local advancedMaterial, rest = math.modf(exp/advancedMaterialExp)
            local cheapMaterial = math.modf(rest * advancedMaterialExp / cheapMaterialExp)

            if advancedMaterial > 0 then
                self._tempCompensations[returnMaterial[1]] = 
                    (self._tempCompensations[returnMaterial[1]] or 0) + advancedMaterial
            end
            if cheapMaterial > 0 then
                self._tempCompensations[returnMaterial[2]] = 
                    (self._tempCompensations[returnMaterial[2]] or 0) + cheapMaterial
            end
        end
    end
    
    -- Get the compensation for enchant
    if itemConfig.enchants then
        local enchantLevel = itemConfig.enchants or 0
        local enchantTotalMoney = 0
        for i = 1, enchantLevel do
            local enchantConfig = QStaticDatabase:sharedDatabase():getEnchant(equipmentId, i, heroId)
            enchantTotalMoney = enchantTotalMoney + (enchantConfig.money or 0)
            for j = 1, 3 do 
                if enchantConfig["enchant_item"..j] then
                    self._tempCompensations[enchantConfig["enchant_item"..j]] = 
                        (self._tempCompensations[enchantConfig["enchant_item"..j]] or 0) + enchantConfig["enchant_num"..j]
                end
            end
        end
        self._totalMoney = self._totalMoney + enchantTotalMoney
    end

    -- Merge duplicate items
    for _, v in ipairs(evolveMaterials or {}) do
        self._tempCompensations[v] = (self._tempCompensations[v] or 0) + 1
    end
end

function QUIWidgetHeroRecycle:compensationForArtifact(hero)
    local grade = hero.artifact.artifactBreakthrough
    local characher = db:getCharacterByID(hero.actorId)
    local artifactId = characher.artifact_id
    local configs = db:getArtifactGradeConfigById(artifactId) or {}
    for _,config in ipairs(configs) do
        if config.breakthrough <= grade then
            local consumeItems = string.split(config.consume_item_str, ",")
            for _,consumItem in ipairs(consumeItems) do
                local strs = string.split(consumItem, ";")
                local id = nil
                local itemType = remote.items:getItemType(strs[1])
                local count = tonumber(strs[2])
                if itemType == nil then
                    id = tonumber(strs[1])
                    self._tempSpecialCompensations[id] = (self._tempSpecialCompensations[id] or 0) + count
                else
                    self._tempCompensations[itemType] = (self._tempCompensations[itemType] or 0) + count
                end
            end
        end
    end

    local level = hero.artifact.artifactLevel
    local exp = hero.artifact.artifactExp or 0
    local totalExp = db:getArtifactTotalExpByLevel(characher.aptitude, level) + exp

    local material = remote.artifact:getArtifactLevelMaterials()
    local exp1 = db:getItemByID(material[3]).exp_num
    local exp2 = db:getItemByID(material[2]).exp_num
    local exp3 = db:getItemByID(material[1]).exp_num

    local materialNum1 = math.modf(totalExp/exp1)
    totalExp = totalExp - materialNum1*exp1
    local materialNum2 = math.modf(totalExp/exp2)
    totalExp = totalExp - materialNum2*exp2
    local materialNum3 = math.modf(totalExp/exp3)

    if self._tempSpecialCompensations[material[3]] then
        self._tempSpecialCompensations[material[3]] = self._tempSpecialCompensations[material[3]] + materialNum1
    elseif materialNum1 > 0 then
        self._tempSpecialCompensations[material[3]] = materialNum1
    end
    if self._tempSpecialCompensations[material[2]] then
        self._tempSpecialCompensations[material[2]] = self._tempSpecialCompensations[material[2]] + materialNum2
    elseif materialNum2 > 0 then
        self._tempSpecialCompensations[material[2]] = materialNum2
    end
    if self._tempSpecialCompensations[material[1]] then
        self._tempSpecialCompensations[material[1]] = self._tempSpecialCompensations[material[1]] + materialNum3
    elseif materialNum3 > 0 then
        self._tempSpecialCompensations[material[1]] = materialNum3
    end
end

function QUIWidgetHeroRecycle:compensationForGlyphSkill( heroInfo )
    if heroInfo and heroInfo.glyphStoneConsume then
        if heroInfo.glyphStoneConsume > 0 then
            self._tempCompensations["glyphStone"] = heroInfo.glyphStoneConsume
        end
    end
    print("compensation glyphStone are " .. heroInfo.glyphStoneConsume)
end

function QUIWidgetHeroRecycle:compensationForRefine( actorId )
    local heroInfo = remote.herosUtil:getHeroByID(actorId)
    if not heroInfo.refineHeroInfo then
        local refineHeroInfo = remote.herosUtil:getHeroRefineInfoByID(actorId)
        if refineHeroInfo then
            heroInfo.refineHeroInfo = {}
            heroInfo.refineHeroInfo = { openGrid = refineHeroInfo.openGrid, refineAttrsPre = refineHeroInfo.refineAttrsPre, refineMoneyConsume = refineHeroInfo.refineMoneyConsume }
        end
    end
    local refineMoney = 0
    -- QPrintTable(heroInfo.refineHeroInfo)
    if heroInfo and heroInfo.refineHeroInfo then
        if heroInfo.refineHeroInfo.openGrid then
            local count = heroInfo.refineHeroInfo.openGrid
            local price = 0
            for i = 1, count, 1 do
                price = price + QStaticDatabase.sharedDatabase():getConfigurationValue( "gezi_kaiqi"..i ) 
            end
            if price ~= 0 then
                self._tempCompensations[5000003] = price
            end
        end
        refineMoney = heroInfo.refineHeroInfo.refineMoneyConsume or 0
        self._tempCompensations["refineMoney"] = math.floor(refineMoney * 0.3)
    end

    print("compensation refineMoney are " .. math.floor(refineMoney / 2))
end


function QUIWidgetHeroRecycle:sortCompensations(compensations)
    if compensations["money"] then
        table.insert(self._compensations, {id = "money", value = compensations["money"]})
        compensations["money"] = nil
    end
    if compensations["glyphs"] then
        table.insert(self._compensations, {id = "glyphs", value = compensations["glyphs"]})
        compensations["glyphs"] = nil
    end
    if compensations["trainMoney"] then
        table.insert(self._compensations, {id = "trainMoney", value = compensations["trainMoney"]})
        compensations["trainMoney"] = nil
    end
    if compensations["arena_money"] then
        table.insert(self._compensations, {id = "arena_money", value = compensations["arena_money"]})
        compensations["arena_money"] = nil
    end
    if compensations["thunder_money"] then
        table.insert(self._compensations, {id = "thunder_money", value = compensations["thunder_money"]})
        compensations["thunder_money"] = nil
    end
    if compensations["glyphStone"] then
        table.insert(self._compensations, {id = 600001, value = compensations["glyphStone"]})
        compensations["glyphStone"] = nil
    end
    if compensations["glyphMoney"] then
        table.insert(self._compensations, {id = "glyphMoney", value = compensations["glyphMoney"]})
        compensations["glyphMoney"] = nil
    end
    if compensations["soulMoney"] then
        table.insert(self._compensations, {id = "soulMoney", value = compensations["soulMoney"]})
        compensations["soulMoney"] = nil
    end
    if compensations["token"] then
        table.insert(self._compensations, {id = "token", value = compensations["token"]})
        compensations["token"] = nil
    end
    if compensations["refineMoney"] then
        if compensations["refineMoney"] ~= 0 then
            table.insert(self._compensations, {id = "refine_money", value = compensations["refineMoney"]})
        end
        compensations["refineMoney"] = nil
    end

    -- 特殊道具提前
    local tempSpecialCompensations = {}
    for k, v in pairs(self._tempSpecialCompensations) do
        table.insert(tempSpecialCompensations, {id = k, value = v})
    end
    table.sort(tempSpecialCompensations, function(x, y)
            return x.id < y.id
        end)
    for k, v in ipairs(tempSpecialCompensations) do
        table.insert(self._compensations, v)
    end

    -- 普通道具
    local tempCompensations = {}
    for k, v in pairs(compensations) do
        table.insert(tempCompensations, {id = k, value = v})
    end
    table.sort(tempCompensations, function(x, y)
            return x.id < y.id
        end)
    for _, v in ipairs(tempCompensations) do
        table.insert(self._compensations, v)
    end
end

function QUIWidgetHeroRecycle:heroIsAvailable(heroId)
    -- Check if hero is less than slots
    local slotCount = remote.herosUtil:getUnlockTeamNum()
    local existingHeros = remote.herosUtil:getHaveHero()
    if #existingHeros <= slotCount then
        app.tip:floatTip(QUIWidgetHeroRecycle.NOTENOUNG_NA, tipOffsetX) 
        return false, true
    end

    local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.ARENA_DEFEND_TEAM)
    if teamVO:contains(heroId) then
        return false
    end

    teamVO = remote.teamManager:getTeamByKey(remote.teamManager.GLORY_DEFEND_TEAM)
    if teamVO:contains(heroId) then
        return false
    end

    teamVO = remote.teamManager:getTeamByKey(remote.teamManager.STORM_ARENA_DEFEND_TEAM)
    if teamVO:contains(heroId) then
        return false
    end

    teamVO = remote.teamManager:getTeamByKey(remote.teamManager.MARITIME_DEFEND_TEAM)
    if teamVO:contains(heroId) then
        return false
    end

    local battleFormation = remote.silverMine:getDefenseArmy()
    if battleFormation then
        for _, actorId in ipairs(battleFormation.mainHeroIds or {}) do
            if actorId == heroId then
                -- app.tip:floatTip(QUIWidgetHeroRecycle.SILVERMINE_NA, tipOffsetX)
                return false
            end
        end
        for _, actorId in ipairs(battleFormation.sub1HeroIds or {}) do
            if actorId == heroId then
                -- app.tip:floatTip(QUIWidgetHeroRecycle.SILVERMINE_NA, tipOffsetX)
                return false
            end
        end
        for _, actorId in ipairs(battleFormation.sub2HeroIds or {}) do
            if actorId == heroId then
                -- app.tip:floatTip(QUIWidgetHeroRecycle.SILVERMINE_NA, tipOffsetX)
                return false
            end
        end
    end

    local battleFormation = remote.plunder:getDefenseArmy()
    if battleFormation then
        for _, actorId in ipairs(battleFormation.mainHeroIds or {}) do
            if actorId == heroId then
                -- app.tip:floatTip(QUIWidgetHeroRecycle.PLUNDER_NA, tipOffsetX)
                return false
            end
        end
        for _, actorId in ipairs(battleFormation.sub1HeroIds or {}) do
            if actorId == heroId then
                -- app.tip:floatTip(QUIWidgetHeroRecycle.PLUNDER_NA, tipOffsetX)
                return false
            end
        end
        for _, actorId in ipairs(battleFormation.sub2HeroIds or {}) do
            if actorId == heroId then
                -- app.tip:floatTip(QUIWidgetHeroRecycle.PLUNDER_NA, tipOffsetX)
                return false
            end
        end
    end
    
    return true
end

-- Callbacks
function QUIWidgetHeroRecycle:onTriggerSelect()
	if self._playing then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview", options = {heroRecycle = true}}, {isPopCurrentDialog = false})
end

function QUIWidgetHeroRecycle:onHeroSelected(event)
	if self._playing then return end
    -- app.sound:playSound("common_small")
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroReborn()
    if event.actorId == nil then return end
    local existingHeroes = remote.herosUtil:getHaveHero()
    if table.find(existingHeroes, event.actorId) then
        self._heroId = event.actorId
        self:update(self._heroId)
    else
        print("Find no hero", event.actorId)
    end
end

function QUIWidgetHeroRecycle:onTriggerPreview()
	if self._playing then return end
    app.sound:playSound("common_small")

    self:compensations(self._heroId)	
    self:compensationForTrainingEnhance(self._heroId, function ( ... )
        self:sortCompensations(self._tempCompensations)

    	if next(self._compensations) == nil then
    		app.tip:floatTip(QUIWidgetHeroRecycle.REBORN_NA, tipOffsetX)
    		return 
    	end

    	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
    		options = {heroId = self._heroId, compensations = self._compensations, preview = true, title = "分解预览"}})
    end)
end

function QUIWidgetHeroRecycle:onTriggerRecycle(event)
	if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_recyle) == false then return end
    app.sound:playSound("common_small")

	if not self._heroId then
		app.tip:floatTip(QUIWidgetHeroRecycle.HERO_NA, tipOffsetX) 
		return
	end

    local slotCount = remote.herosUtil:getUnlockTeamNum()
    local existingHeros = remote.herosUtil:getHaveHero()
    if #existingHeros <= slotCount then
        app.tip:floatTip(QUIWidgetHeroRecycle.NOTENOUNG_NA, tipOffsetX) 
        return false
    end

    self:compensations(self._heroId)	

    local function callRecycleAPI()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        self:onTriggerRecycleFinished()
    end

    self:compensationForTrainingEnhance(self._heroId, function ( ... )
        self:sortCompensations(self._tempCompensations)
        
        if next(self._compensations) == nil then
            app.tip:floatTip(QUIWidgetHeroReborn.REBORN_NA, tipOffsetX)
            return 
        end

    	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
    		options = {heroId = self._heroId, compensations = self._compensations, 
                        callFunc = callRecycleAPI, title = self:getTitle(self._heroId), tips = "提示：分解后，该魂师将彻底消失"}})
    end)
end

function QUIWidgetHeroRecycle:getTitle(heroId)
    -- local elite = QStaticDatabase:sharedDatabase():getCharacterByID(heroId).golden_dragon == 1 金龙取消啦~~~
    local elite = false
    local title = QUIWidgetHeroRecycle.TITLE
    if elite then
        title = title .. QUIWidgetHeroRecycle.ELITE_TITLE
    end

    return title
end

function QUIWidgetHeroRecycle:onTriggerRecycleFinished()
    app:getClient():heroRecycle(self._heroId, function(response)
        remote.headProp:updateAvatarInfos()
        self._playing = true
        local effect = QUIWidgetAnimationPlayer.new()
        self._ccbOwner.effect:addChild(effect)
    	effect:playAnimation("effects/HeroRecoverEffect_up2.ccbi", function()
			self._ccbOwner.node_heroinformation:setVisible(false)
		    local avatar = QUIWidgetHeroInformation.new({isSmall = true})
            avatar:setBackgroundVisible(false)
			avatar:setAvatar(self._heroId, 1.2)
            avatar:setStarVisible(false)
            avatar:changeStarNodeParent(self._ccbOwner.starNode)
            avatar:setStarPositionOffset(-70, 60)
			effect._ccbOwner.node_avatar:addChild(avatar:getView())

            avatar:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY)
		end, 
        function()
	    	effect:removeFromParentAndCleanup(true)
			self._ccbOwner.node_heroinformation:setVisible(true)
		    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
		        options = {compensations = self._compensations, type = 2, subtitle = "魂师分解返还以下资源"}}, {isPopCurrentDialog = false})
            self._heroId = nil
		    self:update(self._heroId)
		    self._playing = false
	    end)
    end,function ()
        self._heroId = nil
        self:update(self._heroId)
    end)
end

function QUIWidgetHeroRecycle:onTriggerClose()
    if self._playing then return end
 
    self._heroId = nil 
    self:update(self._heroId)
end

function QUIWidgetHeroRecycle:onTriggerRule()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 2}}, {isPopCurrentDialog = false})
end

function QUIWidgetHeroRecycle:onTriggerExchange()
    app.sound:playSound("common_small")
    if app.unlock:checkLock("UNLOCK_SOUL_SHOP", true) then
        remote.stores:openShopDialog(SHOP_ID.soulShop)
    end
end


return QUIWidgetHeroRecycle
