--
-- Kumo.Wang
-- 回收站，单个回收界面——英雄重生
--
local QUIWidgetRecycleForAlone = import("..widgets.QUIWidgetRecycleForAlone")
local QUIWidgetRecycleForHeroReset = class("QUIWidgetRecycleForHeroReset", QUIWidgetRecycleForAlone)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local QRichText = import("...utils.QRichText")
local QUIDialogHeroOverview = import("..dialogs.QUIDialogHeroOverview")

function QUIWidgetRecycleForHeroReset:ctor(options)
	QUIWidgetRecycleForHeroReset.super.ctor(self, options)
end

function QUIWidgetRecycleForHeroReset:onEnter()
    QUIWidgetRecycleForHeroReset.super.onEnter(self)

    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogHeroOverview.SELECT_CLICK, self.node_level_info, self)
end

function QUIWidgetRecycleForHeroReset:onExit()
    QUIWidgetRecycleForHeroReset.super.onExit(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogHeroOverview.SELECT_CLICK, self._onItemSelected, self)
end

function QUIWidgetRecycleForHeroReset:_onItemSelected(event)
    if self.isPlaying then return end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroReborn()
    if event.actorId == nil then return end

    local existingHeroes = remote.herosUtil:getHaveHero()
    if table.find(existingHeroes, event.actorId) then
        self.id = event.actorId
        self:update()
    else
        print("Find no hero", event.actorId)
    end
end

function QUIWidgetRecycleForHeroReset:init()
    QUIWidgetRecycleForHeroReset.super.init(self)

    -- 初始化剪影
    QSetDisplayFrameByPath(self._ccbOwner.sp_sketch, QResPath("recycleSketch")[1])
    self._ccbOwner.tf_unselect_tips:setString("选择需要重生的魂师")
end

function QUIWidgetRecycleForHeroReset:initExplain()
    QUIWidgetRecycleForHeroReset.super.initExplain(self)

    local richText = QRichText.new({
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "100%"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "返还养成的道具、金魂币、材料，"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "魂师转换成魂师碎片"},
        }, 680, {autoCenter = true})
    richText:setAnchorPoint(ccp(0.5, 0))
    self._ccbOwner.node_tf_explain:addChild(richText)
end

function QUIWidgetRecycleForHeroReset:initMenu()
    QUIWidgetRecycleForHeroReset.super.initMenu(self)

    self._ccbOwner.node_btn_help:setVisible(true)
    self._ccbOwner.node_btn_store:setVisible(true)
end

function QUIWidgetRecycleForHeroReset:updateData()
    if self.id then
        self._ccbOwner.node_unselected:setVisible(false)
        self._ccbOwner.node_selected:setVisible(true)

        local hero = remote.herosUtil:getHeroByID(self.id)
        if hero then
            self._ccbOwner.node_avatar:removeAllChildren()

            if not self.itemClass then
                self.itemClass = import(app.packageRoot .. ".ui.widgets." .. self.itemClassName)
            end

            self.avatar = self.itemClass.new({isSmall = true})
            self.avatar:setBackgroundVisible(false)
            self.avatar:setStarVertical(false)
            self.avatar:setAvatar(self.id, 1.2)
            self.avatar:setNamePositionOffset(0, 0)
            self.avatar:setSabcVisible(false)
            self._ccbOwner.node_avatar:addChild(self.avatar:getView())
            self._ccbOwner.tf_level:setString("LV."..hero.level)
            self._ccbOwner.node_level_info:setVisible(true)

            local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(self.id))
            local profession = heroInfo.func or "dps"
            self.avatar:setProfession(profession)
            self.avatar:setProfessionPositionOffset(-290, 40)

            self.avatar:changeStarNodeParent(self._ccbOwner.node_avatar_star)
            self.avatar:setStarPositionOffset(0, -220)
            self._ccbOwner.node_avatar_star:setVisible(true)
        else
            self.id = nil
            self:updateData()
        end
    else
        self._ccbOwner.node_unselected:setVisible(true)
        self._ccbOwner.node_selected:setVisible(false)
    end
end

function QUIWidgetRecycleForHeroReset:updateRecyclePreviewInfo()
    local info = {}
    self.importantKeysList = {"money", "trainMoney", "glyphs", "arena_money", "thunder_money", "glyphStone", "glyphMoney", "soulMoney", "token", "refineMoney"}

    if not self.id then return info end

    local hero = remote.herosUtil:getHeroByID(self.id)
    if not hero then return info end

    self._compensations = {}
    self._totalMoney = 0
    self._totalSkillPoint = 0

    
    -- 回收等級
    self:_getLevelPreviewInfo(info, hero.level, hero.exp)
    -- 回收強化
    self:_getBreakthroughPreviewInfo(info, hero.breakthrough)
    -- 回收升星金币（这里的升星碎片回收放在后面，因为要照顾ss英雄）
    self:_getGradePreviewInfo(info, hero.grade)
    -- 回收洗練（現在好像沒有這個）
    self:_getRefinePreviewInfo(info)
    -- 回收技能
    self:_getSkillPreviewInfo(info, hero)
    -- 回收裝備
    self:_getEquipmentPreviewInfo(info, hero)
    -- 回收武魂真身
    self:_getArtifactPreviewInfo(info, hero)
    -- 回收魂师（计算碎片，ss神技）
    self:_getFragmentPreviewInfo(info, hero)

    return info
end


function QUIWidgetRecycleForHeroReset:_getLevelPreviewInfo(info, heroLevel, heroExp)
    local expIdAdv = 6
    local expIdLow = 3
    local materialAdvancedExp = db:getItemByID(expIdAdv).exp
    local materialLowExp = db:getItemByID(expIdLow).exp
    local exp = db:getTotalExperienceByLevel(heroLevel) + heroExp
    local expAdvancedNum = math.modf(exp/materialAdvancedExp)
    local expLowNum = math.modf(math.fmod(exp, materialAdvancedExp)/materialLowExp)

    if expAdvancedNum == 0 and expLowNum == 0 and heroLevel > 1 then
        expLowNum = 1
    end

    if info[expIdAdv] then
        info[expIdAdv] = info[expIdAdv] + expAdvancedNum
    elseif expAdvancedNum > 0 then
        info[expIdAdv] = expAdvancedNum
    end
    if info[expIdLow] then
        info[expIdLow] = info[expIdLow] + expLowNum
    elseif expLowNum > 0 then
        info[expIdLow] = expLowNum
    end
end
function QUIWidgetRecycleForHeroReset:_getBreakthroughPreviewInfo(info, breakthrough)
    local talentId = db:getBreakthroughByActorId(self.id)
    for _, v in ipairs(talentId) do
        if v.breakthrough_level <= breakthrough then
            local addValue = v.money or 0
            if info["money"] then
                info["money"] = info["money"] + addValue
            elseif addValue > 0 then
                info["money"] = addValue
            end
        end
    end
end
function QUIWidgetRecycleForHeroReset:_getGradePreviewInfo(info, grade)
    local gradeConfig = db:getGradeByHeroId(self.id)
    local minGrade = db:getCharacterByID(self.id).grade
    for k, v in pairs(gradeConfig) do
        if v.grade_level <= grade then
            if v.grade_level > minGrade then
                local addValue = v.money or 0
                if info["money"] then
                    info["money"] = info["money"] + addValue
                elseif addValue > 0 then
                    info["money"] = addValue
                end
            end
        end
    end
end
function QUIWidgetRecycleForHeroReset:_getRefinePreviewInfo(info)
    local heroInfo = remote.herosUtil:getHeroByID(self.id)
    if not heroInfo.refineHeroInfo then
        local refineHeroInfo = remote.herosUtil:getHeroRefineInfoByID(self.id)
        if refineHeroInfo then
            heroInfo.refineHeroInfo = {}
            heroInfo.refineHeroInfo = { openGrid = refineHeroInfo.openGrid, refineAttrsPre = refineHeroInfo.refineAttrsPre, refineMoneyConsume = refineHeroInfo.refineMoneyConsume }
        end
    end
    local refineMoney = 0
    if heroInfo and heroInfo.refineHeroInfo then
        if heroInfo.refineHeroInfo.openGrid then
            local count = heroInfo.refineHeroInfo.openGrid
            local price = 0
            for i = 1, count, 1 do
                price = price + db:getConfigurationValue( "gezi_kaiqi"..i ) 
            end
            if price ~= 0 then
                info[5000003] = price
            end
        end
        refineMoney = heroInfo.refineHeroInfo.refineMoneyConsume or 0
        info["refineMoney"] = math.floor(refineMoney * 0.3)
    end
end
function QUIWidgetRecycleForHeroReset:_getSkillPreviewInfo(info, hero)
    if not hero.slots then return end

    for k, v in pairs(hero.slots) do
        local skillId = db:getSkillByActorAndSlot(self.id, v.slotId)
        local skillGroup = db:getSkillGroupBySkillId(skillId)
        local totalGlyphsMoney = 0
        for _, skill in ipairs(skillGroup) do
            if skill.level > v.slotLevel then
                break
            end
            local addValue = skill.item_cost or 0
            if info["money"] then
                info["money"] = info["money"] + addValue
            elseif addValue > 0 then
                info["money"] = addValue
            end
        end
    end
end
function QUIWidgetRecycleForHeroReset:_getEquipmentPreviewInfo(info, hero)
    if not hero.equipments then return end

    for k, v in pairs(hero.equipments) do
        local itemConfig = remote.herosUtil:getWearByItem(self.id, v.itemId)
        if not itemConfig then
            assert(false, "No item config for " .. v.itemId)
            return
        end

        local enchantMaterials = {}
        local evolveMaterials = {}
        -- Get the compensation for evolvment
        if itemConfig.itemId then
            local itemCraftConfig = db:getItemCraftByItemId(v.itemId)
            local prevItemId = nil
            while itemCraftConfig and itemCraftConfig.item_before_id do 
                local addValue = itemCraftConfig.price or 0
                if info["money"] then
                    info["money"] = info["money"] + addValue
                elseif addValue > 0 then
                    info["money"] = addValue
                end

                prevItemId = itemCraftConfig.item_before_id
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
                    info[itemCraftConfig.money_type] = (info[itemCraftConfig.money_type] or 0) + (itemCraftConfig.money_num or 0)
                end

                itemCraftConfig = db:getItemCraftByItemId(itemCraftConfig.item_before_id)
            end
            table.insert(evolveMaterials, prevItemId)
        end

        -- Get the compensation for enhance
        -- Normal equipment has only money to return, jewelry has material to return
        local equipmentType = remote.herosUtil:getUIHeroByID(self.id):getEquipmentPosition(v.itemId)
        if equipmentType == EQUIPMENT_TYPE.JEWELRY1 or equipmentType == EQUIPMENT_TYPE.JEWELRY2 then
            local returnMaterial = equipmentType == EQUIPMENT_TYPE.JEWELRY1 and {33, 31} or {38, 36} -- It is hardcoded to return material
            local expIndex = equipmentType == EQUIPMENT_TYPE.JEWELRY1 and 1 or 2 -- JEWELRY1 <> enhance_exp1, JEWELRY2 <> enhance_exp2
            if itemConfig.level then
                local exp = (itemConfig.enhance_exp or 0) + db:getJewelryStrengthenTotalExpByLevel(itemConfig.level, 1, "enhance_exp")
                local advancedMaterialExp = db:getItemByID(returnMaterial[1])["enhance_exp" .. expIndex]
                local cheapMaterialExp = db:getItemByID(returnMaterial[2])["enhance_exp" .. expIndex]

                local advancedMaterial, rest = math.modf(exp/advancedMaterialExp)
                local cheapMaterial = math.modf(rest * advancedMaterialExp / cheapMaterialExp)

                if advancedMaterial > 0 then
                    info[returnMaterial[1]] = (info[returnMaterial[1]] or 0) + advancedMaterial
                end
                if cheapMaterial > 0 then
                    info[returnMaterial[2]] = (info[returnMaterial[2]] or 0) + cheapMaterial
                end
            end
        end

        -- Get the compensation for enchant
        if itemConfig.enchants then
            local enchantLevel = itemConfig.enchants or 0
            local enchantTotalMoney = 0
            for i = 1, enchantLevel do
                local enchantConfig = db:getEnchant(v.itemId, i, self.id)
                if enchantConfig and next(enchantConfig) then
                    local addValue = enchantConfig.money or 0
                    if info["money"] then
                        info["money"] = info["money"] + addValue
                    elseif addValue > 0 then
                        info["money"] = addValue
                    end

                    for j = 1, 3 do 
                        if enchantConfig["enchant_item"..j] then
                            info[enchantConfig["enchant_item"..j]] = (info[enchantConfig["enchant_item"..j]] or 0) + enchantConfig["enchant_num"..j]
                        end
                    end
                end
            end
        end

        -- Merge duplicate items
        for _, v in ipairs(evolveMaterials or {}) do
            info[v] = (info[v] or 0) + 1
        end
    end
end
function QUIWidgetRecycleForHeroReset:_getArtifactPreviewInfo(info, hero)
    if not hero.artifact then return end

    local importantKeys = {}
    local grade = hero.artifact.artifactBreakthrough
    local characher = db:getCharacterByID(self.id)
    local artifactId = characher.artifact_id
    local configs = db:getArtifactGradeConfigById(artifactId) or {}
    for _, config in ipairs(configs) do
        if config.breakthrough <= grade then
            local consumeItems = string.split(config.consume_item_str, ",")
            for _, consumItem in ipairs(consumeItems) do
                local strs = string.split(consumItem, ";")
                local itemType = remote.items:getItemType(strs[1])
                local count = tonumber(strs[2])
                if itemType == nil then
                    local id = tonumber(strs[1])
                    importantKeys[id] = true
                    info[id] = (info[id] or 0) + count
                else
                    info[itemType] = (info[itemType] or 0) + count
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
    importantKeys[material[3]] = true
    importantKeys[material[2]] = true
    importantKeys[material[1]] = true
    if info[material[3]] then
        info[material[3]] = info[material[3]] + materialNum1
    elseif materialNum1 > 0 then
        info[material[3]] = materialNum1
    end
    if info[material[2]] then
        info[material[2]] = info[material[2]] + materialNum2
    elseif materialNum2 > 0 then
        info[material[2]] = materialNum2
    end
    if info[material[1]] then
        info[material[1]] = info[material[1]] + materialNum3
    elseif materialNum3 > 0 then
        info[material[1]] = materialNum3
    end

    for key, _ in pairs(importantKeys) do
        table.insert(self.importantKeysList, key)
    end
end
function QUIWidgetRecycleForHeroReset:_getFragmentPreviewInfo(info, hero)
    local fragmentCount = 0
    local fragmentId = nil
    local importantKeys = {}
    if hero.godSkillGrade and hero.godSkillGrade > 0 then
        local godSkillConfig = db:getGodSkillById(self.id) or {}
        for i, v in pairs(godSkillConfig) do
            if hero.godSkillGrade >= v.level then
                fragmentCount = fragmentCount + (v.stunt_num or 0)
            end
        end

        local totalExp = hero.superHeroExp or 0
        for i = 0, hero.grade, 1 do
            local config = db:getGradeByHeroActorLevel(self.id, i)
            if config ~= nil then
                totalExp = totalExp + (config.super_devour_consume or 0)
                if config.soul_gem then
                    fragmentId = config.soul_gem
                end
            end
        end
        local itemId = tonumber(ITEM_TYPE.SUPER_EXP)
        local exp = db:getItemByID(itemId).devour_exp or 1
        local itemCount = math.modf(totalExp/exp)
        if itemCount > 0 then
            importantKeys[itemId] = true
            info[itemId] = itemCount
        end
    else
        for i = 0, hero.grade, 1 do
            local config = db:getGradeByHeroActorLevel(self.id, i)
            if config ~= nil then
                fragmentCount = fragmentCount + config.soul_gem_count
                fragmentId = config.soul_gem
            end
        end  
    end

    if fragmentId then
        if info[fragmentId] then
            info[fragmentId] = info[fragmentId] + fragmentCount
        elseif fragmentCount > 0 then
            info[fragmentId] = fragmentCount
        end
        table.insert(self.importantKeysList, 1, fragmentId)
    end

    for key, _ in pairs(importantKeys) do
        table.insert(self.importantKeysList, key)
    end
end

function QUIWidgetRecycleForHeroReset:_getHeroTrainingPreviewInfo(info, callback)
    app:getClient():heroTrainingCompensationRequest(self.id, function(data)
        if data.heroGetInfoResponse then            
            local trainMoney, enhanceCost, glyphCost, soulCost, tokenCost, moneyCost = 0, 0, 0, 0, 0, 0
            for k, v in ipairs(data.heroGetInfoResponse.heroInfo) do
                trainMoney = trainMoney + v.trainMoneyConsume
                enhanceCost = enhanceCost + v.enhanceTotalCost
                glyphCost = glyphCost + v.glyphStoneConsume
                soulCost = soulCost + v.soulMoneyConsume
                tokenCost = tokenCost + (v.trainConsumeToken or 0)
                moneyCost = moneyCost + (v.trainConsumeMoney or 0)
            end
            info["money"] = info["money"] + enhanceCost + moneyCost

            local trainMoneyId = ITEM_TYPE.TRAIN_MONEY
            if trainMoney > 0 then
                info[trainMoneyId] = (info[trainMoneyId] or 0) + trainMoney
            end
            local tokenId = ITEM_TYPE.TOKEN_MONEY
            if tokenCost > 0 then
                info[tokenId] = (info[tokenId] or 0) + tokenCost
            end
            local glyphId = ITEM_TYPE.GLYPH_MONEY
            if glyphCost > 0 then
                info[glyphId] = (info[glyphId] or 0) + glyphCost
            end
            local soulId = ITEM_TYPE.SOULMONEY
            if soulCost > 0 then
                info[soulId] = (info[soulId] or 0) + soulCost
            end

            callback(info)
        end
    end)
end

function QUIWidgetRecycleForHeroReset:onTriggerRecycle()
    if self.isPlaying then return end
    app.sound:playSound("common_small")

    if not self.id then
        app.tip:floatTip("请先选择一个需要重生的魂师") 
        return
    end

    local slotCount = remote.herosUtil:getUnlockTeamNum()
    local existingHero = remote.herosUtil:getHaveHero()
    if #existingHero <= slotCount then
        app.tip:floatTip("当前魂师数量太少，魂师不支持重生")
        return
    end

    if remote.user.token < self.price then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return
    end

    local function callRebornAPI(finalRecycleInfo)
        app:getClient():heroReborn(self.id, function ()
                if self._ccbView then
                    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
                    self:_onTriggerRecycleFinished(finalRecycleInfo)
                    remote.headProp:updateAvatarInfos()
                end
            end,function ()
                if self._ccbView then
                    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
                    self.id = nil
                    self.info = nil
                    self:update()
                end
            end)
    end

    local info = self:updateRecyclePreviewInfo()    
    QKumo(info)
    self:_getHeroTrainingPreviewInfo(info, function(callbarckInfo)
        local finalRecycleInfo = self:sortRecyclePreviewInfo(callbarckInfo)
        if next(finalRecycleInfo) == nil then
            app.tip:floatTip("不能重生初始状态的魂师")
            return 
        end
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
            options = {compensations = finalRecycleInfo, token = self.price, title = "魂师重生后将返还以下资源，是否确认重生该魂师", callFunc = callRebornAPI}})
    end)
end
function QUIWidgetRecycleForHeroReset:_onTriggerRecycleFinished(finalRecycleInfo)
    self.isPlaying = true
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:addChild(effect)
    effect:playAnimation("effects/HeroRecoverEffect_up.ccbi", function()
            if self._ccbView then
                effect._ccbOwner.node_avatar:setVisible(false)
                self._ccbOwner.node_selected_info:setVisible(false)
                self.avatar:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY)
                remote.headProp:updateAvatarInfos()
            end
        end, function()
            if self._ccbView then
                effect:removeFromParentAndCleanup(true)
                self._ccbOwner.node_selected_info:setVisible(true)
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                    options = {compensations = finalRecycleInfo, type = 1, subtitle = "魂师重生返还以下资源"}}, {isPopCurrentDialog = false})
                self.id = nil
                self.info = nil
                self:update()
                self.isPlaying = false
            end
        end)
end

function QUIWidgetRecycleForHeroReset:onTriggerStore()
    if self.isPlaying then return end
    app.sound:playSound("common_small")
    if app.unlock:checkLock("UNLOCK_SOUL_SHOP", true) then
        remote.stores:openShopDialog(SHOP_ID.soulShop)
    end
end

function QUIWidgetRecycleForHeroReset:onTriggerHelp()
    if self.isPlaying then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", options = {type = 1}}, {isPopCurrentDialog = false})
end

function QUIWidgetRecycleForHeroReset:onTriggerSelect()
    if self.isPlaying then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroOverview", options = {heroReborn = true}}, {isPopCurrentDialog = false})
end

return QUIWidgetRecycleForHeroReset
