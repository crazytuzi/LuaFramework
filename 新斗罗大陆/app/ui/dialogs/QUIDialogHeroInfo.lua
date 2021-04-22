--
-- Author: Kumo
-- Date: 
-- 魂师信息展示主界面
--
local QUIDialog = import(".QUIDialog")
local QUIDialogHeroInfo = class("QUIDialogHeroInfo", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentBox = import("..widgets.QUIWidgetEquipmentBox")
local QUIWidgetEquipmentSpecialBox = import("..widgets.QUIWidgetEquipmentSpecialBox")
local QUIWidgetHeroEquipment = import("..widgets.QUIWidgetHeroEquipment")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QGemstoneController = import("..controllers.QGemstoneController")
local QUIWidgetMountBox = import("..widgets.mount.QUIWidgetMountBox")
local QUIWidgetArtifactBox = import("..widgets.artifact.QUIWidgetArtifactBox")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")
local QUIWidgetSoulSpiritHead = import("..widgets.QUIWidgetSoulSpiritHead")
local QActorProp = import("...models.QActorProp")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QUIWidgetSuperGodStar = import("..widgets.QUIWidgetSuperGodStar")

QUIDialogHeroInfo.EQUIPMENT_TAB = "EQUIPMENT_TAB"
QUIDialogHeroInfo.GEMSTONE_TAB = "GEMSTONE_TAB"
QUIDialogHeroInfo.MAGICHERB_TAB = "MAGICHERB_TAB"

function QUIDialogHeroInfo:ctor(options)
    assert(options.fighter ~= nil, "alert dialog options.fighter is nil !")
    local ccbFile = "ccb/Dialog_wanjiaxinxi2.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggereRight)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggereLeft)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerEquipment", callback = handler(self, self._onTriggerEquipment)},
        {ccbCallbackName = "onTriggerGemstone", callback = handler(self, self._onTriggerGemstone)},
        {ccbCallbackName = "onTriggerMagicHerb", callback = handler(self, self._onTriggerMagicHerb)},
    }
    QUIDialogHeroInfo.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:hideAll() 
    page:setScalingVisible(false)

    if options then
        self._fighter = options.fighter
        self._heroIds = options.hero
        self._pos = options.pos
        self._tab = options.tab or QUIDialogHeroInfo.EQUIPMENT_TAB
    end
    
    self._information = QUIWidgetHeroInformation.new()
    self._information:setBackgroundVisible(false)
    self._information:setNameVisible(false)
    self._ccbOwner.node_heroinformation:addChild(self._information:getView())

    self._equipBox = {}
    for i = 1, 4 do
        self._equipBox[i] = QUIWidgetEquipmentBox.new()
        self._ccbOwner["node_equip"..i]:addChild(self._equipBox[i])
    end
    for i = 5, 6 do
        self._equipBox[i] = QUIWidgetEquipmentSpecialBox.new()
        self._ccbOwner["node_equip"..i]:addChild(self._equipBox[i])
    end
    --武器 护手 衣服 脚  饰品1 饰品2
    self._equipBox[1]:setType(EQUIPMENT_TYPE.WEAPON)
    self._equipBox[2]:setType(EQUIPMENT_TYPE.BRACELET)
    self._equipBox[3]:setType(EQUIPMENT_TYPE.CLOTHES)
    self._equipBox[4]:setType(EQUIPMENT_TYPE.SHOES)
    self._equipBox[5]:setType(EQUIPMENT_TYPE.JEWELRY1)
    self._equipBox[6]:setType(EQUIPMENT_TYPE.JEWELRY2)

    for i = 1, 6 do
        self._ccbOwner["node_equip"..i]:setScale(1)
        self._equipBox[i]:setBoxScale(1)
    end

    local mountLock = self:checkPlayerLock("UNLOCK_ZUOQI", self._fighter.level, false)
    local artifactLock = self:checkPlayerLock("UNLOCK_ARTIFACT", self._fighter.level, false)
    if mountLock or artifactLock then
        -- 暗器
        if mountLock then
            self._mountBox = QUIWidgetMountBox.new( {isDisplay = true} )
            self._ccbOwner.AccessoryBox1:addChild(self._mountBox)
            self._ccbOwner.AccessoryBox1:setScale(0.9)
        end
        --武魂真身
        if artifactLock then
            self._artifactBox = QUIWidgetArtifactBox.new( {isDisplay = true} )
            self._ccbOwner.AccessoryBox2:addChild(self._artifactBox)
            self._ccbOwner.AccessoryBox2:setScale(1.1)
        end
        for i = 1, 6 do
            self._equipBox[i]:setBoxScale(0.9)
            self._ccbOwner["node_equip"..i]:setPosition(ccp(0,0))
        end
    else
        for i = 1, 6 do
            self._equipBox[i]:setBoxScale(1)
        end
        self._ccbOwner.node_equip1:setPositionY(-20)
        self._ccbOwner.node_equip2:setPositionY(-40)
        self._ccbOwner.node_equip3:setPositionY(-20)
        self._ccbOwner.node_equip4:setPositionY(-40)
        self._ccbOwner.node_equip5:setPositionY(-60)
        self._ccbOwner.node_equip6:setPositionY(-60)
    end

    --装备控制器
    self._equipmentUtils = QUIWidgetHeroEquipment.new( {isDisplay = true} )
    self:getView():addChild(self._equipmentUtils) --此处添加至节点没有显示需求
    self._equipmentUtils:setUI(self._equipBox)

    --晶石
    self._sparBoxs = {}
    self._ccbOwner.node_spar:setVisible(false)
    self._isSparUnlock = self:checkPlayerLock("UNLOCK_ZHUBAO", self._fighter.level, false)
    if self._isSparUnlock then
        for i = 1, 2 do
            self._sparBoxs[i] = QUIWidgetSparBox.new()
            self._ccbOwner["node_spar"..i]:addChild(self._sparBoxs[i])
            self._sparBoxs[i]:setNameNode(self._ccbOwner["tf_spar_name"..i])
            -- self._ccbOwner["node_spar"..i]:setScale(0.8)
        end
        for i = 1, 4 do
            -- self._ccbOwner["node_gemstone"..i]:setScale(0.8)
        end
        self._ccbOwner.node_spar:setVisible(true)
    end
    self._heroInfo = self:_getLocalHeroInfoByID(self._heroIds[self._pos])
    if self._heroInfo then
        QPrintTable(self._heroInfo)
    end

    --宝石
    self._gemstoneBoxs = {}
    self._isGemstoneUnlock = self:checkPlayerLock("UNLOCK_GEMSTONE", self._fighter.level, false)
    if self._isGemstoneUnlock then
        for i = 1, 4 do
            self._gemstoneBoxs[i] = QUIWidgetGemstonesBox.new()
            self._gemstoneBoxs[i]:setNameVisible(true)
            setShadow4(self._ccbOwner["tf_gemstone_name"..i], nil, ccc3(239,224,198))
            self._gemstoneBoxs[i]:setNameNode(self._ccbOwner["tf_gemstone_name"..i])
            self._gemstoneBoxs[i]:setPos(i)
            self._ccbOwner["node_gemstone"..i]:addChild(self._gemstoneBoxs[i])
        end
    end

    if self._isSparUnlock or self._isGemstoneUnlock then
        self._gemstoneController = QGemstoneController.new( {isDisplay = true} )
        self._gemstoneController:setBoxs(self._gemstoneBoxs, self._sparBoxs)
        self._gemstoneController:setGemstones( self:_getLocalHeroInfoByID(self._heroIds[self._pos]).gemstones, self:_getLocalHeroInfoByID(self._heroIds[self._pos]).spar )
    else
        self._ccbOwner.btn_gemstone:setVisible(false)
    end

    
    --仙品
    self._magicHerbBoxs = {}
    self._isMagicHerbUnlock = self:checkPlayerLock("UNLOCK_MAGIC_HERB", self._fighter.level, false)
    if self._isMagicHerbUnlock then
        for i = 1, 3 do
            self._magicHerbBoxs[i] = QUIWidgetMagicHerbBox.new()
            self._ccbOwner["node_magicHerb_box_"..i]:addChild(self._magicHerbBoxs[i])
            local tfProp1 = self._ccbOwner["node_prop_"..i.."_1"]
            if tfProp1 then
                tfProp1:setVisible(false)
            end
            local tfProp2 = self._ccbOwner["node_prop_"..i.."_2"]
            if tfProp2 then
                tfProp2:setVisible(false)
            end
        end
    else
        self._ccbOwner.btn_magicHerb:setVisible(false)
    end

    if #self._heroIds == 1 then
        self._ccbOwner.arrowLeft:setVisible(false)
        self._ccbOwner.arrowRight:setVisible(false)
    end

    self:_setNormalStyle()
    self:setPlayerHeroInfo()
end

function QUIDialogHeroInfo:_setNormalStyle()
    self._ccbOwner.sp_magicHerb_bg:setVisible(false)
    self._ccbOwner.sp_heroInfo_bg:setPositionX(-5)
    self._ccbOwner.node_heroInfo_name:setPositionX(-5)
    self._ccbOwner.node_heroinformation:setPositionX(-5)
    self._ccbOwner.lab_jobTitle:setPositionX(-110)
    self._ccbOwner.ccb_sabc:setPositionX(-133)
    self._ccbOwner.node_force:setPositionX(-5)
end

function QUIDialogHeroInfo:_setMagicHerbStyle()
    self._ccbOwner.sp_magicHerb_bg:setVisible(true)
    self._ccbOwner.sp_heroInfo_bg:setPositionX(-135)
    self._ccbOwner.node_heroInfo_name:setPositionX(-135)
    self._ccbOwner.node_heroinformation:setPositionX(-135)
    self._ccbOwner.lab_jobTitle:setPositionX(-240)
    self._ccbOwner.ccb_sabc:setPositionX(-263)
    self._ccbOwner.node_force:setPositionX(-135)
end

function QUIDialogHeroInfo:checkPlayerLock(key, playerLevel, isTips)
    local isUnlock = true                 -- 默认解锁
    local unlockConfig = QStaticDatabase:sharedDatabase():getUnlock()
    local config = unlockConfig[key]
    if config == nil then return isUnlock end

    --检查战队等级是否解锁
    if config.team_level ~= nil then
        isUnlock = tonumber(config.team_level) <= tonumber(playerLevel)
        if isTips == true and isUnlock == false then
            app.tip:floatTip(string.format("%s将在%s级开启，该魂师尚未开启%s！", config.name, config.team_level, config.name))
        end
    end

    return isUnlock
end

function QUIDialogHeroInfo:_getLocalHeroInfoByID(actorId)
    if not self._fighter then return end
    for _, heroInfo in pairs(self._fighter.heros or {}) do
        if heroInfo and heroInfo.actorId == actorId then
            return heroInfo
        end
    end
    for _, heroInfo in pairs(self._fighter.alternateHeros or {}) do
        if heroInfo and heroInfo.actorId == actorId then
            return heroInfo
        end
    end
    for _, heroInfo in pairs(self._fighter.subheros or {}) do
        if heroInfo and heroInfo.actorId == actorId then
            return heroInfo
        end
    end
    for _, heroInfo in pairs(self._fighter.sub2heros or {}) do
        if heroInfo and heroInfo.actorId == actorId then
            return heroInfo
        end
    end
    for _, heroInfo in pairs(self._fighter.sub3heros or {}) do
        if heroInfo and heroInfo.actorId == actorId then
            return heroInfo
        end
    end
    for _, heroInfo in pairs(self._fighter.main1Heros or {}) do
        if heroInfo and heroInfo.actorId == actorId then
            return heroInfo
        end
    end
    for _, heroInfo in pairs(self._fighter.sub1heros or {}) do
        if heroInfo and heroInfo.actorId == actorId then
            return heroInfo
        end
    end
    for _, heroInfo in pairs(self._fighter.mainHeros3 or {}) do
        if heroInfo and heroInfo.actorId == actorId then
            return heroInfo
        end
    end
    for _, heroInfo in pairs(self._fighter.subheros3 or {}) do
        if heroInfo and heroInfo.actorId == actorId then
            return heroInfo
        end
    end

end 

function QUIDialogHeroInfo:viewDidAppear()
    QUIDialogHeroInfo.super.viewDidAppear(self)
    self:_refreshHero()
    self:addBackEvent()
    self:_selectedTab()
    self._information:startAutoPlay(10)
end

function QUIDialogHeroInfo:viewWillDisappear()
    QUIDialogHeroInfo.super.viewWillDisappear(self)
    self._equipBox = {}
    self._sparBoxs = {}
    self._gemstoneBoxs = {}

    self:removeBackEvent()
    remote.herosUtil:cleanTempHeros(false)
end

function QUIDialogHeroInfo:setPlayerHeroInfo()
    remote.herosUtil:cleanTempHeros(true)

    for _, heroInfo in pairs(self._fighter.heros or {}) do
        if heroInfo then
            remote.herosUtil:setTempHeroByID( clone(heroInfo) )
        end
    end
    for _, heroInfo in pairs(self._fighter.alternateHeros or {}) do
        if heroInfo then
            remote.herosUtil:setTempHeroByID( clone(heroInfo) )
        end
    end
    for _, heroInfo in pairs(self._fighter.subheros or {}) do
        if heroInfo then
            remote.herosUtil:setTempHeroByID( clone(heroInfo) )
        end
    end
    for _, heroInfo in pairs(self._fighter.sub2heros or {}) do
        if heroInfo then
            remote.herosUtil:setTempHeroByID( clone(heroInfo) )
        end
    end
    for _, heroInfo in pairs(self._fighter.sub3heros or {}) do
        if heroInfo then
            remote.herosUtil:setTempHeroByID( clone(heroInfo) )
        end
    end
    for _, heroInfo in pairs(self._fighter.main1Heros or {}) do
        if heroInfo then
            remote.herosUtil:setTempHeroByID( clone(heroInfo) )
        end
    end
    for _, heroInfo in pairs(self._fighter.sub1heros or {}) do
        if heroInfo then
            remote.herosUtil:setTempHeroByID( clone(heroInfo) )
        end
    end

    for _, heroInfo in pairs(self._fighter.mainHeros3 or {}) do
        if heroInfo then
            remote.herosUtil:setTempHeroByID( clone(heroInfo) )
        end
    end
    for _, heroInfo in pairs(self._fighter.subheros3 or {}) do
        if heroInfo then
            remote.herosUtil:setTempHeroByID( clone(heroInfo) )
        end
    end
    
end

function QUIDialogHeroInfo:_refreshHero()
    if self._pos ~= nil and self._heroIds ~= nil then
        self:_showInformation(remote.herosUtil:getHeroByID(self._heroIds[self._pos]))
    end
end

function QUIDialogHeroInfo:_showInformation(hero)
	if not hero then return end

    self._hero = hero
    self._actorId = self._hero.actorId
    self:_showBaseInfo()

    local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self._hero.actorId)
    if nil ~= heroInfo then 
        self._equipmentUtils:setHero(self._hero.actorId) -- 装备显示
        if self._gemstoneController then
            local gemstonesInfo = self:_getLocalHeroInfoByID(self._heroIds[self._pos]).gemstones or {}
            local sparData = self:_getLocalHeroInfoByID(self._heroIds[self._pos]).spar or {}
            local sparInfo = {}
            for _, value in pairs(sparData) do
                local itemConfig = db:getItemByID(value.itemId)
                if itemConfig.type == ITEM_CONFIG_TYPE.GARNET then
                    sparInfo[1] = value
                elseif itemConfig.type == ITEM_CONFIG_TYPE.OBSIDIAN then
                    sparInfo[2] = value
                end
            end
            self._gemstoneController:setGemstones( gemstonesInfo, sparInfo )
            self._gemstoneController:setHero(self._hero.actorId)
            for index, gemstoneBox in ipairs(self._gemstoneBoxs) do
                if gemstonesInfo then
                    local gemstoneInfo = gemstonesInfo[index]
                    if not gemstoneInfo then
                      self._ccbOwner["node_noWear"..index]:setVisible(true)
                    end
                else
                    self._ccbOwner["node_noWear"..index]:setVisible(true)
                end
            end
        end
        if self._mountBox ~= nil then
            self._mountBox:setHero(self._hero.actorId)
            self._mountBox:setNoWearTips()
            self._mountBox:showDressMountLevel()
            self._mountBox:showGraveMountLevel()
        end
        if self._artifactBox ~= nil then
            self._artifactBox:setHero(self._hero.actorId)
            self._artifactBox:setNoWearTips()       
            if heroInfo.artifact_id then
                self._artifactBox:setVisible(true)   
            else
                self._artifactBox:setVisible(false)   
            end
        end
        if self._magicHerbBoxs ~= nil then
            for pos, box in ipairs(self._magicHerbBoxs) do
                box:setMagicHerbInfoByInfo(nil, true)
                for p, magicHerb in ipairs(self._hero.magicHerbs or {}) do
                    if not magicHerb.position and pos == p then
                        magicHerb.position = pos
                        box:setMagicHerbInfoByInfo(magicHerb, true)
                    elseif pos == magicHerb.position then
                        box:setMagicHerbInfoByInfo(magicHerb, true)
                    end
                end
            end
            self:_showMagicHerbProp()
        end
    end

    -- Show enchant level 
    if self._equipBox[5]:getItemId() ~= nil then
        self._equipBox[5]:showEnchantIcon(true, remote.herosUtil:getWearByItem(self._hero.actorId, self._equipBox[5]:getItemId()).enchants or 0, 0.7)
    end
    if self._equipBox[6]:getItemId() ~= nil then
        self._equipBox[6]:showEnchantIcon(true, remote.herosUtil:getWearByItem(self._hero.actorId, self._equipBox[6]:getItemId()).enchants or 0, 0.7)
    end
    
    --魂灵
    local soulSpiritLock = self:checkPlayerLock("UNLOCK_SOUL_SPIRIT", self._fighter.level, false)
    if soulSpiritLock then
        if not self._soulSpiritBox then
            self._soulSpiritBox = QUIWidgetSoulSpiritHead.new()
            self._ccbOwner.node_soulSpritBox:addChild(self._soulSpiritBox)
        end
        if self._hero.soulSpirit then
            self._soulSpiritBox:setInfo(self._hero.soulSpirit)
        else
            self._soulSpiritBox:setNoWearTips()
        end
    else
        self._ccbOwner.node_soulSpritBox:removeAllChildren()
        self._soulSpiritBox = nil
    end

    -- 神技
    self._ccbOwner.node_super_star:removeAllChildren()
    self._ccbOwner.node_super_icon:removeAllChildren()
    if self._hero.godSkillGrade and self._hero.godSkillGrade > 0 then
        local godSkillConfig = db:getGodSkillByIdAndGrade(self._actorId, self._hero.godSkillGrade)
        local skillIds = string.split(godSkillConfig.skill_id, ";")
        local skillId = skillIds[1]
        if skillId ~= nil then
            local skillIcon = QUIWidgetHeroSkillBox.new()
            skillIcon:setLock(false)
            skillIcon:setSkillID(skillId)
            skillIcon:showSkillName()
            skillIcon:setGodSkillShowLevel(self._hero.godSkillGrade, self._actorId)
            self._ccbOwner.node_super_icon:addChild(skillIcon)

            local skillStar = QUIWidgetSuperGodStar.new()
            skillStar:setGrade(self._actorId)
            self._ccbOwner.node_super_star:addChild(skillStar)
        end
    end
    self:_selectedTab()
end

function QUIDialogHeroInfo:_showMagicHerbProp()
    local index = 1
    while true do
        local isBreak = true
        -- local tfName = self._ccbOwner["tf_prop_name_"..index]
        -- if tfName then
        --     isBreak = false
        --     tfName:setVisible(false)
        -- end
        -- local tfValue = self._ccbOwner["tf_prop_value_"..index]
        -- if tfValue then
        --     isBreak = false
        --     tfValue:setVisible(false)
        -- end
        local tf1 = self._ccbOwner["tf_prop_"..index.."_1"]
        if tf1 then
            isBreak = false
            tf1:setVisible(false)
        end
        local tf2 = self._ccbOwner["tf_prop_"..index.."_2"]
        if tf2 then
            isBreak = false
            tf2:setVisible(false)
        end
        local tf3 = self._ccbOwner["tf_prop_"..index.."_3"]
        if tf3 then
            isBreak = false
            tf3:setVisible(false)
        end

        if isBreak then
            break
        end
        index = index + 1
    end

    if not self._hero.magicHerbs or #self._hero.magicHerbs == 0 then 
        -- self._ccbOwner.node_magicHerb_prop:setVisible(false)
        -- self._ccbOwner.node_noMagicHerb:setVisible(true)
        return
    end
    -- self._ccbOwner.node_magicHerb_prop:setVisible(true)
    -- self._ccbOwner.node_noMagicHerb:setVisible(false)

    -- local propList = {}
    for _, magicHerb in ipairs(self._hero.magicHerbs) do
        local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerb.itemId)
        if magicHerb.attributes and magicHerbConfig then
            local additional_attributes = remote.magicHerb:getMagicHerbAdditionalAttributes(magicHerb)
            local _propList = self:_getPropList(magicHerb.attributes, additional_attributes)
            if _propList then
                for i, prop in ipairs(_propList) do
                    -- table.insert(propList, value)
                    local tf = self._ccbOwner["tf_prop_"..magicHerb.position.."_"..i]
                    if tf then
                        local color = COLORS[prop.color]
                        tf:setColor(color)
                        tf = setShadowByFontColor(tf, color)

                        tf:setString(prop.name.."+"..prop.value)
                        tf:setVisible(true)
                    end
                end
            end
        end
    end

    -- table.sort(propList, function(a, b)
    --         local aNameLen = string.len(a.name)
    --         local bNameLen = string.len(b.name)
    --         if aNameLen ~= bNameLen then
    --             return aNameLen < bNameLen
    --         elseif a.isPercent ~= b.isPercent then
    --             return b.isPercent
    --         else
    --             return a.num < b.num
    --         end
    --     end)

    -- index = 1
    -- for _, prop in ipairs(propList) do
    --     local tfName = self._ccbOwner["tf_prop_name_"..index]
    --     local tfValue = self._ccbOwner["tf_prop_value_"..index]

    --     if tfName and tfValue then
    --         local color = COLORS[prop.color]
    --         tfValue:setColor(color)
    --         tfValue = setShadowByFontColor(tfValue, color)

    --         tfName:setString(prop.name)
    --         tfName:setVisible(true)
    --         tfValue:setString(prop.value)
    --         tfValue:setVisible(true)

    --         index = index + 1
    --     end
    -- end

    -- self:_autoLayerMagicHerbProp( index - 1 )
end

function QUIDialogHeroInfo:_autoLayerMagicHerbProp( propCount )
    -- local maxCount = 6
    -- if propCount > maxCount then propCount = maxCount end
    -- local _offsetHeight = (maxCount - propCount) * 50
    -- local _height = 350 - _offsetHeight
    -- self._ccbOwner.s9s_prop_bg:setPreferredSize(CCSize(142, _height))
    -- local _y = 155 - _offsetHeight / 2
    -- self._ccbOwner.node_magicHerb_prop:setPositionY(_y)
end

function QUIDialogHeroInfo:_getPropList( prop, refineId )
    local tbl = {}
    if prop then
        for _, value in pairs(prop) do
            local key = value.attribute
            local num = value.refineValue
            if QActorProp._field[key] then
                local color, isMax = remote.magicHerb:getRefineValueColorAndMax(key, num, refineId)
                local name = QActorProp._field[key].uiName or QActorProp._field[key].name
                num = q.getFilteredNumberToString(num, QActorProp._field[key].isPercent, 2)     
                table.insert(tbl, {name = name, value = num, num = value.refineValue, color = color, isMax = isMax, isPercent = QActorProp._field[key].isPercent })
            end
        end
    end

    return tbl
end

function QUIDialogHeroInfo:_showSabc()
    if not self._hero.actorId then return end

    local aptitudeInfo = db:getActorSABC(self._hero.actorId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

--显示魂师的基本信息 等级
function QUIDialogHeroInfo:_showBaseInfo()
    -- 戰力
    self._ccbOwner.tf_battleForce:setString(self._hero.force)
    local fontInfo = QStaticDatabase.sharedDatabase():getForceColorByForce(self._hero.force)
    if fontInfo ~= nil then
        local color = string.split(fontInfo.force_color, ";")
        local fontColor = ccc3(color[1], color[2], color[3])
        self._ccbOwner.tf_battleForce:setColor(fontColor)
    end
    self:_autoLayerBattleForce()

    self._information:setAvatar(self._hero.actorId, 1.4)

    self:_showSabc()

    -- 信息
    local characherConfig = QStaticDatabase:sharedDatabase():getCharacterByID(self._hero.actorId)
    if not characherConfig then 
        self._ccbOwner.node_heroInfo_name:setVisible(false)
        self._ccbOwner.lab_jobTitle:setVisible(false)
        return
    end
    self._ccbOwner.lab_jobTitle:setString(characherConfig.label or "")
    self._ccbOwner.lab_jobTitle:setVisible(true)
    self:_setHeroName(characherConfig)
end

function QUIDialogHeroInfo:_autoLayerBattleForce()
    local minSizeW = 300 -- 战力底图的最小宽度
    local maxSizeW = 420 -- 战力底图的最大宽度
    local s9sOffsetW = 111 * 2 -- 九宫格底图2边的渐变部分宽度
    local spBattleForceW = 66 -- 战力字样图片的宽度（包括与战力数字之间的间隔）
    local s9sHeight = 58
    local posX = self._ccbOwner.node_battleForce_size:getPositionX() -- 战力展示区域的中心点位置

    self._ccbOwner.sp_battleForce:setPositionX(0)
    self._ccbOwner.tf_battleForce:setPositionX(spBattleForceW)
    local tfW = self._ccbOwner.tf_battleForce:getContentSize().width
    local totalW = tfW + spBattleForceW
    -- local s9sWidth = totalW + s9sOffsetW
    -- if s9sWidth < minSizeW then
    --     s9sWidth = minSizeW
    -- elseif s9sWidth > maxSizeW then
    --     s9sWidth = maxSizeW
    -- end
    -- self._ccbOwner.s9s_battleForce:setPreferredSize(CCSize(s9sWidth, s9sHeight))
    -- print("QUIDialogHeroInfo:_autoLayerBattleForce() totalW = ", totalW, "  s9sWidth = ", s9sWidth)
    self._ccbOwner.s9s_battleForce:setPositionX(posX)
    self._ccbOwner.node_battleForce:setPositionX(posX - totalW/2)
end

function QUIDialogHeroInfo:_setHeroName(characherConfig)
    if not characherConfig then 
        self._ccbOwner.node_heroInfo_name:setVisible(false)
        return 
    end
    self._ccbOwner.node_heroInfo_name:setVisible(true)

    local fontColor = BREAKTHROUGH_COLOR_LIGHT["white"]
    local breakthroughLevel = 0
    local color = nil
    if self._hero ~= nil then
        breakthroughLevel, color = remote.herosUtil:getBreakThrough(self._hero.breakthrough)
    end
    if color ~= nil then
        fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
    end
    self._ccbOwner.tf_heroInfo_name:setColor(fontColor)
    self._ccbOwner.tf_heroInfo_name = setShadowByFontColor(self._ccbOwner.tf_heroInfo_name, fontColor)

    local breakthroughLevelStr = ""
    if breakthroughLevel and breakthroughLevel > 0 then
        breakthroughLevelStr = "+"..tostring(breakthroughLevel)
    end
    -- print("LV."..self._hero.level, characherConfig.name, breakthroughLevelStr)
    self._ccbOwner.tf_heroInfo_name:setString(string.format("%s %s %s", "LV."..self._hero.level, characherConfig.name, breakthroughLevelStr))
    self._ccbOwner.tf_heroInfo_name:setScale(1)
    -- print( self._ccbOwner.tf_heroInfo_name:getContentSize().width )
    if self._ccbOwner.tf_heroInfo_name:getContentSize().width > 250 then
        self._ccbOwner.tf_heroInfo_name:setScale(0.9)
    end
end

--根据状态显示
function QUIDialogHeroInfo:_selectedTab()
    self:_resetTabBtn()
    self._ccbOwner.node_equipment:setVisible(false)
    self._ccbOwner.node_gemstone:setVisible(false)
    self._ccbOwner.node_magicHerb:setVisible(false)
    if self._tab == QUIDialogHeroInfo.EQUIPMENT_TAB then 
        self._ccbOwner.btn_equipment:setHighlighted(true)
        self._ccbOwner.btn_equipment:setEnabled(false)
        self._ccbOwner.node_equipment:setVisible(true)
        self:_setNormalStyle()
    elseif self._tab == QUIDialogHeroInfo.GEMSTONE_TAB then 
        self._ccbOwner.btn_gemstone:setHighlighted(true)
        self._ccbOwner.btn_gemstone:setEnabled(false)
        self._ccbOwner.node_gemstone:setVisible(true)
        self:_setNormalStyle()
    elseif self._tab == QUIDialogHeroInfo.MAGICHERB_TAB then 
        self._ccbOwner.btn_magicHerb:setHighlighted(true)
        self._ccbOwner.btn_magicHerb:setEnabled(false)
        self._ccbOwner.node_magicHerb:setVisible(true)
        self:_setMagicHerbStyle()
    end
end

function QUIDialogHeroInfo:_resetTabBtn()
    self._ccbOwner.btn_equipment:setHighlighted(false)
    self._ccbOwner.btn_equipment:setEnabled(true)
    self._ccbOwner.btn_equipment:setVisible(true)
    self._ccbOwner.btn_gemstone:setHighlighted(false)
    self._ccbOwner.btn_gemstone:setEnabled(true)
    self._ccbOwner.btn_gemstone:setVisible(self._isSparUnlock or self._isGemstoneUnlock)
    self._ccbOwner.btn_magicHerb:setHighlighted(false)
    self._ccbOwner.btn_magicHerb:setEnabled(true)
    self._ccbOwner.btn_magicHerb:setVisible(self._isMagicHerbUnlock)
end

-- function QUIDialogHeroInfo:setHeroJobTitle(grade)
--     self._ccbOwner.lab_jobTitle:setVisible(false)
--     local stringTilte = remote.herosUtil:getJobTitleByGradeLevelNum(grade+1)
--     if stringTilte then 
--         self._ccbOwner.lab_jobTitle:setVisible(true)
--         self._ccbOwner.lab_jobTitle:setString(stringTilte)
--     end
-- end

function QUIDialogHeroInfo:_onTriggereRight()
    app.sound:playSound("common_change")
    local n = table.nums(self._heroIds)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos + 1
        if self._pos > n then
            self._pos = 1
        end
        local options = self:getOptions()
        options.pos = self._pos
        self:_showInformation(remote.herosUtil:getHeroByID(self._heroIds[self._pos]))
    end
end

function QUIDialogHeroInfo:_onTriggereLeft()
    app.sound:playSound("common_change")
    local n = table.nums(self._heroIds)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos - 1
        if self._pos < 1 then
            self._pos = n
        end
        local options = self:getOptions()
        options.pos = self._pos
        self:_showInformation(remote.herosUtil:getHeroByID(self._heroIds[self._pos]))
    end
end

function QUIDialogHeroInfo:_onTriggerEquipment(e)
    if e ~= nil then
        app.sound:playSound("common_menu")
    end
    if self._tab == QUIDialogHeroInfo.EQUIPMENT_TAB then return end
    self._tab = QUIDialogHeroInfo.EQUIPMENT_TAB
    self:getOptions().tab = self._tab
    self:_selectedTab()
end

function QUIDialogHeroInfo:_onTriggerGemstone(e)
    --检查是否解锁
    if self:checkPlayerLock("UNLOCK_GEMSTONE", self._fighter.level, true) == false then return end

    if e ~= nil then
        app.sound:playSound("common_menu")
    end
    if self._tab == QUIDialogHeroInfo.GEMSTONE_TAB then return end
    self._tab = QUIDialogHeroInfo.GEMSTONE_TAB
    self:getOptions().tab = self._tab
    self:_selectedTab()
end

function QUIDialogHeroInfo:_onTriggerMagicHerb(e)
    --检查是否解锁
    if self:checkPlayerLock("UNLOCK_MAGIC_HERB", self._fighter.level, true) == false then
        return
    end
    if e ~= nil then
        app.sound:playSound("common_menu")
    end
    if self._tab == QUIDialogHeroInfo.MAGICHERB_TAB then return end
    self._tab = QUIDialogHeroInfo.MAGICHERB_TAB
    self:getOptions().tab = self._tab
    self:_selectedTab()
end

function QUIDialogHeroInfo:onTriggerBackHandler(tag)
    self:_onTriggerBack()
end

function QUIDialogHeroInfo:onTriggerHomeHandler(tag)
    self:_onTriggerHome()
end

function QUIDialogHeroInfo:_onTriggerClose()
	self:_onTriggerBack()
end

-- 对话框退出
function QUIDialogHeroInfo:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogHeroInfo:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogHeroInfo
