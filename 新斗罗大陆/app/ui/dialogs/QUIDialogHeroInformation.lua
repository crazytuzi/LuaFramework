
local QUIDialog = import(".QUIDialog")
local QUIDialogHeroInformation = class("QUIDialogHeroInformation", QUIDialog)

local QRemote = import("...models.QRemote")
local QActorProp = import("...models.QActorProp")
local QHerosUtils = import("...utils.QHerosUtils")
local QUIViewController = import("..QUIViewController")
local QUIWidgetScaling = import("..widgets.QUIWidgetScaling")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroFrame = import("..widgets.QUIWidgetHeroFrame")
local QUIDialogGrade = import(".QUIDialogGrade")
local QUIDialogHeroOverview = import(".QUIDialogHeroOverview")
local QUIDialogBreakthrough = import(".QUIDialogBreakthrough")
local QUIWidgetEquipmentBox = import("..widgets.QUIWidgetEquipmentBox")
local QUIWidgetEquipmentSpecialBox = import("..widgets.QUIWidgetEquipmentSpecialBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetHeroIntroduce = import("..widgets.QUIWidgetHeroIntroduce")
local QUIWidgetHeroUpgradeNew = import("..widgets.QUIWidgetHeroUpgradeNew")
local QUIWidgetHeroSkillUpgrade = import("..widgets.QUIWidgetHeroSkillUpgrade")
local QUIWidgetHeroGlyphUpgrade = import("..widgets.QUIWidgetHeroGlyphUpgrade")
local QUIWidgetHeroEquipment = import("..widgets.QUIWidgetHeroEquipment")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")
local QTutorialDirector = import("...tutorial.QTutorialDirector")
local QUIWidgetHeroCombination = import("..widgets.QUIWidgetHeroCombination")
local QUIDialogAlertBreak = import("..dialogs.QUIDialogAlertBreak")
local QUIWidgetTraining = import("..widgets.QUIWidgetTraining")
local QQuickWay = import("...utils.QQuickWay")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIHeroModel = import("...models.QUIHeroModel")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QGemstoneController = import("..controllers.QGemstoneController")
local QUIDialogHeroGemstoneDetail = import("..dialogs.QUIDialogHeroGemstoneDetail")
local QUIWidgetMountBox = import("..widgets.mount.QUIWidgetMountBox")
local QUIWidgetHeroMagicHerb = import("..widgets.QUIWidgetHeroMagicHerb")
local QUIWidgetArtifactBox = import("..widgets.artifact.QUIWidgetArtifactBox")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")
local QUIDialogHeroSparDetail = import("..dialogs.QUIDialogHeroSparDetail")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetSoulSpiritHead = import("..widgets.QUIWidgetSoulSpiritHead")
local QUIWidgetSwitchBtn = import("..widgets.QUIWidgetSwitchBtn")

QUIDialogHeroInformation.HERO_DETAIL = "HERO_DETAIL" --魂师详细面板
QUIDialogHeroInformation.HERO_CARD = "HERO_CARD" --装备卡牌
QUIDialogHeroInformation.EQUIPMENT_DETAIL = "EQUIPMENT_DETAIL" --装备详细面板
QUIDialogHeroInformation.HERO_UPGRADE = "HERO_UPGRADE" --升级详细面板
QUIDialogHeroInformation.HERO_SKILL = "HERO_SKILL" --技能详细面板
QUIDialogHeroInformation.HERO_COMBINATION = "HERO_COMBINATION" --组合详细面板
QUIDialogHeroInformation.HERO_TRAINING = "HERO_TRAINING" --培养详细面板
QUIDialogHeroInformation.HERO_GLYPH = "HERO_GLYPH" --雕纹详细面板
QUIDialogHeroInformation.HERO_REFINE = "HERO_REFINE" --洗炼详细面板
QUIDialogHeroInformation.HERO_MAGICHERB = "HERO_MAGICHERB" --仙品详细面板

QUIDialogHeroInformation.NUMBER_TIME = 1


function QUIDialogHeroInformation:ctor(options)
    local ccbFile = "ccb/Dialog_HeroInformation.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggereRight)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggereLeft)},
        -- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},

        {ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)}, 
        {ccbCallbackName = "onAdvance", callback = handler(self, self._onAdvance)}, --进阶 
        {ccbCallbackName = "onAwake", callback = handler(self, self._onAwake)}, --觉醒
        {ccbCallbackName = "onUpgrade", callback = handler(self, self._onUpgrade)}, --升级
        {ccbCallbackName = "onBreakthrough", callback = handler(self, self._onBreakthrough)}, --突破
        {ccbCallbackName = "onHeroCard", callback = handler(self, self._onHeroCard)}, --打开卡牌
        {ccbCallbackName = "onHeroIntroduction", callback = handler(self, self._onHeroIntroduction)}, --打开资料
        {ccbCallbackName = "onTriggerCombination", callback = handler(self, self._onTriggerCombination)}, --打开组合
        {ccbCallbackName = "onSkill", callback = handler(self, self._onSkill)}, --打开技能
        {ccbCallbackName = "onTriggerTraining", callback = handler(self, self._onTriggerTraining)}, --打开培养
        {ccbCallbackName = "onTriggerAptitude", callback = handler(self, self._onTriggerAptitude)}, --点击资质
        {ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)}, -- 打开成长大师
        {ccbCallbackName = "onTriggerGlyph", callback = handler(self, self._onTriggerGlyph)}, -- 打开雕纹
        {ccbCallbackName = "onTriggerMagicHerb", callback = handler(self, self._onTriggerMagicHerb)}, -- 打开仙品
        {ccbCallbackName = "onTriggerCard", callback = handler(self, self._onTriggerShowHero)}, -- 打开资料
        {ccbCallbackName = "onTriggerDoComment", callback = handler(self, self._onTriggerDoComment)}, -- 打开评论
        {ccbCallbackName = "onTriggerClickSkin", callback = handler(self, self._onTriggerClickSkin)}, -- 打开评论
        {ccbCallbackName = "onGemstoneQuickChange", callback = handler(self, self._onGemstoneQuickChange)}, -- 打开魂骨一键交换
        {ccbCallbackName = "onSuperReduce", callback = handler(self, self._onSuperReduce)}, -- SS魂师满星降星

    }
    QUIDialogHeroInformation.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroOverView()
    CalculateUIBgSize(self._ccbOwner.sp_background)
    CalculateUIBgSize(self._ccbOwner.node_super_effect, UI_VIEW_MIN_WIDTH)

    self.winSize = CCDirector:sharedDirector():getWinSize()
    self.heroRunningAniamtion = false

    ui.tabButton(self._ccbOwner.tab_skill, "技能")
    ui.tabButton(self._ccbOwner.tab_upgrade, "升级")
    ui.tabButton(self._ccbOwner.tab_peiyang, "培养")
    ui.tabButton(self._ccbOwner.tab_combination, "宿命")
    ui.tabButton(self._ccbOwner.tab_glyph, "体技")
    ui.tabButton(self._ccbOwner.tab_MagicHerb, "仙品")
    ui.tabButton(self._ccbOwner.tab_heroIntroduction, "资料")
    local tabs = {}
    table.insert(tabs, self._ccbOwner.tab_skill)
    table.insert(tabs, self._ccbOwner.tab_upgrade)
    table.insert(tabs, self._ccbOwner.tab_peiyang)
    table.insert(tabs, self._ccbOwner.tab_combination)
    table.insert(tabs, self._ccbOwner.tab_glyph)
    table.insert(tabs, self._ccbOwner.tab_MagicHerb)
    table.insert(tabs, self._ccbOwner.tab_heroIntroduction)
    self._tabManager = ui.tabManager(tabs)

    if self._switchBtn == nil then
        self._switchBtn = QUIWidgetSwitchBtn.new({isBig = true})
        self._switchBtn:addEventListener(QUIWidgetSwitchBtn.EVENT_CLICK, handler(self, self._onTriggerSwtich))
        self._ccbOwner.node_switch:addChild(self._switchBtn, -1) 
        self._switchBtn:setInfo({closeFont = "装备", openFont = "魂骨", isOpen = true})
    end

    self._information = QUIWidgetHeroInformation.new({parent = self})
    self._information:setBackgroundVisible(false)
    self._information:changeNameNodeParent(self._ccbOwner.node_name)
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

    --装备控制器
    self._equipmentUtils = QUIWidgetHeroEquipment.new()
    self:getView():addChild(self._equipmentUtils) --此处添加至节点没有显示需求
    self._equipmentUtils:setUI(self._equipBox)

    --宝石控制器
    self._gemstoneBoxs = {}
    for i = 1, 4 do
        self._gemstoneBoxs[i] = QUIWidgetGemstonesBox.new()
        self._gemstoneBoxs[i]:setNameVisible(true)
        setShadow4(self._ccbOwner["tf_gemstone_name"..i], nil, ccc3(239,224,198))
        self._ccbOwner["tf_gemstone_name"..i]:setFontSize(18)
        self._gemstoneBoxs[i]:setNameNode(self._ccbOwner["tf_gemstone_name"..i])
        self._gemstoneBoxs[i]:setPos(i)
        self._ccbOwner["node_gemstone"..i]:addChild(self._gemstoneBoxs[i])
    end
    --晶石
    self._sparBoxs = {}
    local sparLock = app.unlock:checkLock("UNLOCK_ZHUBAO", false)
    if sparLock then
        for i = 1, 2 do
            self._sparBoxs[i] = QUIWidgetSparBox.new()
            self._ccbOwner["node_spar"..i]:addChild(self._sparBoxs[i])
            setShadow4(self._ccbOwner["tf_spar_name"..i], nil, ccc3(239,224,198))
            self._ccbOwner["tf_spar_name"..i]:setFontSize(18)
            self._sparBoxs[i]:setNameNode(self._ccbOwner["tf_spar_name"..i])
        end
        for i = 1, 4 do
            local positionY1 = i > 2 and -47 or 72
            self._ccbOwner["node_gemstone"..i]:setPositionY(positionY1)
        end
        self._ccbOwner.node_gemstone_bg:setVisible(false)
        self._ccbOwner.node_spar:setVisible(true)
    else
        for i = 1, 4 do
            local positionY1 = i > 2 and -115 or 30
            self._ccbOwner["node_gemstone"..i]:setPositionY(positionY1)
            self._ccbOwner["node_gemstone"..i]:setScale(1)
        end
    end
    self._gemstoneController = QGemstoneController.new()
    self._gemstoneController:setBoxs(self._gemstoneBoxs, self._sparBoxs)

    for i = 1, 6 do
        self._ccbOwner["node_equip"..i]:setScale(1)
        self._equipBox[i]:setBoxScale(1)
    end

    local mountLock = app.unlock:checkLock("UNLOCK_ZUOQI", false)
    local artifactLock = app.unlock:checkLock("UNLOCK_ARTIFACT", false)
    if mountLock or artifactLock then
        -- 暗器
        if mountLock then
            self._mountBox = QUIWidgetMountBox.new()
            self._mountBox:addEventListener(self._mountBox.MOUNT_EVENT_CLICK, handler(self, self.onEvent))
            self._ccbOwner.AccessoryBox1:addChild(self._mountBox)
        end
        --武魂真身
        if artifactLock then
            self._artifactBox = QUIWidgetArtifactBox.new()
            self._artifactBox:addEventListener(self._artifactBox.ARTIFACT_EVENT_CLICK, handler(self, self.onEvent))
            self._artifactBox:setVisible(false)
            self._ccbOwner.AccessoryBox2:addChild(self._artifactBox)
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

    if remote.soulSpirit:checkSoulSpiritUnlock() then
        self._ccbOwner.node_soulSpirit:setVisible(true)
        self._soulSpiritBox = QUIWidgetSoulSpiritHead.new()
        self._soulSpiritBox:addEventListener(QUIWidgetSoulSpiritHead.EVENT_SOULSPIRIT_HEAD_CLICK, handler(self, self.onEvent))
        self._ccbOwner.node_soulSpirit:removeAllChildren()
        self._ccbOwner.node_soulSpirit:addChild(self._soulSpiritBox)
        -- self._soulSpiritBox:setScale(0.6)
        self._soulSpiritBox:setInfo()
    else
        self._ccbOwner.node_soulSpirit:setVisible(false)
    end

    if options ~= nil and options.hero ~= nil and options.pos ~= nil then
        self._pos = options.pos
        self._herosID = options.hero
        --检查魂师ID 是否存在了 不存在则删除掉
        local selectId = self._herosID[self._pos]
        local herosId = {}
        self._pos = nil
        for _,heroId in ipairs(self._herosID) do
            if remote.herosUtil:getHeroByID(heroId) ~= nil then
                table.insert(herosId, heroId)
                if heroId == selectId then
                    self._pos = #herosId
                end
            end
        end
        self._herosID = herosId
        if self._pos == nil then
            self._pos = 1
        end
    end
    if options ~= nil and options.detailType ~= nil then
        self._detailType = options.detailType
    end
    if options ~= nil and options.isQuickWay ~= nil then
        self._isQuickWay = options.isQuickWay
    end

    if #self._herosID == 1 then
        self._ccbOwner.arrowLeft:setVisible(false)
        self._ccbOwner.arrowRight:setVisible(false)
    end

    if app.unlock:getUnlockGlyph() == false or not ENABLE_GLYPH then
        self._ccbOwner.btn_glyph:setVisible(false)
    else
        self._ccbOwner.btn_glyph:setVisible(true)
    end

    if remote.magicHerb:checkMagicHerbUnlock() == false then
        self._ccbOwner.btn_MagicHerb:setVisible(false)
    else
        self._ccbOwner.btn_MagicHerb:setVisible(true)
    end

    local proxy = CCBProxy:create()
    local ccbClientOwner = {}
    self._aptitudePrompt = CCBuilderReaderLoad("ccb/Widget_TreasureChestDraw_Prompt.ccbi", proxy, ccbClientOwner)
    self._ccbOwner.prompt:addChild(self._aptitudePrompt)
    self._aptitudePrompt:setVisible(false)

    self._forceUpdate = QTextFiledScrollUtils.new()

    self._swtichState = self:getOptions().swtichState or false

    --self._statusPosX = self._ccbOwner.sp_status_light:getPositionX()
    self._statusWidth = self._ccbOwner.status_bar:getContentSize().width

    -- 初始化进度条
    if not self._percentBarClippingNode then
        self._totalStencilPosition = self._ccbOwner.sp_exp_bar:getPositionX() -- 这个坐标必须sp_exp_bar节点的锚点为(0, 0.5)
        self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_exp_bar)
        self._totalStencilWidth = self._ccbOwner.sp_exp_bar:getContentSize().width * self._ccbOwner.sp_exp_bar:getScaleX()
    end
end

function QUIDialogHeroInformation:viewDidAppear()
    QUIDialogHeroInformation.super.viewDidAppear(self)
    self._equipmentUtils:addEventListener(QUIWidgetEquipmentBox.EVENT_EQUIPMENT_BOX_CLICK, handler(self, self.onEvent))

    self._gemstoneController:addEventListener(QUIWidgetGemstonesBox.EVENT_CLICK, handler(self, self.onEvent))
    self._gemstoneProxy = cc.EventProxy.new(remote.gemstone)
    self._gemstoneProxy:addEventListener(remote.gemstone.EVENT_WEAR, handler(self, self.gemstoneWearHandler))

    self._mountProxy = cc.EventProxy.new(remote.mount)
    self._mountProxy:addEventListener(remote.mount.EVENT_WEAR, handler(self, self.mountWearHandler))

    self._artifactProxy = cc.EventProxy.new(remote.artifact)
    self._artifactProxy:addEventListener(remote.artifact.EVENT_WEAR, handler(self, self.artifactWearHandler))

    self._soulSpiritProxy = cc.EventProxy.new(remote.soulSpirit)
    self._soulSpiritProxy:addEventListener(remote.soulSpirit.EVENT_WEAR, handler(self, self.soulSpiritWearHandler))

    self._sparProxy = cc.EventProxy.new(remote.spar)
    self._sparProxy:addEventListener(remote.spar.EVENT_WEAR_SPAR_SUCCESS, handler(self, self.sparWearHandler))

    self._heroProxy = cc.EventProxy.new(remote.herosUtil)
    self._heroProxy:addEventListener(QHerosUtils.EVENT_HERO_PROP_UPDATE, handler(self, self.heroPropUpdateHandler))
    self._heroProxy:addEventListener(QHerosUtils.EVENT_HERO_EXP_UPDATE, handler(self, self.heroPropUpdateHandler))
    self._heroProxy:addEventListener(QHerosUtils.EVENT_HERO_LEVEL_UPDATE, handler(self, self.heroPropUpdateHandler))
    self._heroProxy:addEventListener(QHerosUtils.BATTLEFORCE_UPDATE, handler(self, self.heroPropUpdateHandler))
    self._heroProxy:addEventListener(QHerosUtils.EVENT_HERO_BREAK_BY_ONEKEY, handler(self, self._onBreakthroughEffect))

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(QRemote.HERO_UPDATE_EVENT, handler(self, self.onEvent))
    
    self._userProxy = cc.EventProxy.new(remote.user)
    self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))
    
    self._itemProxy = cc.EventProxy.new(remote.items)
    self._itemProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))

    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.HERO_ADVANCE_SUCCESS, self._onAdvanceSucc, self)

    self:refreshHero()
    self:addBackEvent()
    -- self:guideGrow() --引导成长大师
    self:showGemstoneByState()
    self:showRunningAction(true)

end
function QUIDialogHeroInformation:showRunningAction(fist)

    self.heroRunningAniamtion = true

    local posx,posy = self._ccbOwner.node_herointroduce:getPosition()
    self._ccbOwner.node_herointroduce:setPosition(ccp(posx + self.winSize.width,posy))

    local array1 = CCArray:create()
    array1:addObject(CCCallFunc:create(function()
            makeNodeFadeToOpacity(self._ccbOwner.node_herointroduce,250/770,255)
        end))
    array1:addObject(CCEaseSineOut:create(CCMoveBy:create(250/770, ccp(-self.winSize.width,0))))

    local array2 = CCArray:create()
    array2:addObject(CCSpawn:create(array1))
    array2:addObject(CCCallFunc:create(function()
        self.heroRunningAniamtion = false
        if fist then
            self:guideGrow() --引导成长大师
        end        
        self._information:startAutoPlay(10)

    end))
    self._ccbOwner.node_herointroduce:runAction(CCSequence:create(array2))    
end
function QUIDialogHeroInformation:viewWillDisappear()
    QUIDialogHeroInformation.super.viewWillDisappear(self)
    self._heroProxy:removeAllEventListeners()
    self._equipmentUtils:removeAllEventListeners()
    self._remoteProxy:removeAllEventListeners()
    self._userProxy:removeAllEventListeners()
    self._itemProxy:removeAllEventListeners()
    self._gemstoneController:removeAllEventListeners()
    self._mountProxy:removeAllEventListeners()
    self._artifactProxy:removeAllEventListeners()
    self._soulSpiritProxy:removeAllEventListeners()

    if self._mountBox ~= nil then
        self._mountBox:removeAllEventListeners()
    end
    if self._artifactBox ~= nil then
        self._artifactBox:removeAllEventListeners()
    end
    if self._soulSpiritBox ~= nil then
        self._soulSpiritBox:removeAllEventListeners()
    end

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.HERO_ADVANCE_SUCCESS, self._onAdvanceSucc, self)

    if self._breakthrough ~= nil then
        self._breakthrough:removeAllEventListeners()
        self._breakthrough = nil
    end
    if self._gemstoneProxy ~= nil then
        self._gemstoneProxy:removeAllEventListeners()
        self._gemstoneProxy = nil
    end
    if self._grade ~= nil then
        self._grade:removeAllEventListeners()
        self._grade = nil
    end

    self._equipBox = {}

    if self._expHandler ~= nil then
        scheduler.unscheduleGlobal(self._expHandler)
        self._expHandler = nil
    end
    if self._alertHandler ~= nil then
        scheduler.unscheduleGlobal(self._alertHandler)
        self._alertHandler = nil
    end
    if self._animationHandler ~= nil then
        scheduler.unscheduleGlobal(self._animationHandler)
        self._animationHandler = nil
    end
    if self._gemstoneHandler ~= nil then
        scheduler.unscheduleGlobal(self._gemstoneHandler)
        self._gemstoneHandler = nil
    end
    if self._soulSpiritHandler ~= nil then
        scheduler.unscheduleGlobal(self._soulSpiritHandler)
        self._soulSpiritHandler = nil
    end
    self:removeBackEvent()

    if self._forceUpdate then
        self._forceUpdate:stopUpdate()
        self._forceUpdate = nil
    end
    remote.herosUtil:requestSkillUp()
    if self._wearEffectShow ~= nil then
        self._wearEffectShow:disappear()
        self._wearEffectShow = nil
    end

    if self._masterDialog ~= nil then
        self._masterDialog:removeAllEventListeners()
        self._masterDialog = nil
    end

    if self._training then
        self._training:removeAllEventListeners()
        self._training = nil
    end
end

function QUIDialogHeroInformation:_exitFromBattle()
    self:refreshHero()
end

function QUIDialogHeroInformation:refreshHero()
    if self._pos ~= nil and self._herosID ~= nil then
        self:showInformation(remote.herosUtil:getHeroByID(self._herosID[self._pos]))
    end
end

function QUIDialogHeroInformation:onEvent(event)
    if event.name == QUIWidgetEquipmentBox.EVENT_EQUIPMENT_BOX_CLICK then
        local itemId = nil
        if event.info ~= nil then
            itemId = event.info.id
        end
        if itemId == nil then
            if event.type == EQUIPMENT_TYPE.JEWELRY1 then
                app.tip:floatTip("饰品戒指战队" .. tostring(app.unlock:getConfigByKey("UNLOCK_BADGE").team_level) .. "级解锁")
            elseif event.type == EQUIPMENT_TYPE.JEWELRY2 then
                app.tip:floatTip("饰品项链战队" .. tostring(app.unlock:getConfigByKey("UNLOCK_GAD").team_level) .. "级解锁")
            end
            return
        end
        app.sound:playSound("common_item")
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
            options = {itemId=itemId, equipmentPos = event.type, heros = self._herosID, pos = self._pos, parentOptions = self:getOptions(), isQuickWay = self._isQuickWay}})
    elseif event.name == QRemote.HERO_UPDATE_EVENT and self._isInAdvance ~= true then
        self:refreshHero()
    elseif event.name == remote.user.EVENT_USER_PROP_CHANGE then
        self:_checkTips()
    elseif event.name == remote.items.EVENT_ITEMS_UPDATE then
        self:_checkTips()
        self:_refreshGradInfo()
        if self._artifactBox ~= nil then
            self._artifactBox:refreshBox()
        end
    elseif event.name == QUIWidgetGemstonesBox.EVENT_CLICK then
        app.sound:playSound("common_item")
        if event.boxType == 1 then 
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSparDetail", 
                options = {sparPos = event.sparPos, heros = self._herosID, pos = self._pos, parentOptions = self:getOptions(), initTab = QUIDialogHeroSparDetail.TAB_DETAIL}})
        else
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroGemstoneDetail", 
                options = {gemstonePos = event.pos, heros = self._herosID, pos = self._pos, parentOptions = self:getOptions(), initTab = QUIDialogHeroGemstoneDetail.TAB_DETAIL}})
        end
    elseif self._mountBox ~= nil and event.name == self._mountBox.MOUNT_EVENT_CLICK then
        app.sound:playSound("common_item")
        local lockConfig = app.unlock:getConfigByKey("UNLOCK_ZUOQI")
        if lockConfig.hero_level > self._hero.level then
            app.tip:floatTip("魂师大人，魂师达到"..lockConfig.hero_level.."级后才能装备暗器")
            return
        end
        if event.mountId == nil then
            local haveMounts = remote.mount:getMountMap()
            if next(haveMounts) then
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountOverView", 
                    options = {actorId = self._herosID[self._pos], isSelect = true}})
            else
                app.tip:floatTip("没有可以装备的暗器~")
            end
        else
            --进入详细界面
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroMountDetail", 
                options = {heros = self._herosID, pos = self._pos, parentOptions = self:getOptions()}})
        end
    elseif self._artifactBox ~= nil and event.name == self._artifactBox.ARTIFACT_EVENT_CLICK then
        app.sound:playSound("common_item")
        local actorId = self._herosID[self._pos]
        local actorIds, pos = remote.artifact:getHerosAndPos(actorId)
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroArtifactDetail", 
            options = {heros = actorIds, pos = pos, parentOptions = self:getOptions()}})
    elseif event.name == QUIWidgetSoulSpiritHead.EVENT_SOULSPIRIT_HEAD_CLICK then
        local heroId = self._herosID[self._pos]
        if event.target._soulSpiritInfo then
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritDetail", 
                options={heroId = heroId, heroIdList = self._herosID}})
        else
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritOverView", 
                options = {heroId = heroId}})
        end
    end
end

function QUIDialogHeroInformation:guideGrow()
    local options = self:getOptions()
    if options.guideGrow == true then
        options.guideGrow = false
        self._guideGrowWidget = QUIWidget.new("ccb/Widget_NewBuilding_open2.ccbi")
        self._guideGrowWidget._ccbOwner.word:setString("请点击成长大师")
        self._guideGrowWidget._ccbOwner.controller_btn:setVisible(false)
        self._guideGrowWidget:setPositionX(-120)
        self._guideGrowWidget:setPositionY(195)
        self:getView():addChild(self._guideGrowWidget)
    end
end

function QUIDialogHeroInformation:showSabc()
    if not self._hero.actorId then return end
    local aptitudeInfo = db:getActorSABC(self._hero.actorId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIDialogHeroInformation:showInformation(hero)
    local isSwitchHero = (self._hero ~= nil and self._hero.actorId ~= hero.actorId)
    self._hero = hero
    self._actorId = self._hero.actorId
    self._heroModel = remote.herosUtil:createHeroProp(self._hero)
    self._oldHero = clone(hero)
    self._targetExp = 0
    self:showBaseInfo()
    self:_checkTips()

    local characherConfig = QStaticDatabase:sharedDatabase():getCharacterByID(self._hero.actorId)
    self._information:setAvatar(self._hero.actorId, 1.287 * 1.1)
    self._ccbOwner.lab_jobTitle:setString(characherConfig.label or "")
    
    local bgPath = nil
    if characherConfig.aptitude == APTITUDE.SSR then
        bgPath = QResPath("hero_background")[4]
        self._ccbOwner.node_super_effect:setVisible(true)
        self._ccbOwner.fca_ssr_bg_effect:setVisible(true)
        self._ccbOwner.fca_ss_bg_effect:setVisible(false)
    elseif characherConfig.aptitude == APTITUDE.SS then
        bgPath = QResPath("hero_background")[3]
        self._ccbOwner.node_super_effect:setVisible(true)
        self._ccbOwner.fca_ss_bg_effect:setVisible(true)
        self._ccbOwner.fca_ssr_bg_effect:setVisible(false)
    else
        local isDay = app:checkDayNightTime()
        if isDay then
            bgPath = QResPath("hero_background")[1]
        else
            bgPath = QResPath("hero_background")[2]
        end
        self._ccbOwner.node_super_effect:setVisible(false)
    end

    local texture = CCTextureCache:sharedTextureCache():addImage(bgPath)
    if texture then
        self._ccbOwner.sp_background:setTexture(texture)
    end

    self._ccbOwner.node_artifact:removeAllChildren()
    if self._hero.artifact then
        if characherConfig.backSoulFile then
            local artifact = QUIWidgetFcaAnimation.new(characherConfig.backSoulFile, "actor")
            if artifact:getSkeletonView().isFca then
                artifact:setScale(0.37)
            else
                artifact:setScale(1.2)
                artifact:getSkeletonView():flipActor()
                artifact:attachEffectToDummy(characherConfig.backSoulShowEffect)
                if characherConfig.backSoulFile_xy then
                    local tbl = string.split(characherConfig.backSoulFile_xy,",")
                    artifact:setPosition(ccp(tonumber(tbl[1]), tonumber(tbl[2])))
                end
            end
            self._ccbOwner.node_artifact:addChild(artifact)
            --[[
                1星 70%
                3星 80%
                5星 90%
                6星 100%
            --]]
            if hero.artifact then
                local artifactLevel = hero.artifact.artifactBreakthrough or 1
                if artifactLevel == 6 then
                    self._ccbOwner.node_artifact:setScale(1)
                elseif artifactLevel == 5 then
                    self._ccbOwner.node_artifact:setScale(0.96)
                elseif artifactLevel == 4 then
                    self._ccbOwner.node_artifact:setScale(0.93)
                elseif artifactLevel == 3 then
                    self._ccbOwner.node_artifact:setScale(0.90)   
                elseif artifactLevel == 2 then
                    self._ccbOwner.node_artifact:setScale(0.85)                                        
                else
                    self._ccbOwner.node_artifact:setScale(0.8)
                end
            end
        end
    end
    --xurui: 皮肤按钮
    self._ccbOwner.node_hero_skin:setVisible(false)
    if remote.heroSkin:checkUnlock() then
        local skinConfig = remote.heroSkin:getHeroSkinConfigListById(self._hero.actorId, true)
        local isShowSkinBtn = false
        for _,v in pairs(skinConfig) do
            if v.is_nature == 1 then
                self._ccbOwner.node_hero_skin:setVisible(true)
                break
            end
        end
        -- if q.isEmpty(skinConfig) == false then
        --     self._ccbOwner.node_hero_skin:setVisible(true)
        -- end

        local isTip = remote.heroSkin:checkHeroHaveSkinItem(self._hero.actorId)
        self._ccbOwner.node_tip_skin:setVisible(isTip)
    end

    --xurui 显示宿命
    self._ccbOwner.but_suming:setVisible(true)
    local combination = QStaticDatabase:sharedDatabase():getCombinationInfoByHeroId(self._hero.actorId)
    if next(combination) == nil or ENABLE_COMBINATION == false then 
        self._ccbOwner.but_suming:setVisible(false)
        if self._detailType == QUIDialogHeroInformation.HERO_COMBINATION then
            self._detailType = nil
        end
        if self._combination then
            self._combination:removeFromParent()
            self._combination = nil
            self._detailView = nil
        end
    end

    -- 魂靈
    if self._soulSpiritBox then
        if self._hero.soulSpirit then
            self._soulSpiritBox:setInfo(self._hero.soulSpirit)
            if remote.soulSpirit:isGradeRedTipsById(self._hero.soulSpirit.id) then
                self._soulSpiritBox:setRedTips(true)
            end
        else
            self._soulSpiritBox:setInfo()
            if remote.soulSpirit:isFreeSoulSpirit() then
                self._soulSpiritBox:setRedTips(true)
            end
        end
    end

    --默认打开魂师技能界面
    if self._detailType == nil then
        self:_switchDetail(QUIDialogHeroInformation.HERO_SKILL)
    else
        self:_switchDetail(self._detailType)
    end

    if nil ~= characherConfig then 
        self._equipmentUtils:setHero(self._hero.actorId) -- 装备显示
        self._gemstoneController:setHero(self._hero.actorId)
        self._gemstoneController:checkSuitEffect()
        if self._mountBox ~= nil then
            self._mountBox:setHero(self._hero.actorId)
        end
        if self._artifactBox ~= nil then
            local artifactId = remote.artifact:getArtiactByActorId(self._hero.actorId)
            if artifactId then
                self._artifactBox:setVisible(true)
                self._artifactBox:setHero(self._hero.actorId)
            else
                self._artifactBox:setVisible(false)
            end
        end
    end
    self:showSabc()
    -- self:setHeroJobTitle()

    self:_refreshGradInfo()

    if self._introduce ~= nil and self._detailType == QUIDialogHeroInformation.HERO_DETAIL then
        self._introduce:setHero(self._hero,self._heroModel)
        self._introduceNeedRefresh = false
    elseif self._introduce then
        self._introduceNeedRefresh = true
    end
    if self._upgrade ~= nil and self._detailType == QUIDialogHeroInformation.HERO_UPGRADE  then
        self._upgrade:_saveExp()
        self._upgrade:showById(self._herosID[self._pos], self._ccbOwner.node_heroinformation:convertToWorldSpaceAR(ccp(0,0)), self._ccbOwner.tf_battleForce:convertToWorldSpaceAR(ccp(0,0)))
        self._upgradeNeedRefresh = false
    elseif self._upgrade then
        self._upgradeNeedRefresh = true
    end
    if self._skill ~= nil and isSwitchHero == true then
        if self._detailType == QUIDialogHeroInformation.HERO_SKILL then
            self._skill:setHero(self._hero.actorId)
            self._skillNeedRefresh = false
        elseif self._skill then
            self._skillNeedRefresh = true
        end
    end
    if self._glyph ~= nil and isSwitchHero == true then
        if self._detailType == QUIDialogHeroInformation.HERO_GLYPH then
            self._glyph:setHero(self._hero.actorId)
            self._glyphNeedRefresh = false
        elseif self._glyph then
            self._glyphNeedRefresh = true
        end
    end
    if self._combination ~= nil and self._detailType == QUIDialogHeroInformation.HERO_COMBINATION  then
        self._combination:setHero(self._hero.actorId)
        self._combinationNeedRefresh = false
    elseif self._combination then
        self._combinationNeedRefresh = true
    end
    if self._training ~= nil and self._detailType == QUIDialogHeroInformation.HERO_TRAINING  then
        self._training:update(self._hero.actorId)
        self._trainingNeedRefresh = false
    elseif self._training then
        self._trainingNeedRefresh = true
    end
    if self._magicHerb ~= nil and self._detailType == QUIDialogHeroInformation.HERO_MAGICHERB  then
        self._magicHerb:update(self._hero.actorId)
        self._magicHerb:saveListInfo(self._herosID, self._pos, self:getOptions())
        self._magicHerbNeedRefresh = false
    elseif self._magicHerb then
        self._magicHerbNeedRefresh = true
    end

    -- Show enchant level 
    self._ccbOwner.enchantNode:setVisible(false)
    if self._equipBox[5]:getItemId() ~= nil then
        self._equipBox[5]:showEnchantIcon(true, remote.herosUtil:getWearByItem(self._hero.actorId, self._equipBox[5]:getItemId()).enchants or 0, 0.7)
    end
    if self._equipBox[6]:getItemId() ~= nil then
        self._equipBox[6]:showEnchantIcon(true, remote.herosUtil:getWearByItem(self._hero.actorId, self._equipBox[6]:getItemId()).enchants or 0, 0.7)
    end

    -- 显示成长大师
    -- self._ccbOwner.master:setVisible(not self._swtichState and app.master:checkAllMasterUnlock())
    self:showGemstoneByState()

    self:setBtnPosition()
end

--显示魂师的基本信息 等级 经验等
function QUIDialogHeroInformation:showBaseInfo()
    self._ccbOwner.level_prior:setString(self._oldHero.level)
    self._ccbOwner.level_prior2:setString(self._oldHero.level)
    self._ccbOwner.level_rear:setString("/"..tostring(remote.herosUtil:getHeroMaxLevel()))
    q.autoLayerNode({self._ccbOwner.level_prior2, self._ccbOwner.level_rear}, "x")
    self._maxexp = db:getExperienceByLevel(self._oldHero.level)
    self._ccbOwner.tf_exp:setString(self._oldHero.exp.."/"..tostring(self._maxexp))
    local stencil = self._percentBarClippingNode:getStencil()
    local curProportion = self._oldHero.exp/self._maxexp
    stencil:setPositionX(-self._totalStencilWidth + curProportion*self._totalStencilWidth)
    self._battleforce = self._heroModel:getBattleForce(true)
    -- self._battleforce = self._heroModel:getBattleForce()
    self._ccbOwner.tf_battleForce:setString(self._battleforce)
    local fontInfo = db:getForceColorByForce(self._battleforce)
    if fontInfo ~= nil then
        local color = string.split(fontInfo.force_color, ";")
        local fontColor = ccc3(color[1], color[2], color[3])
        self._ccbOwner.tf_battleForce:setColor(fontColor)
    end
end

function QUIDialogHeroInformation:_refreshGradInfo()
    self._ccbOwner.node_icon:removeAllChildren()
    self._ccbOwner.sp_super_icon:setVisible(false)
    local characherConfig = db:getCharacterByID(self._hero.actorId)
    if characherConfig.aptitude == APTITUDE.SS or characherConfig.aptitude == APTITUDE.SSR then
        self._ccbOwner.node_plus:setVisible(false)
        self._ccbOwner.sp_super_icon:setVisible(true)
        self._ccbOwner.node_super_reduce:setVisible(true)
    else
        self._ccbOwner.node_plus:setVisible(true)
        self._ccbOwner.node_super_reduce:setVisible(false)
    end

    self._gradeConfig = db:getGradeByHeroActorLevel(self._hero.actorId, self._hero.grade+1)
    local width = 0
    if self._gradeConfig ~= nil then
        -- 显示魂力精魄
        if self._gradeConfig.super_devour_consume and self._gradeConfig.super_devour_consume > 0 then
            local expCount = self._gradeConfig.super_devour_consume
            local exp = self._hero.superHeroExp or 0
            self._ccbOwner.status1_tf:setString(exp.."/"..expCount)
            if exp <= 0 then
                width = 0
                self._ccbOwner.status_bar:setScaleX(0.01)
            else 
                width = self._statusWidth*exp/expCount
                self._ccbOwner.status_bar:setScaleX(exp/expCount)
            end
        else
            local itemBox = QUIWidgetItemsBox.new()
            itemBox:setGoodsInfo(self._gradeConfig.soul_gem, ITEM_TYPE.ITEM, 0)
            itemBox:hideSabc()
            itemBox:hideTalentIcon()
            itemBox:setScale(0.5)
            self._ccbOwner.node_icon:addChild(itemBox)
            self._ccbOwner.node_plus:setVisible(true)

            local soulNum = remote.items:getItemsNumByID(self._gradeConfig.soul_gem) -- 魂力精魄的数量
            local soulGemCount = self._gradeConfig.soul_gem_count or 1
            self._ccbOwner.status1_tf:setString(soulNum.."/"..soulGemCount)
            if soulNum >= soulGemCount then
                soulNum = soulGemCount
            end
            if soulNum <= 0 then
                width = 0
                self._ccbOwner.status_bar:setScaleX(0.01)
            else 
                width = self._statusWidth*soulNum/soulGemCount
                self._ccbOwner.status_bar:setScaleX(soulNum/soulGemCount)
            end
        end

        self._ccbOwner.btn_grade:setVisible(true)
        self._ccbOwner.node_super_reduce:setVisible(false)
        self._ccbOwner.node_bar_status:setPositionX(-227)

        if characherConfig.aptitude == APTITUDE.SS or characherConfig.aptitude == APTITUDE.SSR then
            self._ccbOwner.node_bar_status:setPositionX(-195)
        end
    else
        width = 1
        self._ccbOwner.btn_grade:setVisible(false)
        self._ccbOwner.status_bar:setScaleX(1)
        self._ccbOwner.status1_tf:setString("已升星到顶级")
        self._ccbOwner.node_bar_status:setPositionX(-165)
    end
    --self._ccbOwner.sp_status_light:setPositionX(self._statusPosX+width)
end

-- function QUIDialogHeroInformation:setHeroJobTitle(grade)
--     self._ccbOwner.lab_jobTitle:setVisible(false)
--     if self._hero then
--         local stringTilte = remote.herosUtil:getJobTitleByGradeLevelNum(self._hero.grade+1)
--         if stringTilte then 
--             self._ccbOwner.lab_jobTitle:setVisible(true)
--             self._ccbOwner.lab_jobTitle:setString(stringTilte)
--         end
--     end
-- end

function QUIDialogHeroInformation:_addIcon(node,itemID)
    local iconURL = QStaticDatabase:sharedDatabase():getItemByID(tonumber(itemID)).icon
    if iconURL ~= nil then
        local texture = CCTextureCache:sharedTextureCache():addImage(iconURL)
        local ccsprite = CCSprite:createWithTexture(texture)
    end
    if ccsprite ~= nil then
        node:addChild(ccsprite)
    end
end

function QUIDialogHeroInformation:setBtnPosition()

    local posY = self._ccbOwner.btn_skill:getPositionY()
    if self._ccbOwner.btn_skill:isVisible() == true then
        self._ccbOwner.btn_skill:setPositionY(posY)
        posY = posY - 67
    end
    if self._ccbOwner.btn_upgrade:isVisible() == true then
        self._ccbOwner.btn_upgrade:setPositionY(posY)
        posY = posY - 67
    end
    if self._ccbOwner.but_peiyang:isVisible() == true then
        self._ccbOwner.but_peiyang:setPositionY(posY)
        posY = posY - 67
    end
    if self._ccbOwner.but_suming:isVisible() == true then
        self._ccbOwner.but_suming:setPositionY(posY)
        posY = posY - 67
    end
    if self._ccbOwner.btn_glyph:isVisible() == true then
        self._ccbOwner.btn_glyph:setPositionY(posY)
        posY = posY - 67
    end
    if self._ccbOwner.btn_MagicHerb:isVisible() == true then
        self._ccbOwner.btn_MagicHerb:setPositionY(posY)
        posY = posY - 67
    end
    if self._ccbOwner.btn_intro:isVisible() == true then
        self._ccbOwner.btn_intro:setPositionY(posY)
        posY = posY - 67
    end
    -- if self._ccbOwner.btn_master:isVisible() == true then
    --     self._ccbOwner.btn_master:setPositionY(posY)
    --     posY = posY - 79
    -- end
end

--[[
    穿装备效果显示
]]
function QUIDialogHeroInformation:_wearEffect(itemId)
    app.sound:playSound("hero_put_on")
    if self._wearEquipEffect == nil then
        self._wearEquipEffect = QUIWidgetAnimationPlayer.new()
        self:getView():addChild(self._wearEquipEffect)
    end
    for _,box in pairs(self._equipBox) do
        if box:getItemId() == itemId then
            local p = box:convertToWorldSpaceAR(ccp(0, 0))
            p = self:getView():convertToNodeSpaceAR(p)
            self._wearEquipEffect:setPosition(p.x, p.y)
            self._wearEquipEffect:playAnimation("ccb/effects/EquipmentUpgarde.ccbi", nil, function()
                    self._equipmentUtils:refreshBox()
                end)
            break
        end
    end
    self._information:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY)

    local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)

    self:_showEffectToAvatar("生命：", itemInfo.hp)
    self:_showEffectToAvatar("攻击：", itemInfo.attack)
    self:_showEffectToAvatar("命中：", itemInfo.hit_rating)
    self:_showEffectToAvatar("闪避：", itemInfo.dodge_rating)
    self:_showEffectToAvatar("暴击：", itemInfo.critical_rating)
    self:_showEffectToAvatar("格挡：", itemInfo.block_rating)
    self:_showEffectToAvatar("攻速：", itemInfo.haste_rating)
    self:_showEffectToAvatar("物理防御：", itemInfo.armor_physical)
    self:_showEffectToAvatar("法术防御：", itemInfo.armor_magic)
    self:refreshHero()
end

function QUIDialogHeroInformation:_showEffectToAvatar(name,value)
    if value ~= nil then
        if type(value) == "number" then
            if value > 0 then
                self._information:playPropEffect(name.."+ "..value)
            end
        else
            self._information:playPropEffect(name.."+ "..value)
        end
    end
end

function QUIDialogHeroInformation:heroPropUpdateHandler(event)
    if event.actorId == self._herosID[self._pos] then
        if event.name == QHerosUtils.EVENT_HERO_PROP_UPDATE then 
            self._information:playPropEffect(event.value)
        elseif event.name == QHerosUtils.EVENT_HERO_LEVEL_UPDATE then
            self:nodeEffect(self._ccbOwner.level_prior)
            self._information:playLevelUp()
            self._equipmentUtils:refreshBox() 
            self._gemstoneController:refreshBox() 
            self._gemstoneController:checkSuitEffect()
            if self._mountBox ~= nil then
                self._mountBox:refreshBox()
            end
            if self._artifactBox ~= nil then
                self._artifactBox:refreshBox()
            end
            -- self:_checkTips()
        elseif event.name == QHerosUtils.EVENT_HERO_EXP_UPDATE then
            self:nodeEffect(self._ccbOwner.tf_exp)
            self:_expEffect(event.exp)
        elseif event.name == QHerosUtils.BATTLEFORCE_UPDATE then
            -- 战力滚动显示
            local hero = remote.herosUtil:getHeroByID(self._herosID[self._pos])
            local force = QActorProp.new(hero):getBattleForce(true)
            app.sound:playSound("force_add")
            self._forceUpdate:addUpdate(self._battleforce, force, handler(self, self._onForceUpdate), QUIDialogHeroInformation.NUMBER_TIME)
            self._battleforce = force
        end
        self:_checkTips()
    end
end

function QUIDialogHeroInformation:_onForceUpdate(value)
    self._ccbOwner.tf_battleForce:setString(tostring(math.ceil(value)))
end

--[[
    经验滚动效果显示
]]
function QUIDialogHeroInformation:_expEffect(exp)
    app.sound:playSound("hero_eat_off")
    self._runTime = 1
    self._targetExp = self._targetExp + exp
    self._expPreNum = math.floor(self._targetExp / (self._runTime*60))
    self._startTime = q.time()
    self._expEffectForEach = function ()
        if q.time() - self._startTime > self._runTime then
            if self._expHandler ~= nil then
                scheduler.unscheduleGlobal(self._expHandler)
                self._expHandler = nil
            end
            self._oldHero.exp = self._oldHero.exp + self._targetExp
            self._targetExp = 0
        else
            if self._targetExp > self._expPreNum then
                self._targetExp = self._targetExp - self._expPreNum
                self._oldHero.exp = self._oldHero.exp + self._expPreNum
            else
                self._oldHero.exp = self._oldHero.exp + self._targetExp
                self._targetExp = 0
            end
        end
        while true do
            local maxExp = QStaticDatabase:sharedDatabase():getExperienceByLevel(self._oldHero.level)
            if self._oldHero.exp >= maxExp then
                self._oldHero.exp = self._oldHero.exp - maxExp
                self._oldHero.level = self._oldHero.level + 1
            else
                break
            end
        end
        self._ccbOwner.level_prior:setString(self._oldHero.level)
        self._ccbOwner.level_prior2:setString(self._oldHero.level)
        self._ccbOwner.level_rear:setString("/"..tostring(remote.herosUtil:getHeroMaxLevel()))
        q.autoLayerNode({self._ccbOwner.level_prior2, self._ccbOwner.level_rear}, "x")
        self._maxexp = QStaticDatabase:sharedDatabase():getExperienceByLevel(self._oldHero.level)
        self._ccbOwner.tf_exp:setString(self._oldHero.exp.."/"..tostring(self._maxexp))
        local stencil = self._percentBarClippingNode:getStencil()
        local curProportion = self._oldHero.exp/self._maxexp
        stencil:setPositionX(-self._totalStencilWidth + curProportion*self._totalStencilWidth)
    end
    if self._expHandler == nil then
        self._expHandler = scheduler.scheduleGlobal(self._expEffectForEach,0)
    end
end

function QUIDialogHeroInformation:_checkTips()
    local isGrade, isAwake = remote.herosUtil:checkHerosGradeByID(self._hero.actorId)
    local isBreakthrough = remote.herosUtil:checkHerosBreakthroughByID(self._hero.actorId)
    self._ccbOwner.node_tips_breakthrough:setVisible(false)
    self._ccbOwner.node_tips_grade:setVisible(isGrade)
    self._ccbOwner.Button_awake:setVisible(isAwake)

    local skillCanUp,slotId,costCount = remote.herosUtil:checkHerosSkillByID(self._hero.actorId)
    if slotId ~= nil then
        skillCanUp = costCount <= remote.user.money
        local point, lastTime = remote.herosUtil:getSkillPointAndTime()
        local maxPoint = QVIPUtil:getSkillPointCount() or 0
        skillCanUp = skillCanUp and point >= maxPoint
    end
    self._ccbOwner.node_tips_skill:setVisible(skillCanUp)

    self._ccbOwner.node_tips_upgrade:setVisible(false)
    self._ccbOwner.node_tips_combination:setVisible(false)

    self._ccbOwner.node_tips_peiyang:setVisible(false)
    if app.unlock:getUnlockTraining() and remote.stores._trainTips == false then
        if remote.herosUtil:checkIdInTopN(self._hero.actorId) and remote.herosUtil:getUIHeroByID(self._hero.actorId):getCanTrain() then
            self._ccbOwner.node_tips_peiyang:setVisible(remote.user.trainMoney >= 500)
        end
    end 

    self._ccbOwner.node_tips_gemstone:setVisible(false)
    if not self._swtichState then
        if remote.herosUtil:checkHerosGemstoneRedTipsByID(self._hero.actorId) or remote.herosUtil:checkHerosSparRedTipsByID(self._hero.actorId) then
            self._ccbOwner.node_tips_gemstone:setVisible(true)
        end
    end
    local b = (remote.herosUtil:checkHerosEvolutionByID(self._hero.actorId) ~= nil) or remote.herosUtil:checkHerosBreakthroughByID(self._hero.actorId)
    self._ccbOwner.node_tips_equipment:setVisible(self._swtichState and b)
    self._ccbOwner.node_switch:setVisible(app.unlock:checkLock("UNLOCK_GEMSTONE"))

    self._ccbOwner.node_tips_glyph:setVisible( false )
    if app.unlock:getUnlockGlyph() and remote.redPoint.isShowGlyphRedPoint then
        self._ccbOwner.node_tips_glyph:setVisible( remote.user.glyphMoney > 5000 )
    end

    self._ccbOwner.node_tips_MagicHerb:setVisible( false )
    if remote.magicHerb:checkMagicHerbUnlock() and remote.herosUtil:checkHerosMagicHerbRedTipsByID(self._hero.actorId) then
        self._ccbOwner.node_tips_MagicHerb:setVisible( true )
    end
end

-- function QUIDialogHeroInformation:_isTrainFull(actorId)
--     local attributes = remote.herosUtil:getHeroByID(actorId).trainAttr or {}
--     local index = QStaticDatabase:sharedDatabase():getCharacterByID(actorId).train_id
--     local level = remote.herosUtil:getHeroByID(actorId).level

--     if (attributes["hp"] or 0) >= self:_hpUpperLimit(index, level)
--         and (attributes["attack"] or 0) >= self:_attackUpperLimit(index, level)
--         and (attributes["armorPhysical"] or 0) >= self:_physicalDefendUpperLimit(index, level)
--         and (attributes["armorMagic"] or 0) >= self:_magicalDefendUpperLimit(index, level) then
--         return true
--     else
--         return false
--     end
-- end

function QUIDialogHeroInformation:_hpUpperLimit(index, level)
    return QStaticDatabase:sharedDatabase():getTrainingAttribute(index, level)["hp_value"] or 0
end

function QUIDialogHeroInformation:_attackUpperLimit(index, level)
    return QStaticDatabase:sharedDatabase():getTrainingAttribute(index, level)["attack_value"] or 0
end

function QUIDialogHeroInformation:_physicalDefendUpperLimit(index, level)
    return QStaticDatabase:sharedDatabase():getTrainingAttribute(index, level)["armor_physical"] or 0
end

function QUIDialogHeroInformation:_magicalDefendUpperLimit(index, level)
    return QStaticDatabase:sharedDatabase():getTrainingAttribute(index, level)["armor_magic"] or 0
end

--切换详细信息面板
function QUIDialogHeroInformation:_switchDetail(detailType)
    if self._isRunAnimation == true then
        return
    end
    self._ccbOwner.level_prior2:setVisible(detailType == QUIDialogHeroInformation.HERO_UPGRADE)
    self._ccbOwner.level_rear:setVisible(detailType == QUIDialogHeroInformation.HERO_UPGRADE)
    self._ccbOwner.tf_exp:setVisible(detailType == QUIDialogHeroInformation.HERO_UPGRADE)
    self._ccbOwner.node_expBar:setVisible(detailType == QUIDialogHeroInformation.HERO_UPGRADE)
    if self._upgrade ~= nil and self._upgrade._saveExp then
        self._upgrade:_saveExp()
    end

    self._detailType = detailType
    if detailType == QUIDialogHeroInformation.HERO_DETAIL then
        if self._introduce == nil then
            self._introduce = QUIWidgetHeroIntroduce.new()
            self._introduce:setHero(self._hero,self._heroModel)
            self._ccbOwner.node_herointroduce:addChild(self._introduce,-1)
        elseif self._introduceNeedRefresh then
            self._introduce:setHero(self._hero,self._heroModel)
        end
        self._introduceNeedRefresh = false
        self:_switchDetailForAnimation(self._introduce)
        self._tabManager:selected(self._ccbOwner.tab_heroIntroduction)
    elseif detailType == QUIDialogHeroInformation.HERO_UPGRADE then
        if self._upgrade == nil then
            self._upgrade = QUIWidgetHeroUpgradeNew.new()
            self._upgrade:showById(self._herosID[self._pos], self._ccbOwner.node_heroinformation:convertToWorldSpaceAR(ccp(0,0)), self._ccbOwner.tf_battleForce:convertToWorldSpaceAR(ccp(0,0)))
            self._ccbOwner.node_herointroduce:addChild(self._upgrade,-1)
        elseif self._upgradeNeedRefresh then
            self._upgrade:_saveExp()
            self._upgrade:showById(self._herosID[self._pos], self._ccbOwner.node_heroinformation:convertToWorldSpaceAR(ccp(0,0)), self._ccbOwner.tf_battleForce:convertToWorldSpaceAR(ccp(0,0)))
        end
        self._upgradeNeedRefresh = false
        self:_switchDetailForAnimation(self._upgrade)
        self._tabManager:selected(self._ccbOwner.tab_upgrade)
    elseif detailType == QUIDialogHeroInformation.HERO_SKILL then
        if self._skill == nil then
            self._skill = QUIWidgetHeroSkillUpgrade.new()
            self._ccbOwner.node_herointroduce:addChild(self._skill,-1)
            self._skill:setHero(self._hero.actorId) 
        elseif self._skillNeedRefresh then
            self._skill:setHero(self._hero.actorId)
        end
        self._skillNeedRefresh = false
        self:_switchDetailForAnimation(self._skill)
        self._tabManager:selected(self._ccbOwner.tab_skill)
    elseif detailType == QUIDialogHeroInformation.HERO_GLYPH then
        if self._glyph == nil then
            self._glyph = QUIWidgetHeroGlyphUpgrade.new()
            self._ccbOwner.node_herointroduce:addChild(self._glyph,-1)
            self._glyph:setHero(self._hero.actorId)
        elseif self._glyphNeedRefresh then
            self._glyph:setHero(self._hero.actorId)
        end
        self._glyphNeedRefresh = false
        self:_switchDetailForAnimation(self._glyph)
        self._tabManager:selected(self._ccbOwner.tab_glyph)
    elseif detailType == QUIDialogHeroInformation.HERO_COMBINATION then
        -- self._ccbOwner.node_mask_btn:setVisible(false)
        if self._combination == nil then
            self._combination = QUIWidgetHeroCombination.new()
            self._ccbOwner.node_herointroduce:addChild(self._combination,-1)
            self._combination:setHero(self._hero.actorId)
        elseif self._combinationNeedRefresh then
            self._combination:setHero(self._hero.actorId)
        end
        self._combinationNeedRefresh = false
        self:_switchDetailForAnimation(self._combination)
        self._tabManager:selected(self._ccbOwner.tab_combination)
    elseif detailType == QUIDialogHeroInformation.HERO_TRAINING then
        if self._training == nil then
            self._training = QUIWidgetTraining.new()
            self._ccbOwner.node_herointroduce:addChild(self._training,-1)
            self._training:addEventListener(QUIWidgetTraining.CLICK_TRAIN_MASTER, handler(self, self._onTriggerMaster))
        elseif self._trainingNeedRefresh then
        end
        self._trainingNeedRefresh = false
        self._training:update(self._hero.actorId)
        self:_switchDetailForAnimation(self._training)
        self._tabManager:selected(self._ccbOwner.tab_peiyang)
    elseif detailType == QUIDialogHeroInformation.HERO_MAGICHERB then
        if self._magicHerb == nil then
            self._magicHerb = QUIWidgetHeroMagicHerb.new()
            self._ccbOwner.node_herointroduce:addChild(self._magicHerb,-1)
            self._magicHerb:setHero(self._hero.actorId) 
            self._magicHerb:saveListInfo(self._herosID, self._pos, self:getOptions())
        elseif self._magicHerbNeedRefresh then
            self._magicHerb:setHero(self._hero.actorId) 
            self._magicHerb:saveListInfo(self._herosID, self._pos, self:getOptions())
        end
        self._magicHerbNeedRefresh = false
        self:_switchDetailForAnimation(self._magicHerb)
        self._tabManager:selected(self._ccbOwner.tab_MagicHerb)
    end
    self:_checkTips()
end

function QUIDialogHeroInformation:_switchDetailForAnimation(view)
    if view == nil then return end

    if self._detailView == nil then
        self._detailView = view
        self._detailView:setVisible(true)
        self._detailView:setPosition(0, 0)
    elseif self._detailView == view then
        return        
    else
        self._detailView:setVisible(false)
        self._detailView = view
        self._detailView:setVisible(true)
    end
end

--根据状态显示宝石或者装备
function QUIDialogHeroInformation:showGemstoneByState()
    -- self._ccbOwner.btn_swtich:setHighlighted(self._swtichState)
    self._switchBtn:setState(self._swtichState)
    self._ccbOwner.node_gemstone:setVisible(self._swtichState)
    self._ccbOwner.node_equipment:setVisible(not self._swtichState)
    self._ccbOwner.node_breakthrough:setVisible(not self._swtichState)
    self._ccbOwner.node_soulSpirit:setVisible(not self._swtichState)
    if self._swtichState == true then
        self._ccbOwner.master:setVisible(app.master:checkGemstoneBreakMasterUnlock())
        self._ccbOwner.node_gemstone_change:setVisible(app.unlock:checkLock("GEMSTONE_QUICK_EXCHANGE"))
    else
        self._ccbOwner.master:setVisible(app.master:checkAllMasterUnlock())
        self._ccbOwner.node_gemstone_change:setVisible(false)
    end

    self._ccbOwner.node_tips_gemstone:setVisible(false)
    if not self._swtichState then
        if remote.herosUtil:checkHerosGemstoneRedTipsByID(self._hero.actorId) or remote.herosUtil:checkHerosSparRedTipsByID(self._hero.actorId) then
            self._ccbOwner.node_tips_gemstone:setVisible(true)
        end
    end
    local b = remote.herosUtil:checkHerosEvolutionByID(self._hero.actorId) ~= nil or remote.herosUtil:checkHerosBreakthroughByID(self._hero.actorId)
    self._ccbOwner.node_tips_equipment:setVisible(self._swtichState and b)

    self._ccbOwner.node_spar:setVisible(false)
    if self._swtichState and app.unlock:checkLock("UNLOCK_ZHUBAO", false) then 
        self._ccbOwner.node_spar:setVisible(true)
    end
end

function QUIDialogHeroInformation:_onTriggereRight()
    -- if self._ccbOwner.node_mask_btn:isVisible() == true then return end
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end

    app.sound:playSound("common_change")
    remote.herosUtil:requestSkillUp()
    local n = table.nums(self._herosID)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos + 1
        if self._pos > n then
            self._pos = 1
        end
        local options = self:getOptions()
        options.pos = self._pos
        self:showInformation(remote.herosUtil:getHeroByID(self._herosID[self._pos]))
        -- self:showRunningAction()
    end
end

function QUIDialogHeroInformation:_onTriggereLeft()
    -- if self._ccbOwner.node_mask_btn:isVisible() == true then return end
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end

    app.sound:playSound("common_change")
    remote.herosUtil:requestSkillUp()
    local n = table.nums(self._herosID)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos - 1
        if self._pos < 1 then
            self._pos = n
        end
        local options = self:getOptions()
        options.pos = self._pos
        self:showInformation(remote.herosUtil:getHeroByID(self._herosID[self._pos]))
        -- self:showRunningAction()
    end
end

function QUIDialogHeroInformation:_onPlus(event) 
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if q.buttonEventShadow(event, self._ccbOwner.node_plus) == false then return end
    if self.heroRunningAniamtion then return end
    app.sound:playSound("common_increase")
    local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._hero.actorId, self._hero.grade+1)
    if config == nil then 
        config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._hero.actorId, self._hero.grade)
    end
    QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, config.soul_gem, config.soul_gem_count, nil, false)
end

--进阶
function QUIDialogHeroInformation:_onAdvance(event)
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if q.buttonEventShadow(event, self._ccbOwner.node_advance) == false then return end
    if self.heroRunningAniamtion then return end
    app.sound:playSound("common_hero")
    remote.herosUtil:dispatchEvent({name = QHerosUtils.EVENT_HERO_EXP_CHECK})
    local characherConfig = db:getCharacterByID(self._hero.actorId)
    if characherConfig.aptitude == APTITUDE.SS or characherConfig.aptitude == APTITUDE.SSR then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSuperHeroGrade", 
            options = {actorId = self._herosID[self._pos]}}, {isPopCurrentDialog = false})
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroAdvance", 
            options = {actorId = self._herosID[self._pos]}}, {isPopCurrentDialog = false})
    end
end

function QUIDialogHeroInformation:_onAwake(event)
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if q.buttonEventShadow(event, self._ccbOwner.btn_awake) == false then return end
    if self.heroRunningAniamtion then return end
    app.sound:playSound("common_hero")
    remote.herosUtil:dispatchEvent({name = QHerosUtils.EVENT_HERO_EXP_CHECK})
    local characherConfig = db:getCharacterByID(self._hero.actorId)
    if characherConfig.aptitude == APTITUDE.SS or characherConfig.aptitude == APTITUDE.SSR then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSuperHeroGrade", 
            options = {actorId = self._herosID[self._pos]}}, {isPopCurrentDialog = false})
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroAdvance", 
            options = {actorId = self._herosID[self._pos]}}, {isPopCurrentDialog = false})
    end
end

function QUIDialogHeroInformation:_onAdvanceSucc(event)
    if self._gradeConfig.money > remote.user.money then
        QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
        return
    end
    self._isInAdvance = true
    local actorId = self._herosID[self._pos]
    app:getClient():grade(actorId, event.items, function(data)
            if self:safeCheck() then
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGrade",options = { 
                    actorId = self._herosID[self._pos], addGrade = event.addGrade, callback = handler(self, self.refreshHero)}},{isPopCurrentDialog = false})
                self._isInAdvance = false
                self:_checkTips()
            end
        end)
end

--突破
function QUIDialogHeroInformation:_onBreakthrough()
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    app.sound:playSound("common_hero")

    if app.unlock:checkLock("UNLOCK_YIJIANTUPO", false) == false then
        app.unlock:tipsLock("UNLOCK_YIJIANTUPO", nil, true)
        return
    end

    remote.herosUtil:dispatchEvent({name = QHerosUtils.EVENT_HERO_EXP_CHECK})
    local actorId = self._herosID[self._pos]
    local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
    local heroModel = remote.herosUtil:getUIHeroByID(actorId)
    local breakthroughInfo = QStaticDatabase:sharedDatabase():getBreakthroughByTalentLevel(characterInfo.talent, remote.herosUtil:getHeroByID(actorId).breakthrough + 1)
    if breakthroughInfo ~= nil then
        local items, needItems, canBreak, breakLevel = heroModel:getHeroMaxBreakLevelNeedItems()
        if breakLevel <= 0 and table.nums(needItems) <= 0 and not canBreak then
            app.tip:floatTip("战队等级不足，魂师无法突破到下一级")
            return
        else
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBreakthroughQuick", 
                options = {actorId = self._actorId, items = items, needItems = needItems, canBreak = canBreak, breakLevel = breakLevel}}) 
        end
    else
        app.tip:floatTip("已经突破到顶级")
    end
end

function QUIDialogHeroInformation:_onBreakthroughEffect(event)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBreakthrough", 
        options = { actorId = self._herosID[self._pos], oldHeroInfo = event.oldHeroInfo}}, {isPopCurrentDialog = false})
end

function QUIDialogHeroInformation:_onCheckSucc()
    self:_checkTips()
end 

--升级
function QUIDialogHeroInformation:_onUpgrade()
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if self._detailType ~= QUIDialogHeroInformation.HERO_UPGRADE then
        app.sound:playSound("common_switch")
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:setManyUIVisible()
        page.topBar:showWithHeroOverView()
        self._detailType = QUIDialogHeroInformation.HERO_UPGRADE
        self._options.detailType = self._detailType
        self:_switchDetail(self._detailType)    
    end
end

function QUIDialogHeroInformation:_onHeroCard()
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if self._detailType ~= QUIDialogHeroInformation.HERO_CARD then
        app.sound:playSound("common_switch")
        self._detailType = QUIDialogHeroInformation.HERO_CARD
        self._options.detailType = self._detailType
        self:_switchDetail(self._detailType)   
    end 
end

function QUIDialogHeroInformation:_onHeroIntroduction()
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if self._detailType ~= QUIDialogHeroInformation.HERO_DETAIL then
        app.sound:playSound("common_switch")
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:setManyUIVisible()
        page.topBar:showWithHeroOverView()
        remote.herosUtil:dispatchEvent({name = QHerosUtils.EVENT_HERO_EXP_CHECK})
        remote.herosUtil:requestSkillUp()
        self._detailType = QUIDialogHeroInformation.HERO_DETAIL
        self._options.detailType = self._detailType
        self:_switchDetail(self._detailType) 
    end    
end

function QUIDialogHeroInformation:_onTriggerCombination()
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if self._detailType ~= QUIDialogHeroInformation.HERO_COMBINATION then
        app.sound:playSound("common_switch")
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:setManyUIVisible()
        page.topBar:showWithHeroOverView()
        self._detailType = QUIDialogHeroInformation.HERO_COMBINATION
        self._options.detailType = self._detailType
        self:_switchDetail(self._detailType)  
    end    
end

function QUIDialogHeroInformation:_onSkill() 
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if self._detailType ~= QUIDialogHeroInformation.HERO_SKILL then
        app.sound:playSound("common_switch")
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:setManyUIVisible()
        page.topBar:showWithHeroOverView()
        remote.herosUtil:dispatchEvent({name = QHerosUtils.EVENT_HERO_EXP_CHECK})
        remote.herosUtil:requestSkillUp()
        self._detailType = QUIDialogHeroInformation.HERO_SKILL
        self._options.detailType = self._detailType
        self:_switchDetail(self._detailType)    
    end   
end

function QUIDialogHeroInformation:_onTriggerTraining() 
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if self._detailType ~= QUIDialogHeroInformation.HERO_TRAINING then
        app.sound:playSound("common_switch")
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:setManyUIVisible()
        page.topBar:showWithHeroOverView()
        self._detailType = QUIDialogHeroInformation.HERO_TRAINING
        self._options.detailType = self._detailType

        --xurui: WOW-13639 update scaling red tips
        if remote.stores._trainTips == false then
            remote.stores._trainTips = true
            local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
            if page and page._scaling and page._scaling._onUserDataUpdate then
                page._scaling:_onUserDataUpdate()
            end
        end
        self:_switchDetail(self._detailType)      
    end   
end

function QUIDialogHeroInformation:_onTriggerAptitude(eventType)
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if tonumber(eventType) == CCControlEventTouchUpInside or tonumber(eventType) == CCControlEventTouchDragOutside then
        self._aptitudePrompt:setVisible(false)
    else
        self._aptitudePrompt:setVisible(true)
    end
end

function QUIDialogHeroInformation:_onTriggerMaster(event)
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if event ~= nil then 
        app.sound:playSound("common_common")
    end
    if self._guideGrowWidget ~= nil then
        self:getView():removeChild(self._guideGrowWidget)
        self._guideGrowWidget = nil
    end
    local masterType = event.masterType or QUIHeroModel.EQUIPMENT_MASTER
    if event.name ~= QUIWidgetTraining.CLICK_TRAIN_MASTER and self._swtichState then
        masterType = QUIHeroModel.GEMSTONE_BREAK_MASTER
    end
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaster",
        options = {actorId=self._hero.actorId, masterType=masterType, pos = self._pos, parentOptions = self:getOptions(), heros = self._herosID, isQuickWay = self._isQuickWay}},{isPopCurrentDialog = true})
end

function QUIDialogHeroInformation:_onTriggerGlyph()
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if self._detailType ~= QUIDialogHeroInformation.HERO_GLYPH then
        app.sound:playSound("common_switch")
        remote.redPoint.isShowGlyphRedPoint = false
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:setManyUIVisible()
        page.topBar:showWithGlyph()
        self._detailType = QUIDialogHeroInformation.HERO_GLYPH
        self._options.detailType = self._detailType
        self:_switchDetail(self._detailType) 
    end      
end

function QUIDialogHeroInformation:_onTriggerSwtich(e)
    if self.heroRunningAniamtion then return end
    --检查是否解锁
    if (not self._swtichState) == true and app.unlock:checkLock("UNLOCK_GEMSTONE", true) == false then
        return
    end
    if e ~= nil then
        app.sound:playSound("common_menu")
    end
    self._swtichState = not self._swtichState
    self:getOptions().swtichState = self._swtichState
    self:showGemstoneByState()
end

function QUIDialogHeroInformation:_onTriggerMagicHerb()
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if self._detailType ~= QUIDialogHeroInformation.HERO_MAGICHERB then
        app.sound:playSound("common_switch")
        remote.redPoint.isShowMagicHerbRedPoint = false
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:setManyUIVisible()
        page.topBar:showWithHeroOverView()
        self._detailType = QUIDialogHeroInformation.HERO_MAGICHERB
        self._options.detailType = self._detailType
        self:_switchDetail(self._detailType) 
    end      
end

function QUIDialogHeroInformation:_onTriggerShowHero(event)
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if q.buttonEventShadow(event, self._ccbOwner.btn_card) == false then return end
    if self.heroRunningAniamtion then return end
    app.sound:playSound("common_small")
    remote.handBook:openMainDialog(self._actorId)
    -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroImageCard", 
    --     options = {actorId = self._actorId, herosID = self._herosID, pos = self._pos}}) 
end

function QUIDialogHeroInformation:_onTriggerDoComment(event)
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_doComment) == false then return end
    app.sound:playSound("common_small")
    if remote.handBook:getDoCommentFuncSwitch() then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookBBS", 
            options = {actorId = self._actorId}})
    else
        app.tip:floatTip("敬请期待")
    end
end

function QUIDialogHeroInformation:_onTriggerClickSkin(event)
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_skin) == false then return end
    app.sound:playSound("common_small")
   
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSkin", 
        options = {actorId = self._actorId}})
end

function QUIDialogHeroInformation:_onGemstoneQuickChange(event)
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if self.heroRunningAniamtion then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_gemstone_change) == false then return end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneQuickChange", 
        options = {actorId = self._actorId, callBack = function(isShowEffect)
            if isShowEffect > 0 then
                self:enableTouchSwallowTop()
                local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
                self._wearEffectShow = QUIWidgetAnimationPlayer.new()
                self:getView():addChild(self._wearEffectShow)
                self._wearEffectShow:setPosition(ccp(0, 150))
                self._wearEffectShow:playAnimation(ccbFile, 
                    function(ccbOwner)
                        ccbOwner.node_green:setVisible(true)
                        ccbOwner.node_red:setVisible(false)
                        ccbOwner.node_title_bg:setVisible(false)
                        ccbOwner.tf_title1:setVisible(false)
                        for i = 1,4 do
                            ccbOwner["node_"..i]:setVisible(false)
                        end
                        local index = 1
                        local addPropText = function(name)
                            if index > 4 then return end
                            if name ~= nil then
                                ccbOwner["node_"..index]:setVisible(true)
                                ccbOwner["tf_name"..index]:setString(name)
                                index = index + 1
                            end
                        end
                        if isShowEffect == 1 or isShowEffect == 3 then
                            addPropText("魂骨一键交换完成")
                        end
                        if isShowEffect == 2 or isShowEffect == 3 then
                            addPropText("外附魂骨一键交换完成")
                        end
                    end, 
                    function()
                        if self._wearEffectShow ~= nil then
                            self._wearEffectShow:disappear()
                            self._wearEffectShow = nil
                        end
                        self:disableTouchSwallowTop()
                    end
                )    
            end
        end}})
end


function QUIDialogHeroInformation:_onSuperReduce(event)
    if self._magicHerb then
        if self._magicHerb:isRunAnimation() then
            return
        end
    end
    if q.buttonEventShadow(event, self._ccbOwner.node_super_reduce) == false then return end
    if self.heroRunningAniamtion then return end
    app.sound:playSound("common_hero")
    remote.herosUtil:dispatchEvent({name = QHerosUtils.EVENT_HERO_EXP_CHECK})
    local characherConfig = db:getCharacterByID(self._hero.actorId)
    if characherConfig.aptitude == APTITUDE.SS or characherConfig.aptitude == APTITUDE.SSR then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSuperHeroGrade", 
            options = {actorId = self._herosID[self._pos]}}, {isPopCurrentDialog = false})
    end
end    

function QUIDialogHeroInformation:onTriggerBackHandler(tag)
    -- if self._ccbOwner.node_mask_btn:isVisible() == false then
    self:_onTriggerBack()
    -- end
end

function QUIDialogHeroInformation:onTriggerHomeHandler(tag)
    -- if self._ccbOwner.node_mask_btn:isVisible() == false then
    self:_onTriggerHome()
    -- end
end

function QUIDialogHeroInformation:nodeEffect(node)
    if node ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        node:runAction(ccsequence)
    end
end

--穿装备事件
function QUIDialogHeroInformation:gemstoneWearHandler(event)
    local sid = event.sid
    local gemstone = remote.gemstone:getGemstoneById(sid)
    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    if self._wearEffectShow ~= nil then
        self._wearEffectShow:disappear()
        self._wearEffectShow = nil
    end

    app.sound:playSound("sound_num")
    
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner["node_gemstone"..gemstone.position]:addChild(effect)
    effect:playAnimation("ccb/effects/Baoshizhuangbei.ccbi")
    
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
    arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1,1))
    self._gemstoneBoxs[gemstone.position]:runAction(CCSequence:create(arr))

    local suitCallBack = function ()
        if self:safeCheck() then
            self:checkTriggerBreakMaster()
        end
    end


    self:enableTouchSwallowTop()
    self._gemstoneHandler = scheduler.performWithDelayGlobal(function ()
        self._gemstoneHandler = nil
        local gemstoneSuits = remote.gemstone:getSuitByItemId(gemstone.itemId)
        local suits = {}
        local godsuits = {}
        local mixsuits = {}
        local mixskillId = nil
        for index,gemstoneConfig in ipairs(gemstoneSuits) do
            if index > 4 then
                break
            end
            if self._hero.gemstones ~= nil then
                for _,v in ipairs(self._hero.gemstones) do
                    if v.itemId == gemstoneConfig.id then
                        table.insert(suits, v)
                        break
                    end
                end
            end
        end
        local isSs = remote.gemstone:checkGemstoneIsSsAptitude(gemstone)
        if isSs then
            local gemstoneSuitsSS = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,GEMSTONE_MAXADVANCED_LEVEL)
            local gemstoneSuits_ss = remote.gemstone:getSuitByItemId(gemstoneSuitsSS.gem_evolution_new_id)
            for index,godGemstoneConfig in pairs(gemstoneSuits_ss) do
                if index > 4 then
                    break
                end
                if self._hero.gemstones ~= nil then
                    for _,v in ipairs(self._hero.gemstones) do
                        local visSs = remote.gemstone:checkGemstoneIsSsAptitude(v)
                        local gemInfo = db:getGemstoneEvolutionBygodLevel(v.itemId,GEMSTONE_MAXADVANCED_LEVEL)
                        if gemInfo then
                            if visSs then 
                                if gemInfo.gem_evolution_new_id and gemInfo.gem_evolution_new_id == godGemstoneConfig.id then
                                    table.insert(godsuits, v)
                                    break
                                end
                            end
                        else
                            break
                        end
                    end
                end                     
            end
        end
        local mixLevel = gemstone.mix_level or 0
        if mixLevel > 0 then
            local showLv = 999
            for i,v in ipairs(suits) do
                if v.mix_level and  v.mix_level > 0 then
                    table.insert(mixsuits, v)
                    showLv = math.min(showLv , v.mix_level)
                end
            end
            local mixConfig = remote.gemstone:getGemstoneMixConfigAndNextByIdAndLv(gemstone.itemId,1)
            if mixConfig then
                local num = #mixsuits
                local suitSkill = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit, num ,showLv)
                if suitSkill and suitSkill.suit_skill then
                    local skillIdTbl = string.split(suitSkill.suit_skill , ";")
                    if skillIdTbl and not q.isEmpty(skillIdTbl) then
                        mixskillId = skillIdTbl[1]
                    end
                end
            end
        end
        -- if #suits > 1 then
        --     -- self:enableTouchSwallowTop()
        -- else
        --     self:disableTouchSwallowTop()
        -- end
        QPrintTable(mixsuits)

        self._wearEffectShow = QUIWidgetAnimationPlayer.new()
        self:getView():addChild(self._wearEffectShow)
        self._wearEffectShow:setPosition(ccp(0, 100))
        self._wearEffectShow:playAnimation(ccbFile, function(ccbOwner)
            ccbOwner.node_green:setVisible(true)
            ccbOwner.node_red:setVisible(false)
            for i=1,4 do
                ccbOwner["node_"..i]:setVisible(false)
            end
            local index = 1
            local addPropText = function(name,value)
                if index > 4 then return end
                value = value or 0
                if value > 0 then
                    ccbOwner["node_"..index]:setVisible(true)
                    ccbOwner["tf_name"..index]:setString(name.."＋"..value)
                    index = index + 1
                end
            end
            addPropText("攻击", gemstone.prop.attack_value)
            addPropText("生命", gemstone.prop.hp_value)
            addPropText("物理防御", gemstone.prop.armor_physical)
            addPropText("法术防御", gemstone.prop.armor_magic)
            end, function()
                if self._wearEffectShow ~= nil then
                    self._wearEffectShow:disappear()
                    self._wearEffectShow = nil
                end
                self:disableTouchSwallowTop()
                local successTip = app.master.GEMSTONE_SUIT_TIP
                if #suits > 1 and app.master:getMasterShowState(successTip) then
                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneActivitySuit", 
                        options = {suits = suits, successTip = successTip, callback = function ()
                            if next(godsuits) ~= nil and #godsuits > 1 then
                                self:getScheduler().performWithDelayGlobal(function()
                                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodGemstoneActivitySuit", 
                                        options = {suits = godsuits,successTip = successTip, suitstype = "godsuit",callback = function ()
                                            if mixsuits and next(mixsuits) ~= nil and #mixsuits > 1 then
                                                self:getScheduler().performWithDelayGlobal(function()
                                                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneSsPlusMixSuit", 
                                                        options = {suits = mixsuits , successTip = successTip,skillId = mixskillId, suitstype = "mixsuit",callback = function ()
                                                                suitCallBack()
                                                         end}}, {isPopCurrentDialog = false})    
                                                end, 0.5)                       
                                            else
                                                suitCallBack()
                                            end
                                        end}}, {isPopCurrentDialog = false})      
                                end, 0.5)                       
                            else
                                suitCallBack()
                            end
                        end}}, {isPopCurrentDialog = false})
                else
                    suitCallBack()
                end
            end)    
    end,0.2)
end

function QUIDialogHeroInformation:soulSpiritWearHandler(event)
    local id = event.id
    local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(id)

    local characherConfig = QStaticDatabase.sharedDatabase():getCharacterByID(id)
    local levelConfig = remote.soulSpirit:getLevelConfigByAptitudeAndLevel(characherConfig.aptitude, soulSpiritInfo.level)
    local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(id, soulSpiritInfo.grade)

    local propDic = {}
    propDic = remote.soulSpirit:getPropDicByConfig(levelConfig, propDic)
    propDic = remote.soulSpirit:getPropDicByConfig(gradeConfig, propDic)

    local ccbFile = "ccb/effects/SoulSpirit_PropTips.ccbi"

    if self._wearEffectShow ~= nil then
        self._wearEffectShow:disappear()
        self._wearEffectShow = nil
    end

    app.sound:playSound("sound_num")
    
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
    arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1,1))
    self._soulSpiritBox:runAction(CCSequence:create(arr))

    self:enableTouchSwallowTop()
    self._soulSpiritHandler = scheduler.performWithDelayGlobal(function ()
        self._soulSpiritHandler = nil
        self._wearEffectShow = QUIWidgetAnimationPlayer.new()
        self:getView():addChild(self._wearEffectShow)
        self._wearEffectShow:setPosition(ccp(0, 100))
        self._wearEffectShow:playAnimation(ccbFile, function(ccbOwner)
                ccbOwner.node_green:setVisible(true)
                ccbOwner.node_red:setVisible(false)
                ccbOwner.tf_title1:setString("护佑成功")
                for i=1, 5 do
                    ccbOwner["node_"..i]:setVisible(false)
                end
                local index = 1
                local addPropText = function (name, value)
                    if index > 5 then return end
                    ccbOwner["node_"..index]:setVisible(true)
                    ccbOwner["tf_name"..index]:setString(name.."＋"..value)
                    index = index + 1
                end
                for key, value in pairs(propDic) do
                    local name = QActorProp._field[key].uiName or QActorProp._field[key].name
                    local isPercent = QActorProp._field[key].isPercent
                    if not isPercent then
                        -- 策劃的特殊需求，穿戴的時候，不顯示百分比的屬性，因為加了百分比屬性，必須合併不然太多，但合併了又太長，影響美觀！
                        local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2) 
                        addPropText(name, str)
                    end
                end
            end, function()
                if self._wearEffectShow ~= nil then
                    self._wearEffectShow:disappear()
                    self._wearEffectShow = nil
                end
                self:disableTouchSwallowTop()
            end)    
    end, 0.2)
end

--穿暗器事件
function QUIDialogHeroInformation:mountWearHandler(event)
    local mountId = event.mountId
    local mountProp = remote.mount:getMountPropById(mountId)
    local prop = mountProp:getTotalProp()
    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    if self._wearEffectShow ~= nil then
        self._wearEffectShow:disappear()
        self._wearEffectShow = nil
    end

    app.sound:playSound("sound_num")
    
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.AccessoryBox1:addChild(effect)
    effect:setPosition(ccp(2,-5))
    effect:playAnimation("ccb/effects/EquipmentUpgarde.ccbi")
    
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
    arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1,1))
    self._mountBox:runAction(CCSequence:create(arr))

    self:enableTouchSwallowTop()
    self._gemstoneHandler = scheduler.performWithDelayGlobal(function ()
        self._gemstoneHandler = nil
        self._wearEffectShow = QUIWidgetAnimationPlayer.new()
        self:getView():addChild(self._wearEffectShow)
        self._wearEffectShow:setPosition(ccp(0, 100))
        self._wearEffectShow:playAnimation(ccbFile, function(ccbOwner)
            ccbOwner.node_green:setVisible(true)
            ccbOwner.node_red:setVisible(false)
            ccbOwner.tf_title1:setString("佩戴成功")
            for i=1,4 do
                ccbOwner["node_"..i]:setVisible(false)
            end
            local index = 1
            local addPropText = function (name,value)
                if index > 4 then return end
                value = value or 0
                if value > 0 then
                    ccbOwner["node_"..index]:setVisible(true)
                    ccbOwner["tf_name"..index]:setString(name.."＋"..value)
                    index = index + 1
                end
            end
            addPropText("攻击", prop.attack_value)
            addPropText("生命", prop.hp_value)
            addPropText("物理防御", prop.armor_physical)
            addPropText("法术防御", prop.armor_magic)
            end, function()
                if self._wearEffectShow ~= nil then
                    self._wearEffectShow:disappear()
                    self._wearEffectShow = nil
                end
                self:disableTouchSwallowTop()
            end)    
    end,0.2)
end

--穿戴武魂真身事件
function QUIDialogHeroInformation:artifactWearHandler(event)
    local artifactId = event.artifactId
    -- local mountInfo = remote.mount:getMountById(mountId)
    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    if self._wearEffectShow ~= nil then
        self._wearEffectShow:disappear()
        self._wearEffectShow = nil
    end

    app.sound:playSound("sound_num")
    
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.AccessoryBox2:addChild(effect)
    effect:setPosition(ccp(2,-5))
    effect:playAnimation("ccb/effects/EquipmentUpgarde.ccbi")
    
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
    arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1,1))
    self._artifactBox:runAction(CCSequence:create(arr))

    self:enableTouchSwallowTop()
    self._gemstoneHandler = scheduler.performWithDelayGlobal(function ()
        self._gemstoneHandler = nil
        self._wearEffectShow = QUIWidgetAnimationPlayer.new()
        self:getView():addChild(self._wearEffectShow)
        self._wearEffectShow:setPosition(ccp(0, 100))
        self._wearEffectShow:playAnimation(ccbFile, function(ccbOwner)
            ccbOwner.node_green:setVisible(true)
            ccbOwner.node_red:setVisible(false)
            ccbOwner.tf_title1:setString("佩戴成功")
            for i=1,4 do
                ccbOwner["node_"..i]:setVisible(false)
            end
            local index = 1
            local addPropText = function (name,value)
                if index > 4 then return end
                ccbOwner["node_"..index]:setVisible(true)
                ccbOwner["tf_name"..index]:setString(name.."＋"..value)
                index = index + 1
            end
            local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
            local prop = remote.artifact:countArtifactPropByActorId(self._actorId, heroInfo.artifact)
            for _,v in ipairs(QActorProp._uiFields) do
                if prop[v.fieldName] > 0 then
                    local value = prop[v.fieldName]
                    if v.handlerFun ~= nil then
                        value = v.handlerFun(value)
                    end
                    addPropText(v.name, value)
                end
            end
            end, function()
                if self._wearEffectShow ~= nil then
                    self._wearEffectShow:disappear()
                    self._wearEffectShow = nil
                end
                self:disableTouchSwallowTop()
            end)    
    end,0.2)
end

--穿戴晶石事件
function QUIDialogHeroInformation:sparWearHandler(event)
    if self:safeCheck() == false then return end
    local sparId = event.sparId
    local sparInfo, sparIndex = remote.spar:getSparsIndexBySparId(sparId)

    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    if self._wearEffectShow ~= nil then
        self._wearEffectShow:disappear()
        self._wearEffectShow = nil
    end

    app.sound:playSound("sound_num")
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner["node_spar"..sparIndex]:addChild(effect)
    effect:setPosition(ccp(2,-5))
    effect:playAnimation("ccb/effects/Baoshizhuangbei.ccbi")
    
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
    arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1,1))
    self._sparBoxs[sparIndex]:runAction(CCSequence:create(arr))

    self:enableTouchSwallowTop()
    self._gemstoneHandler = scheduler.performWithDelayGlobal(function ()
        local suits = {}
        local heroModel = remote.herosUtil:getUIHeroByID(self._actorId)
        local sparInfo1 = heroModel:getSparInfoByPos(1).info
        local sparInfo2 = heroModel:getSparInfoByPos(2).info
        local minGrade = heroModel:getHeroSparMinGrade()
        if sparInfo1 ~= nil and sparInfo2 ~= nil then
            suits = QStaticDatabase:sharedDatabase():getActiveSparSuitInfoBySparId(sparInfo1.itemId, sparInfo2.itemId, minGrade)
         end
        if #suits > 1 then
            -- self:enableTouchSwallowTop()
        else
            self:disableTouchSwallowTop()
        end
            
        self._gemstoneHandler = nil
        self._wearEffectShow = QUIWidgetAnimationPlayer.new()
        self:getView():addChild(self._wearEffectShow)
        self._wearEffectShow:setPosition(ccp(0, 100))
        self._wearEffectShow:playAnimation(ccbFile, function(ccbOwner)
            ccbOwner.node_green:setVisible(true)
            ccbOwner.node_red:setVisible(false)
            ccbOwner.tf_title1:setString("装备外附魂骨成功")
            for i=1,4 do
                ccbOwner["node_"..i]:setVisible(false)
            end
            local index = 1
            local addPropText = function(name, value, isPercent)
                if index > 4 then return end
                value = value or 0
                if value > 0 then
                    ccbOwner["node_"..index]:setVisible(true)
                    if isPercent then
                        ccbOwner["tf_name"..index]:setString(name.."＋"..(value*100).."%")
                    else
                        ccbOwner["tf_name"..index]:setString(name.."＋"..value)
                    end
                    index = index + 1
                end
            end
            addPropText("攻击", sparInfo.prop.attack_value)
            addPropText("生命", sparInfo.prop.hp_value)
            addPropText("物理防御", sparInfo.prop.armor_physical)
            addPropText("法术防御", sparInfo.prop.armor_magic)
            addPropText("生命百分比", sparInfo.prop.hp_percent, true)
            addPropText("攻击百分比", sparInfo.prop.attack_percent, true)
            addPropText("物防百分比", sparInfo.prop.armor_physical_percent, true)
            addPropText("法防百分比", sparInfo.prop.armor_magic_percent, true)
            end, function()
                if self._wearEffectShow ~= nil then
                    self._wearEffectShow:disappear()
                    self._wearEffectShow = nil
                end
                self:disableTouchSwallowTop()
                local successTip = app.master.SPAR_SUIT_TIP
                if #suits > 1 and app.master:getMasterShowState(successTip) then
                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSparSuitActiveSuccess", 
                        options = {suitInfo = suits, successTip = successTip, actorId = self._actorId, callback = function ()
                            self:checkSparStrengthMaster()
                        end}}, {isPopCurrentDialog = false})
                else
                    self:checkSparStrengthMaster()
                end
            end)    
    end,0.2)
end

--检查是否触发晶石强化大师
function QUIDialogHeroInformation:checkSparStrengthMaster()
    local masterLevel = remote.herosUtil:getUIHeroByID(self._actorId):getMasterLevelByType(QUIHeroModel.SPAR_STRENGTHEN_MASTER)
    if masterLevel > 0 then
        self._masterDialog = app.master:upGradeGemstoneMaster(0, masterLevel, QUIHeroModel.SPAR_STRENGTHEN_MASTER, self._actorId)
        if self._masterDialog then
            self._masterDialog:addEventListener(self._masterDialog.EVENT_CLOSE, function (e)
                    self._masterDialog:removeAllEventListeners()
                    self._masterDialog = nil
                    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
                end)
        else
            remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
        end
    else
        remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
    end
end

--检查是否触发突破大师
function QUIDialogHeroInformation:checkTriggerBreakMaster()
    local masterLevel = remote.herosUtil:getUIHeroByID(self._actorId):getMasterLevelByType(QUIHeroModel.GEMSTONE_BREAK_MASTER)
    if masterLevel > 0 then
        self._masterDialog = app.master:upGradeGemstoneMaster(0, masterLevel, QUIHeroModel.GEMSTONE_BREAK_MASTER, self._actorId)
        if self._masterDialog then
            self._masterDialog:addEventListener(self._masterDialog.EVENT_CLOSE, function (e)
                self._masterDialog:removeAllEventListeners()
                self._masterDialog = nil
                self:checkTriggerStrengthMaster()
                end)
        else
            self:checkTriggerStrengthMaster()
        end
    else
        self:checkTriggerStrengthMaster()
    end
end

--检查是否触发突破大师
function QUIDialogHeroInformation:checkTriggerStrengthMaster()
    local masterLevel = remote.herosUtil:getUIHeroByID(self._actorId):getMasterLevelByType(QUIHeroModel.GEMSTONE_MASTER)
    if masterLevel > 0 then
        self._masterDialog = app.master:upGradeGemstoneMaster(0, masterLevel, QUIHeroModel.GEMSTONE_MASTER, self._actorId)
        if self._masterDialog then
            self._masterDialog:addEventListener(self._masterDialog.EVENT_CLOSE, function (e)
                    self._masterDialog:removeAllEventListeners()
                    self._masterDialog = nil
                    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
                end)
        else
            remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
        end
    else
        remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
    end
end

-- 对话框退出
function QUIDialogHeroInformation:_onTriggerBack(tag, menuItem)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogHeroInformation:_onTriggerHome(tag, menuItem)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogHeroInformation
