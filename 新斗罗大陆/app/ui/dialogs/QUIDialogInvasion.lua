
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogInvasion = class("QUIDialogInvasion", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIDialogRule = import("..dialogs.QUIDialogRule")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInvasionChest = import("..widgets.QUIWidgetInvasionChest")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")
local QUIWidgetInvasionRankInfoClient = import("..widgets.QUIWidgetInvasionRankInfoClient")

local DEFAULT_YELL = "攻打副本时，有几率触发魂兽入侵，击杀魂兽后可以获得极品宝箱"
local YELL_MODEL = "1002"

function QUIDialogInvasion:ctor(options)
    local ccbFile = "ccb/Dialog_Panjun_Main.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)}, 
        {ccbCallbackName = "onTriggerReward", callback = handler(self, self._onTriggerReward)},
        {ccbCallbackName = "onTriggerStore", callback = handler(self, self._onTriggerStore)}, 
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
        {ccbCallbackName = "onTriggerBoss1", callback = handler(self, self._onTriggerBoss1)},
        {ccbCallbackName = "onTriggerBoss2", callback = handler(self, self._onTriggerBoss2)},
        {ccbCallbackName = "onTriggerBoss3", callback = handler(self, self._onTriggerBoss3)},
        {ccbCallbackName = "onTriggerDungeon", callback = handler(self, self._onTriggerDungeon)},
        {ccbCallbackName = "onTriggerWorldBoss", callback = handler(self, self._onTriggerWorldBoss)},
        {ccbCallbackName = "onTriggerLegendMonster", callback = handler(self, self._onTriggerLegendMonster)},
        {ccbCallbackName = "onTriggerKillAward", callback = handler(self, self._onTriggerKillAward)},
        -- {ccbCallbackName = "onTriggerSetting", callback = handler(self, self._onTriggerSetting)},
        {ccbCallbackName = "onTriggerPrevirw", callback = handler(self, self._onTriggerPrevirw)}, 
        {ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
        {ccbCallbackName = "onTriggerFastFighter1", callback = handler(self, self._onTriggerFastFighter1)},
        {ccbCallbackName = "onTriggerFastFighter2", callback = handler(self, self._onTriggerFastFighter2)},
        {ccbCallbackName = "onTriggerFastFighter3", callback = handler(self, self._onTriggerFastFighter3)},
    }
    QUIDialogInvasion.super.ctor(self, ccbFile, callBacks, options)

    self._schedulers = {}

    self._hpBarClippingNodeList = {}
    setShadow5(self._ccbOwner.name_meritorious)
    setShadow5(self._ccbOwner.name_maxDamage)
    setShadow5(self._ccbOwner.maxDamage)
    setShadow5(self._ccbOwner.meritorious)
    CalculateUIBgSize(self._ccbOwner.node_bg_main,UI_VIEW_MIN_WIDTH)
    q.setButtonEnableShadow(self._ccbOwner.btn_legend_monster)

    -- if remote.robot:checkRobotUnlock() then
    --     self._ccbOwner.btn_setting:setVisible( true )
    -- else
        self._ccbOwner.node_setting:setVisible( false )
    -- end

    --http://jira.joybest.com.cn/browse/WOW-9386
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page and page.setManyUIVisible then page:setManyUIVisible() end
    if page and page.setScalingVisible then page:setScalingVisible(false) end
    if page and page.topBar and page.topBar.showWithInvasion then
        page.topBar:showWithInvasion()
    end

    for i=1,3 do
        self._ccbOwner["tf_userName"..i] = QRichText.new(nil, nil, {fontName = global.font_name})
        self._ccbOwner["tf_userName"..i]:setAnchorPoint(0.5,0.5)
        self._ccbOwner["tf_userName"..i]:setPositionX(20)
        -- self._ccbOwner["tf_userName"..i]:setPositionY(-178)
        self._ccbOwner["node_user"..i]:addChild(self._ccbOwner["tf_userName"..i])
    end
    --刷新
    self._ccbOwner.node_refresh:setVisible(false)

    self:setSelfInfo()
    local options = self:getOptions() or {}
    self._invasions = options.invasions or {}
    local afterBattle = remote.invasion:getAfterBattle()
    if self._invasions == nil or #self._invasions == 0 or afterBattle ~= true then
        self:getInvasionsData()
        self:setMonster()
    else
        self:setMonster()
        local invasions = remote.invasion:getInvasions()
        local index = self:getOptions().selectIndex or 99
        local invasion = invasions[index]
        if invasion == nil and self._invasions[index] ~= nil then 
            self._ccbOwner["node_hp"..index]:setVisible(false)
        end
    end

    self:setChestInfo()

    local yell = QStaticDatabase:sharedDatabase():getRandomInvasionYell() or DEFAULT_YELL
    self._ccbOwner.yell:setString(yell)

    --xurui: 检查世界BOSS是否开启
    local bossOpen = app.unlock:getUnlockWorldBoss()
    self._ccbOwner.node_world_boss:setVisible(bossOpen)
    local legendOpen = app.unlock:checkLock("UNLOCK_MONSTER_INVOKE", false)
    self._ccbOwner.node_legend_monster:setVisible(legendOpen)

    if not bossOpen then
        self._ccbOwner.node_legend_monster:setPositionX(-122)
    end

    self:checkIsHaveKillAwards()

    self:checkTutorial()

    self:checkFastFightUnlock()

    local data1 = remote.invasion:getSelfInvasion()
    QPrintTable(data1)
    local data2 = remote.invasion:getInvasions()
    QPrintTable(data2)
end

function QUIDialogInvasion:checkTutorial()
    if app.tutorial and app.tutorial:isTutorialFinished() == false then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        if page.buildLayer then
            page:buildLayer()
        end
        local haveTutorial = false
        if app.tutorial:getStage().invasion == app.tutorial.Guide_Start and app.unlock:getUnlockInvasion() then
            haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_Invasion)
        end
        if haveTutorial == false and page.cleanBuildLayer then
            page:cleanBuildLayer()
        end
    end
end

function QUIDialogInvasion:viewDidAppear()
    QUIDialogInvasion.super.viewDidAppear(self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_QUICKBATTLE, self.exitFromQuickBattleHandler, self)
    self._invasionProxy = cc.EventProxy.new(remote.invasion)
    self._invasionProxy:addEventListener(remote.invasion.EVENT_UPDATE, handler(self, self.invasionUpdateHandler))
    self._invasionProxy:addEventListener(remote.invasion.EVNET_SHOW_KILL_AWARD, handler(self, self.getKillAwards))

    self:addBackEvent(false)
    if remote.invasion:getInvasionUpdate() == true then
        remote.invasion:setInvasionUpdate(false)
        remote.invasion:getInvasionRequest()
    end
end

function QUIDialogInvasion:viewWillDisappear()
    QUIDialogInvasion.super.viewWillDisappear(self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_QUICKBATTLE, self.exitFromQuickBattleHandler, self)
    if self._invasionProxy ~= nil then
        self._invasionProxy:removeAllEventListeners()
        self._invasionProxy = nil
    end
    if self.schedulerHandler ~= nil then
        scheduler.unscheduleGlobal(self.schedulerHandler)
        self.schedulerHandler = nil
    end
    self:removeBackEvent()
    self:clearSchedulers()

    if self._schedulers ~= nil then
        for _,handler in ipairs(self._schedulers) do
            scheduler.unscheduleGlobal(handler)
        end
    end
    self._schedulers = {}
end

function QUIDialogInvasion:invasionUpdateHandler(event)
    local isInBattle = remote.invasion:getAfterBattle()
    if isInBattle == false then
        self:setSelfInfo()
        self:getInvasionsData()
        self:setMonster()
    end
end

function QUIDialogInvasion:setChestInfo()
    if self._chests == nil then
        self._chests = {}
        for i = 1,3 do
            local chest = QUIWidgetInvasionChest.new()
            chest:addEventListener(QUIWidgetInvasionChest.EVENT_OPEN_CHEST, handler(self, self.chestHandler))
            chest:addEventListener(QUIWidgetInvasionChest.EVENT_OPEN_CHEST_END, handler(self, self.chestHandler))
            chest:setInfo(i)
            self._ccbOwner["node_chest"..i]:addChild(chest)
            table.insert(self._chests, chest)
        end
    end
    self._chests[1]:refreshInfo()
    self._chests[2]:refreshInfo()
    self._chests[3]:refreshInfo()
end

function QUIDialogInvasion:chestHandler(event)
    if event.name == QUIWidgetInvasionChest.EVENT_OPEN_CHEST then
        self:enableTouchSwallowTop()
    elseif event.name == QUIWidgetInvasionChest.EVENT_OPEN_CHEST_END then
        self:disableTouchSwallowTop()
    end
end

function QUIDialogInvasion:setSelfInfo()
    local invasion = remote.invasion:getSelfInvasion()

    -- local meritoriousRank = invasion.allHurtRank and string.format("（第%d名）", invasion.allHurtRank) or "（尚未进榜）"
    -- local maxDamageRank = invasion.maxHurtRank and string.format("（第%d名）", invasion.maxHurtRank) or "（尚未进榜）"
    local num1,unit1 = q.convertLargerNumber(invasion.allHurt)
    local meritorious = string.format("%s", num1..(unit1 or "") or 0)
    local num2,unit2 = q.convertLargerNumber(invasion.maxHurt)
    local maxDamage = string.format("%s", num2..(unit2 or ""))

    self._ccbOwner.meritorious:setString(meritorious)

    self._ccbOwner.maxDamage:setString(maxDamage)
    
    self._ccbOwner.merit:setString(remote.user.intrusion_money or 0)
    
    self._ccbOwner.rewardTip:setVisible(remote.invasion:invasionRewardApplicable())
    
    self._ccbOwner.shop_tips:setVisible(false)
    if remote.stores:checkFuncShopRedTips(SHOP_ID.invasionShop) then
        self._ccbOwner.shop_tips:setVisible(true)
    end

    local worldBossTips = remote.worldBoss:checkWorldBossRedTips()
    local worldBossEffect = remote.worldBoss:checkWorldBossIsUnlock()
    self._ccbOwner.world_boss_tips:setVisible(worldBossTips)
    self._ccbOwner.node_world_boss_effect:setVisible(worldBossEffect)
    self._ccbOwner.node_world_boss_fire:setVisible(worldBossEffect)

    self:setRankAwardsInfo(invasion.allHurtRank or 0, invasion.maxHurtRank or 0)
    self:updateLegendMonsterInfo()
end


function QUIDialogInvasion:updateLegendMonsterInfo()
    local energyConsume = remote.invasion:getEnergyConsume()
    local cost  = db:getConfigurationValue("intrusion_energy_consume") or 1 

    local bossSummonCount = remote.invasion:getBossSummonCount()
    local totalCount  = db:getConfigurationValue("intrusion_boss_summon_max_count") or 1 

    self._ccbOwner.tf_cost_energy:setString(energyConsume.."/"..cost)
    if energyConsume >= cost then
        self._ccbOwner.tf_desc_cost:setVisible(false)
        self._ccbOwner.tf_cost_energy:setVisible(false)
        self._ccbOwner.tf_desc_ready:setVisible(true)
    else
        self._ccbOwner.tf_desc_cost:setVisible(true)
        self._ccbOwner.tf_cost_energy:setVisible(true)
        self._ccbOwner.tf_desc_ready:setVisible(false)
    end
    self._ccbOwner.node_legend_monster_effect:setVisible(energyConsume >= cost)
    self._ccbOwner.sp_legend_monster_tips:setVisible(energyConsume >= cost)

    if totalCount <= bossSummonCount then
        makeNodeFromNormalToGray(self._ccbOwner.btn_legend_monster)
        self._ccbOwner.node_legend_monster_effect:setVisible(false)
        self._ccbOwner.sp_legend_monster_tips:setVisible(false)

        self._ccbOwner.tf_desc_cost:setVisible(false)
        self._ccbOwner.tf_cost_energy:setVisible(false)
        self._ccbOwner.tf_desc_ready:setVisible(true)
        self._ccbOwner.tf_desc_ready:setString("已召唤")
    else
        makeNodeFromGrayToNormal(self._ccbOwner.btn_legend_monster)
    end

 end


function QUIDialogInvasion:setRankAwardsInfo(meritoriousRank, maxDamageRank)
    local database = QStaticDatabase:sharedDatabase()
    local title1 = "累积积分排名："
    local title2 = "目标奖励："

    -- set meritorious rank info
    local meritoriousConfigs1, meritoriousConfigs2 = database:getIntrusionAwardsRankByRank(meritoriousRank, 1, remote.user.level)
    local meritoriousAwards1 = database:getluckyDrawById(meritoriousConfigs1.intrusion_rank)
    if meritoriousConfigs2 == nil or next(meritoriousConfigs2) == nil then
        meritoriousConfigs2 = database:getIntrusionRankAwardByLevel(1, remote.user.level)
        table.sort( meritoriousConfigs2, function(a, b) return a.rank < b.rank end )
        meritoriousConfigs2 = meritoriousConfigs2[#meritoriousConfigs2]
    end
    local meritoriousAwards2 = database:getluckyDrawById(meritoriousConfigs2.intrusion_rank)
    if  self._meritoriousRank == nil then
        self._meritoriousRank = QUIWidgetInvasionRankInfoClient.new()
        self._ccbOwner.node_meritorious_rank:addChild(self._meritoriousRank)
    end
    self._meritoriousRank:setInfo(title1, meritoriousRank, meritoriousAwards1, title2, meritoriousConfigs2.rank, meritoriousAwards2)

    title1 = "最高伤害排名："
    local maxDamageConfigs1, maxDamageConfigs2 = database:getIntrusionAwardsRankByRank(maxDamageRank, 1, remote.user.level)
    local maxDamageAwards1 = database:getluckyDrawById(maxDamageConfigs1.intrusion_hurt_rank)
    if maxDamageConfigs2 == nil or next(maxDamageConfigs2) == nil then
        maxDamageConfigs2 = database:getIntrusionRankAwardByLevel(1, remote.user.level)
        table.sort( maxDamageConfigs2, function(a, b) return a.rank < b.rank end )
        maxDamageConfigs2 = maxDamageConfigs2[#maxDamageConfigs2]
    end
    local maxDamageAwards2 = database:getluckyDrawById(maxDamageConfigs2.intrusion_hurt_rank)
    -- set maxDamage rank info
    if  self._maxDamageRank == nil then
        self._maxDamageRank = QUIWidgetInvasionRankInfoClient.new()
        self._ccbOwner.node_maxDamage_rank:addChild(self._maxDamageRank)
    end
    self._maxDamageRank:setInfo(title1, maxDamageRank, maxDamageAwards1, title2, maxDamageConfigs2.rank, maxDamageAwards2)
end

--设置自己和朋友的入侵怪物信息
function QUIDialogInvasion:setMonster()
    self._inAnimation = false
    self:resetAllMonster()

    if self._invasions == nil or #self._invasions == 0 then --没有任何怪物信息
        self:_invasionNotApplicable()
    else
        -- 屏蔽
        self._ccbOwner.node_refresh:setVisible(false)
        self._ccbOwner.noBoss:setVisible(false)
        for index,invasion in ipairs(self._invasions) do
            if index>3 then break end
            self:_invasionApplicable(invasion, index)
        end
    end
    for index, invasion in ipairs(self._invasions) do
        if invasion.bossHp <= 0 then
            self:playMonsterDeadAni(index)
            break
        end
    end
end

--重置所有怪物信息
function QUIDialogInvasion:resetAllMonster()
    self._ccbOwner.node_refresh:setVisible(false)
    for i=1,3 do
        if self._ccbOwner["bossReady"..i] ~= nil then
            self._ccbOwner["bossReady"..i]:setVisible(false)
        end
    end
end

function QUIDialogInvasion:_invasionNotApplicable()
    self._ccbOwner.noBoss:setVisible(true)
    -- self._ccbOwner.bossReady:setVisible(false)

    -- Display boss character
    local avatar = QUIWidgetHeroInformation.new()
    avatar:setAvatar(YELL_MODEL, 1.5)
    self._ccbOwner.noBossNode:removeAllChildren()
    self._ccbOwner.noBossNode:addChild(avatar)
    avatar:setBackgroundVisible(false)
    avatar:setNameVisible(false)
    avatar:setStarVisible(false)

    local yell = QStaticDatabase:sharedDatabase():getRandomInvasionYell() or DEFAULT_YELL
    self._ccbOwner.yell:setString(yell)

    -- self._onTriggerBossImpl = function ()
    --     -- body
    -- end
end

function QUIDialogInvasion:_invasionApplicable(invasion, index)
    if invasion == nil then
        return
    end
    if invasion.bossId == nil or invasion.bossId == 0 then
        return
    end
    -- Display boss character
    self._ccbOwner["node_hp"..index]:setVisible(true)
    self._ccbOwner["bossReady"..index]:setVisible(true)
    if self._avatars == nil then self._avatars = {} end
    self._avatars[index] = QUIWidgetHeroInformation.new()
    local scale = 1
    local posY = -50
    if index > 1 then
        scale = 0.85
        posY = -130
    end
    self._avatars[index]:setAvatar(invasion.bossId, scale)
    self._ccbOwner["bossNode"..index]:removeAllChildren()
    self._ccbOwner["node_effect"..index]:removeAllChildren()
    self._ccbOwner["node_arrow"..index]:removeAllChildren()
    self._ccbOwner["bossNode"..index]:addChild(self._avatars[index])
    self._avatars[index]:setBackgroundVisible(false)
    self._avatars[index]:setNameVisible(false)
    self._avatars[index]:setStarVisible(false)
    self._ccbOwner["node_battle"..index]:setVisible(false)
    
    if invasion.fightingUserId ~= nil and invasion.fightingUserId ~= remote.user.userId then --自己再打的时候不显示自己的战斗信息
        self._ccbOwner["node_battle"..index]:setVisible(invasion.isFighting == true)
        if invasion.isFighting == true then
            local battleing = QUIWidget.new("ccb/effects/battle_ing.ccbi")
            self._ccbOwner["node_arrow"..index]:addChild(battleing)
            self._ccbOwner["tf_fighter_name"..index]:setString(invasion.fightingNickname or "")
        end
        if invasion.hurtHp ~= nil and invasion.hurtHp > 0 then
            if invasion.isFighting == false then
                local battleing = QUIWidget.new("ccb/effects/battle_ing.ccbi")
                self._ccbOwner["node_arrow"..index]:addChild(battleing)
                self._ccbOwner["tf_fighter_name"..index]:setString(invasion.fightingNickname or "")
                self._ccbOwner["node_battle"..index]:setVisible(true)
            end

            local ccbFile = "ccb/effects/xdaoguangdonghua_1.ccbi"
            local animationPlayer = QUIWidgetAnimationPlayer.new()
            animationPlayer:setPositionY(posY)
            animationPlayer:setScale(scale)
            animationPlayer:playAnimation(ccbFile,nil,function ()
                animationPlayer:removeFromParent()
            end)
            self._ccbOwner["node_effect"..index]:addChild(animationPlayer)
            local hurtHp = invasion.hurtHp
            local handler = scheduler.performWithDelayGlobal(function ()
                    self._ccbOwner["node_battle"..index]:setVisible(false)
                    local richText = QRichText.new()
                    richText:setPositionY(posY+50)
                    local strokeColor = ccc3(0,0,0)
                    local num,unit = q.convertLargerNumber(hurtHp)
                    richText:setAnchorPoint(0.5,0.5)
                    richText:setString({
                            {oType = "font", content = invasion.fightingNickname or "", strokeColor = strokeColor, size = 22,color = UNITY_COLOR.white},
                            {oType = "font", content = "打出伤害"..num..(unit or ""), strokeColor = strokeColor, size = 22,color = QIDEA_QUALITY_COLOR.YELLOW},
                        },790)
                    self._ccbOwner["node_effect"..index]:addChild(richText)
                    -- richText:setCascadeOpacityEnabled(true)

                    local arr = CCArray:create()
                    arr:addObject(CCFadeIn:create(4/30))
                    arr:addObject(CCDelayTime:create(17/30))
                    local arr2 = CCArray:create()
                    arr2:addObject(CCMoveTo:create(25/30,ccp(0, 78)))
                    arr2:addObject(CCFadeOut:create(25/30))
                    arr:addObject(CCSpawn:create(arr2))
                    arr:addObject(CCCallFunc:create(function()  
                            richText:removeFromParent()
                        end))
                    richText:runAction(CCSequence:create(arr))
                end,0.4)
            table.insert(self._schedulers, handler)

            local realInvasion = remote.invasion:getInvasionByUserId(invasion.userId)
            realInvasion.hurtHp = 0
            invasion.hurtHp = 0        
        end
    end

    self:_showBoss(invasion, index)
    if invasion.bossHp > 0 then
        self:_showBossState(1, index)
    end

    local fromStr = ""
    if invasion.userId ~= remote.user.userId then
        self._ccbOwner["node_user"..index]:setVisible(true)
        if invasion.friend == true then
            fromStr = "好友 "..(invasion.nickname or "")
        else
            fromStr = "宗门成员 "..(invasion.nickname or "")
        end
        self._ccbOwner["tf_userName"..index]:setString({
                {oType = "font", content = "来自", size = 22,color = ccc3(220,207,177)},
                {oType = "font", content = fromStr, size = 24,color = ccc3(255,239,0)},
                {oType = "font", content = "的魂兽",size = 22,color = ccc3(220,207,177)},
            },790)
    else
        self._ccbOwner["node_user"..index]:setVisible(false)
    end
end

-- Display boss hp percent
function QUIDialogInvasion:_addMaskLayer(ccb, mask)
    local width = ccb:getContentSize().width * ccb:getScaleX()
    local height = ccb:getContentSize().height
    local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
    maskLayer:setAnchorPoint(ccp(0, 0.5))
    maskLayer:setPosition(ccp(-width/2, -height/2))

    local ccclippingNode = CCClippingNode:create()
    ccclippingNode:setStencil(maskLayer)
    ccb:retain()
    ccb:removeFromParent()
    ccb:setPosition(ccp(-width/2, 0))
    ccclippingNode:addChild(ccb)
    ccb:release()

    mask:addChild(ccclippingNode)
    return maskLayer
end
-- Display boss hp percent
function QUIDialogInvasion:_showBoss(invasion, index)
    local actorId = invasion.bossId
    local level = invasion.fightCount + 1
    local maxLevel = db:getIntrusionMaximumLevel(invasion.bossId)
    level = math.min(level, maxLevel)
    local data = QStaticDatabase:sharedDatabase():getCharacterDataByID(actorId, level)
    local maxHP = (data.hp_value or 0) + (data.hp_grow or 0) * level

     -- local hpMask = self:_addMaskLayer(self._ccbOwner["hp_bar"..index], self._ccbOwner["hp_mask"..index])
    local hpRatio = invasion.bossHp/maxHP
    hpRatio = hpRatio > 1 and 1 or (hpRatio < 0 and 0 or hpRatio)
    -- hpMask:setScaleX(hpRatio)
    if not self._hpBarClippingNodeList[index] then
        self._hpBarClippingNodeList[index] = q.newPercentBarClippingNode(self._ccbOwner["hp_bar"..index])
    end
    local stencil = self._hpBarClippingNodeList[index]:getStencil()
    local totalStencilWidth = stencil:getContentSize().width * stencil:getScaleX()
    stencil:setPositionX(-totalStencilWidth + hpRatio*totalStencilWidth)

    -- Show boss color
    -- local prefix = "优秀"
    local fontColor = remote.invasion:getBossColorByType(invasion.boss_type)
    self._ccbOwner["bossName"..index]:setColor(fontColor)
    self._ccbOwner["bossName"..index] = setShadowByFontColor(self._ccbOwner["bossName"..index], fontColor)

    local data = QStaticDatabase:sharedDatabase():getCharacterDataByID(actorId, level)
    local title = string.format("%s(LV.%d)", QStaticDatabase:sharedDatabase():getCharacterByID(actorId).name, level)
    self._ccbOwner["bossName"..index]:setString(title)
end

-- state: 1 normal, 2 dead, 3 runaway
function QUIDialogInvasion:_showBossState(state, index)
    state = state or 1
    self._ccbOwner["isDead"..index]:setVisible(state == 2)
    self._ccbOwner["isRunaway"..index]:setVisible(state == 3)

    if state == 2 then
        makeNodeFromNormalToGray(self._avatars[index])
        self._avatars[index]:pauseAnimation()
    elseif state == 3 then
        self._avatars[index]:pauseAnimation()
    end
end

function QUIDialogInvasion:refresh()
    self:setSelfInfo()
end

function QUIDialogInvasion:exitFromBattleHandler()
    self:setSelfInfo()
    self:triggerBossByIndex(self:getOptions().selectIndex, handler(self, self._openBossInfoDialog))
end

function QUIDialogInvasion:exitFromQuickBattleHandler()
    self:setSelfInfo()
    self:triggerBossByIndex(self:getOptions().selectIndex, handler(self, self._openBossInfoDialog))
    
    -- self:setChestInfo()
end

function QUIDialogInvasion:getInvasionsData()
    self._invasions = clone(remote.invasion:getInvasions())
    local options = self:getOptions() or {}
    options.invasions = self._invasions
    self:setOptions(options)
end

function QUIDialogInvasion:getKillAwards()
    remote.invasion:intrusionKillAwardRequest(function()
        if self:safeCheck() then
            self:checkIsHaveKillAwards()
            self:setChestInfo()
        end
    end)
end

function QUIDialogInvasion:setOptions(options)
    self._options = options
end

function QUIDialogInvasion:triggerBossByIndex(index, callback)
    local invasions = remote.invasion:getInvasions()
    local afterBattle = remote.invasion:getAfterBattle()
    remote.invasion:setAfterBattle(false)
    local options = self:getOptions() or {}
    local oldInvasion = nil
    if options.invasions ~= nil and options.invasions[index] ~= nil then
        oldInvasion = options.invasions[index]
        local isFind = false
        if oldInvasion ~= nil then
            for _,invasion in ipairs(invasions) do
                if invasion.userId == oldInvasion.userId and invasion.bossId == oldInvasion.bossId then
                    isFind = true
                    break
                end
            end
        end
        if isFind == false then
            self._invasions = options.invasions
            self._invasions[index].bossHp = 0.1
            self:setMonster()
            self:playMonsterDead(index)
            if self._ccbOwner["node_battle"..index] ~= nil then
                self._ccbOwner["node_battle"..index]:setVisible(false)
            end
            return
        end
    end
    self:getInvasionsData()
    self:setMonster()
    options.selectIndex = index
    self:setOptions(options)
    local invasion = invasions[index]
    if invasion == nil then return end
    if invasion.isFighting == true then
        app.tip:floatTip("怪物正在被其他玩家攻打！") 
        return 
    end

    local bossId = invasion.bossId
    local userId = invasion.userId

    if callback then
        callback(afterBattle, bossId, userId)
    end
end

--播放怪物死亡
function QUIDialogInvasion:playMonsterDeadAni(index)
    self._inAnimation = true
    local avatar = self._avatars[index]
    if avatar ~= nil then
        avatar:avatarPlayAnimation(ANIMATION_EFFECT.DEAD)
        avatar:setAutoStand(false)
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(2.0))
        arr:addObject(CCCallFunc:create(function()
                remote.invasion:getInvasionRequest()
            end))
        avatar:runAction(CCSequence:create(arr)) 
    end
end

--播放怪物死亡
function QUIDialogInvasion:playMonsterDead(index)
    self._inAnimation = true
    local avatar = self._avatars[index]
    local items = remote.invasion:getBattleItems()
    if avatar ~= nil and items ~= nil and #items > 0 then
        avatar:avatarPlayAnimation(ANIMATION_EFFECT.DEAD)
        avatar:setAutoStand(false)
        self._ccbOwner["node_hp"..index]:setVisible(false)
        local deadOverFun = function ()
            if self.schedulerHandler ~= nil then
                scheduler.unscheduleGlobal(self.schedulerHandler)
                self.schedulerHandler = nil
            end
            local pos = ccp(self._ccbOwner["bossNode"..index]:getPosition())
            pos = self._ccbOwner["bossNode"..index]:convertToWorldSpace(ccp(0,0))
            pos = self:getView():convertToNodeSpace(pos)
            local dropItems = {}
            self._animationFun = {}
            for _,value in ipairs(items) do
                for i,itemId in ipairs(remote.invasion.CHEST) do
                    if value.id == itemId then
                        if self._animationFun[i] == nil then 
                            self._animationFun[i] = {}
                        end
                        if self._animationFun[i]["chest"] == nil then
                            self._animationFun[i]["chest"] = 0
                        end
                        self._animationFun[i]["chest"] = self._animationFun[i]["chest"] + 1
                        for j=1,value.count do
                            table.insert(dropItems,{"chest", i, pos.x, pos.y})
                        end
                        break
                    end
                end
                for i,itemId in ipairs(remote.invasion.KEY) do
                    if value.id == itemId then
                        if self._animationFun[i] == nil then 
                            self._animationFun[i] = {}
                        end
                        if self._animationFun[i]["key"] == nil then
                            self._animationFun[i]["key"] = 0
                        end
                        self._animationFun[i]["key"] = self._animationFun[i]["key"] + 1
                        for j=1,value.count do
                            table.insert(dropItems,{"key", i, pos.x, pos.y})
                        end
                        break
                    end
                end
            end
            self:clearSchedulers()
            local totalItem = #dropItems
            local line = 4
            local cellH = 70
            local startPosY = -((math.ceil(totalItem/line)-1) * cellH/2) - 100
            local startPosX = math.min(line, totalItem) * cellH/2 - 50
            for index,value in ipairs(dropItems) do
                local handler = scheduler.performWithDelayGlobal(function ()
                    self:dropItemAnimation(value[1],value[2],value[3] + startPosX + ((index-1)%line) * -cellH,
                        value[4] + startPosY + math.floor((index-1)/line) * cellH)
                end,0.1 * index)
                table.insert(self._schedulerHandler, handler)
            end
        end
        deadOverFun()
    else
        self:getInvasionsData()
        self:setMonster()
    end
end

function QUIDialogInvasion:clearSchedulers()
    if self._schedulerHandler ~= nil then
        for _,handler in ipairs(self._schedulerHandler) do
            scheduler.unscheduleGlobal(handler)
        end
    end
    self._schedulerHandler = {}
end

-- --获取掉落的物品
function QUIDialogInvasion:dropItemAnimation(typeName, index, posX, posY)
    local animationPlayer = QUIWidgetAnimationPlayer.new()
    animationPlayer:setScale(0.7)
    --移动的函数
    local moveFun = function ()
        local node = nil
        if typeName == "chest" then
            node = self._chests[index]._ccbOwner["sp_chest"..index]
        elseif typeName == "key" then
            node = self._chests[index]._ccbOwner["sp_key"..index]
        end
        local targetPos = node:convertToWorldSpace(ccp(0,0))
        targetPos = self:getView():convertToNodeSpace(targetPos)
        local arr = CCArray:create()
        arr:addObject(CCMoveTo:create(0.3,ccp(targetPos.x, targetPos.y)))
        arr:addObject(CCCallFunc:create(function()
                if typeName == "chest" then
                    animationPlayer:setPositionX(targetPos.x + 53)
                    animationPlayer:setPositionY(targetPos.y + 36)
                end
                animationPlayer:playAnimation("ccb/effects/zhanchang_baoxiang_feidao.ccbi",nil,function ()
                    animationPlayer:disappear()
                    self._animationFun[index][typeName] = self._animationFun[index][typeName] - 1
                    if self._animationFun[index][typeName] == 0 then
                        self._chests[index]:updateInfoForAnimation()
                        self:getInvasionsData()
                        self:setMonster()
                        self:getKillAwards()
                    end
                end)
            end))
        animationPlayer:runAction(CCSequence:create(arr))
    end
    local ccbFile = nil
    if typeName == "chest" then
        if index == 1 then
            ccbFile = "ccb/effects/zhanchang_baoxiang_chuxian2.ccbi"
        elseif index == 2 then
            ccbFile = "ccb/effects/zhanchang_baoxiang_chuxian3.ccbi"
        elseif index == 3 then
            ccbFile = "ccb/effects/zhanchang_baoxiang_chuxian.ccbi"
        end
        animationPlayer:playAnimation(ccbFile,function (ccbOwner)
        end,moveFun,false)
    elseif typeName == "key" then
        if index == 1 then
            ccbFile = "ccb/effects/zhanchang_yaoshi_chuxian3.ccbi"
        elseif index == 2 then
            ccbFile = "ccb/effects/zhanchang_yaoshi_chuxian2.ccbi"
        elseif index == 3 then
            ccbFile = "ccb/effects/zhanchang_yaoshi_chuxian.ccbi"
        end
        animationPlayer:playAnimation(ccbFile,function (ccbOwner)
        end,moveFun,false)
    end
    animationPlayer:setPosition(ccp(posX,posY))
    self:getView():addChild(animationPlayer)
end

--xurui: 检查是否有击杀奖励
function QUIDialogInvasion:checkIsHaveKillAwards()
    if remote.invasion:checkKillAwards() --[[and remote.robot:checkRobotUnlock()]] then 
        -- 有奖励，有扫荡
        self._ccbOwner.node_kill_reward:setVisible(true)
        self._ccbOwner.kill_tips:setVisible(true)
        -- self._ccbOwner.btn_setting:setVisible( true )
        -- self._ccbOwner.btn_setting:setPositionX( -409 )
        -- self._ccbOwner.btn_preview:setPositionX( -516.5 )
        self._ccbOwner.node_preview:setPositionX( -409 )
    elseif not remote.invasion:checkKillAwards() --[[and remote.robot:checkRobotUnlock()]] then
        -- 无奖励，有扫荡
        self._ccbOwner.node_kill_reward:setVisible(false)
        self._ccbOwner.kill_tips:setVisible(false)
        -- self._ccbOwner.btn_setting:setVisible( true )
        -- self._ccbOwner.btn_setting:setPositionX( -307 )
        -- self._ccbOwner.btn_preview:setPositionX( -409 )
        self._ccbOwner.node_preview:setPositionX( -307 )
    -- elseif remote.invasion:checkKillAwards() and not remote.robot:checkRobotUnlock() then
    --     -- 有奖励，无扫荡
    --     self._ccbOwner.btn_kill_reward:setVisible(true)
    --     self._ccbOwner.kill_tips:setVisible(true)
    --     self._ccbOwner.btn_setting:setVisible( false )
    --     -- self._ccbOwner.btn_setting:setPositionX( -307 )
    --     self._ccbOwner.btn_preview:setPositionX( -409 )
    -- elseif not remote.invasion:checkKillAwards() and not remote.robot:checkRobotUnlock() then
    --     -- 无奖励，无扫荡
    --     self._ccbOwner.btn_kill_reward:setVisible(false)
    --     self._ccbOwner.kill_tips:setVisible(false)
    --     self._ccbOwner.btn_setting:setVisible( false )
    --     -- self._ccbOwner.btn_setting:setPositionX( -307 )
    --     self._ccbOwner.btn_preview:setPositionX( -307 )
    end

    -- if remote.robot:checkRobotUnlock() then
    --     self._ccbOwner.btn_setting:setVisible( true )
    -- else
       
    --     self._ccbOwner.btn_setting:setVisible( false )
    -- end
end

function QUIDialogInvasion:checkFastFightUnlock()
    local unlock = app.unlock:checkLock("UNLOCK_INTRUSION_SAODANG")

    self._ccbOwner.btn_fastFighter_1:setVisible(unlock)
    self._ccbOwner.btn_fastFighter_2:setVisible(unlock)
    self._ccbOwner.btn_fastFighter_3:setVisible(unlock)
    if not app:getUserData():getValueForKey("UNLOCK_INTRUSION_SAODANG"..remote.user.userId) and unlock then
        self._ccbOwner.node_fastFighter1_effect:setVisible(true)
        self._ccbOwner.node_fastFighter2_effect:setVisible(true)
        self._ccbOwner.node_fastFighter3_effect:setVisible(true)
    end    
end

function QUIDialogInvasion:triggerFastFightByIndex(index)

end

function QUIDialogInvasion:_openBossInfoDialog(afterBattle, bossId, userId)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasionBoss", 
        options = {afterBattle = afterBattle, bossId = bossId, userId = userId}})
end

function QUIDialogInvasion:_openFastFightDialog(afterBattle, bossId, userId)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasionFastFight", 
        options = {afterBattle = afterBattle, bossId = bossId, userId = userId}})
end

function QUIDialogInvasion:_onTriggerBoss1()
    if self._inAnimation == true then return end
    app.sound:playSound("common_small")
    self:triggerBossByIndex(1, handler(self, self._openBossInfoDialog))
end

function QUIDialogInvasion:_onTriggerBoss2()
    if self._inAnimation == true then return end
    app.sound:playSound("common_small")
    self:triggerBossByIndex(2, handler(self, self._openBossInfoDialog))
end

function QUIDialogInvasion:_onTriggerBoss3()
    if self._inAnimation == true then return end
    app.sound:playSound("common_small")
    self:triggerBossByIndex(3, handler(self, self._openBossInfoDialog))
end

function QUIDialogInvasion:_onTriggerFastFighter1()
    if self._inAnimation == true then return end
    self:checkFastFightEffect()
    app.sound:playSound("common_small")
    self:triggerBossByIndex(1, handler(self, self._openFastFightDialog))
end

function QUIDialogInvasion:_onTriggerFastFighter2()
    if self._inAnimation == true then return end
    self:checkFastFightEffect()
    app.sound:playSound("common_small")
    self:triggerBossByIndex(2, handler(self, self._openFastFightDialog))
end

function QUIDialogInvasion:_onTriggerFastFighter3()
    if self._inAnimation == true then return end
    app.sound:playSound("common_small")
    self:checkFastFightEffect()
    self:triggerBossByIndex(3, handler(self, self._openFastFightDialog))
end

function QUIDialogInvasion:checkFastFightEffect()
    if not app:getUserData():getValueForKey("UNLOCK_INTRUSION_SAODANG"..remote.user.userId) then
        app:getUserData():setValueForKey("UNLOCK_INTRUSION_SAODANG"..remote.user.userId, "true")
        self._ccbOwner.node_fastFighter1_effect:setVisible(false)
        self._ccbOwner.node_fastFighter2_effect:setVisible(false)
        self._ccbOwner.node_fastFighter3_effect:setVisible(false)
    end   
end


function QUIDialogInvasion:_onTriggerDungeon(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_goFuben) == false then return end
    app.sound:playSound("common_small")
    app:showCloudInterlude(function( cloudInterludeCallBack )
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMap", options = {cloudInterludeCallBack = cloudInterludeCallBack}})
        end)
end

function QUIDialogInvasion:_onTriggerRefresh()
    app.sound:playSound("common_small")
    remote.invasion:intrusionBossRefreshRequest(function()
            self:refresh()
        end)
end

function QUIDialogInvasion:_onTriggerWorldBoss()
    app.sound:playSound("common_small")

    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.WORLDBOSS) then
        app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.WORLDBOSS)
    end
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBoss"})
end

function QUIDialogInvasion:_onTriggerLegendMonster()

    local invasion = remote.invasion:getSelfInvasion()
    if invasion.bossId ~=0 and not invasion.share then
        app.tip:floatTip("您的魂兽区没有魂兽时才可以召唤传说魂兽")
        return
    end

    if #self._invasions >= 3 then
        app.tip:floatTip("您的魂兽区有空间时才可以召唤传说魂兽")
        return
    end

    local energyConsume = remote.invasion:getEnergyConsume()
    local cost  = db:getConfigurationValue("intrusion_energy_consume") or 1 
    if energyConsume < cost then
        app.tip:floatTip("本日消耗体力达到"..cost.."才可召唤传说魂兽")
        return 
    end
    local bossSummonCount = remote.invasion:getBossSummonCount()
    local totalCount  = db:getConfigurationValue("intrusion_boss_summon_max_count") or 1 

    if bossSummonCount >= totalCount then
        app.tip:floatTip("您今天已召唤过传说魂兽，每天5点重置召唤次数")
        return 
    end

    app:alert({content = "##n是否要召唤传说魂兽？", title = "召唤确认", 
        callback = function(callType)
            if callType == ALERT_TYPE.CONFIRM then
                remote.invasion:intrusionGenerateBossRequest(function(data)
                    if self:safeCheck() then

                        self:refresh()
                    end
                end)
            end
        end, isAnimation = true, colorful = true}, true, true)   

end

function QUIDialogInvasion:_onTriggerReward()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasionReward", 
        options = {closeCallback = function ( ... )
            self:refresh()
        end}})
end

function QUIDialogInvasion:_onTriggerRank()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
        options = {initRank = "invasion"}})
end

function QUIDialogInvasion:_onTriggerRule( ... )
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasionHelp"})
end

function QUIDialogInvasion:_onTriggerStore()
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.invasionShop)
end

function QUIDialogInvasion:_onTriggerKillAward()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasionKillAward", options = {callBack = function()
            if self:safeCheck() then
                self:checkIsHaveKillAwards()
                self:setChestInfo()
            end
        end}})
end

function QUIDialogInvasion:_onTriggerSetting()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRobotInvasionSetting"}, {isPopCurrentDialog = false})
end

function QUIDialogInvasion:_onTriggerPrevirw()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChestPreview", 
        options = {previewType = 28, title = {"金色宝箱", "紫色宝箱", "蓝色宝箱"}}})
end

function QUIDialogInvasion:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogInvasion:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogInvasion