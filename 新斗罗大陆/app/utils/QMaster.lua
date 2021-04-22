local QMaster = class("QMaster")

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIHeroModel = import("..models.QUIHeroModel")

QMaster.STRENGTHEN_MASTER = "STRENGTHEN_MASTER"
QMaster.JEWELRY_MASTER = "JEWELRY_MASTER"

QMaster.EQUIPMENT_BREAK_TIP = "EQUIPMENT_BREAK_TIP"     --装备突破成功是否显示
QMaster.EQUIPMENT_ENCHANT_TIP = "EQUIPMENT_ENCHANT_TIP"     --装备觉醒成功是否显示
QMaster.JEWELRY_BREAK_TIP = "JEWELRY_BREAK_TIP"     --饰品突破成功是否显示
QMaster.JEWELRY_ENCHANT_TIP = "JEWELRY_ENCHANT_TIP"     --饰品觉醒成功是否显示
QMaster.GLYPH_LEVEL_UP = "GLYPH_LEVEL_UP"     --体技升级成功是否显示
QMaster.GEMSTONE_BREAK_TIP = "GEMSTONE_BREAK_TIP"     --魂骨突破成功是否显示
QMaster.GEMSTONE_SUIT_TIP = "GEMSTONE_SUIT_TIP"     --魂骨套装是否显示
QMaster.GEMSTONE_GOD_ADVANCED_TIP = "GEMSTONE_GOD_ADVANCED_TIP"     --魂骨进阶是否显示
QMaster.SPAR_BREAK_TIP = "SPAR_BREAK_TIP"     --外附魂骨突破成功是否显示
QMaster.SPAR_SUIT_TIP = "SPAR_SUIT_TIP"     --外附魂骨套装是否显示
QMaster.GLORY_TOWER_FLOOR_TIP = "GLORY_TOWER_FLOOR_TIP"     --大魂师赛段位提升是否显示
QMaster.ARTIFACT_MASTER_TIP = "ARTIFACT_MASTER_TIP"     --武魂真身是否显示
QMaster.MOUNT_MASTER_TIP = "MOUNT_MASTER_TIP"     --暗器真身是否显示
QMaster.GODARM_MASTER_TIP = "GODARM_MASTER_TIP"     --神器天赋是否显示
QMaster.SOULFIRE_MASTER_TIP = "GODARM_MASTER_TIP"     --魂火点亮是否显示
QMaster.SOULFIRE_LOCKTEAM_TIP = "SOULFIRE_LOCKTEAM_TIP"     --魂火激活上阵位是否显示
QMaster.MOUNT_GRAVE_MASTER_TIP = "MOUNT_GRAVE_MASTER_TIP" --暗器雕刻大师是否显示

function QMaster:ctor()
    self._strengthenMasterLevel = 0 
    self._jewelryMasterLevel = 0

    self._showMaster = {}
    self.masterShowType = {   --unlock，对应功能的解锁；tipUnlock，今日不再显示的解锁等级（会有多个），默认是 UNLOCK_BLACKSCREEN_NO_PROMPT
        --大师
        [QUIHeroModel.GEMSTONE_MASTER] = {showSelect = true, unlock = "UNLOCK_GEMSTONE"}, 
        [QUIHeroModel.GEMSTONE_BREAK_MASTER] = {showSelect = true, unlock = "UNLOCK_GEMSTONE"},
        [QUIHeroModel.EQUIPMENT_MASTER] = {showSelect = true}, 
        [QUIHeroModel.JEWELRY_MASTER] = {showSelect = true, unlock = "UNLOCK_GAD"},
        [QUIHeroModel.SPAR_STRENGTHEN_MASTER] = {showSelect = true, unlock = "UNLOCK_ZHUBAO"}, 
        [QUIHeroModel.JEWELRY_BREAK_MASTER] = {showSelect = true, unlock = "UNLOCK_GAD"}, 
        [QUIHeroModel.EQUIPMENT_ENCHANT_MASTER] = {showSelect = true, unlock = "UNLOCK_ENCHANT"}, 
        [QUIHeroModel.JEWELRY_ENCHANT_MASTER] = {showSelect = true, unlock = "UNLOCK_GAD"}, 
        [QUIHeroModel.HERO_TRAIN_MASTER] = {showSelect = true, unlock = "UNLOCK_TRAIN"},
        [QUIHeroModel.MAGICHERB_UPLEVEL_MASTER] = {showSelect = true, unlock = "UNLOCK_MAGIC_HERB"},
        --非大师
        [QMaster.EQUIPMENT_BREAK_TIP] = {showSelect = true, tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"}, 
        [QMaster.EQUIPMENT_ENCHANT_TIP] = {showSelect = true, unlock = "UNLOCK_ENCHANT", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"},
        [QMaster.JEWELRY_BREAK_TIP] = {showSelect = true, unlock = "UNLOCK_GAD", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"}, 
        [QMaster.JEWELRY_ENCHANT_TIP] = {showSelect = true, unlock = "UNLOCK_GAD", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"},
        [QMaster.GLYPH_LEVEL_UP] = {showSelect = true, unlock = "GLYPH_SYSTEMS", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"}, 
        [QMaster.GEMSTONE_BREAK_TIP] = {showSelect = true, unlock = "UNLOCK_GEMSTONE", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"}, 
        [QMaster.GEMSTONE_SUIT_TIP] = {showSelect = true, unlock = "UNLOCK_GEMSTONE", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"}, 
        [QMaster.GEMSTONE_GOD_ADVANCED_TIP] = {showSelect = true, unlock = "UNLOCK_GEMSTONE", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"}, 
        [QMaster.SPAR_BREAK_TIP] = {showSelect = true, unlock = "UNLOCK_ZHUBAO", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"}, 
        [QMaster.SPAR_SUIT_TIP] = {showSelect = true, unlock = "UNLOCK_ZHUBAO", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"}, 
        [QMaster.GLORY_TOWER_FLOOR_TIP] = {showSelect = true, unlock = "UNLOCK_TOWER_OF_GLORY", tipUnlock = "UNLOCK_TOWER_OF_GLORY_NO_BLACKSCREEN"}, 
        [QMaster.ARTIFACT_MASTER_TIP] = {showSelect = true, unlock = "UNLOCK_ARTIFACT", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"},
        [QMaster.MOUNT_MASTER_TIP] = {showSelect = true, unlock = "UNLOCK_ZUOQI", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"},
        [QMaster.GODARM_MASTER_TIP] = {showSelect = true, unlock = "UNLOCK_GOD_ARM", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"},
        [QMaster.SOULFIRE_MASTER_TIP] = {showSelect = true, unlock = "UNLOCK_SOUL_SPIRIT", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"},
        [QMaster.SOULFIRE_LOCKTEAM_TIP] = {showSelect = true, unlock = "UNLOCK_SOUL_SPIRIT", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"},
        [QMaster.MOUNT_GRAVE_MASTER_TIP] = {showSelect = true, unlock = "UNLOCK_ZUOQI", tipUnlock = "UNLOCK_BLACKSCREEN_NO_PROMPT2"},
    }
end

function QMaster:upGradeMaster(level, masterType, actorId, oldCurObj, upLevel)
    if self:getMasterShowState(masterType) then
        app.tip:refreshTip()
        app.tip:masterTip(masterType, level, actorId, oldCurObj, upLevel)
    end
end

--宝石系统的大师达成
--@param level1 起始等级
--@param level2 到达等级
--@param masterType 大师类型
function QMaster:upGradeGemstoneMaster(level1, level2, masterType, actorId, oldCurObj)
    if self:getMasterShowState(masterType) then
        app.tip:refreshTip()
        return app.tip:gemstoneMasterTip(level1, level2, masterType, actorId, oldCurObj)
    end
end

function QMaster:upGradeMagicHerbMaster(level1, level2, masterType, actorId)
    if self:getMasterShowState(masterType) then
        app.tip:refreshTip()
        app.tip:magicHerbMasterTip(level1, level2, masterType, actorId)
    end
end

function QMaster:createMasterLayer()
    if self.masterLayer == nil then
        self.masterLayer = CCLayerColor:create(ccc4(0, 0, 0, 0), display.width, display.height)
        self.masterLayer:setPosition(-display.width/2, -display.height/2)
        self.masterLayer:setTouchEnabled(true)
        app._uiScene:addChild(self.masterLayer)
    end
end

function QMaster:cleanMasterLayer()
    if self.masterLayer ~= nil then
        self.masterLayer:removeFromParent()
        self.masterLayer = nil
    end
end

function QMaster:getForceChanges(actorId)
    local newHeroInfo = remote.herosUtil:getHeroByID(actorId)
    if not newHeroInfo.trainAttr then return 0 end
    local hpForce = QStaticDatabase:sharedDatabase():getBattleForceBySingleAttribute("hp", newHeroInfo.trainAttr.hp or 0, newHeroInfo.level)
    local attackForce = QStaticDatabase:sharedDatabase():getBattleForceBySingleAttribute("attack", newHeroInfo.trainAttr.attack or 0, newHeroInfo.level)
    local pdForce = QStaticDatabase:sharedDatabase():getBattleForceBySingleAttribute("armor_physical", newHeroInfo.trainAttr.armorPhysical or 0, newHeroInfo.level)
    local mdForce = QStaticDatabase:sharedDatabase():getBattleForceBySingleAttribute("armor_magic", newHeroInfo.trainAttr.armorMagic or 0, newHeroInfo.level)

    return math.ceil(hpForce + attackForce + pdForce + mdForce)
end

-- 根据培养大师属性计算战力
function QMaster:getTrainMasterForce(attributes, actorId)
    if not attributes then return 0 end

    local newHeroInfo = remote.herosUtil:getHeroByID(actorId)
    
    local hpForce = QStaticDatabase:sharedDatabase():getBattleForceBySingleAttribute("hp", attributes.hp_value or 0, newHeroInfo.level)
    local attackForce = QStaticDatabase:sharedDatabase():getBattleForceBySingleAttribute("attack", attributes.attack_value or 0, newHeroInfo.level)
    local pdForce = QStaticDatabase:sharedDatabase():getBattleForceBySingleAttribute("armor_physical", attributes.armor_physical or 0, newHeroInfo.level)
    local mdForce = QStaticDatabase:sharedDatabase():getBattleForceBySingleAttribute("armor_magic", attributes.armor_magic or 0, newHeroInfo.level)

    return math.ceil(hpForce + attackForce + pdForce + mdForce)
end

-- 累加培养大师当前等级的属性
function QMaster:countCurrentTrainMasterProp(masterInfo, actorId)
    if masterInfo == nil or next(masterInfo) == nil then return {} end

    local msater = q.cloneShrinkedObject(masterInfo)
    local config = QStaticDatabase:sharedDatabase():getTrainingBonus(actorId)
    for k, v in ipairs(config) do
        if (msater.standard or 0) > v.standard then
            msater.hp_value = msater.hp_value + v.hp_value
            msater.attack_value = msater.attack_value + v.attack_value
            msater.armor_physical = msater.armor_physical + v.armor_physical
            msater.armor_magic = msater.armor_magic + v.armor_magic
        end
    end

    return msater
end

--设置今日不再显示强化大师
function QMaster:setMasterShowState(masterType)
    local showInfo = self.masterShowType[masterType]
    if showInfo == nil then
        return
    end
    app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.SHOW_MASTER_TIP..masterType)
    self._showMaster[masterType] = false
end

--今日是否显示强化大师
function QMaster:getMasterShowState(masterType)

    local showInfo = self.masterShowType[masterType]
    if showInfo == nil then
        return true
    end
    if self._showMaster[masterType] == nil then
        self._showMaster[masterType] = true
    end

    local isShow = false
    if app.unlock:checkLock("UNLOCK_BLACKSCREEN_NO_PROMPT_WEEK") then
        isShow = app:getUserOperateRecord():checkNewWeekCompareWithRecordeTime(DAILY_TIME_TYPE.SHOW_MASTER_TIP..masterType, 0)
    else
        isShow = app:getUserOperateRecord():checkNewDayCompareWithRecordeTime(DAILY_TIME_TYPE.SHOW_MASTER_TIP..masterType, 0)
    end
    self._showMaster[masterType] = isShow 

    return isShow
end

--不在显示提示
function QMaster:getMasterShowTips()
    local showTips = ""
    if app.unlock:checkLock("UNLOCK_BLACKSCREEN_NO_PROMPT_WEEK") then
        showTips = "本周不再显示"
    else
        showTips = "今日不再显示"
    end

    return showTips
end

--今日是否显示强化大师
function QMaster:showMasterSelect(masterType)
    local showInfo = self.masterShowType[masterType]
    if showInfo == nil then
        return false
    end

    local unlockType = "UNLOCK_BLACKSCREEN_NO_PROMPT"
    if showInfo.tipUnlock and showInfo.tipUnlock ~= "" then
        unlockType = showInfo.tipUnlock
    end
    if app.unlock:checkLock(unlockType) == false then
        return false
    end
    
    local unlockLevel = 0
    if showInfo.unlock then
        local unlockConfig = app.unlock:getConfigByKey(showInfo.unlock)
        if unlockConfig then
            unlockLevel = unlockConfig.team_level or 0
        end
    end

    if self._showMasterSelectLevel == nil then
        self._showMasterSelectLevel = QStaticDatabase.sharedDatabase():getConfigurationValue("black_screen_no_prompt") or 3
    end
    if remote.user.level >= unlockLevel + self._showMasterSelectLevel then
        return true
    end

    return false
end

function QMaster:checkAllMasterUnlock(actorId)
    if self:checkEquipStrengMasterUnlock(actorId) then
        return true
    elseif self:checkJewelryStrengMasterUnlock(actorId) then 
        return true
    elseif self:checkEquipEnchantMasterUnlock(actorId) then 
        return true
    elseif self:checkJewelryEnchantMasterUnlock(actorId) then 
        return true
    elseif self:checkJewelryBreakMasterUnlock(actorId) then 
        return true
    end
    return false
end

function QMaster:checkEquipStrengMasterUnlock(actorId, isTip)
    if app.unlock:getUnlockEnhance(isTip) then
        return true
    end
    return false
end

function QMaster:checkJewelryStrengMasterUnlock(actorId, isTip)
    if app.unlock:getUnlockEnhanceAdvanced(isTip)  then
        local heroUIModel = remote.herosUtil:getUIHeroByID(actorId)
        if heroUIModel ~= nil and heroUIModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1) and heroUIModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY2) then 
            return true
        end
    end
    return false
end

function QMaster:checkEquipEnchantMasterUnlock(actorId, isTip)
    if app.unlock:getUnlockEnchant(isTip) then
        return true
    end
    return false
end

--检查宝石的强化大师解锁
function QMaster:checkGemstoneStrengthMasterUnlock()
    if app.unlock:checkLock("UNLOCK_GEMSTONE_MASTER") then
        return true
    end
    return false
end

--检查宝石的突破大师解锁
function QMaster:checkGemstoneBreakMasterUnlock()
    if app.unlock:checkLock("UNLOCK_GEMSTONE_MASTER") then
        return true
    end
    return false
end

--检查晶石的强化大师解锁
function QMaster:checkSparStrengthMasterUnlock()
    if app.unlock:checkLock("UNLOCK_ZHUBAO") then
        return true
    end
    return false
end

--检查仙品的升級大师解锁
function QMaster:checkMagicHerbUpLevelMasterUnlock()
    if remote.magicHerb:checkMagicHerbUnlock() then
        return true
    end
    return false
end


function QMaster:checkJewelryEnchantMasterUnlock(actorId, isTip)
    if app.unlock:getUnlockEnchant(isTip) then 
        local heroUIModel = remote.herosUtil:getUIHeroByID(actorId)
        if heroUIModel ~= nil and heroUIModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1) and heroUIModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY2) then 
            return true
        end
    end
    return false
end

function QMaster:checkJewelryBreakMasterUnlock(actorId, isTip)
    local heroUIModel = remote.herosUtil:getUIHeroByID(actorId)
    if heroUIModel ~= nil and heroUIModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1) and heroUIModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY2) then 
        return true
    end
    return false
end

function QMaster:checkClearBlackRecord()
    local unlockConfig = app.unlock:getConfigByKey("UNLOCK_BLACKSCREEN_NO_PROMPT_WEEK")
    local unlockLevel = 0
    if unlockConfig then
        unlockLevel = unlockConfig.team_level or 0
    end
    if remote.user.level == unlockLevel then
        local removeList = {}
        for masterType, v in pairs(self.masterShowType) do
            local showType = DAILY_TIME_TYPE.SHOW_MASTER_TIP..masterType
            table.insert(removeList, showType)
        end
        app:getUserOperateRecord():removeRecordByTypes(removeList)
    end
end
return QMaster 