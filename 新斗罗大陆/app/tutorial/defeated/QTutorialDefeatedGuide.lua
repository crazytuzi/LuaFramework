--
-- Author: Qinyuanji
-- Date: 2015-02-28
-- 
-- This class is to pop up the corresponding page/dialog in terms of guide for battle lose

local QTutorialDefeatedGuide = class("QTutorialDefeatedGuide")

local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIDialogHeroInformation = import("...ui.dialogs.QUIDialogHeroInformation")
local QUIDialogHeroEquipmentDetail = import("...ui.dialogs.QUIDialogHeroEquipmentDetail")
local QUIDialogHeroGemstoneDetail = import("...ui.dialogs.QUIDialogHeroGemstoneDetail")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

-- In this order
QTutorialDefeatedGuide.EQUIPMENT = "Equipment" --装备穿戴
QTutorialDefeatedGuide.FARM = "Farm" --装备获取 
QTutorialDefeatedGuide.EVOLVE1 = "Evolve1" --装备突破
QTutorialDefeatedGuide.SKILL = "Skill" --魂师技能
QTutorialDefeatedGuide.ENHANCE = "Enhance" --装备强化
QTutorialDefeatedGuide.EVOLVE2 = "Evolve2" --装备突破
QTutorialDefeatedGuide.UPGRADE = "Upgrade" --魂师升级
QTutorialDefeatedGuide.ENCHANTE = "Enchante" --装备觉醒
QTutorialDefeatedGuide.STARUP = "StarUp" --魂师升星
QTutorialDefeatedGuide.TAVERN = "Tavern" --酒馆
QTutorialDefeatedGuide.GROW = "Grow" --成长
QTutorialDefeatedGuide.TRAIN = "Train" --魂师培养
QTutorialDefeatedGuide.GLYPH = "Glyph" --魂师体技
QTutorialDefeatedGuide.ELITE = "Elite" --精英副本
QTutorialDefeatedGuide.TIMEMACHINE = "TimeMachine" --活动试炼
QTutorialDefeatedGuide.SHOP = "Shop" --商店
QTutorialDefeatedGuide.REBIRTH = "Rebirth" --重生天使
QTutorialDefeatedGuide.ARENA = "Arena" --斗魂场
QTutorialDefeatedGuide.ARCHAEOLOGY = "Archaeology" --考古
QTutorialDefeatedGuide.THUNDER = "Thunder" --雷电王座
QTutorialDefeatedGuide.SUNWELL = "Sunwell" --太阳井
QTutorialDefeatedGuide.INVASION = "Invasion" --要塞
QTutorialDefeatedGuide.GLORYTOWER = "GloryTower" --魂师大赛
QTutorialDefeatedGuide.UNION = "Union" --宗门
QTutorialDefeatedGuide.FRIEND = "Friend" --好友
QTutorialDefeatedGuide.ADDMoney = "AddMoney" --金魂币
QTutorialDefeatedGuide.BACKMAINPAGE = "BackMainPage" --返回主界面
QTutorialDefeatedGuide.GEMSTONE = "GEMSTONE" --魂师
QTutorialDefeatedGuide.SPAR_UNLOCK = "SPAR_UNLOCK" --晶石场
QTutorialDefeatedGuide.GEMSTONE_EVOLVE = "GEMSTONE_EVOLVE" --宝石突破

local function getPosByHeroID(heroes, heroId)
    local pos = 1
    for i, actorId in ipairs(heroes) do
        if actorId == heroId then
            pos = i
            break
        end
    end

    return pos
end

function QTutorialDefeatedGuide:ctor()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.EQUIPMENT, self.onEquipment,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.FARM, self.onFarm,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.EVOLVE1, self.onEvolve1,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.SKILL, self.onSkill,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.ENHANCE, self.onEnhance,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.EVOLVE2, self.onEvolve2,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.UPGRADE, self.onUpgrade,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.ENCHANTE, self.onEnchant,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.STARUP, self.onStarup,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.TAVERN, self.onTavern,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.GROW, self.onGrow,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.TRAIN, self.onTrain,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.GLYPH, self.onGlyph,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.GEMSTONE_EVOLVE, self.onGemstoneEvolve,self) 

    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.ELITE, self.onElite,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.TIMEMACHINE, self.onTimeMachine,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.SHOP, self.onShop,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.REBIRTH, self.onRebirth,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.ARENA, self.onArena,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.ARCHAEOLOGY, self.onArchaeology,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.THUNDER, self.onThunder,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.SUNWELL, self.onSunWell,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.INVASION, self.onInvasion,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.GLORYTOWER, self.onGloryTower,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.UNION, self.onUnion,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.FRIEND, self.onFriend,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.ADDMoney, self.onAddMoney,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.BACKMAINPAGE, self.onBackMainPage,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.GEMSTONE, self.onGemstone,self) 
    QNotificationCenter.sharedNotificationCenter():addEventListener(QTutorialDefeatedGuide.SPAR_UNLOCK, self.onSparField,self) 
end

function QTutorialDefeatedGuide:detach()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.EQUIPMENT, self.onEquipment,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.FARM, self.onFarm,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.EVOLVE1, self.onEvolve1,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.SKILL, self.onSkill,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.ENHANCE, self.onEnhance,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.EVOLVE2, self.onEvolve2,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.UPGRADE, self.onUpgrade,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.ENCHANTE, self.onEnchant,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.STARUP, self.onStarup,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.TAVERN, self.onTavern,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.GROW, self.onGrow,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.TRAIN, self.onTrain,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.GEMSTONE_EVOLVE, self.onGemstoneEvolve,self) 

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.ELITE, self.onElite,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.TIMEMACHINE, self.onTimeMachine,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.SHOP, self.onShop,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.REBIRTH, self.onRebirth,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.ARENA, self.onArena,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.ARCHAEOLOGY, self.onArchaeology,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.THUNDER, self.onThunder,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.SUNWELL, self.onSunWell,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.INVASION, self.onInvasion,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.GLORYTOWER, self.onGloryTower,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.UNION, self.onUnion,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.FRIEND, self.onFriend,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.ADDMoney, self.onAddMoney,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.BACKMAINPAGE, self.onBackMainPage,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.GEMSTONE, self.onGemstone,self) 
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTutorialDefeatedGuide.SPAR_UNLOCK, self.onSparField,self) 
end

function QTutorialDefeatedGuide:onEquipment(event)
    local equipmentId = event.options.equipmentId or EQUIPMENT_TYPE.WEAPON
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    local parentOptions = {hero = remote.herosUtil:getHaveHero() , pos = pos}
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation", options = parentOptions}, nil},
        {{uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
        options = {itemId = equipmentId, heros = remote.herosUtil:getHaveHero(), pos = pos, parentOptions = parentOptions}}, nil}
        })
end

function QTutorialDefeatedGuide:onFarm(event)
    local equipmentId = event.options.equipmentId or EQUIPMENT_TYPE.WEAPON
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    local parentOptions = {hero = remote.herosUtil:getHaveHero() , pos = pos}
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation", options = parentOptions}, nil},
        {{uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
        options = {itemId = event.options.equipmentId, heros = remote.herosUtil:getHaveHero(), pos = pos, parentOptions = parentOptions}}, nil}
        })
end

function QTutorialDefeatedGuide:onEvolve1(event)
    local equipmentId = event.options.equipmentId or EQUIPMENT_TYPE.WEAPON
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    local parentOptions = {hero = remote.herosUtil:getHaveHero() , pos = pos}
    local uiHero = remote.herosUtil:getUIHeroByID(event.options.actorId)
    local equipmentPos = uiHero:getEquipmentPosition(equipmentId)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation", options = parentOptions}, nil},
        {{uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
        options = {equipmentPos = equipmentPos, heros = remote.herosUtil:getHaveHero(), pos = pos, parentOptions = parentOptions,
        initTab = QUIDialogHeroEquipmentDetail.TAB_EVOLUTION}}, nil}
        })
end

function QTutorialDefeatedGuide:onSkill(event)
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
         options = {hero = remote.herosUtil:getHaveHero(), pos = pos, detailType = QUIDialogHeroInformation.HERO_SKILL}}, nil}
         })
end

function QTutorialDefeatedGuide:onEnhance(event)
    local equipmentId = event.options.equipmentId or EQUIPMENT_TYPE.WEAPON
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    local parentOptions = {hero = remote.herosUtil:getHaveHero() , pos = pos}
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation", options = parentOptions}, nil},
        {{uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
        options = {itemId = equipmentId, heros = remote.herosUtil:getHaveHero(), pos = pos,equipmentPos = event.options.equipmentPos, parentOptions = parentOptions,
        initTab = QUIDialogHeroEquipmentDetail.TAB_STRONG}}, nil}
        })
end

function QTutorialDefeatedGuide:onEvolve2(event)
    local equipmentId = event.options.equipmentId or EQUIPMENT_TYPE.WEAPON
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    local parentOptions = {hero = remote.herosUtil:getHaveHero() , pos = pos}
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation", options = parentOptions}, nil},
        {{uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
        options = {itemId = equipmentId, heros = remote.herosUtil:getHaveHero(), pos = pos, parentOptions = parentOptions,
        initTab = QUIDialogHeroEquipmentDetail.TAB_EVOLUTION}}, nil}
        })
end

function QTutorialDefeatedGuide:onGrow(event)
    local guideGrow = true 
    if event.options.guideGrow == false then guideGrow = false end
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
         options = {hero = remote.herosUtil:getHaveHero(), pos = pos, guideGrow = guideGrow,isShowTanNian = event.options.isShowTanNian}}, nil}
         })
end

function QTutorialDefeatedGuide:onTrain(event)
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
         options = {hero = remote.herosUtil:getHaveHero(), pos = pos, detailType = QUIDialogHeroInformation.HERO_TRAINING}}, nil}
         })
end

function QTutorialDefeatedGuide:onGlyph(event)
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
         options = {hero = remote.herosUtil:getHaveHero(), pos = pos, detailType = QUIDialogHeroInformation.HERO_GLYPH}}, nil}
         })
end

-- event.options is hero Id
function QTutorialDefeatedGuide:onUpgrade(event)
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
         options = {hero = remote.herosUtil:getHaveHero(), pos = pos, detailType = QUIDialogHeroInformation.HERO_UPGRADE}}, nil}
         })
end

function QTutorialDefeatedGuide:onEnchant(event)
    local equipmentId = event.options.equipmentId or EQUIPMENT_TYPE.WEAPON
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    local parentOptions = {hero = remote.herosUtil:getHaveHero() , pos = pos}
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation", options = parentOptions}, nil},
        {{uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
        options = {itemId = equipmentId, heros = remote.herosUtil:getHaveHero(), pos = pos, parentOptions = parentOptions
        , initTab = QUIDialogHeroEquipmentDetail.TAB_MAGIC}}, nil}
        })
end

-- event.options is hero Id
function QTutorialDefeatedGuide:onStarup(event)
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
         options = {hero = remote.herosUtil:getHaveHero(), pos = pos}}, nil}
         })
end

function QTutorialDefeatedGuide:onTavern()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()
    
    local config = QStaticDatabase:sharedDatabase():getConfiguration()
  
    return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTreasureChestDraw"})
    
end

function QTutorialDefeatedGuide:onElite(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)

    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMap",  
        options = {instanceType = event.options.instanceType,showType = event.options.showType, isShowTanNian = event.options.isShowTanNian}})
end

function QTutorialDefeatedGuide:onTimeMachine(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTimeMachine", 
        options = {initPage = event.options.initPage,isShowTanNian = event.options.isShowTanNian, isQuickWay = true}})
end

function QTutorialDefeatedGuide:onShop(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    if event.options.shopId == SHOP_ID.blackShop then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogShopList", options = {position = position}})
    else
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = event.options.className, 
            options = {type = event.options.shopId}},{isPopCurrentDialog = true})
    end
end

function QTutorialDefeatedGuide:onRebirth(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroReborn", 
        options = {tab = event.options.tab}})
end

function QTutorialDefeatedGuide:onArena(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    remote.arena:openArena()
end

function QTutorialDefeatedGuide:onArchaeology(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArchaeologyClient"})
end

function QTutorialDefeatedGuide:onThunder(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    remote.thunder:openDilaog()
end

function QTutorialDefeatedGuide:onSunWell(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSunWar"})
end

function QTutorialDefeatedGuide:onInvasion(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    remote.invasion:getInvasionRequest(function(data)
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasion",
            options = {}})
    end)
end

function QTutorialDefeatedGuide:onGloryTower(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    
    remote.tower:openGloryTower()
end

function QTutorialDefeatedGuide:onUnion(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    remote.union:openDialog()
end

function QTutorialDefeatedGuide:onFriend(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogFriend"})
end

function QTutorialDefeatedGuide:onAddMoney(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyVirtual",
            options = {typeName=ITEM_TYPE.MONEY}})
end

function QTutorialDefeatedGuide:onBackMainPage(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QTutorialDefeatedGuide:onGemstone(event)
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    local parentOptions = {hero = remote.herosUtil:getHaveHero() , pos = pos}
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, 
        {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation", options = parentOptions}, nil},
        })
end

function QTutorialDefeatedGuide:onSparField(event)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    
    -- remote.sparField:openSparField()
end

function QTutorialDefeatedGuide:onGemstoneEvolve(event)
    local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), event.options.actorId)
    local parentOptions = {hero = remote.herosUtil:getHaveHero() , pos = pos, swtichState = true}
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    app:getNavigationManager():pushDialogInOrder(app.mainUILayer, {
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"}, {transitionClass = "QUITransitionDialogHeroOverview"}}, 
        {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation", options = parentOptions}, nil},
        {{uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroGemstoneDetail", 
            options = {heros = remote.herosUtil:getHaveHero(), pos = pos, gemstonePos = 1, initTab = QUIDialogHeroGemstoneDetail.TAB_EVOLUTION}}, nil}
        })
end

return QTutorialDefeatedGuide
