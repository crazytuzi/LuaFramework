--[[
    Class name: QBattleScene
    Create by Julian
    QBattleScene is a scene inherit from QBaseScene that display and control the battle process
--]]

local QBaseScene = import(".QBaseScene")
local QBattleScene = class("QBattleScene", QBaseScene)

local QFileCache = import("..utils.QFileCache")
local QBaseActorView = import("..views.QBaseActorView")
local QTouchActorView = import("..views.QTouchActorView")
local QHeroActorView = import("..views.QHeroActorView")
local QNpcActorView = import("..views.QNpcActorView")
local QUFOView = import("..views.QUFOView")
local QDragLineController = import("..controllers.QDragLineController")
local QTouchController = import("..controllers.QTouchController")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QBattleManager = import("..controllers.QBattleManager")
local QSkeletonViewController = import("..controllers.QSkeletonViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QPositionDirector = import("..utils.QPositionDirector")
local QActor = import("..models.QActor")
local QSkill = import("..models.QSkill")
local QUserData = import("..utils.QUserData")
local QHeroStatusView = import("..ui.battle.QHeroStatusView")
local QSupporterStatusView = import("..ui.battle.QSupporterStatusView")
local QSoulSpiritStatusView = import("..ui.battle.QSoulSpiritStatusView")
local QBattleDialog = import("..ui.battle.QBattleDialog")
local QBattleDialogGameRule = import("..ui.battle.QBattleDialogGameRule")
local QBattleDialogPause = import("..ui.battle.QBattleDialogPause")
local QBattleDialogAutoSkill = import("..ui.battle.QBattleDialogAutoSkill")
local QBattleDialogMissions = import("..ui.battle.QBattleDialogMissions")
local QBattleDialogBossIntroduction = import("..ui.battle.QBattleDialogBossIntroduction")
local QBattleDialogWaveResult= import("..ui.battle.QBattleDialogWaveResult")
local QBossHpView = import("..ui.battle.QBossHpView")
local QBossHpViewMultilayer = import("..ui.battle.QBossHpViewMultilayer")
local QBossHpViewInfinite = import("..ui.battle.QBossHpViewInfinite")
local QBaseEffectView = import("..views.QBaseEffectView")
local QDialogTeamUp = import("..ui.battle.QDialogTeamUp")
local QUIWidgetTutorialHandTouch = import("..ui.widgets.QUIWidgetTutorialHandTouch")
local QUIWidgetTutorialDialogue = import("..ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetBattleTutorialDialogue = import("..ui.widgets.QUIWidgetBattleTutorialDialogue")
local QUIWidgetItemsBox = import("..ui.widgets.QUIWidgetItemsBox")
local QUIWidgetBlackRockTeamDungeon = import("..ui.widgets.blackrock.QUIWidgetBlackRockTeamDungeon")
local QBattleMissionTracer = import("..tracer.QBattleMissionTracer")
local QEntranceBase = import("..cutscenes.QEntranceBase")
local QKreshEntrance = import("..cutscenes.QKreshEntrance")
local QNavigationController = import("..controllers.QNavigationController")
local QMissionBase = import("..tracer.mission.QMissionBase")
local QUIWidgetAnimationPlayer = import("..ui.widgets.QUIWidgetAnimationPlayer")
local QTextFiledScrollUtils = import("..utils.QTextFiledScrollUtils")
local QUIWidgetAvatar = import("..ui.widgets.QUIWidgetAvatar")
local QReplayUtil = import("..utils.QReplayUtil")
local QBattleDialogAgainstRecord = import("..ui.battle.QBattleDialogAgainstRecord")
local QBattleDialogFightEndRecord = import("..ui.battle.QBattleDialogFightEndRecord")
local QBuriedPoint = import("..utils.QBuriedPoint")
local QVIPUtil = import("..utils.QVIPUtil")
local QMountSkillView = import("..ui.battle.QMountSkillView")
local QBattleDialogNewEnemyTips = import("..ui.battle.QBattleDialogNewEnemyTips")
local QFullCircleUiMask = import("..ui.battle.QFullCircleUiMask")

local QActorProp = import("..models.QActorProp")
local QLogFile = import("..utils.QLogFile")
local QBattleResultProxy = import("..ui.battle.result.QBattleResultProxy")

local QRichText = import("..utils.QRichText")

local QBattleDialogPVEWaveEnd= import("..ui.battle.QBattleDialogPVEWaveEnd")
local QBattleDialogPVPWaveResult= import("..ui.battle.QBattleDialogPVPWaveResult")
local QBattleDialogImageDialog= import("..ui.battle.QBattleDialogImageDialog")
local QVideoPlayer = import("..video.QVideoPlayer")

local QBattleDialogConsortiaWar = import("..ui.battle.QBattleDialogConsortiaWar")
--[[
    member of QBattleScene:
--]]

QBattleScene.TSPRTOFFSET = 110 --当有两个魂灵时，援助技能图标的Y轴偏移

function QBattleScene:ctor(config)
    -- self:setPositionY((display.height - BATTLE_SCREEN_HEIGHT / BATTLE_SCREEN_WIDTH * display.width) / 2)
    local owner = {}
    local database = QStaticDatabase.sharedDatabase()
    QBattleScene.super.ctor(self, {ccbi = config.scene, owner = owner})

    local this = self
    self._ccbOwner = setmetatable({}, {__index = function(tab, key)
        local reKey = key .. "_autoPvp"
        if this:isAutoTwoWavePVP() and  owner[reKey] ~= nil then
            return owner[reKey]
        else
            return owner[key]
        end
    end})

    self._dungeonConfig = config
    if self._dungeonConfig.mode == nil then
        self._dungeonConfig.mode = BATTLE_MODE.SEVERAL_WAVES
    end
    
    self._isSkipVideo = true --是否点击视频跳过了
    self._heroPisition = config.heroPosition
    
    self._resultProxy = QBattleResultProxy.new({battleScene = self})

    self._isHaveMissions = remote.instance:checkDungeonIsShowStar(self._dungeonConfig.id)
    self._isPassedBefore = false
    local passInfo = remote.instance:getPassInfoForDungeonID(self._dungeonConfig.id)
    if passInfo ~= nil and passInfo.star ~= nil and passInfo.star >= 3 then
        self._isPassedBefore = true
    end
    self._isActiveDungeon = self._dungeonConfig.isActiveDungeon
    if self._isActiveDungeon then
        self._activeDungeonInfo = remote.activityInstance:getDungeonById(self._dungeonConfig.id)
    end

    local autoSkill_ccbProxy = CCBProxy:create()
    local autoSkill_ccbOwner = {}
    autoSkill_ccbOwner.onClickAutoSkill = handler(self, QBattleScene._onAutoSkillClicked)
    self._autoSkillBar = CCBuilderReaderLoad("Battle_But_AutoSkill.ccbi", autoSkill_ccbProxy, autoSkill_ccbOwner)
    self._autoSkillBar:setPosition(self._ccbOwner.node_autoSkillButton:getPosition())
    self._autoSkillBar:setVisible(not self:isInDragon())
    self._autoSkillBar:setVisible(not self:isAutoTwoWavePVP())
    
    self:addUI(self._autoSkillBar)

    local topBar_ccbProxy = CCBProxy:create()
    local topBar_ccbOwner = {}
    if self:isPVPMode() == true then
        if self:isInArena() or self:isInSilverMine() or self:isInSilvesArena() or self:isInMetalAbyss() then
            if self._dungeonConfig.isReplay and not self._dungeonConfig.isQuick or self._dungeonConfig.isFriend or self._dungeonConfig.isTotemChallenge then
                topBar_ccbOwner.onPause = handler(self, QBattleScene._onPauseButtonClicked)
                self._topBar = CCBuilderReaderLoad("Battle_Sunwell_TopBar.ccbi", topBar_ccbProxy, topBar_ccbOwner)
            elseif self._dungeonConfig.isPVPMultipleWave then
                self._topBar = CCBuilderReaderLoad("Battle_StormArena_TopBar.ccbi", topBar_ccbProxy, topBar_ccbOwner)
            else
                self._topBar = CCBuilderReaderLoad("Battle_Arena_TopBar.ccbi", topBar_ccbProxy, topBar_ccbOwner)
            end
        elseif self:isInSunwell() then
            topBar_ccbOwner.onPause = handler(self, QBattleScene._onPauseButtonClicked)
            self._topBar = CCBuilderReaderLoad("Battle_Sunwell_TopBar.ccbi", topBar_ccbProxy, topBar_ccbOwner)
        else
            assert(false, "Unknown PVP Mode!")
        end
        self._topBar:setPosition(0, display.height)
        self._labelCountDown = topBar_ccbOwner.label_Countdown
        self._labelCountDown:setVisible(false)
        if self._dungeonConfig.isPvpMultipleNew then
            local owner = {}
            local node = CCBuilderReaderLoad("Widget_StormArena_bifen.ccbi", CCBProxy:create(), owner)
            self._labelCountDown = owner.ttf_time
            self._labelCountDown:setVisible(false)
            local score_1, score_2 = 0, 0
            if self._dungeonConfig._newPvpMultipleScoreInfo then
                score_1 = self._dungeonConfig._newPvpMultipleScoreInfo.heroScore
                score_2 = self._dungeonConfig._newPvpMultipleScoreInfo.enemyScore
            end
            owner.score:setString(string.format("%s : %s", score_1, score_2))
            topBar_ccbOwner.sp_Countdown:setVisible(false)
            topBar_ccbOwner.time_number:addChild(node)
            if self._dungeonConfig.isReplay or self._dungeonConfig.isFriend or self._dungeonConfig.isTotemChallenge then
                topBar_ccbOwner.time_number:setPositionY(0)
            end
        end

        if self._dungeonConfig.team1Name ~= nil then
            topBar_ccbOwner.CCLabelTFF_TeamName1:setString(self._dungeonConfig.team1Name)
        end
        if self._dungeonConfig.team1Icon ~= nil then
            topBar_ccbOwner.node_head1:addChild(QUIWidgetAvatar.new(self._dungeonConfig.team1Icon))
        end

        if self._dungeonConfig.team2Name ~= nil then
            topBar_ccbOwner.CCLabelTFF_TeamName2:setString(self._dungeonConfig.team2Name)
        end
        if self._dungeonConfig.team2Icon ~= nil then
            topBar_ccbOwner.node_head2:addChild(QUIWidgetAvatar.new(self._dungeonConfig.team2Icon))
        end
    else
        topBar_ccbOwner.onPause = handler(self, QBattleScene._onPauseButtonClicked)
        -- topBar_ccbOwner.onClickMission = handler(self, QBattleScene._onMissionButtonClicked)
        self._topBar = CCBuilderReaderLoad("Battle_Widget_TopBar.ccbi", topBar_ccbProxy, topBar_ccbOwner)
        self._topBar:setPosition(0, display.height)
        self._labelCountDown = topBar_ccbOwner.label_Countdown
        self._labelCountDown:setVisible(false)
        self._labelMoney = topBar_ccbOwner.label_money
        self._labelMoneyNode = topBar_ccbOwner.money_node
        self._currentMoney = 0
        self._labelMoney:setString("0")
        self._labelChest = topBar_ccbOwner.label_chest
        self._labelChestNode = topBar_ccbOwner.chest_node
        self._currentChest = 0
        self._labelChest:setString("0")
        self._sprite_money = topBar_ccbOwner.sprite_money
        self._sprite_item = topBar_ccbOwner.sprite_item
        self._labelWave = topBar_ccbOwner.label_wave
        self._metalcityWave = topBar_ccbOwner.metalcity_wave
        self._metalcityWave:setVisible(false)
        self._labelWave:setVisible(false)
        self._waveBackground = topBar_ccbOwner.sprite_waveBackground
        self._waveBackground:setVisible(false)
        self._missionCompleteNode = topBar_ccbOwner.node_MissionComplete
        self._starRoot = topBar_ccbOwner.node_starRoot
        self._starOff1 = topBar_ccbOwner.node_starOff1
        self._starOff1:setVisible(true)
        self._starOff2 = topBar_ccbOwner.node_starOff2
        self._starOff2:setVisible(true)
        self._starOff3 = topBar_ccbOwner.node_starOff3
        self._starOff3:setVisible(true)
        self._starOn1 = topBar_ccbOwner.node_starOn1
        self._starOn1:setVisible(false)
        self._starOn2 = topBar_ccbOwner.node_starOn2
        self._starOn2:setVisible(false)
        self._starOn3 = topBar_ccbOwner.node_starOn3
        self._starOn3:setVisible(false)
        self._labelDeadEnemies = topBar_ccbOwner.label_deadEnemies

        self._moneyUpdate = QTextFiledScrollUtils.new()
        self._chestUpdate = QTextFiledScrollUtils.new()
        topBar_ccbOwner.reward_node:setVisible(false)
        if config.dailyAwards then
            self._labelChest = topBar_ccbOwner.raward_text
            topBar_ccbOwner.reward_node:setVisible(true)
            topBar_ccbOwner.chest_node:setVisible(false)
            topBar_ccbOwner.reward_item_bg:setVisible(false)
            topBar_ccbOwner.sprite_item:setVisible(false)
            topBar_ccbOwner.node_reward_money:setVisible(false)
        end

        if self._isHaveMissions == false or self._isActiveDungeon == true then
            self._starRoot:setVisible(false)
        end

        if self:isMoneyDungeon() then
            self._labelChestNode:setVisible(false)
            self._labelMoneyNode:setVisible(true)
        else
            self._labelChestNode:setVisible(true)
            self._labelMoneyNode:setVisible(false)
        end
        if config.isSoulTower then
            self._labelChestNode:setVisible(false)
            self._labelMoneyNode:setVisible(false)
        end

        if config.boss_hp_infinite then
            self._bossHpBar = QBossHpViewInfinite.new()
        elseif self:_isBossHpViewMultiLayer() then
            self._bossHpBar = QBossHpViewMultilayer.new()
        else
            self._bossHpBar = QBossHpView.new()
        end
        if config.isTutorial then
            self:addUI(self._bossHpBar)
            self._bossHpBar:setPosition(display.width * 0.75, display.height * 0.92)
        else
            topBar_ccbOwner.node_bossHealth:addChild(self._bossHpBar)
        end
        self._bossHpBar:setVisible(false)

        if self:isInRebelFight() == true or self:isInWorldBoss() or self:isInSocietyDungeon() or self:isInDragon() then
            topBar_ccbOwner.node_topBar:setVisible(false)
        end

        if self:isInWorldBoss() or self:isInDragon() or self:isMazeExplore() then
            topBar_ccbOwner.node_reward_money:setVisible(false)
        end

        if self:isInDragon() or (self._dungeonConfig.isActiveDungeon == true and self._dungeonConfig.activeDungeonType == DUNGEON_TYPE.ACTIVITY_TIME) then
            self._labelCountDown:setPositionX(0)
        end
    end
    if topBar_ccbOwner.node_thunder then
        topBar_ccbOwner.node_thunder:setVisible(false)
    end
    self._topBar_ccbOwner = topBar_ccbOwner

    
    self:addUI(self._topBar)

    self._isAutoSkillLocked = true
    self._isClickAutoSkillEver = false;
    if app.unlock:getUnlockAutoSkill() then
        self._isAutoSkillLocked = false
        local isClicked = app:getUserData():getUserValueForKey(QUserData.CLICK_AUTO_SKILL)
        if isClicked ~= nil and isClicked == QUserData.STRING_TRUE then
            self._isClickAutoSkillEver = true
            autoSkill_ccbOwner.node_autoSkillLight:setVisible(false)
        else
            autoSkill_ccbOwner.node_autoSkillLight:setVisible(true)
            self._node_autoSkillLight = autoSkill_ccbOwner.node_autoSkillLight
        end 
    else
        autoSkill_ccbOwner.sprite_lock:setVisible(true)
        autoSkill_ccbOwner.node_autoSkillLight:setVisible(false)
        local button = autoSkill_ccbOwner.btn_autoskill
        button:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_auto_skill"), CCControlStateHighlighted)
    end
    self._autoSkill_ccbowner = autoSkill_ccbOwner

    local arrow_ccbProxy = CCBProxy:create()
    local arrow_ccbOwner = {}
    arrow_ccbOwner.onTriggerNext = handler(self, QBattleScene._onNextWaveClicked)
    self._arrow = CCBuilderReaderLoad("effects/arrow_battle.ccbi", arrow_ccbProxy, arrow_ccbOwner)
    self._arrow:setPosition(self._ccbOwner.node_arrow:getPosition())
    
    self:addUI(self._arrow)
    self._arrow:setVisible(false)

    local bgFileName = ""
    if self._dungeonConfig.bg ~= nil then
        local bgs = string.split(self._dungeonConfig.bg, ";")
        if string.find(bgs[1], "%", 1, true) then
            local percent = 1.0
            if self._dungeonConfig.isInRebelFight and self._dungeonConfig.rebelHP and self._dungeonConfig.rebelHP > 0 then
                local character_id = self._dungeonConfig.rebelID
                local level = self._dungeonConfig.rebelLevel
                local data = db:getCharacterDataByID(character_id, level)
                local maxHP = (data.hp_value or 0) + (data.hp_grow or 0) * level
                percent = self._dungeonConfig.rebelHP / maxHP
            elseif self._dungeonConfig.isInWorldBossFight and self._dungeonConfig.worldBossHP and self._dungeonConfig.worldBossHP > 0 then
                local character_id = self._dungeonConfig.worldBossID
                local level = self._dungeonConfig.worldBossLevel
                local data = db:getCharacterDataByID(character_id, level)
                local maxHP = (data.hp_value or 0) + (data.hp_grow or 0) * level
                percent = self._dungeonConfig.worldBossHP / maxHP
            elseif self._dungeonConfig.isUnionDragonWar and self._dungeonConfig.unionDragonWarBossHp and self._dungeonConfig.unionDragonWarBossHp > 0 then
                local character_id = self._dungeonConfig.unionDragonWarBossId
                local level = self._dungeonConfig.unionDragonWarBossLevel
                local data = db:getCharacterDataByID(character_id, level)
                local maxHP = (data.hp_value or 0) + (data.hp_grow or 0) * level
                percent = self._dungeonConfig.unionDragonWarBossHp / maxHP
            end
            for _, bg in ipairs(bgs) do
                bg = string.split(bg, ",")
                if percent <= tonumber(string.sub(bg[1], 1, string.len(bg[1]) - 1)) / 100  then
                    bgFileName = bg[2]
                else
                    break
                end
            end
        else
            bgFileName = bgs[math.random(1, #bgs)]
        end
    else
        bgFileName = "map/arena.jpg"
    end
    if self._dungeonConfig.isSilverMine then
        local mineId = self._dungeonConfig.mineId
        local caveRegion = 1
        if self._dungeonConfig.isSectHunting then
            caveRegion = remote.plunder:getCaveConfigByMineId(mineId).cave_region
            if caveRegion == PAGE_NUMBER.ONE then
                bgFileName = db:getDungeonConfigByID("silvermine_3").bg
            elseif caveRegion == PAGE_NUMBER.TWO then
                bgFileName = db:getDungeonConfigByID("silvermine_4").bg
            end
        else
            caveRegion = remote.silverMine:getCaveConfigByMineId(mineId).cave_region
            if caveRegion == PAGE_NUMBER.ONE then
                bgFileName = db:getDungeonConfigByID("silvermine_1").bg
            elseif caveRegion == PAGE_NUMBER.TWO then
                bgFileName = db:getDungeonConfigByID("silvermine_2").bg
            end
        end
    elseif self._dungeonConfig.isUnionDragonWar and self._dungeonConfig.unionDragonWarWeatherId then
        bgFileName = db:getDragonWarWeatherById(self._dungeonConfig.unionDragonWarWeatherId).bg_scene or bgFileName
    end
    self:replaceBGFile(bgFileName, nil, true)

    self._dungeonBGNodes = {}
    if self._dungeonConfig.bg_2 ~= nil then
        local bgFileName = ""
        local bgs = string.split(self._dungeonConfig.bg_2, ";")
        bgFileName = bgs[math.random(1, #bgs)]
        local bgNode = self:_createBGFile(bgFileName)
        if bgNode ~= nil then
            bgNode:retain()
            self._dungeonBGNodes[2] = {bgFileName, bgNode}
        end
    end
    if self._dungeonConfig.bg_3 ~= nil then
        local bgFileName = ""
        local bgs = string.split(self._dungeonConfig.bg_3, ";")
        bgFileName = bgs[math.random(1, #bgs)]
    
        local bgNode = self:_createBGFile(bgFileName)
        if bgNode ~= nil then
            bgNode:retain()
            self._dungeonBGNodes[3] = {bgFileName, bgNode}
        end
    end
   

    self._groundEffectView = {}
    self._heroViews = {}
    self._heroStatusViews = {}
    self._enemyStatusViews = {}
    self._enemyViews = {}
    self._effectViews = {}
    self._frontEffectView = {}
    self._loopSkillSoundEffects = {}

    self._showBlackLayerReferenceCount = 0

    local tip_cache = self.createTipCache()
    if self._dungeonConfig.isPVPMode then
        tip_cache.makeRoom("effects/Heal_number.ccbi", 16)
        tip_cache.makeRoom("effects/Attack_Ynumber.ccbi", 16)
        tip_cache.makeRoom("effects/Attack_number.ccbi", 25)
        tip_cache.makeRoom("effects/Attack_baoji.ccbi", 10)
        tip_cache.makeRoom("effects/Attack_Ybaoji.ccbi", 10)
    else
        tip_cache.makeRoom("effects/Heal_number.ccbi", 8)
        tip_cache.makeRoom("effects/Attack_Ynumber.ccbi", 8)
        tip_cache.makeRoom("effects/Attack_number.ccbi", 8)
        tip_cache.makeRoom("effects/Attack_baoji.ccbi", 4)
        tip_cache.makeRoom("effects/Attack_Ybaoji.ccbi", 4)
    end
    if string.find(self._dungeonConfig.id, "booty_bay") or string.find(self._dungeonConfig.id, "dwarf_cellar") then
        tip_cache.makeRoom("effects/Box2.ccbi", 15)
        tip_cache.makeRoom("effects/Box.ccbi", 15)
        tip_cache.makeRoom("effects/ItemFall_end.ccbi", 9)
    else
        tip_cache.makeRoom("effects/Box2.ccbi", 6)
        tip_cache.makeRoom("effects/Box.ccbi", 6)
        tip_cache.makeRoom("effects/ItemFall_end.ccbi", 6)
    end
    self._tip_cache = tip_cache

    local owner = {}
    local node = CCBuilderReaderLoad("effects/fire_wall.ccbi", CCBProxy:create(), owner)
    node:setPosition(ccp(display.cx, display.cy))
    self:addUI(node, false)
    node:setVisible(false)
    -- node:setContentSize(CCSize(display.width, display.height))
    self._fireWall = node
    CalculateUIBgSize(self._fireWall , 1280)

    local owner = {onTriggerInfo = handler(self, self._onClickLostCountInfo)}
    local node = CCBuilderReaderLoad("Battle_Addbuff.ccbi", CCBProxy:create(), owner)
    node:setPosition(ccp(60, display.height - 120))
    
    self:addUI(node)
    node:setVisible(false)
    self._lostCount = node
    self._lostCountOwner = owner

    local owner = {}
    local node = CCBuilderReaderLoad("Widget_fight_buff.ccbi", CCBProxy:create(), owner)
    node:setPosition(ccp(0, display.height - 180))
    
    self:addUI(node)
    node:setVisible(false)
    self._lostCountInfo = node
    self._lostCountInfoOwner = owner

    -- 武将击杀动画
    if QFcaSkeletonView_cpp ~= nil and ENABLE_FCA_CPP then
        --self._killActorAnimation1 = QBaseEffectView.new("effect/fca/dijiangjisha_1")
        self._killActorAnimation2 = QBaseEffectView.new("effect/fca/dijiangjisha_2")
        self._killActorAnimation3 = QBaseEffectView.new("effect/fca/dijiangjisha_3")
    end
    self._anim1end = false
    self._anim2end = false
    self._anim3end = false

    self:addUI(self._killActorAnimation3, false)
    self._backgroundLayer:addChild(self._killActorAnimation2)
    --self:addUI(self._killActorAnimation1)
    --self._killActorAnimation1:setVisible(false)
    self._killActorAnimation2:setVisible(false)
    self._killActorAnimation3:setVisible(false)


    self._killActorAnimation3:setZOrder(998)
    --self._killActorAnimation1:setZOrder(999)

    --缩放 没取到contentsize 大概手动算了一下1.2
    -- self._killActorAnimation2:setScaleX(1.2)
    -- self._killActorAnimation2:setScaleY(1.2)

    -- 暗器动画
    self._heroMountSkillViews = {}
    for i = 1, 2 do
        local mountSkillView = QMountSkillView.new()
        mountSkillView:setPositionY(470 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2 - (i - 1) * 80)
        
        self:addUI(mountSkillView, false)
        self._heroMountSkillViews[i] = mountSkillView
    end
    self._enemyMountSkillViews = {}
    for i = 1, 2 do
        local mountSkillView = QMountSkillView.new()
        mountSkillView:setPositionY(470 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2 - (i - 1) * 80)
        mountSkillView:setPositionX(display.cx * 2)
        mountSkillView:setScaleX(-1)
        
        self:addUI(mountSkillView, false)
        self._enemyMountSkillViews[i] = mountSkillView
    end
    -- 暗器动画序列
    self._heroMountSkillQueue = {}
    self._enemyMountSkillQueue = {}

    self._startDelay = 0
    self._ended = false -- 战斗结束，比如获胜或者失败后，有些功能应该屏蔽掉，比如暂停。

    self:_debugCheat()
    -- self:_debugQuickBattle(config)
    self:_initPlaySpeedAndSkip(config)
    -- 魂灵 status view
    self._soulSpiritStatusViews = {}
    self._soulSpiritStatusViewsEnemy = {}

    self._candidateHeroAnimationList = {}
    self._candidateEnemyAnimationList = {}
    -- hero 神器弹出动画
    local owner = {}
    local node = CCBuilderReaderLoad("effects/shenqi_tanchu_1.ccbi", CCBProxy:create(), owner)
    node:setPosition(ccp(0, 170))
    self:addUI(node)
    
    node:setVisible(false)
    node:setZOrder(100)
    self._godArmAnimationSS = node
    self._godArmOwnerSS = owner
    -- enemy 神器弹出动画
    local owner = {}
    local node = CCBuilderReaderLoad("effects/shenqi_tanchu_1.ccbi", CCBProxy:create(), owner)
    node:setPosition(ccp(display.width, 170))
    self:addUI(node, nil, true)
    
    node:setVisible(false)
    node:setZOrder(100)
    self._enemyGodArmAnimationSS = node
    self._enemyGodArmOwnerSS = owner
    local owner = {}
    local node = CCBuilderReaderLoad("effects/shenqi_tanchu.ccbi", CCBProxy:create(), owner)
    node:setPosition(ccp(0, 170))
    self:addUI(node)
    
    node:setVisible(false)
    node:setZOrder(100)
    self._godArmAnimation = node
    self._godArmOwner = owner
    -- enemy 神器弹出动画
    local owner = {}
    local node = CCBuilderReaderLoad("effects/shenqi_tanchu.ccbi", CCBProxy:create(), owner)
    node:setPosition(ccp(display.width, 170))
    self:addUI(node, nil, true)
    
    node:setVisible(false)
    node:setZOrder(100)
    self._enemyGodArmAnimation = node
    self._enemyGodArmOwner = owner

    self._ccbOwner.autoPvpUI:setVisible(not not self:isAutoTwoWavePVP())
    CalculateBattleUIPosition(self._ccbOwner.autoPvpUI)
end

function QBattleScene:checkBossDeadAnimationEnd()
    if --[[self._anim1end and ]]self._anim2end and self._anim3end then
        self._is_not_kill_animation_end = false
        --self._killActorAnimation1:setVisible(false)
        app.battle:setTimeGear(self._bossDeadTimeGear)
    end
end
function QBattleScene:_onSkeletonActorAnimationEvent1(eventType, trackIndex, animationName, loopCount)
    self._anim1end = true
    self:checkBossDeadAnimationEnd()
end
function QBattleScene:_onSkeletonActorAnimationEvent2(eventType, trackIndex, animationName, loopCount)
    self._anim2end = true
    self._killActorAnimation2:setVisible(false)
    self:checkBossDeadAnimationEnd()
end
function QBattleScene:_onSkeletonActorAnimationEvent3(eventType, trackIndex, animationName, loopCount)
    self._anim3end = true
    self._killActorAnimation3:setVisible(false)
    self:checkBossDeadAnimationEnd()
end
function QBattleScene:_isBossHpViewMultiLayer()
    return (self._dungeonConfig.activity_date == nil or string.find(self._dungeonConfig.id, "strength") or string.find(self._dungeonConfig.id, "wisdom")) and not self._dungeonConfig.isInRebelFight and not self._dungeonConfig.isSocietyDungeon and not self._dungeonConfig.isInWorldBossFight and not self._dungeonConfig.isInUnionDragonWar
end

function QBattleScene:showHeroStatusViews()
    for _, view in ipairs(self._heroStatusViews) do
        view:getParent():setVisible(true)
    end
end

function QBattleScene:hideHeroStatusViews()
    for _, view in ipairs(self._heroStatusViews) do
        view:getParent():setVisible(false)
    end
end

function QBattleScene:showHeroStatusViews2()
    for _, view in ipairs(self._heroStatusViews) do
        view:getParent():setScale(1)
    end
end

function QBattleScene:hideHeroStatusViews2()
    for _, view in ipairs(self._heroStatusViews) do
        view:getParent():setScale(0)
    end
end

function QBattleScene:showHeroStatusView(i, isPlayAnimation)
    if isPlayAnimation == nil then
        isPlayAnimation = true
    end
    self._heroStatusViews[i]:setVisible(true)
    self:_handleHeroStatusView(i, isPlayAnimation)
end

function QBattleScene:hideHeroStatusView(i, isPlayAnimation)
    if isPlayAnimation == nil then
        isPlayAnimation = false
    end
    self._heroStatusViews[i]:setVisible(false)
    self:_handleHeroStatusView(i, isPlayAnimation)
end

-- 添加助战魂师的控制widget
function QBattleScene:addHeroStatusView(actor, isPlayAnimation)
    if #self._heroStatusViews == 4 then
        return
    end

    local heroStatusView = QHeroStatusView.new(actor:isNeedComboPoints())
    heroStatusView:setHero(actor)
    
    self:addUI(heroStatusView)
    table.insert(self._heroStatusViews, heroStatusView)

    if isPlayAnimation == nil then
        isPlayAnimation = true
    end
    self:showHeroStatusView(#self._heroStatusViews, isPlayAnimation)
end

-- 删除助战魂师的控制widget
function QBattleScene:removeHeroStatusView(actor)
    for i, heroStatusView in ipairs(self._heroStatusViews) do
        if heroStatusView:getActor() == actor then
            self:hideHeroStatusView(i)
            break
        end
    end
end

function QBattleScene:removeAllHeroStatusViews()
    for i, heroStatusView in ipairs(self._heroStatusViews) do
        heroStatusView:removeFromParentAndCleanup(true)
    end
    self._heroStatusViews = {}
end

function QBattleScene:removeAllEnemyStatusViews()
    for i, enemyStatusView in ipairs(self._enemyStatusViews) do
        enemyStatusView:removeFromParentAndCleanup(true)
    end
    self._enemyStatusViews = {}
end

function QBattleScene:getHeroStatusViews()
    return self._heroStatusViews
end

function QBattleScene:getHeroStatusViewByActor(actor)
    for _, heroStatusView in ipairs(self._heroStatusViews) do
        if heroStatusView:getActor() == actor then
            return heroStatusView
        end
    end
end 

function QBattleScene:_handleHeroStatusView(viewIndex, isPlayAnimation)
    if viewIndex <= 0 or viewIndex > #self._heroStatusViews then
        return
    end

    local indices = {}
    for i, view in ipairs(self._heroStatusViews) do
        if view:isVisible() == true then
            table.insert(indices, i)
        end
    end

    local count = #indices
    if count == 0 then
        return
    end

    local animationTime = 0.5
    local nodeName

    for i, index in ipairs(indices) do
        local viewPos = self:getHeroSKillBtnPos(count, index)

        local x, y = viewPos.x, viewPos.y
        local heroStatusView = self._heroStatusViews[index]
        if isPlayAnimation == true then
            if viewIndex == index then
                heroStatusView:setPosition(x, y)
            else
                heroStatusView:runAction(CCEaseIn:create(CCMoveTo:create(animationTime, ccp(x, y)), 5))
            end
        else
            heroStatusView:setPosition(x, y)
        end
    end

    if isPlayAnimation == true then
        local heroStatusView = self._heroStatusViews[viewIndex]
        if heroStatusView:isVisible() == true then
            heroStatusView:setVisible(false)
            heroStatusView:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(animationTime), CCShow:create()))
        end
    end
end

function QBattleScene:_checkBattleStartDelay(startPosition, stopPosition, moveSpeed)
    if startPosition == nil or stopPosition == nil or moveSpeed == nil or moveSpeed <= 0 then
        return
    end

    local deltaX = startPosition.x - stopPosition.x
    local deltaY = startPosition.y - stopPosition.y
    local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
    local timeCost = distance / moveSpeed
    if self._startDelay < timeCost then
        self._startDelay = timeCost
    end
end

function QBattleScene:_prepareHeroes()
    -- create views for heroes
    local views = {}

    local function getHeroStatusView(hero) 
        if hero == nil then return nil end

        local cachedArray = self._dungeonConfig.heroStatusView
        if cachedArray == nil or #cachedArray == 0 then
            local view = QHeroStatusView.new(hero:isNeedComboPoints())
            view:setHero(hero)
            view:retain()
            return view

        else
            local view = cachedArray[1]
            table.remove(cachedArray, 1)
            view:setHero(hero)
            return view

        end
    end

    local offset = self:getSupportViewOffsetHero()
 
    local function getSupportView(supportUIcount, hero)
        local posNode = self._ccbOwner["node_fujingButton" .. supportUIcount]
        local view = QSupporterStatusView.new()
        view:setSupporter(hero)
        view:setPositionX(posNode:getPositionX())
        view:setPositionY(posNode:getPositionY() + offset)
        view:setScale(posNode:getScale())
        
        self:addUI(view)

        return view
    end

    if app.battle:isInTutorial() == true then
        local heros = app.battle:getHeroes()
        local heroCount = table.nums(heros)
        for i, hero in ipairs(heros) do
            local view = QHeroActorView.new(hero)
            table.insert(views, view)
            self:addSkeletonContainer(view)
            self:addHpAndDamageContainer(view:getHpAndDamageNode())

            -- manual skill button, hero hp and icon
            local j = heroCount - i + 1
            local viewPos = self:getHeroSKillBtnPos(heroCount, i)
            heroStatusView:setPosition(viewPos)
            
            self:addUI(heroStatusView) 
            heroStatusView:release()
            table.insert(self._heroStatusViews, heroStatusView)
        end

    elseif app.battle:isPVPMode() == true then
        local heros = app.battle:getHeroes()
        local heroCount = table.nums(heros)
        for i, hero in ipairs(heros) do
            local view = QHeroActorView.new(hero)
            if hero:isFlipX() then
                view:getSkeletonActor():flipActor()
            end
            table.insert(views, view)

            -- manual skill button, hero hp and icon
            local heroStatusView = getHeroStatusView(hero)
            local viewPos = self:getHeroSKillBtnPos(heroCount, i)
            heroStatusView:setPosition(viewPos)
            
            self:addUI(heroStatusView)
            heroStatusView:release()
            table.insert(self._heroStatusViews, heroStatusView)
        end
        for i, hero in ipairs(app.battle:getCandidateHeroes()) do
            local view = QHeroActorView.new(hero)
            view:setPosition(ccp(-display.width, -display.height))
            -- if hero:isFlipX() then view:getSkeletonActor():flipActor() end
            table.insert(views, view)
        end

        for i, view in ipairs(views) do
            local index = heroCount - i + 1
            self:addSkeletonContainer(view)
            self:addHpAndDamageContainer(view:getHpAndDamageNode())

            self:_checkBattleStartDelay(startPosition, stopPosition, view:getModel():getMoveSpeed())
        end
    else
        local heros = app.battle:getHeroes()
        local heroCount = table.nums(heros)

        for i, hero in ipairs(heros) do
            local view = QHeroActorView.new(hero)
            if hero:isFlipX() then
                view:getSkeletonActor():flipActor()
            end
            view:setPosition(ccp(-display.width, -display.height))
            table.insert(views, view)

            -- manual skill button, hero hp and icon
            local index = i
            local heroStatusView = getHeroStatusView(hero)
            local viewPos = self:getHeroSKillBtnPos(heroCount, i)
            heroStatusView:setPosition(viewPos)
            
            self:addUI(heroStatusView)
            heroStatusView:release()
            table.insert(self._heroStatusViews, heroStatusView)
        end
        
        for i, view in ipairs(views) do
            local index = heroCount - i + 1
            self:addSkeletonContainer(view)
            self:addHpAndDamageContainer(view:getHpAndDamageNode())
        end
    end

    -- 副将 魂师副将actor view 初始化
    local sprt = app.battle:getSupportSkillHero()
    if sprt then
        local view = QHeroActorView.new(sprt)
        if sprt:isFlipX() then
            view:getSkeletonActor():flipActor()
        end
        view:setPosition(sprt:getPosition().x, sprt:getPosition().y)
        table.insert(views, view)
        self:addSkeletonContainer(view)
        self:addHpAndDamageContainer(view:getHpAndDamageNode())
    end

    -- 副将2 魂师副将actor view 初始化
    local sprt = app.battle:getSupportSkillHero2()
    if sprt then
        local view = QHeroActorView.new(sprt)
        if sprt:isFlipX() then
            view:getSkeletonActor():flipActor()
        end
        view:setPosition(sprt:getPosition().x, sprt:getPosition().y)
        table.insert(views, view)
        self:addSkeletonContainer(view)
        self:addHpAndDamageContainer(view:getHpAndDamageNode())
    end

    -- 副将3 魂师副将actor view 初始化
    local sprt = app.battle:getSupportSkillHero3()
    if sprt then
        local view = QHeroActorView.new(sprt)
        if sprt:isFlipX() then
            view:getSkeletonActor():flipActor()
        end
        view:setPosition(sprt:getPosition().x, sprt:getPosition().y)
        table.insert(views, view)
        self:addSkeletonContainer(view)
        self:addHpAndDamageContainer(view:getHpAndDamageNode())
    end

    local sprtSkillHero = app.battle:getSupportSkillHero()
    local sprtSkillHero2 = app.battle:getSupportSkillHero2()
    local sprtSkillHero3 =app.battle:getSupportSkillHero3()

    local supportUIcount = 0
    if sprtSkillHero3 then
        supportUIcount = supportUIcount + 1
        self._supporterHeroStatusView3 = getSupportView(supportUIcount, sprtSkillHero3)
        if sprtSkillHero then
            local sprite = self._supporterHeroStatusView3:getSpriteYuan()
            if sprite then
                local spriteFrame = QSpriteFrameByKey("fight_hero_yuan3")
                if spriteFrame then
                    sprite:setDisplayFrame(spriteFrame)
                end
            end
        end
    end

    if sprtSkillHero2 then
        supportUIcount = supportUIcount + 1
        self._supporterHeroStatusView2 = getSupportView(supportUIcount, sprtSkillHero2)
        if sprtSkillHero then
            local sprite = self._supporterHeroStatusView2:getSpriteYuan()
            if sprite then
                local spriteFrame = QSpriteFrameByKey("fight_hero_yuan2")
                if spriteFrame then
                    sprite:setDisplayFrame(spriteFrame)
                end
            end
        end
    end

    if sprtSkillHero then
        supportUIcount = supportUIcount + 1
        self._supporterHeroStatusView = getSupportView(supportUIcount, sprtSkillHero)
        if sprtSkillHero2 then
            local sprite = self._supporterHeroStatusView:getSpriteYuan()
            if sprite then
                local spriteFrame = QSpriteFrameByKey("fight_hero_yuan1")
                if spriteFrame then
                    sprite:setDisplayFrame(spriteFrame)
                end
            end
        end
    end

    if self._dungeonConfig.heroStatus3View then
        for _, view in ipairs(self._dungeonConfig.heroStatus3View) do
            view:cleanup()
            view:release()
        end
        self._dungeonConfig.heroStatus3View = nil
    end

    if self._dungeonConfig.heroStatusView then
        for _, view in ipairs(self._dungeonConfig.heroStatusView) do
            view:cleanup()
            view:release()
        end
        self._dungeonConfig.heroStatusView = nil
    end

    if self._dungeonConfig.activeSkillCoolDownView then
        for _, view in ipairs(self._dungeonConfig.activeSkillCoolDownView) do
            view:cleanup()
            view:release()
        end
        self._dungeonConfig.activeSkillCoolDownView = nil
    end

    table.mergeForArray(self._heroViews, views);

    self:_defaultSelectHero() -- 太阳井情况下self._touchController还未创建，并且self:_defaultSelectHero()依赖于self._touchController的创建，所以还要在之后调用一次
end

function QBattleScene:_removeLastPVPWave()
    local heroViews = self._heroViews
    local i, count = 1, #heroViews
    while i <= count do
        local view = heroViews[i]
        if view == nil then
            break
        elseif not view:getModel():isDead() then
            view:removeFromParentAndCleanup(true)
            table.remove(heroViews, i)
        else
            i = i + 1
        end
    end
    local enemyViews = self._enemyViews
    local i, count = 1, #enemyViews
    while i <= count do
        local view = enemyViews[i]
        if view == nil then
            break
        elseif not view:getModel():isDead() then
            view:removeFromParentAndCleanup(true)
            table.remove(enemyViews, i)
        else
            i = i + 1
        end
    end
end

function QBattleScene:_removeLastPVEWave()
    for i,view in pairs(self._heroViews) do
        if view then
            view:removeFromParentAndCleanup(true)
        end
    end
    for i,view in pairs(self._enemyViews) do
        if view then
            view:removeFromParentAndCleanup(true)
        end
    end
    self._heroViews = {}
    self._enemyViews = {}
end

local NUMBER_WORD = {"一","二","三","四","五","六","七","八","九","十"}

function QBattleScene:SetPVEMultipleWaveString(wave)
    self._metalcityWave:setVisible(true)
    self._metalcityWave:setString(string.format("试炼%d",wave))
end

function QBattleScene:_preparePVPWave()
    for _, view in ipairs(self._soulSpiritStatusViews) do
        view:setHero(nil)
    end
    -- create views for heroes
    local views = {}
    local heroes = app.battle:getHeroes()
    local heroCount = table.nums(heroes)
    self:removeAllHeroStatusViews()
    local index = 1
    for i, hero in ipairs(heroes) do
        if not hero:isPet() then
            local view = QHeroActorView.new(hero)
            table.insert(views, view)
            self:addHeroStatusView(hero, false)
            index = index + 1
        end
    end
    for i, view in ipairs(views) do
        local index = heroCount - i + 1
        self:addSkeletonContainer(view)
        self:addHpAndDamageContainer(view:getHpAndDamageNode())
        table.insert(self._heroViews, view)
    end
    -- create views for enemies
    local views = {}
    local enemies = app.battle:getEnemies()
    local enemyCount = table.nums(enemies)
    for i, enemy in ipairs(enemies) do
        if not enemy:isPet() then
            local view = QHeroActorView.new(enemy)
            table.insert(views, view)
        end
    end
    for i, view in ipairs(views) do
        self:addSkeletonContainer(view)
        self:addHpAndDamageContainer(view:getHpAndDamageNode())
        table.insert(self._enemyViews, view)
    end
end

function QBattleScene:_enterScenePreperation()
    app.randomseed(1458643806)
    app.battle = QBattleManager.new(self._dungeonConfig)
    app.grid = QPositionDirector.new()
    app.grid:onEnter()
    -- app.grid:setScale(self._skeletonLayer:getScale())
    -- self:addOverlay(app.grid)

    app.battleFrame = 1
    app.battleTime = 0

    self._eventProxy = cc.EventProxy.new(app.battle)
    self._eventProxy:addEventListener(QBattleManager.NPC_CREATED, handler(self, self._onNpcCreated))
    self._eventProxy:addEventListener(QBattleManager.CANDIDATE_ACTOR_ENTER, handler(self, self._onCandidate_enter))
    self._eventProxy:addEventListener(QBattleManager.NPC_CLEANUP, handler(self, self._onNpcCleanUp))
    self._eventProxy:addEventListener(QBattleManager.NPC_DEATH_LOGGED, handler(self, self._onNpcDeathLogged))
    self._eventProxy:addEventListener(QBattleManager.PAUSE, handler(self, self._onPause))
    self._eventProxy:addEventListener(QBattleManager.RESUME, handler(self, self._onResume))
    self._eventProxy:addEventListener(QBattleManager.HERO_CLEANUP, handler(self, self._onHeroCleanup))
    self._eventProxy:addEventListener(QBattleManager.START, handler(self, self._onBattleStart))
    self._eventProxy:addEventListener(QBattleManager.CUTSCENE_START, handler(self, self._onBattleCutsceneStart))
    self._eventProxy:addEventListener(QBattleManager.WIN, handler(self, self._onWin))
    self._eventProxy:addEventListener(QBattleManager.LOSE, handler(self, self._onLose))
    self._eventProxy:addEventListener(QBattleManager.ONTIMER, handler(self, self._onBattleTimer))
    self._eventProxy:addEventListener(QBattleManager.WAVE_STARTED, handler(self, self._onWaveStarted))
    self._eventProxy:addEventListener(QBattleManager.WAVE_ENDED, handler(self, self._onWaveEnded))
    self._eventProxy:addEventListener(QBattleManager.USE_MANUAL_SKILL, handler(self, self._onUseManualSkill))
    self._eventProxy:addEventListener(QBattleManager.ON_SET_TIME_GEAR, handler(self, self._onSetTimeGear))
    self._eventProxy:addEventListener(QBattleManager.ON_CHANGE_DAMAGE_COEFFICIENT, handler(self, self._onChangeDamageCoefficient))
    self._eventProxy:addEventListener(QBattleManager.EVENT_BULLET_TIME_TURN_START, handler(self, self._onBulletTimeTurnStart))
    self._eventProxy:addEventListener(QBattleManager.EVENT_BULLET_TIME_TURN_FINISH, handler(self, self._onBulletTimeTurnFinish))
    self._eventProxy:addEventListener(QBattleManager.PVP_WAVE_END, handler(self, self._onPvpWaveEnd))
    self._eventProxy:addEventListener(QBattleManager.PVE_MULTIPLE_WAVE_END, handler(self, self._onPveMultipleWaveEnd))
    self._eventProxy:addEventListener(QBattleManager.PVP_MULTIPLE_WAVE_END, handler(self, self._onPvpMultipleWaveEnd))
    self._eventProxy:addEventListener(QBattleManager.UFO_CREATED, handler(self, self._onUFOCreated))
    self._eventProxy:addEventListener(QBattleManager.HOLY_PRESSURE_WAVE, handler(self, self._onHolyPressureWave))
    self._blackRockEventProxy = cc.EventProxy.new(remote.blackrock)
    self._blackRockEventProxy:addEventListener(remote.blackrock.EVENT_PASS_INFO, handler(self, self._onBlackRockPassInfo))


    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()

    self:_prepareLostCount()

    app.battle:_updateDungeonDialogs()
end

function QBattleScene:onEnter()
    QBattleScene.super.onEnter(self)
    app.scene = self

    self._preAnimationInterval = CCDirector:sharedDirector():getAnimationInterval()
    CCDirector:sharedDirector():setAnimationInterval(1.0 / 60)


    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE, self.changeUIViewPos, self)

    if CAN_SKIP_BATTLE == true and app.battle:isInTutorial() ~= true then
        self:_enterScenePreperation()
        self:_onSkipBattle(self._dungeonConfig.skipBattleWithWin == true)
    else
        local activeDungeonInfo = remote.activityInstance:getDungeonById(self._dungeonConfig.id)
        if self._activeDungeonInfo and self._activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME then
            -- 活动副本在开始的时候一段需要点击确认的对话框，那一段时间不录入战斗，所以要等对话框关闭之后再启动战斗
            -- TOFIX: 战斗没开始就打不开QBattleDialogGameRule。
            app.battle = {}
            function app.battle:pause() end
            function app.battle:resume() end
            local func_start = function()
                self:_enterScenePreperation()
                QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchActorView.EVENT_ACTOR_TOUCHED_BEGIN, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_MOVE, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_ATTACK, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchController.EVENT_TOUCH_END_FOR_SELECT, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchController.EVENT_TOUCH_END_FOR_MOVE, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchController.EVENT_TOUCH_END_FOR_ATTACK, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QEntranceBase.ANIMATION_FINISHED, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QMissionBase.COMPLETE_STATE_CHANGE, self.onEvent, self)
                self._dragController = QDragLineController.new()
                self:addDragLine(self._dragController)
                self._touchController = QTouchController.new()
                self:addDragLine(self._touchController)
                self._touchController:enableTouchEvent()
                if self._isPassedBefore == false and self._isHaveMissions == true then
                    app.missionTracer = QBattleMissionTracer.new(self._dungeonConfig.id)
                    app.missionTracer:beginTracer()
                else
                    self._starOff1:setVisible(false)
                    self._starOff2:setVisible(false)
                    self._starOff3:setVisible(false)
                    self._starOn1:setVisible(true)
                    self._starOn2:setVisible(true)
                    self._starOn3:setVisible(true)
                end
                self._labelDeadEnemies:setString(tostring(app.battle:getDungeonDeadEnemyCount()) .. "/" .. tostring(app.battle:getDungeonEnemyCount()))
                self._labelCountDown:setVisible(true)
                local animationManager = tolua.cast(self._topBar:getUserObject(), "CCBAnimationManager")
                animationManager:runAnimationsForSequenceNamed("EnterDungeon")
                app.battle:start()
            end
            -- 必须保证func_start的执行地点在mainloop里一致，无论是录像还是回放,所以统一放在全局的schedule中执行
            if self._dungeonConfig.isReplay then
                self._enterHandl1 = scheduler.performWithDelayGlobal(function()
                    self._enterHandl1 = nil
                    func_start()
                end, 0)
            else
                -- @qinyuanji - WOW-6181
                -- QBattleDialogGameRule.new("Battle_Widget_TimeMachine_RulePrompt.ccbi", function()
                --     scheduler.performWithDelayGlobal(function()
                        func_start()
                --     end, 0)
                -- end)
            end

        else
            self:_enterScenePreperation()

            -- add drag controller and touch controller
            if app.battle:isInTutorial() == true then
                -- invisible some node
                self._topBar:setVisible(false)
                self._autoSkillBar:setVisible(false)
                app.battle:createEnemiesInTutorial()
                app.battle:start()

            elseif app.battle:isPVPMode() == true then
                app.battle:createEnemiesInPVPMode()
                app.battle:start()
                self:_prepareHeroes()
                self:_createEnmeyStatusView()

                self._labelCountDown:setVisible(true)
                self._labelCountDown:setString(string.format("%.2d:%.2d", math.floor(app.battle:getDungeonDuration() / 60.0), math.floor(app.battle:getDungeonDuration() % 60.0)))

                if (app.battle:isInSunwell() and not app.battle:isSunwellAllowControl()) 
                    or (app.battle:isInArena() and not app.battle:isArenaAllowControl())
                    or (app.battle:isInSilverMine() and app.battle:isPVPMode())
                then
                    self._autoSkill_ccbowner.sprite_lock:setVisible(true)
                    self._autoSkill_ccbowner.node_autoSkillLight:setVisible(false)
                    local button = self._autoSkill_ccbowner.btn_autoskill
                    button:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_auto_skill_an"), CCControlStateNormal)
                    button:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_auto_skill_an"), CCControlStateHighlighted)
                end

                if (app.battle:isInSunwell() and app.battle:isSunwellAllowControl()) 
                    or (app.battle:isInArena() and app.battle:isArenaAllowControl())
                    or (app.battle:isInSilverMine() and not app.battle:isPVPMode())
                then
                    QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchActorView.EVENT_ACTOR_TOUCHED_BEGIN, self.onEvent, self)
                    QNotificationCenter.sharedNotificationCenter():addEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_MOVE, self.onEvent, self)
                    QNotificationCenter.sharedNotificationCenter():addEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_ATTACK, self.onEvent, self)
                    QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchController.EVENT_TOUCH_END_FOR_SELECT, self.onEvent, self)
                    QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchController.EVENT_TOUCH_END_FOR_MOVE, self.onEvent, self)
                    QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchController.EVENT_TOUCH_END_FOR_ATTACK, self.onEvent, self)

                    self._dragController = QDragLineController.new()
                    self:addDragLine(self._dragController)
                    self._touchController = QTouchController.new()
                    self:addDragLine(self._touchController)
                    self._touchController:enableTouchEvent()
                    
                    self:_defaultSelectHero()
                end

                -- 副将刷buff
                local walk_delay = global.pvp_hero_move_time
                self._enterHandl2 = scheduler.performWithDelayGlobal(function()
                    self._enterHandl2 = nil
                    if self.playSupportBuffs == nil or app.battle == nil then
                        return
                    end

                    local support_hero_count = #app.battle:getSupportHeroes() + #app.battle:getSupportHeroes2() + #app.battle:getSupportHeroes3()
                    local support_enemy_count = #app.battle:getSupportEnemies() + #app.battle:getSupportEnemies2() + #app.battle:getSupportEnemies3()
                    -- 刷buff
                    self:playSupportBuffs()
                    local support_delay = (support_hero_count > 0 or support_enemy_count > 0) and 1.0 or 0
                    -- 副将半身像战力动画
                    self:playSupportAnimation()
                end, walk_delay)
            else
                QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchActorView.EVENT_ACTOR_TOUCHED_BEGIN, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_MOVE, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_ATTACK, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchController.EVENT_TOUCH_END_FOR_SELECT, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchController.EVENT_TOUCH_END_FOR_MOVE, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QTouchController.EVENT_TOUCH_END_FOR_ATTACK, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QEntranceBase.ANIMATION_FINISHED, self.onEvent, self)
                QNotificationCenter.sharedNotificationCenter():addEventListener(QMissionBase.COMPLETE_STATE_CHANGE, self.onEvent, self)

                self._dragController = QDragLineController.new()
                self:addDragLine(self._dragController)
                self._touchController = QTouchController.new()
                self:addDragLine(self._touchController)
                self._touchController:enableTouchEvent()

                --@qinyuanji wow-6198
                -- if self._isPassedBefore == false and self._isHaveMissions == true then
                if self._isHaveMissions == true then
                    app.missionTracer = QBattleMissionTracer.new(self._dungeonConfig.id)
                    app.missionTracer:beginTracer()
                else
                    self._starOff1:setVisible(false)
                    self._starOff2:setVisible(false)
                    self._starOff3:setVisible(false)
                    self._starOn1:setVisible(true)
                    self._starOn2:setVisible(true)
                    self._starOn3:setVisible(true)
                end

                if app.battle:isInEditor() == true then
                    self._autoSkillBar:setVisible(false)
                    self._labelCountDown:setVisible(true)
                    app.battle:start()
                else
                    self._labelCountDown:setVisible(true)
                    app.battle:start()
                end

                -- 副将刷buff
                local walk_delay = 1.6
                scheduler.performWithDelayGlobal(function()
                    if self.playSupportBuffs == nil or app.battle == nil then
                        return
                    end

                    local support_hero_count = #app.battle:getSupportHeroes() + #app.battle:getSupportHeroes2() + #app.battle:getSupportHeroes3()
                    local support_enemy_count = #app.battle:getSupportEnemies() + #app.battle:getSupportEnemies2() + #app.battle:getSupportEnemies3()
                    -- 刷buff
                    self:playSupportBuffs()
                    local support_delay = (support_hero_count > 0 or support_enemy_count > 0) and 1.0 or 0
                    -- 副将半身像战力动画
                    self:playSupportAnimation()
                    -- 要塞星级buff动画
                    self:playRebelBuffs()
                end, walk_delay)
            end
            if app.battle:isInReplay() then
                self._autoSkill_ccbowner.node_autoSkillLight:setVisible(false)
            end
        end


        if not app.battle:isInEditor() then
            self:onWaveShowDungeonName()
        end

        -- play BGM
        self:onWavePlayBgm(1)
    end
end

function QBattleScene:disablePlayBGM()
    self._display_play_bgm = true
    app.sound:stopMusic()
end

function QBattleScene:enablePlayBGM()
    self._display_play_bgm = false
    local bgms = string.split(self._dungeonConfig.bgm, ";")
    local cur_wave = math.max(app.battle:getCurrentWave() or 1, 1)
    for i = cur_wave, 1, -1 do
        if bgms[i] then
            cur_wave = i
            break
        end
    end
    self:onWavePlayBgm(cur_wave)
end

function QBattleScene:onExit()
    if self._restartFlag ~= true then
        if not app.battle:isInEditor() then
            app:setSpeedGear(1, 1)
        end
    end

    CCDirector:sharedDirector():setAnimationInterval(self._preAnimationInterval)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE, self.changeUIViewPos, self)

    -- stop BGM
    -- audio.stopBackgroundMusic()
    if self._restartFlag ~= true then
        QSkeletonViewController.sharedSkeletonViewController():removeSkeletonData()
        app:setIsClearSkeletonData(true)
    end

    if app.battle:isInTutorial() == true then

    elseif app.battle:isPVPMode() == true then
        if (app.battle:isInSunwell() and app.battle:isSunwellAllowControl()) or (app.battle:isInArena() and app.battle:isArenaAllowControl()) then
            if self._touchController ~= nil then
                self._touchController:disableTouchEvent()
            end

            QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchActorView.EVENT_ACTOR_TOUCHED_BEGIN, self.onEvent, self)
            QNotificationCenter.sharedNotificationCenter():removeEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_MOVE, self.onEvent, self)
            QNotificationCenter.sharedNotificationCenter():removeEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_ATTACK, self.onEvent, self)
            QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchController.EVENT_TOUCH_END_FOR_SELECT, self.onEvent, self)
            QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchController.EVENT_TOUCH_END_FOR_MOVE, self.onEvent, self)
            QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchController.EVENT_TOUCH_END_FOR_ATTACK, self.onEvent, self)
        end
    else
        if self._touchController ~= nil then
            self._touchController:disableTouchEvent()
        end

        QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchActorView.EVENT_ACTOR_TOUCHED_BEGIN, self.onEvent, self)
        QNotificationCenter.sharedNotificationCenter():removeEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_MOVE, self.onEvent, self)
        QNotificationCenter.sharedNotificationCenter():removeEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_ATTACK, self.onEvent, self)
        QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchController.EVENT_TOUCH_END_FOR_SELECT, self.onEvent, self)
        QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchController.EVENT_TOUCH_END_FOR_MOVE, self.onEvent, self)
        QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchController.EVENT_TOUCH_END_FOR_ATTACK, self.onEvent, self)
        QNotificationCenter.sharedNotificationCenter():removeEventListener(QEntranceBase.ANIMATION_FINISHED, self.onEvent, self)
        QNotificationCenter.sharedNotificationCenter():removeEventListener(QMissionBase.COMPLETE_STATE_CHANGE, self.onEvent, self)

        if app.missionTracer ~= nil then
            app.missionTracer:endTracer()
            app.missionTracer = nil
        end

    end

    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
    self:unscheduleUpdate()

    self._eventProxy:removeAllEventListeners()
    self._blackRockEventProxy:removeAllEventListeners()

    --直接退出战斗 可能导致内存泄露
   
    if self._dungeonBGNodes[2] then

        local node  = self._dungeonBGNodes[2][2]
        if node then
            --如果 map是ccb 动画是autoplay 需要stopAllActions 否则会导致内存泄露
            -- local animationManager = tolua.cast(node:getUserObject(), "CCBAnimationManager")
            -- if animationManager then
            --     animationManager:stopAnimation();
            -- end
            QCleanNode(node)
            node:release()
        end
    end
    if self._dungeonBGNodes[3] then
        
        local node  = self._dungeonBGNodes[3][2]
        if node then
           
            --如果 map是ccb 动画是autoplay 需要stopAllActions 否则会导致内存泄露
            -- local animationManager = tolua.cast(node:getUserObject(), "CCBAnimationManager")
            -- if animationManager then
            --     animationManager:stopAnimation();
            -- end
            QCleanNode(node)
            node:release()
        end
    end
    --在 onexit 调用stopCache 游戏结束前 有些tip 没播放完 回调还没调用 会导致内存泄露
    self._tip_cache:stopCache()

    -- 将actor从grid上清除
    for i, view in ipairs(self._heroViews) do
        if view and view:getModel():isDead() == false then
            app.grid:removeActor(view:getModel())
        end
    end

    for i, view in ipairs(self._heroViews) do
        if view then
            view:removeFromParent()
        end
    end
    self._heroViews = {}

    for i, view in ipairs(self._enemyViews) do
        if view then
            view:removeFromParent()
        end
    end
    self._enemyViews = {}

    for i, view in ipairs(self._groundEffectView) do
        if view then
            view:removeFromParent()
        end
    end
    self._groundEffectView = {}

    for i, view in ipairs(self._effectViews) do
        if view then
            view:removeFromParent()
        end
    end
    self._effectViews = {}

    for i, view in ipairs(self._frontEffectView) do
        if view then
            view:removeFromParent()
        end
    end
    self._frontEffectView = {}

    if self._resultProxy then
        self._resultProxy:removeAll()
        self._resultProxy = nil
    end
    -- app.grid:removeSelf()
    app.grid:onExit()
    app.grid = nil

    app.battle:stop()
    app.battle = nil

    app.scene = nil

    if self._moneyUpdate ~= nil then
        self._moneyUpdate:stopUpdate()
        self._moneyUpdate = nil
    end

    if self._chestUpdate ~= nil then
        self._chestUpdate:stopUpdate()
        self._chestUpdate = nil
    end
    
    self:cancelMoveSchedule()

    QSkeletonViewController.sharedSkeletonViewController():resetAllAnimationScale()
    QBattleScene.super.onExit(self)
end

function QBattleScene:onCleanup()
    QSkeletonDataCache:sharedSkeletonDataCache():removeUnusedData()

    for _, view in ipairs(self._heroMountSkillViews) do
        view:purge()
    end
    for _, view in ipairs(self._enemyMountSkillViews) do
        view:purge()
    end
    self._heroMountSkillViews = {}
    self._enemyMountSkillViews = {}
    self._heroMountSkillQueue = {}
    self._enemyMountSkillQueue = {}
end

function QBattleScene:_createNewEnemyTips(config, monsterId)
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    ccbOwner.onClickNewEnemies = handler(self, QBattleScene._onClickNewEnemies)

    config = string.split(config, ";")
    self._newEnemyTipsConfig = QStaticDatabase.sharedDatabase():getNewEnemyTips(config[1])
    self._newEnemyTipsConfig.monsterId = monsterId

    local animationNode = CCBuilderReaderLoad("Widget_new_enemies_tips.ccbi", ccbProxy, ccbOwner)
    ccbOwner.head_size:setZoomOnTouchDown(false)
    self._newEnemyTipsAnimation = animationNode
    animationNode:setPosition(display.cx + display.width * 0.5 - 70, display.cy + display.height * 0.5 - 150 )
    self._newEnemyTipsNode = animationNode
    
    self:addUI(animationNode)
    local animationManager = tolua.cast(animationNode:getUserObject(), "CCBAnimationManager")
    animationManager:stopAnimation()
    animationManager:runAnimationsForSequenceNamed("1")
    animationManager:connectScriptHandler(function(animationName)
        animationManager:disconnectScriptHandler()
        animationManager:stopAnimation()
        animationManager:runAnimationsForSequenceNamed("2")
        animationManager:connectScriptHandler(function(animationName)
                animationManager:stopAnimation()
                animationManager:runAnimationsForSequenceNamed("2")
            end)
    end)

    local monsterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(monsterId)
    local headImageTexture = CCTextureCache:sharedTextureCache():addImage(monsterInfo.icon)
    local imgSp = CCSprite:createWithTexture(headImageTexture)
    imgSp:setScale(0.7)
    local size = ccbOwner.head_cricle_di:getContentSize()
    local ccclippingNode = QFullCircleUiMask.new()
    ccclippingNode:setRadius(size.width/4.5)
    ccclippingNode:addChild(imgSp)
    ccbOwner.content:addChild(ccclippingNode)

    if app:getUserData():getUserValueForKey("newEnemyTipsTutorial") ~= QUserData.STRING_TRUE or ALWAYS_SHOW_NEW_ENEMY_TUTORIAL then
        app.battle:dispatchEvent({name = app.battle.NEW_ENEMY,isShow = true})
    end

    local delayTime = tonumber(config[2])
    if nil ~= delayTime then
        app.battle:performWithDelay(function()
            self:removeNewEnemyTips() 
        end, delayTime)
    end
end

function QBattleScene:_onClickNewEnemies(config)
    if nil ~= self._newEnemyTipsDialog then
        return
    end

    app:getUserData():setUserValueForKey(tostring(self._newEnemyTipsConfig.monsterId).."newEnemyTips", QUserData.STRING_TRUE)
    self._newEnemyTipsDialog = QBattleDialogNewEnemyTips.new(nil, self._newEnemyTipsConfig)
    self._newEnemyTipsConfig = nil
    app.battle:dispatchEvent({name = app.battle.NEW_ENEMY,isShow = false})
end

function QBattleScene:removeNewEnemyTips()
    self._newEnemyTipsDialog = nil
    if nil ~= self._newEnemyTipsAnimation then
        self._newEnemyTipsAnimation:removeFromParentAndCleanup(true)
        self._newEnemyTipsAnimation = nil
    end
end

function QBattleScene:_onNpcCreated(event)

    local targetPos
    local view
    if app.battle:isPVPMode() == false then
        if (event.isBoss == true or event.isEliteBoss == true) and event.npc.not_show_hp_bar ~= true then
            if self._bossCount == nil then
                self._bossCount = 0
            end
            self._bossCount = self._bossCount + 1
            if self._bossHpBar:getActor() == nil or self._bossHpBar:getActor():isDead() == true then
                if self:_isBossHpViewMultiLayer() then
                    local hp_per_layer
                    if not self._isActiveDungeon then
                        hp_per_layer = QStaticDatabase:sharedDatabase():getHPPerLayerByLevel(event.npc:getLevel(), self._dungeonConfig)
                    else
                        hp_per_layer = event.npc:getMaxHp() / 4
                    end
                    self._bossHpBar:setHPPerLayer(hp_per_layer) 
                end
                self._bossHpBar:setActor(event.npc)
                self._bossHpBar:setVisible(true)
                self._bossHpBar:setIsEliteBoss((event.isBoss and {false} or {true})[1])
                self._starRoot:setVisible(false)
            end
        end

        view = QNpcActorView.new(event.npc, event.skeletonView)
        view:setTag(event.depth_tag or -1)
        self:addSkeletonContainer(view)
        self:addHpAndDamageContainer(view:getHpAndDamageNode())
        if not event.is_hero then
            table.insert(self._enemyViews, view)
        else
            table.insert(self._heroViews, view)
        end
    else
        if not event.isNoneSkillSupport then
            view = QHeroActorView.new(event.npc)
            self:addSkeletonContainer(view)
            self:addHpAndDamageContainer(view:getHpAndDamageNode())
            if not event.is_hero then
                table.insert(self._enemyViews, view)
            else
                table.insert(self._heroViews, view)
            end
            if event.npc:isCopyHero() then
                view:setCanTouchBegin(false)
            end
            if event.isCandidate then
                view:setPosition(ccp(display.width*2, -display.height))
            end
        end
    end

    if app.battle:isInTutorial() == false and app.battle:isPVPMode() == false then
        -- new enemy tips
        local isClicked = app:getUserData():getUserValueForKey(tostring(event.npc:getActorID()).."newEnemyTips")
        if event.newEnemyTipsConfig and (isClicked ~= QUserData.STRING_TRUE or ALWAYS_SHOW_NEW_ENEMY) then
            self:_createNewEnemyTips(event.newEnemyTipsConfig, event.npc:getActorID())
        end
        -- play create effect
        if event.effectId ~= nil then
            local targetPos
            if app.battle:isPVPMode() == false then
                local w = BATTLE_AREA.width / global.screen_big_grid_width
                local h = BATTLE_AREA.height / global.screen_big_grid_height
                if event.screen_pos ~= nil then
                    targetPos = clone(event.screen_pos)
                else
                    targetPos = {x = BATTLE_AREA.left + w * event.pos.x - w / 2, y = BATTLE_AREA.bottom + h * event.pos.y - h / 2}
                end
            else
                if event.screen_pos ~= nil then
                    targetPos = clone(event.screen_pos)
                else
                    targetPos = {x = BATTLE_AREA.left + event.pos.x, y = BATTLE_AREA.bottom + event.pos.y}
                end
            end
            local frontEffect, backEffect = QBaseEffectView.createEffectByID(event.effectId)
            local dummy = QStaticDatabase.sharedDatabase():getEffectDummyByID(event.effectId)
            frontEffect:setPosition(targetPos.x, targetPos.y - 1)
            self:addEffectViews(frontEffect)
            
            -- play animation and sound
            frontEffect:playAnimation(frontEffect:getPlayAnimationName(), false)
            frontEffect:playSoundEffect(false)

            frontEffect:afterAnimationComplete(function()
                app.scene:removeEffectViews(frontEffect)
            end)
        end
        -- play boss effect
        if (event.isBoss == true or event.isEliteBoss == true) 
            and event.isManually ~= true 
            and app:getUserData():getUserValueForKey(tostring(event.npc:getActorID()) .. "_introduced") == QUserData.STRING_TRUE 
            and ALWAYS_SHOW_BOSS_INTRODUCTION ~= true 
            and (not app.battle:isInEditor()) then

            if event.appear_skill == nil then
                if event.isBoss == true then
                    self:_playBossEffect(view)
                else
                    view:showName()
                end
            else
                local appear_skill = event.appear_skill
                local eventListener = cc.EventProxy.new(event.npc)
                eventListener:addEventListener(QActor.SKILL_END, function(skillEvent)
                    if skillEvent.skillId == appear_skill then
                        if event.isBoss == true then
                            app.scene:_playBossEffect(view)
                        elseif event.isEliteBoss == true then
                            view:showName()
                        end
                    end
                    eventListener:removeAllEventListeners()
                end)
            end
        end


    end
    if app.battle:isInSocietyDungeon() and event.isBoss and view and app.battle:isBossHpInfiniteDungeon() then
        view._skeletonActor:setOpacity(UNION_DUNGEON_MAX_BOSS_OPACITY)
    end
    if event.npc:isSoulSpirit() then
        if event.is_hero == true then
            local index = #self._soulSpiritStatusViews
            local view = QSoulSpiritStatusView.new()
            view:setHero(event.npc)
            view:setIndex(index + 1)
            view:setPosition(self._ccbOwner.soulSpiritButton:getPositionX(),
                self._ccbOwner.soulSpiritButton:getPositionY() + index * 100)
            
            self:addUI(view)
            if index == 1 then
                self._soulSpiritStatusViews[1]:setIndex(2)
                view:setIndex(1)
            end
            table.insert(self._soulSpiritStatusViews, view)
        elseif self:isAutoTwoWavePVP() then
            local index = #self._soulSpiritStatusViewsEnemy
            local view = QSoulSpiritStatusView.new()
            view:setHero(event.npc)
            view:setIndex(index + 1)
            view:setPosition(self._ccbOwner.soulSpiritButton_e_autoPvp:getPositionX(),
            self._ccbOwner.soulSpiritButton_e_autoPvp:getPositionY() + index * 100)
            
            self:addUI(view)
            if index == 1 then
                self._soulSpiritStatusViewsEnemy[1]:setIndex(2)
                view:setIndex(1)
            end
            table.insert(self._soulSpiritStatusViewsEnemy, view)
        end
    end
end

function QBattleScene:_playBossEffect(view)
    if self._bossEffectPlayed then
        return
    end
    app.battle:pause()

    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local animationNode = CCBuilderReaderLoad(global.ui_battle_boss_animation_ccbi, ccbProxy, ccbOwner)
    animationNode:setPosition(display.cx, display.cy)
    self:addUI(animationNode)
    self._bossAnimationNode = animationNode

    local animationManager = tolua.cast(animationNode:getUserObject(), "CCBAnimationManager")
    animationManager:connectScriptHandler(function(animationName)
        animationManager:disconnectScriptHandler()
        view:showName()
        animationNode:removeFromParent()
        self._bossAnimationNode = nil
        app.battle:resume()
    end)
    self._bossEffectPlayed = true
end

function QBattleScene:_onNpcDeathLogged(event)

    if app.battle:isActiveDungeon() == true and app.battle:getActiveDungeonType() == DUNGEON_TYPE.ACTIVITY_TIME then
        self._labelDeadEnemies:setString(tostring(app.battle:getDungeonDeadEnemyCount())
            .. "/" .. tostring(app.battle:getDungeonEnemyCount()))
        local animationManager = tolua.cast(self._topBar:getUserObject(), "CCBAnimationManager")
        animationManager:runAnimationsForSequenceNamed("EnemyDead")
    end

    local views = event.is_hero and self._heroViews or self._enemyViews
    for i, view in ipairs(views) do
        if view:getModel() == event.npc then
            local direction
            if view:getModel():isFlipX() == true then
                direction = QActor.DIRECTION_RIGHT
            else
                direction = QActor.DIRECTION_LEFT
            end
            local scale = self._skeletonLayer:getScale()
            if event.npc.rewards ~= nil then
                local deltaPos = {{80, 80}, {0, 0}, {80, 0}, {80, -80}, {0, -80}, {-80, -80}, {-80, 0}, {-80, 80}, {0, 80}}
                local delayTime = 0
                for i, reward in pairs(event.npc.rewards) do
                    local index = i % 9 + 1
                    local position = ccp(view:getPosition())
                    position.x = math.min(math.max(position.x, BATTLE_AREA.left + 80), BATTLE_AREA.right - 80)
                    position.x = position.x * scale + deltaPos[index][1]
                    position.y = position.y * scale + deltaPos[index][2]
                    app.battle:performWithDelay(function()
                        self:_onGetReward(reward, direction, position)
                    end, delayTime)
                    delayTime = delayTime + 0.1
                end
            end

            if view:getModel():isNoDeadSkillOrAnimation() then
                table.removebyvalue(views, view)
                view:removeFromParent()
            else
                local deadDelay = global.npc_view_dead_delay
                local deathDuration = view:getSkeletonActor():getAnimationFrameCount(ANIMATION.DEAD) / 30
                if deathDuration > deadDelay then
                    deadDelay = deathDuration
                end
                local array = CCArray:create()
                array:addObject(CCDelayTime:create(deadDelay))          -- after 2 seconds
                -- array:addObject(CCBlink:create(global.npc_view_dead_blink_time, 3))           -- blink the npc 3 times in 1 second
                view:setCascadeOpacityEnabled(true)
                view:getSkeletonActor():setCascadeOpacityEnabled(true)
                array:addObject(CCFadeOut:create(global.npc_view_dead_blink_time * 1))
                array:addObject(CCCallFunc:create(function()
                    table.removebyvalue(views, view)
                end))
                array:addObject(CCRemoveSelf:create(true))      -- and then remove it from scene
                view:runAction(CCSequence:create(array))
            end

            break
        end
    end
end

function QBattleScene:_onNpcCleanUp(event)

    if (event.isBoss == true or event.isEliteBoss == true) and event.npc.not_show_hp_bar ~= true then
        self._bossCount = self._bossCount - 1
        if self._bossCount <= 0 and self._bossHpBar:getActor() ~= nil then
            self._bossHpBar:setActor(nil)
            self._bossHpBar:setVisible(false)
            if self._isHaveMissions == true and self._isActiveDungeon == false then
                -- @qinyuanji wow-6201
--                self._starRoot:setVisible(true)
            end
        end
        local isShowkillBossEffect = false
        if app.battle:getCurrentWave() == app.battle:getWaveCount() then
            isShowkillBossEffect = true
            for _, enemy in ipairs(app.battle:getEnemies()) do
                if not enemy:isDead() and not app.battle:isEnemyCanBeIgnore(enemy) then
                    isShowkillBossEffect = false
                    break
                end
            end
        end
        if isShowkillBossEffect and self:getActorViewFromModel(event.npc) then
            local pos = event.npc:getCenterPosition_Stage()
            self._killActorAnimation2:setPosition(ccp(pos.x, pos.y))
            self._killActorAnimation3:setPosition(ccp(pos.x, pos.y))

            self._killActorAnimation2:setVisible(true)
            self._killActorAnimation2:setScale(2.5)
            self._killActorAnimation3:setVisible(true)
            -- self._killActorAnimation3:setScale(1.25)

            self._killActorAnimation2:afterAnimationComplete(handler(self, self._onSkeletonActorAnimationEvent2))
            self._killActorAnimation3:afterAnimationComplete(handler(self, self._onSkeletonActorAnimationEvent3))

            self._killActorAnimation2:playAnimation(EFFECT_ANIMATION, false)
            -- self._killActorAnimation2:getSkeletonView():setAnimationScale(0.25)
            self._killActorAnimation3:playAnimation(EFFECT_ANIMATION, false)
            -- self._killActorAnimation3:getSkeletonView():setAnimationScale(0.45)

            self._bossDeadTimeGear = app.battle:getTimeGear() or 1 -- 储存之前的timeGear
            self:shakeScreen(25, 0.48, 2) --晃动屏幕
            self._is_not_kill_animation_end = true
            app.battle:setTimeGear(0.25 * self._bossDeadTimeGear)
        end
    end

end

function QBattleScene:shakeScreen(value, duration, repeat_count, model)
    local model = model or "default"

    if model == "default" then
        return QBattleScene.super.shakeScreen(self, value, duration, repeat_count)
    end
    value = value or 20
    repeat_count = repeat_count or 1
    duration = duration and (duration / 8) or 0.05

    local arr = CCArray:create()
    if model == "crosswise" then
        arr:addObject(CCMoveBy:create(duration / 2, ccp(-value / 2, 0)))
        arr:addObject(CCMoveBy:create(duration, ccp(value, 0)))
        arr:addObject(CCMoveBy:create(duration, ccp(-value, 0)))
        arr:addObject(CCMoveBy:create(duration, ccp(value, 0)))
        arr:addObject(CCMoveBy:create(duration, ccp(-value, 0)))
        arr:addObject(CCMoveBy:create(duration, ccp(value, 0)))
        arr:addObject(CCMoveBy:create(duration, ccp(-value, 0)))
        arr:addObject(CCMoveBy:create(duration, ccp(value, 0)))
        arr:addObject(CCMoveBy:create(duration / 2, ccp(-value / 2, 0)))
    elseif model == "lengthways" then
        arr:addObject(CCMoveBy:create(duration / 2, ccp(0, -value / 2)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, -value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, -value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, -value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, value)))
        arr:addObject(CCMoveBy:create(duration / 2, ccp(0, -value / 2)))
    end
    self:runAction(CCRepeat:create(CCSequence:create(arr), repeat_count))
end

function QBattleScene:isNotSkillAnimationEnd()
    return self._is_not_kill_animation_end
end

function QBattleScene:_onUFOCreated(event)
    local ufo = event.ufo
    if ufo then
        local ufoView = QUFOView.new(ufo, {effectID = ufo:getEffectId(), isFrontEffect = true})
        self:addEffectViews(ufoView)
    end
end

function QBattleScene:_onHolyPressureWave(event)
    local view = QBaseEffectView.createEffectByID("quanpingtx_3")
    view:setPositionX(630)
    view:setPositionY(400)
    app.scene:addEffectViews(view, {isFrontEffect = true})
    view:playAnimation(view:getPlayAnimationName())
    view:playSoundEffect()  
end

function QBattleScene:_onGetReward(rewardInfo, actorDirection, position)
    if rewardInfo == nil or position == nil then
        return 
    end

    local itemNode
    local drapSound = ""
    local isTreasure = false

    local itemInfo = QStaticDatabase.sharedDatabase():getItemByID(rewardInfo.reward.id)

    if remote.items:getItemType(rewardInfo.reward.type) == ITEM_TYPE.ITEM then
        
        if itemInfo == nil then
            return
        else
            if itemInfo.type == ITEM_CONFIG_TYPE.SOUL then
                drapSound = "gem_drop"
            end
        end
        if itemInfo.colour ~= nil and itemInfo.colour >= ITEM_QUALITY_INDEX.PURPLE then
            isTreasure = true
        end
        itemNode = QUIWidgetItemsBox.new({ccb = "small"})
        itemNode:setGoodsInfo(rewardInfo.reward.id,ITEM_TYPE.ITEM,rewardInfo.reward.count)

    elseif remote.items:getItemType(rewardInfo.reward.type) == ITEM_TYPE.MONEY and self:isMoneyDungeon() then
        itemNode = CCSprite:create("icon/item/Gold_one.png")

    else
        return
    end

    actorDirection = actorDirection or QActor.DIRECTION_LEFT
    local ccbiFile = "effects/Box.ccbi"
    if rewardInfo.isGarbage == true or isTreasure == false then
        ccbiFile = "effects/Box2.ccbi"
    end

    -- local ccbProxy = CCBProxy:create()
    -- local ccbOwner = {}
    -- local rewardNode = CCBuilderReaderLoad(ccbiFile, ccbProxy, ccbOwner)
    local rewardNode = self:getTip(ccbiFile)
    local ccbOwner = rewardNode.ccbOwner

    rewardNode:setPosition(position.x, position.y)
    ccbOwner.node_item:removeAllChildren() -- nzhang: 由于rewardNode是反复利用的，需要把之前加上去的itemNode给移除掉。
    ccbOwner.node_item:addChild(itemNode)
    self:addUI(rewardNode, false)

    -- animation
    local animationManager = tolua.cast(rewardNode:getUserObject(), "CCBAnimationManager")
    animationManager:connectScriptHandler(function(animationName)
        animationManager:disconnectScriptHandler()
        local targetPositionX, targetPositionY = self._topBar:getPosition()
        -- if self:getDungeonConfig().dailyAwards then
        --     targetPositionX = targetPositionX + self._topBar_ccbOwner.reward_icon:getPositionX() + self._topBar_ccbOwner.reward_icon:getParent():getPositionX()
        --     targetPositionY = targetPositionY + self._topBar_ccbOwner.reward_icon:getPositionY() + self._topBar_ccbOwner.reward_icon:getParent():getPositionY()
        -- elseif remote.items:getItemType(rewardInfo.reward.type) == ITEM_TYPE.MONEY or itemInfo.type == ITEM_CONFIG_TYPE.CONSUM_MONEY then
        --     targetPositionX = targetPositionX + self._labelMoneyNode:getPositionX() + self._labelMoneyNode:getParent():getPositionX() + self._sprite_money:getPositionX()
        --     targetPositionY = targetPositionY + self._labelMoneyNode:getPositionY() + self._labelMoneyNode:getParent():getPositionY() + self._sprite_money:getPositionY()
        -- elseif remote.items:getItemType(rewardInfo.reward.type) == ITEM_TYPE.ITEM then
        --     targetPositionX = targetPositionX + self._labelChestNode:getPositionX() + self._labelChestNode:getParent():getPositionX() + self._sprite_item:getPositionX()
        --     targetPositionY = targetPositionY + self._labelChestNode:getPositionY() + self._labelChestNode:getParent():getPositionY() + self._sprite_item:getPositionY()
        -- end

        if self:getDungeonConfig().dailyAwards then
            local pos = self._topBar_ccbOwner.reward_icon:convertToWorldSpace(ccp(0,0))
            targetPositionX = pos.x
            targetPositionY = pos.y
        elseif remote.items:getItemType(rewardInfo.reward.type) == ITEM_TYPE.MONEY or itemInfo.type == ITEM_CONFIG_TYPE.CONSUM_MONEY then
            local pos = self._sprite_money:convertToWorldSpace(ccp(0,0))
            targetPositionX = pos.x
            targetPositionY = pos.y
        elseif remote.items:getItemType(rewardInfo.reward.type) == ITEM_TYPE.ITEM then
            local pos = self._sprite_item:convertToWorldSpace(ccp(0,0))
            targetPositionX = pos.x
            targetPositionY = pos.y
        end

        targetPositionX = targetPositionX - itemNode:getPositionX() - itemNode:getParent():getPositionX()
        targetPositionY = targetPositionY - itemNode:getPositionY() - itemNode:getParent():getPositionY()

        local actionArray = CCArray:create()
        actionArray:addObject(CCCallFunc:create(function()
            if self._rewardNodeArray == nil then
                self._rewardNodeArray = {}
            end
            table.insert(self._rewardNodeArray, rewardNode)
        end))
        actionArray:addObject(CCDelayTime:create(1))
        local bezierConfig = ccBezierConfig:new()
        bezierConfig.endPosition = ccp(targetPositionX, targetPositionY)
        local currentPositionX, currentPositionY = rewardNode:getPosition()
        if math.abs(currentPositionX - targetPositionX) < 200 then
            bezierConfig.controlPoint_1 = ccp(currentPositionX + (targetPositionX - currentPositionX) * 1.5, currentPositionY + (targetPositionY - currentPositionY) * 0.3)
            bezierConfig.controlPoint_2 = ccp(currentPositionX + (targetPositionX - currentPositionX) * 1.3, currentPositionY + (targetPositionY - currentPositionY) * 0.6)
        else
            bezierConfig.controlPoint_1 = ccp(currentPositionX + (targetPositionX - currentPositionX) * 0.8, currentPositionY + (targetPositionY - currentPositionY) * 0.3)
            bezierConfig.controlPoint_2 = ccp(currentPositionX + (targetPositionX - currentPositionX) * 0.9, currentPositionY + (targetPositionY - currentPositionY) * 0.6)
        end
        local bezierTo = CCBezierTo:create(0.5, bezierConfig)
        bezierConfig:delete()
        actionArray:addObject(CCEaseIn:create(bezierTo, 5))
        actionArray:addObject(CCRemoveSelf:create(true))
        actionArray:addObject(CCCallFunc:create(function()
            -- local ccbProxy = CCBProxy:create()
            -- local ccbOwner = {}
            -- local endEffect = CCBuilderReaderLoad("effects/ItemFall_end.ccbi", ccbProxy, ccbOwner)

            local endEffect = self:getTip("effects/ItemFall_end.ccbi")
            local ccbOwner = endEffect.ccbOwner
            if self:getDungeonConfig().dailyAwards then
                self._topBar_ccbOwner.reward_icon:addChild(endEffect)
                endEffect:setPosition(self._topBar_ccbOwner.reward_icon:getContentSize().width * 0.5, self._topBar_ccbOwner.reward_icon:getContentSize().height * 0.5)
            elseif remote.items:getItemType(rewardInfo.reward.type) == ITEM_TYPE.MONEY then
                self._sprite_money:addChild(endEffect)
                endEffect:setPosition(self._sprite_money:getContentSize().width * 0.5, self._sprite_money:getContentSize().height * 0.5)
            elseif itemInfo.type == ITEM_CONFIG_TYPE.CONSUM_MONEY then
                self._sprite_money:addChild(endEffect)
                endEffect:setPosition(self._sprite_money:getContentSize().width * 0.5, self._sprite_money:getContentSize().height * 0.5)
            elseif remote.items:getItemType(rewardInfo.reward.type) == ITEM_TYPE.ITEM then
                self._sprite_item:addChild(endEffect)
                endEffect:setPosition(self._sprite_item:getContentSize().width * 0.5, self._sprite_item:getContentSize().height * 0.5)
            end

            local animationManager = tolua.cast(endEffect:getUserObject(), "CCBAnimationManager")
            animationManager:connectScriptHandler(function(animationName)
                animationManager:disconnectScriptHandler()
                endEffect:removeFromParent()
                if endEffect.need_return then
                    self:returnTip(endEffect)
                else
                    endEffect:release()
                end
                if self._labelChest and self:getDungeonConfig().dailyAwards then
                    self:nodeEffect(self._bossHpBar._owner.raward_text)
                    self._chestUpdate:addUpdate(self._currentChest, self._currentChest + rewardInfo.reward.count, function (value)
                            if self._labelChest ~= nil and self._labelChest.setString ~= nil then
                                self._labelChest:setString("x"..tostring(math.ceil(value)))
                            end
                        end, 1)
                    self._currentChest = self._currentChest + rewardInfo.reward.count
                elseif self._labelChest and self._labelMoney then
                    if remote.items:getItemType(rewardInfo.reward.type) == ITEM_TYPE.MONEY then
                        self:nodeEffect(self._labelMoney)
                        self._moneyUpdate:addUpdate(self._currentMoney, self._currentMoney + rewardInfo.reward.count, function (value)
                            self._labelMoney:setString(tostring(math.ceil(value)))
                        end, 1)
                        self._currentMoney = self._currentMoney + rewardInfo.reward.count
                        -- self:showTipsAnimation(rewardInfo.reward.count, self._labelMoneyNode)
                    elseif itemInfo.type == ITEM_CONFIG_TYPE.CONSUM_MONEY then
                        self:nodeEffect(self._labelMoney)
                        self._moneyUpdate:addUpdate(self._currentMoney, self._currentMoney + itemInfo.selling_price, function (value)
                            self._labelMoney:setString(tostring(math.ceil(value)))
                        end, 1)
                        self._currentMoney = self._currentMoney + itemInfo.selling_price
                        -- self:showTipsAnimation(rewardInfo.reward.count, self._labelMoneyNode)
                    elseif remote.items:getItemType(rewardInfo.reward.type) == ITEM_TYPE.ITEM then
                        self:nodeEffect(self._labelChest)
                        self._chestUpdate:addUpdate(self._currentChest, self._currentChest + rewardInfo.reward.count, function (value)
                            if self._labelChest ~= nil and self._labelChest.setString ~= nil then
                                self._labelChest:setString(tostring(math.ceil(value)))
                            end
                        end, 1)
                        self._currentChest = self._currentChest + rewardInfo.reward.count
                        -- self:showTipsAnimation(rewardInfo.reward.count, self._labelChestNode)
                    end
                end
            end)
            animationManager:stopAnimation()
            animationManager:runAnimationsForSequenceNamed("Default Timeline")
        end))
        actionArray:addObject(CCCallFunc:create(function()
            for i, node in ipairs(self._rewardNodeArray) do
                if node == rewardNode then
                    table.remove(self._rewardNodeArray, i)
                    rewardNode:removeFromParent()
                    if rewardNode.need_return then
                        self:returnTip(rewardNode)
                    else
                        rewardNode:release()
                    end
                    break
                end
            end
        end))
        local ccsequence = CCSequence:create(actionArray)
        rewardNode:runAction(ccsequence)
    end)
    animationManager:stopAnimation()
    animationManager:runAnimationsForSequenceNamed("Default Timeline")

    if drapSound ~= nil and string.len(drapSound) > 0 then
        app.sound:playSound(drapSound)
    end

end

function QBattleScene:_onHeroCleanup(event)
    for i, view in ipairs(self._heroViews) do
        if view:getModel() == event.hero then
            local array = CCArray:create()
            local views = self._heroViews

            local deadDelay = global.npc_view_dead_delay
            local deathDuration = view:getSkeletonActor():getAnimationFrameCount(ANIMATION.DEAD) / 30
            if deathDuration > deadDelay then
                deadDelay = deathDuration
            end
            array:addObject(CCDelayTime:create(deadDelay))          -- after 5 seconds
            -- array:addObject(CCBlink:create(global.npc_view_dead_blink_time, 3))           -- blink the npc 3 times in 1 second
            view:setCascadeOpacityEnabled(true)
            view:getSkeletonActor():setCascadeOpacityEnabled(true)
            array:addObject(CCFadeOut:create(global.npc_view_dead_blink_time * 1))
            array:addObject(CCRemoveSelf:create(true))      -- and then remove it from scene
            array:addObject(CCCallFunc:create(function()
                table.removebyvalue(views, view)
            end))
            view:runAction(CCSequence:create(array))

            -- table.removebyvalue(self._heroViews, view)
            break
        end
    end
end

function QBattleScene:_onPause(event)
    self:_pauseNode(self._backgroundLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_pauseNode(self._trackLineLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_pauseNode(self._skeletonLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_pauseNode(self._dragLineLayer,CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_pauseNode(self._overSkeletonLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    if self._topBar_ccbOwner and self._topBar_ccbOwner.tf_dungeon_name then
        self:_pauseNode(self._topBar_ccbOwner.tf_dungeon_name, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    end
    -- self:_pauseNode(self._uiLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_pauseNode(self._overlayLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler()) -- This is how QPositionDirector is paused!
    self:_pauseSoundEffect()

    if self._dragController then
        self._dragController:disableDragLine(true)
    end
end

function QBattleScene:_pauseSoundEffect()
    for i, view in ipairs(self._effectViews) do
        if view.pauseSoundEffect then view:pauseSoundEffect() end
    end
    for i, view in ipairs(self._frontEffectView) do
        if view.pauseSoundEffect then view:pauseSoundEffect() end
    end
    for i, view in ipairs(self._groundEffectView) do
        if view.pauseSoundEffect then view:pauseSoundEffect() end
    end
    for i, view in ipairs(self._heroViews) do
        if view.pauseSoundEffect then view:pauseSoundEffect() end
    end
    for i, view in ipairs(self._enemyViews) do
        if view.pauseSoundEffect then view:pauseSoundEffect() end
    end
    for i,sound in ipairs(self._loopSkillSoundEffects) do
        if sound.pause then sound:pause() end
    end
end

function QBattleScene:_pauseNode(node, actionManager, scheduler)
    actionManager:pauseTarget(node)
    scheduler:pauseTarget(node)
    local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
        local child = tolua.cast(children:objectAtIndex(i), "CCNode")
        self:_pauseNode(child, actionManager, scheduler)
    end
end

function QBattleScene:_onResume(event)
    self:_resumeNode(self._backgroundLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_resumeNode(self._trackLineLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_resumeNode(self._skeletonLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_resumeNode(self._dragLineLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_resumeNode(self._overSkeletonLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    if self._topBar_ccbOwner and self._topBar_ccbOwner.tf_dungeon_name then
        self:_resumeNode(self._topBar_ccbOwner.tf_dungeon_name, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    end
    -- self:_resumeNode(self._uiLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_resumeNode(self._overlayLayer, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_resumeSoundEffect()
end

function QBattleScene:_resumeNode(node, actionManager, scheduler)
    actionManager:resumeTarget(node)
    scheduler:resumeTarget(node)
    local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
        local child = tolua.cast(children:objectAtIndex(i), "CCNode")
        self:_resumeNode(child, actionManager, scheduler)
    end
end

function QBattleScene:_resumeSoundEffect()
    for i, view in ipairs(self._effectViews) do
        if view.resumeSoundEffect then view:resumeSoundEffect() end
    end
    for i, view in ipairs(self._frontEffectView) do
        if view.resumeSoundEffect then view:resumeSoundEffect() end
    end
    for i, view in ipairs(self._groundEffectView) do
        if view.resumeSoundEffect then view:resumeSoundEffect() end
    end
    for i, view in ipairs(self._heroViews) do
        if view.resumeSoundEffect then view:resumeSoundEffect() end
    end
    for i, view in ipairs(self._enemyViews) do
        if view.resumeSoundEffect then view:resumeSoundEffect() end
    end
    for i,sound in ipairs(self._loopSkillSoundEffects) do
        if sound.resume then sound:resume() end
    end
end

function QBattleScene:onEvent(event)
    if event == nil or event.name == nil then
        return
    end

    local eventName = event.name
    if eventName == QEntranceBase.ANIMATION_FINISHED then
        self._topBar:setVisible(true)
        self._autoSkillBar:setVisible(true)
        if self._cutscene:getName() == global.cutscenes.KRESH_ENTRANCE then
            local x, y = self._cutscene:getKreshPosition()
            local kreshView = self._cutscene:getKreshSkeletonView()
            kreshView:retain()
            kreshView:removeFromParentAndCleanup(false)
            app.battle:createEnemyManually("normal_kresh_1", 1, x, y, kreshView)
        end
        self._cutscene:exit()
        self._cutscene = nil
        app.battle:endCutscene()

    elseif eventName == QMissionBase.COMPLETE_STATE_CHANGE then
        if self._dungeonTargetInfo == nil then
            self._dungeonTargetInfo = QStaticDatabase.sharedDatabase():getDungeonTargetByID(self._dungeonConfig.id)
            if self._dungeonTargetInfo == nil then
                return 
            end
        end

        local mission = event.mission
        local index = app.missionTracer:getMissionIndex(mission)
        if index == nil or index == 0 then
            return
        end

        local onNode = self["_starOn" .. tostring(index)]
        local offNode = self["_starOff" .. tostring(index)]
        if onNode == nil or offNode == nil then
            return
        end

        if mission:isCompleted() == true then
        else
            onNode:setVisible(false)
            offNode:setVisible(true)
        end
        

    elseif eventName == QTouchActorView.EVENT_ACTOR_TOUCHED_BEGIN then
        if self._ended == true then
            return
        end

        local canDrag = false
        local actorView = event.actorView

        local heroViews = {}
        for i, view in ipairs(self._heroViews) do
            if actorView == view then
                canDrag = true
                break
            end
        end

        if canDrag and actorView and actorView:getModel():isDead() == false then
            self._dragController:enableDragLine(actorView, {x = event.positionX, y = event.positionY})
        end

    elseif eventName == QDragLineController.EVENT_DRAG_LINE_END_FOR_MOVE then
        local heroView = event.heroView
        if heroView.getModel and heroView:getModel():isDead() == false and not self._dragController:isSameWithTouchStartPosition({x = event.positionX, y = event.positionY}) then
            heroView:getModel():onDragMove(qccp(event.positionX, event.positionY))
            self._touchController:setSelectActorView(heroView)
        end

    elseif eventName == QDragLineController.EVENT_DRAG_LINE_END_FOR_ATTACK then
        local heroView = event.heroView
        if heroView.getModel and heroView:getModel():isDead() == false then
            local targetView = event.targetView
            heroView:getModel():onDragAttack(targetView:getModel())
            self._touchController:setSelectActorView(heroView)
        end

    elseif eventName == QTouchController.EVENT_TOUCH_END_FOR_MOVE then
        local heroView = event.heroView
        if heroView.getModel and heroView:getModel():isDead() == false and not self._dragController:isSameWithTouchStartPosition({x = event.positionX, y = event.positionY}) then
            heroView:getModel():onDragMove(qccp(event.positionX, event.positionY))
        end

    elseif eventName == QTouchController.EVENT_TOUCH_END_FOR_ATTACK then
        local heroView = event.heroView
        if heroView.getModel and heroView:getModel():isDead() == false then
            local targetView = event.targetView
            local targetModel = targetView:getModel()
            heroView:getModel():onDragAttack(targetModel, event.is_focus)
            if app.battle:isBoss(targetModel) == true and not app.battle:isInUnionDragonWar() then
                if self:_isBossHpViewMultiLayer() and not self._isActiveDungeon then
                    local hp_per_layer = QStaticDatabase:sharedDatabase():getHPPerLayerByLevel(targetModel:getLevel(), self._dungeonConfig)
                    self._bossHpBar:setHPPerLayer(hp_per_layer) 
                end
                self._bossHpBar:setActor(targetModel)
                self._bossHpBar:setVisible(true)
            end
        end

    elseif eventName == QTouchController.EVENT_TOUCH_END_FOR_SELECT then
        local oldSelectView = event.oldSelectView
        local newSelectView = event.newSelectView
        if oldSelectView ~= nil and oldSelectView.visibleSelectCircle then
            oldSelectView:visibleSelectCircle(QBaseActorView.HIDE_CIRCLE)
        end
        if newSelectView ~= nil then
            newSelectView:visibleSelectCircle(QBaseActorView.SOURCE_CIRCLE)
            newSelectView:displayHpView()

            for _, heroStatusView in ipairs(self._heroStatusViews) do
                heroStatusView:onSelectHero(newSelectView:getModel())
            end
        else
            for _, heroStatusView in ipairs(self._heroStatusViews) do
                heroStatusView:onSelectHero(nil)
            end

        end
    end

end

function QBattleScene:_onFrame(dt)
    local altered_dt, natural_dt = nil, nil
    app.battle._pauseRecord = app.battle.__pauseRecord
    -- self.isEnd 后台结算结束
    if not self.isEnd and not app.battle:isPaused() and not app.battle:isPauseRecord() and app.battle.onTick ~= nil then
        altered_dt, natural_dt = app.battle:onTick(dt)
        app.battle:update(altered_dt)
        app.grid:_onFrame(altered_dt)
        app.battleFrame = app.battleFrame + 1
        app.battleTime = app.battleTime + altered_dt
    end
    if app.battle._storyLine then
        app.battle._storyLine:visit(dt)
    end

    local zOrder = self:_updateActorZOrder()
    self:_updateActorPerspectiveScale()

    if self._touchController and self._touchController:isTouchEnded() then
        self._dragController:disableDragLine(true)
    end

    self:_updateMazeExploreDisplay()
    self:_updateThunderConditionDisplay()
    self:_udpateRebelFightAndSocietyDungeonDeathExplosion()
    self:_updateRebelStatsDisplay()
    self:_updateSocietyDungeonStatsDisplay()
    self:_updateUnionDragonWarStatsDisplay()
    self:_updateWorldBossStatsDisplay()
    self:_updateBlackRockStatsDisplay()
    self:_updateAutoSkillButton()
    self:_updateMountSkillAnimations()
    self:_updatePVPScore()
    self:_updateBlackRockInfoAnimation()
    self:_updateDailyBossAwards()
    self:_updateConsortiaWarDialog()

    self:wakeup()

    -- dt time padding
    -- CCMessageBox(tostring(altered_dt).." "..tostring(natural_dt), "")
    if altered_dt and natural_dt and altered_dt > natural_dt then
        local _clock = q.time()
        while true do
            if q.time() - _clock >= (altered_dt - natural_dt) then
                break
            end
        end
    end
end

function QBattleScene:_updateConsortiaWarDialog()
    local consortiaWarHallIdNum = self._dungeonConfig.consortiaWarHallIdNum or 0
    if not self._dungeonConfig.isConsortiaWar or self._isShowConsortiaWarDialog or consortiaWarHallIdNum == 0 then
        return
    end
    self.curModalDialog = QBattleDialogConsortiaWar.new()
    self._isShowConsortiaWarDialog = true
end

function QBattleScene:_checkMissionComplete()
    if app.missionTracer == nil then
        return 
    end

    local count = app.missionTracer:getCompleteMissionCount()
    if count == 0 then
        self._starOff1:setVisible(true)
        self._starOff2:setVisible(true)
        self._starOff3:setVisible(true)
        self._starOn1:setVisible(false)
        self._starOn2:setVisible(false)
        self._starOn3:setVisible(false)
    elseif count == 1 then
        self._starOff1:setVisible(false)
        self._starOff2:setVisible(true)
        self._starOff3:setVisible(true)
        self._starOn1:setVisible(true)
        self._starOn2:setVisible(false)
        self._starOn3:setVisible(false)
    elseif count == 2 then
        self._starOff1:setVisible(false)
        self._starOff2:setVisible(false)
        self._starOff3:setVisible(true)
        self._starOn1:setVisible(true)
        self._starOn2:setVisible(true)
        self._starOn3:setVisible(false)
    else
        self._starOff1:setVisible(false)
        self._starOff2:setVisible(false)
        self._starOff3:setVisible(false)
        self._starOn1:setVisible(true)
        self._starOn2:setVisible(true)
        self._starOn3:setVisible(true)
    end

end

function QBattleScene:visibleBackgroundLayer(visible, actor, time, no_fade, isFireWall)
    if actor == nil then
        return
    end

    local view = self:getActorViewFromModel(actor)
    if view == nil then
        return
    end

    time = time or 0.15
    local backgroundLayer = self:getBackgroundOverLayer()
    

    if visible == true then
        self._showBlackLayerReferenceCount = self._showBlackLayerReferenceCount + 1
        if self._showBlackLayerReferenceCount == 1 and self._killActorAnimation3:isVisible() == false then
            backgroundLayer:setVisible(true)
            if no_fade then
                backgroundLayer:stopAllActions()
                backgroundLayer:setOpacity(0)
            else
                backgroundLayer:stopAllActions()
                backgroundLayer:runAction(CCFadeTo:create(time, 128))
            end
        end

        self._showActorView = view
        if isFireWall then
            self._fireWall:setVisible(isFireWall)
        end
    else
        self._showBlackLayerReferenceCount = math.max(0, self._showBlackLayerReferenceCount - 1)
        if self._showBlackLayerReferenceCount == 0 then
            if no_fade then
                backgroundLayer:stopAllActions()
                backgroundLayer:setOpacity(0)
                backgroundLayer:setVisible(false)
            else
                backgroundLayer:stopAllActions()
                local arr = CCArray:create()
                arr:addObject(CCFadeTo:create(time, 0))
                arr:addObject(CCCallFunc:create(function()
                    backgroundLayer:setVisible(false)
                end))
                backgroundLayer:runAction(CCSequence:create(arr))
            end
        end

        self._showActorView = nil
        self._fireWall:setVisible(false)
    end
end

function QBattleScene:_updateActorPerspectiveScale()
    local db = QStaticDatabase:sharedDatabase()
    local scale1 = db:getConfigurationValue("PERSPECTIVE_SCALE_MIN") or 0.9
    local scale2 = db:getConfigurationValue("PERSPECTIVE_SCALE_MAX") or 1.1
    local function _updatePerspective(views)
        for _, view in ipairs(views) do
            if view.setSizeScale then
                local _, y = view:getPosition()
                local scale = math.sampler2(scale1, scale2, BATTLE_AREA.top, BATTLE_AREA.bottom, y)
                view:setSizeScale(scale, "perspective")
            end
        end
    end
    _updatePerspective(self._heroViews)
    _updatePerspective(self._enemyViews)
    _updatePerspective(self._effectViews)
    _updatePerspective(self._groundEffectView)
    _updatePerspective(self._frontEffectView)
end

function QBattleScene:_updateActorZOrder()
    local allActorView = {}
    for i, view in ipairs(self._heroViews) do
        table.insert(allActorView, view)
    end
    for i, view in ipairs(self._enemyViews) do
        table.insert(allActorView, view)
    end
    for i, view in ipairs(self._effectViews) do
        table.insert(allActorView, view)
    end
    local sortedActorView = q.sortNodeZOrder(allActorView, false)

    local layer = self:getBackgroundOverLayer()

    -- reset the z order
    local zOrder = 1
    for _, view in ipairs(self._groundEffectView) do
        view:setZOrder(zOrder)
        zOrder = zOrder + 1
    end
    for _, view in ipairs(sortedActorView) do
        view:setZOrder(zOrder)
        zOrder = zOrder + 1
    end

    if layer:isVisible() == true then
        for i, view in ipairs(self._frontEffectView) do
            view:setZOrder(zOrder)
            zOrder = zOrder + 1
        end
        
        layer:setZOrder(zOrder)
        zOrder = zOrder + 1

        local frontViewsByActorView = {}
        local groundViewsByActorView = {}
        local actorView, views
        for i, view in ipairs(self._groundEffectView) do
            if view.getActorView then
                actorView = view:getActorView()
                if actorView then
                    views = groundViewsByActorView[actorView]
                    if not views then
                        views = {}
                        groundViewsByActorView[actorView] = views
                    end
                    table.insert(views, view)
                end
            end
        end
        for i, view in ipairs(self._frontEffectView) do
            if view.getActorView then
                actorView = view:getActorView()
                if actorView then
                    views = frontViewsByActorView[actorView]
                    if not views then
                        views = {}
                        frontViewsByActorView[actorView] = views
                    end
                    table.insert(views, view)
                end
            end
        end

        local showActorViews = {}
        for _, view in ipairs(sortedActorView) do
            if self._showActorView and self._showActorView.__cname == "QNpcActorView" then
                if view == self._showActorView then
                    table.insert(showActorViews, view)
                end
            else
                if view.__cname == "QHeroActorView" then
                    local skill = view:getModel():getCurrentSkill()
                    if view == self._showActorView or skill ~= nil and skill:getSkillType() == QSkill.MANUAL then
                        local actor = view:getModel()
                        local skill = actor:getCurrentSkill()
                        if skill and skill:getSkillType() == QSkill.MANUAL then
                            if skill:getRangeType() == skill.SINGLE then
                                if skill:getTargetType() == skill.TARGET then
                                    local target = actor:getCurrentSkillTarget()
                                    if target then
                                        local targetView = self:getActorViewFromModel(target)
                                        if targetView then
                                            table.insert(showActorViews, 1, targetView)
                                        end
                                    end
                                end
                            elseif skill:getRangeType() == skill.MULTIPLE then
                                local targets = actor:getMultipleTargetWithSkill(skill, actor:getCurrentSkillTarget())
                                for _, target in ipairs(targets) do
                                    local targetView = self:getActorViewFromModel(target)
                                    if targetView then
                                        table.insert(showActorViews, 1, targetView)
                                    end
                                end
                            end
                            -- 合体魂师也要显示在上面
                            local deputyIDs = actor:getDeputyActorIDs()
                            if deputyIDs and next(deputyIDs) then
                                local mates = app.battle:getMyTeammates(actor)
                                for _, mate in ipairs(mates) do
                                    if deputyIDs[mate:getActorID()] then
                                        table.insert(showActorViews, 1, self:getActorViewFromModel(mate))
                                    end
                                end
                            end
                        end

                        table.insert(showActorViews, view)
                    end
                end
            end
        end

        if self._showActorView then
            local views = groundViewsByActorView[self._showActorView]
            if views then
                for _, view in ipairs(views) do
                    view:setZOrder(zOrder)
                    zOrder = zOrder + 1
                end
            end
        end
        for _, actorview in ipairs(showActorViews) do
            actorview:setZOrder(zOrder)
            zOrder = zOrder + 1
        end
        if self._showActorView then
            local views = frontViewsByActorView[self._showActorView]
            if views then
                for _, view in ipairs(views) do
                    view:setZOrder(zOrder)
                    zOrder = zOrder + 1
                end
            end
        end
    else
        for i, view in ipairs(self._frontEffectView) do
            view:setZOrder(zOrder)
            zOrder = zOrder + 1
        end
    end

    return zOrder
end

function QBattleScene:_onPauseButtonClicked(event)
    if q.buttonEventShadow(event, self._topBar_ccbOwner.btn_pause) == false then
        return
    end
    if self._ended == true or self._tutorialForUseSkill == true or self._tutorialForTouchActor == true or app.battle == nil or app.battle:hasWinOrLose() then
        return 
    end

    if app.battle:isInEditor() == true then
        if app.battle:isPVPMode() then
            if app.battle:isPaused() then
                app.battle:resume()
            else
                app.battle:pause()
            end
        end
        return
    end

    if app.battle:isPaused() == true then
        return
    end

    if not self._battle_started then
        return
    end

    -- self:_onWin()
    -- if true then return end

    self.curModalDialog = QBattleDialogPause.new(nil, {
        -- onAbort = handler(self, QBattleScene._onAbort),
        onAbortCallBack = function (tag)
            self:_onAbort(tag)
            if app.battle:getDungeonDuration() - app.battle:getTimeLeft() > 30 then
                self:requestLost()
            end
        end,
        onRestartCallBack = handler(self, QBattleScene._onRestart),
        isReplay = self._dungeonConfig.isReplay or self._dungeonConfig.isFriend})
end

function QBattleScene:_onMissionButtonClicked()
    if self._ended == true or app.battle == nil then
        return 
    end

    if app.battle:isInEditor() == true then
        return
    end

    if app.battle:isPaused() == true then
        return
    end

    if self._isActiveDungeon == true then
        return
    end

    -- self:_onWin()
    -- if true then return end

    self.curModalDialog = QBattleDialogMissions.new(self._isPassedBefore)
end

function QBattleScene:_onAutoSkillClicked()
    if self._ended == true or app.battle == nil then
        return 
    end

    if app.battle:isInEditor() == true then
        return
    end

    if app.battle:isPaused() == true or app.battle:isPausedBetweenWave() == true then
        self:checkAutoSkillButtonHighlight()
        return
    end

    if app.battle:isInReplay() and not app.battle:isInQuick() then
        app.tip:floatTip(global.replay_warning) 
    else
        if (app.battle:isInSunwell() and not app.battle:isSunwellAllowControl()) 
            or (app.battle:isInArena() and not app.battle:isArenaAllowControl())
            or (app.battle:isInSilverMine() and app.battle:isPVPMode())
        then
            local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
            app.tip:floatTip(global.control_is_not_allowed_warning)
        elseif self._isAutoSkillLocked == false then
            if ENABLE_AUTOSKILL_DIALOG then
                self.curModalDialog = QBattleDialogAutoSkill.new(nil,{callback = self._toggleAutoSkillCast})
            else
                self:_toggleAutoSkillCast()
            end

            if self._isClickAutoSkillEver == false then
                app:getUserData():setUserValueForKey(QUserData.CLICK_AUTO_SKILL, QUserData.STRING_TRUE)
                self._isClickAutoSkillEver = true
                if self._node_autoSkillLight ~= nil then
                    self._node_autoSkillLight:setVisible(false)
                end
            end
        else
            if FinalSDK.isHXShenhe() then
                app.tip:floatTip("功能暂未开放")
            else
                app.tip:floatTip("魂师大人，通关普通副本1-12可开启自动技能哦~")
            end
            -- app.unlock:getUnlockAutoSkill(true)
        end
    end
end


function QBattleScene:_toggleAutoSkillCast()
    local _suffix = "autoUseSkill"
    local dungeonConfig = app.battle:getDungeonConfig()
    local dungeonInfo = remote.activityInstance:getDungeonById(dungeonConfig.id)
    if dungeonInfo ~= nil then
        _suffix = "autoUseSkill-active"
    end
    if app.battle:isPVPMode() == true and app.battle:isInSunwell() == true then
        _suffix = "autoUseSkill-sunwell"
    end
    if app.battle:isPVPMode() == true and app.battle:isInArena() == true then
        _suffix = "autoUseSkill-Arena"
    end
    local autoUseSkill = app:getUserData():getUserValueForKey( _suffix)
    local function _toggleHero(hero)
        if autoUseSkill == nil or autoUseSkill ~= QUserData.STRING_TRUE then
            hero:setForceAuto(true)
        else
            hero:setForceAuto(false)
        end
    end
    for _, view in ipairs(self._heroStatusViews) do
        local hero = view:getActor()
        _toggleHero(hero)
    end
    if self._supporterHeroStatusView then
        local hero = self._supporterHeroStatusView:getActor()
        _toggleHero(hero)
    end
    if self._supporterHeroStatusView2 then
        local hero = self._supporterHeroStatusView2:getActor()
        _toggleHero(hero)
    end
    if autoUseSkill == nil or autoUseSkill ~= QUserData.STRING_TRUE then
        app:getUserData():setUserValueForKey(_suffix, QUserData.STRING_TRUE)
    else
        app:getUserData():setUserValueForKey(_suffix, QUserData.STRING_FALSE)
    end
end

function QBattleScene:_doNextWaveClick()
    -- print(#app.battle._record.recordTimeSlices)
    self:removeNewEnemyTips()
    app.sound:playSound("battle_switch")
    self._arrow:setVisible(false)

    local heroes = {}
    table.mergeForArray(heroes, app.battle._heroes)
    table.mergeForArray(heroes, app.battle._heroGhosts, nil, function(ghost) return ghost.actor end)
    local heroViews = {}
    for _, hero in ipairs(heroes) do
        heroViews[#heroViews + 1] = self:getActorViewFromModel(hero)
    end
    
    for i, view in ipairs(heroViews) do
        if view:getModel():isDead() == false and not view:getModel():isSupport() then
            app.grid:removeActor(view:getModel())
        end
    end

    -- nzhang: make sure this function is called before view:changToWalkAnimationAndRightDirection() is called
    app.battle:onConfirmNewWave()

    local speedCoefficient = 2.0
    local timeToLeave = 0
    for i, view in ipairs(heroViews) do
        if view:getModel():isDead() == false and not view:getModel():isIdleSupport() and view:isVisible() then
            view:getModel():insertPropertyValue("movespeed_value", "nextwave", "*", speedCoefficient)
            view:getSkeletonActor():setAnimationScaleOriginal(view:getSkeletonActor():getAnimationScaleOriginal() * speedCoefficient)

            local moveSpeed = view:getModel():getMoveSpeed()
            local position = view:getModel():getPosition()
            local targetPosition = {x = BATTLE_SCREEN_WIDTH + view:getModel():getRect().size.width + 249, y = position.y}
            local time = (targetPosition.x - position.x) / moveSpeed
            if time > timeToLeave then
                timeToLeave = math.min(time,3)
            end
            view:getModel():setDirection(QActor.DIRECTION_RIGHT)
            view:changToWalkAnimation()
            view:runAction(CCMoveTo:create(time, ccp(targetPosition.x, targetPosition.y)))
        end
    end
    timeToLeave = timeToLeave + 0.5
    app.battle:performWithDelay(function()
        app.grid:resetWeight()
        for i, view in ipairs(heroViews) do
            if view.getModel then
                if view:getModel():isDead() == false and not view:getModel():isIdleSupport() and view:isVisible() then
                    view:showName()
                    app.grid:addActor(view:getModel())
                    if not app.battle:isGhost(view:getModel()) and not view:getModel():isSupport() then
                        app.grid:setActorTo(view:getModel(), view:getModel()._enterStartPosition)
                        app.grid:moveActorTo(view:getModel(), view:getModel()._enterStopPosition)
                    else
                        local start_pos = {x = -100, y = view:getModel():getPosition().y}
                        local stop_pos = {x = start_pos.x + BATTLE_SCREEN_WIDTH / 2, y = start_pos.y}
                        app.grid:setActorTo(view:getModel(), start_pos)
                        app.grid:moveActorTo(view:getModel(), stop_pos)
                    end
                end
            end
        end
        -- change scene background
        if self._dungeonConfig.mode == BATTLE_MODE.WAVE_WITH_DIFFERENT_BACKGROUND then
            if app.battle:getNextWave() == 1 then

            elseif app.battle:getNextWave() == 2 and self._dungeonBGNodes[2] ~= nil then
                if self._dungeonConfig.bg_2 ~= nil then
                    self:replaceBGFile(self._dungeonBGNodes[2][1], self._dungeonBGNodes[2][2])
                    self._dungeonBGNodes[2] = nil
                end

            elseif app.battle:getNextWave() == 3 then
                if self._dungeonConfig.bg_3 ~= nil and self._dungeonBGNodes[3] ~= nil then
                    self:replaceBGFile(self._dungeonBGNodes[3][1], self._dungeonBGNodes[3][2])
                    self._dungeonBGNodes[3] = nil
                end

            else

            end

        elseif self._dungeonConfig.mode == BATTLE_MODE.SEVERAL_WAVES then
            self:flipBG()
        end
        
        self._touchController:setSelectActorView(nil)
        self._touchController:enableTouchEvent()
        for _, view in ipairs(heroViews) do
            if view.setEnableTouchEvent then
                view:setEnableTouchEvent(true)
            end
        end

        if self._lastWaveSelectActorView then
            local view = self._lastWaveSelectActorView
            if view and view.getModel then
                app.scene:uiSelectHero(view:getModel())
            end
            self._lastWaveSelectActorView = nil
        else
            self:_defaultSelectHero()
        end

        app.battle:onStartNewWave()
    end, timeToLeave, nil, true, nil, true)

    app.battle:performWithDelay(function()
        for i, view in ipairs(heroViews) do
            if view.getModel then
                if view:getModel():isDead() == false and not view:getModel():isIdleSupport() and view:isVisible() then
                    view:getModel():removePropertyValue("movespeed_value", "nextwave")
                    view:getSkeletonActor():setAnimationScaleOriginal(view:getSkeletonActor():getAnimationScaleOriginal() / speedCoefficient)
                end
            end
        end

        -- app.battle:onStartNewWave()

    end, timeToLeave + global.hero_enter_time / speedCoefficient - 0.3, nil, true, nil, true)

end

function QBattleScene:_onNextWaveClicked()
    -- 埋点 第一关副本第2节-点击
    if not remote.instance:checkIsPassByDungeonId(self._dungeonConfig.id) 
        and self._dungeonConfig.id == "wailing_caverns_1" then -- 由于只有2波，所以我就不判断当前波次了
        app:triggerBuriedPoint(20430)
    end

    app.battle._executeNextWave = function()
        self:_doNextWaveClick()
    end

    self._wave_end_click = true

    -- 当前帧可能未被记录，所以不能直接继续
    app.battle.__pauseRecord = false
end

function QBattleScene:_checkTeamUp()
    if remote.oldUser ~= nil and remote.oldUser.level < remote.user.level then
        app:sendGameEvent(GAME_EVENTS.GAME_EVENT_ROLE_LEVEL_UP, true)
        local oldUser = remote.oldUser
        remote.oldUser = nil
         if self.curModalDialog ~= nil then
            self.curModalDialog:close()
            self.curModalDialog = nil
        end
        local options = {}
        options["level"]=oldUser.level or 1
        options["level_new"]=remote.user.level
        local database = QStaticDatabase:sharedDatabase()
        local config = database:getTeamConfigByTeamLevel(options["level_new"])
        local energy = 0
        local award = 0
        if config ~= nil then
            energy = config.energy
            award = config.token
        end
        energy = remote.user.energy - energy
        if energy < 0 then energy = 0 end
        options["energy"]=energy
        options["energy_new"]=remote.user.energy
        options["award"]=award
        self.curModalDialog = QDialogTeamUp.new(options,{
                        onChoose = handler(self, QBattleScene._onAbort)})
    else
        self:_onAbort()
    end
end

function QBattleScene:_onAbort(tag, guideEvent)
    if self.curModalDialog ~= nil and self.curModalDialog.close then
        self.curModalDialog:close()
        self.curModalDialog = nil
    end
    
    if app.tip._floatTip ~= nil then
      app.tip._floatTip = nil
      app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TO_CURRENT_PAGE)
    end
    app.grid:pauseMoving()
    self:setBattleEnded(true)
    if self._rewardNodeArray then
        for i, node in ipairs(self._rewardNodeArray) do
            node:stopAllActions()
        end
        self._rewardNodeArray = nil
    end
    app:exitFromBattleScene(true)
    if guideEvent ~= nil then
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = guideEvent.name, options = guideEvent.options})
    end
end

function QBattleScene:_onRestart( ... )
    if app.battle:isInEditor() then
        display.getRunningScene():endBattle()
        display.getRunningScene():onResetBattle()
        return
    end

     if self.curModalDialog ~= nil and self.curModalDialog.close then
        self.curModalDialog:close()
        self.curModalDialog = nil
    end

    if not app.battle:isInReplay() and app.battle:getDungeonDuration() - app.battle:getTimeLeft() > 30 then
        -- self:requestLost()
    end

    self._restartFlag = true

    app.grid:pauseMoving()
    self:setBattleEnded(true)

    -- hero model preload, to comply with QDugeonResourceLoader
    set_replay_pseudo_id(0)

    if self._bossHpBar then
        self._bossHpBar:removeFromParentAndCleanup()
        self._bossHpBar = nil
    end

    app.battle.onTick = nil
    if not app.battle:isInReplay() then
        app.battle._dungeonConfig.timeGearChange = nil
        app.battle._dungeonConfig.playerAction = nil
        app.battle._dungeonConfig.forceAutoChange = nil
        app.battle._dungeonConfig.disableAIChange = nil
    end
    -- print("restart fight battle")
    -- self:requestRestartFight()
    
    collectgarbageCollect()

    --[[Kumo]]
    if self._dungeonConfig.isSilvesArenaBattle then
        local tbl = {...}
        local config = tbl[2]
        if config then
            self._dungeonConfig = config
        else
            self:_onAbort()
        end
    end
    app:replaceBattleScene(self._dungeonConfig)
end

function QBattleScene:requestRestartFight()
    -- requestRestartFight
    if self._dungeonConfig.isRecommend 
        and not app.battle:isInThunder() 
        and not app.battle:isActiveDungeon() 
        and not app.battle:isPVPMode()
        and not app.battle:isInNightmare()
    then
        -- todo
        if self._dungeonConfig.defeat_buff then
            local id = self._dungeonConfig.id
            local m_dungeonInfo = remote.instance:getDungeonById(id)
            local battleType = BattleTypeEnum.DUNGEON_NORMAL
            if dungeonInfo ~= nil and dungeonInfo.dungeon_type == DUNGEON_TYPE.NORMAL then
                battleType = BattleTypeEnum.DUNGEON_NORMAL
            elseif m_dungeonInfo ~= nil and m_dungeonInfo.dungeon_type == DUNGEON_TYPE.ELITE then
                battleType = BattleTypeEnum.DUNGEON_ELITE
            elseif m_dungeonInfo ~= nil and m_dungeonInfo.dungeon_type == DUNGEON_TYPE.WELFARE then
                battleType = BattleTypeEnum.DUNGEON_WELFARE
            else
                local activeDungeonInfo = remote.activityInstance:getDungeonById(id)
                if activeDungeonInfo ~= nil and (activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME or activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_CHALLENGE) then
                    battleType = BattleTypeEnum.DUNGEON_ACTIVITY
                end
            end
            local  battleFormation = self._dungeonConfig.battleFormation
            app:getClient():dungeonFightStart(battleType, id, battleFormation, function (data)
                self._dungeonConfig.dailyAwards = data.batchAwards
                self._dungeonConfig.awards = data.awards
                self._dungeonConfig.awards2 = data.awards2
                self._dungeonConfig.verifyKey = data.gfStartResponse.battleVerify
                self._dungeonConfig.lostCount = remote.instance:getLostCountById(self._dungeonId)
                -- app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                -- app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                -- app:getNavigationManager():getController(app.mainUILayer):getTopPage():loadBattleResources()
            end)
        end
    end
end

function QBattleScene:_onBattleTimer(evt)
    local timeLeft = app.battle:getTimeLeft()
    if timeLeft < 0 then
        timeLeft = 0
    end
    local timeLimit = 10

    if math.floor(timeLeft) <= timeLimit then
        self._labelCountDown:setColor(ccc3(255, 10, 0))

        local oldTimeLeft = timeLeft + evt.dt
        if math.floor(oldTimeLeft) ~= math.floor(timeLeft) then
            local arr = CCArray:create()
            arr:addObject(CCScaleTo:create(0.15, 1.25))
            arr:addObject(CCScaleTo:create(0.15, 1.0))
            self._labelCountDown:stopAllActions()
            self._labelCountDown:runAction(CCSequence:create(arr))
        end
    else
        self._labelCountDown:setColor(ccc3(255, 255, 255))
    end

self._labelCountDown:setString(string.format("%.2d:%.2d", math.floor(timeLeft / 60.0), math.ceil(timeLeft % 60.0)))
end

local function view_filter(view)
    return view.getModel and view:getModel():isDead() == false 
        and (not view:getModel():isSupport() or (not view:getModel():isPet()
            and table.indexof(app.battle:getHeroes(), view:getModel())) or (view:getModel():isPet()
            and table.indexof(app.battle:getHeroes(), view:getModel():getHunterMaster())))
        and (not app.battle:isGhost(view:getModel()) or view:getModel():isControlNPC() or view:getModel():isPet()
            or view:getModel():isSoulSpirit())
        and (not view:getModel():isCandidate() or table.indexof(app.battle:getHeroes(), view:getModel()))
end
    
function QBattleScene:_onWin(event)
    if not app.battle:isInEditor() then
        app:setSpeedGear(1, 1)
    end
    QSkeletonViewController.sharedSkeletonViewController():removeSkeletonData()
    app:setIsClearSkeletonData(true)
    app:cleanTextureCache()

    -- is time over trigger battle end
    self._isTimeOver = event.isTimeOver
    -- end battle to finish buff and skill
    self:setBattleEnded(true, true)

    self._resultProxy:onResult(true)

    self:removeAllDummyAsPositionViews()

    local viewList = {}
    local heroCount = 0
    for i, view in ipairs(self._heroViews) do
        if view_filter(view) then
            heroCount = heroCount + 1
            table.insert(viewList, view)
        end
    end

    if event ~= nil and event.isAllEnemyDead == true then
        local x = BATTLE_AREA.left + BATTLE_AREA.width * 0.5
        local y = BATTLE_AREA.bottom + BATTLE_AREA.height * 0.2
        local interval = 168
        local newPositions = {}

        local start_x = x - interval * (heroCount - 1) / 2
        for i = 1, heroCount do
            table.insert(newPositions, {start_x, y})
            start_x = start_x + interval
        end

        -- 将actor从grid上清除，否则会相互干扰最后的站位
        for i, view in ipairs(viewList) do
            app.grid:removeActor(view:getModel())
        end

        local dataBase = QStaticDatabase:sharedDatabase()
        local eggList = dataBase:getSkinsEggByType(1)
        local validEggList = {}
        for _, config in ipairs(eggList) do
            local isValid1, isValid2 = false, false
            local dict = {}
            for _, view in ipairs(viewList) do
                local skinId = view:getModel():getSkinId()
                if skinId == config.skins_id_1 then
                    isValid1 = true
                    dict.index1 = view
                end
                if skinId == config.skins_id_2 then
                    isValid2 = true
                    dict.index2 = view
                end
            end
            if isValid1 and isValid2 then
                table.insert(validEggList, dict)
            end
        end

        local function moveActor(view, positionIndex)
            view:getModel():setTarget(nil)
            view:getModel():insertPropertyValue("movespeed_percent", self, "+", 0.5) -- 在战斗结束魂师走位的时候，加快移动速度
            app.grid:addActor(view:getModel())
            app.grid:moveActorTo(view:getModel(), qccp(newPositions[positionIndex][1], newPositions[positionIndex][2]))
        end

        app.grid:resetWeight()
        local positionIndex = 1
        local movedCache = {}
        for i, view in ipairs(viewList) do
            if view:getModel():isSoulSpirit() then
                moveActor(view, positionIndex)
                positionIndex = positionIndex + 1
                movedCache[view] = true
            end
        end
        -- 这个彩蛋最多有两个
        for _, config in ipairs(validEggList) do
            moveActor(config.index1, positionIndex)
            positionIndex = positionIndex + 1
            moveActor(config.index2, positionIndex)
            positionIndex = positionIndex + 1
        end
        for _, view in ipairs(viewList) do
            if not movedCache[view] then
                if next(validEggList) then
                    local isEggView = false
                    for _, config in ipairs(validEggList) do
                        if config.index1 == view or config.index2 == view then
                            isEggView = true
                        end
                    end
                    if not isEggView then
                        moveActor(view, positionIndex)
                        positionIndex = positionIndex + 1
                    end
                else
                    moveActor(view, positionIndex)
                    positionIndex = positionIndex + 1
                end
            end
        end
    else
        -- 将actor从grid上清除，否则会相互干扰最后的站位
        for i, view in ipairs(viewList) do
            app.grid:removeActor(view:getModel())
        end

        app.grid:resetWeight()
        for i, view in ipairs(viewList) do
            view:getModel():setTarget(nil) -- 不让魂师再追小怪，不为什么，只是觉得这样正确 http://jira.joybest.com.cn/browse/WOW-7486
            app.grid:addActor(view:getModel())
        end
    end

    local function onMoveCompleted(skipMove)
        -- direction
        for i, view in ipairs(viewList) do
            view:getModel():setDirection(QActor.DIRECTION_RIGHT)
        end

        -- show victory
        for i, view in ipairs(viewList) do
            view:getModel():onVictory()
            view:showName()
        end

        self._onWinHandle1 = scheduler.performWithDelayGlobal(function()
            self._onWinHandle1 = nil
            local isHandlerResultProxy = false
            if self._resultProxy ~= nil then
                isHandlerResultProxy = self._resultProxy:onMoveCompleted()
                if isHandlerResultProxy == true then
                    self:resultHandler({}, true)
                end
            end
            local callback = function()
                    self:_onAbort()
                end
            if isHandlerResultProxy == false then
                if app.battle:isPVPMode() == true then
                    if app.battle == nil then return end

                    if app.battle:isInEditor() then
                        display.getRunningScene():endBattle(true)
                        display.getRunningScene():onResetBattle()
                        return
                    elseif app.battle:isInReplay() and not app.battle:isInQuick() and not app.battle:isInSilvesArenaReplayBattleModule() or self:isInFriend()   then
                        if self._dungeonConfig.isPvpMultipleNew then
                            self.curModalDialog = QBattleDialogFightEndRecord.new({callback = callback})
                        else
                            self.curModalDialog = QBattleDialogAgainstRecord.new({},{}, callback)
                        end
                        return
                    end
                else
                    if app.battle then
                        if app.battle:isInEditor() then
                            display.getRunningScene():endBattle()
                            display.getRunningScene():onResetBattle()
                            return
                        elseif app.battle:isInReplay() and not app.battle:isInQuick() or self:isInFriend() then
                            if self._dungeonConfig.isPvpMultipleNew then
                                self.curModalDialog = QBattleDialogFightEndRecord.new({callback = callback})
                            else
                                self.curModalDialog = QBattleDialogAgainstRecord.new({},{}, callback)
                            end
                            return
                        end
                    end
                end
            end
        end, skipMove and 0 or global.victory_animation_duration)
    end

    self._onWinScheduler = CCDirector:sharedDirector():getScheduler()
    self._onWinHandle = self._onWinScheduler:scheduleScriptFunc(function()
        local move_completed = true

        if event ~= nil and event.isAllEnemyDead == true then
            for i, view in ipairs(viewList) do
                if view:getModel():isWalking() then
                    move_completed = false
                else
                    view:getModel():setDirection(QActor.DIRECTION_RIGHT)
                end
            end
        end

        if event.skipMove then
            move_completed = true
        end

        if move_completed then
            self._onWinScheduler:unscheduleScriptEntry(self._onWinHandle)
            self._onWinHandle = nil
            self._onWinScheduler = nil
            onMoveCompleted(event.skipMove)
        end
    end, 0, false)
end

--跟后台通讯出错
function QBattleScene:requestFail(data)
    app:hideLoading()
    self._requestFail = true
    local errorCode = QStaticDatabase:sharedDatabase():getErrorCode(data.error)
    local errorStr = "很遗憾，本次战斗数据出错！"
    if errorCode ~= nil then
        errorStr = errorCode.desc or errorStr
    end
    app:alert({content = errorStr, title = "系统提示", btns = {ALERT_BTN.BTN_OK}, callback = function (state)
        self:cancelMoveSchedule()
        self:_onAbort()
    end}, nil, true)
end

function QBattleScene:_onLose(event)
    if not app.battle:isInEditor() then
        app:setSpeedGear(1, 1)
    end
    QSkeletonViewController.sharedSkeletonViewController():removeSkeletonData()
    app:setIsClearSkeletonData(true)
    app:cleanTextureCache()

    self:setBattleEnded(true, false)

    local isHandler = self._resultProxy:onResult(false)
    local function playLose()
        if app.battle == nil then
            return
        end

        local function showDialog() 
            self._onLoseHandle2 = scheduler.performWithDelayGlobal(function()
                self._onLoseHandle2 = nil
                -- battle may be nil when user is forced to logout
                if app.battle == nil then return end
                if isHandler == true then
                    self._resultProxy:onMoveCompleted()
                    return 
                end
                if app.battle:isInEditor() then
                    display.getRunningScene():endBattle(false)
                    display.getRunningScene():onResetBattle()
                    return
                elseif app.battle:isInReplay() and not app.battle:isInQuick() and not app.battle:isInSilvesArenaReplayBattleModule() or self:isInFriend() then
                    local callback = function()
                        self:_onAbort()
                    end
                    if self._dungeonConfig.isPvpMultipleNew then
                        self.curModalDialog = QBattleDialogFightEndRecord.new({callback = callback})
                    else
                        self.curModalDialog = QBattleDialogAgainstRecord.new({},{}, callback)
                    end
                    return
                end
            end, 1.5)
        end

        if app.battle:isInEditor() or not self._enemyViews then
            if app.battle:isInEditor() then
                display.getRunningScene():endBattle(true)
                display.getRunningScene():onResetBattle()
            end
            return
        end

        -- move to center
        local x = BATTLE_AREA.left + 840
        local y = BATTLE_AREA.bottom + BATTLE_AREA.height * 0.2
        local interval = 160
        local moveTime = 0

        -- 将actor从grid上清除，否则会相互干扰最后的站位
        for i, view in ipairs(self._enemyViews) do
            if view:getModel():isDead() == false then
                app.grid:removeActor(view:getModel())
            end
        end

        -- show victory
        self._onLoseHandle3 = scheduler.performWithDelayGlobal(function()
            self._onLoseHandle3 = nil
            for i, view in ipairs(self._enemyViews) do
                if view:getModel():isDead() == false then
                    view:getModel():onVictory()
                end
            end

            showDialog()
        end, moveTime)
        moveTime = moveTime + 3.0
    end

    self._onLoseHandle1 = scheduler.performWithDelayGlobal(function()
        self._onLoseHandle1 = nil
        playLose()
    end, 2.0)
end


--请求战斗失败
function QBattleScene:requestLost()
    if self._dungeonConfig.isRecommend 
        and not app.battle:isInThunder() 
        and not app.battle:isActiveDungeon() 
        and not app.battle:isPVPMode()
        and not app.battle:isInNightmare()
    then
        -- todo
        if self._dungeonConfig.defeat_buff then
            local id = self._dungeonConfig.id
            local m_dungeonInfo = remote.instance:getDungeonById(id)
            local battleType = BattleTypeEnum.DUNGEON_NORMAL
            if dungeonInfo ~= nil and dungeonInfo.dungeon_type == DUNGEON_TYPE.NORMAL then
                battleType = BattleTypeEnum.DUNGEON_NORMAL
            elseif m_dungeonInfo ~= nil and m_dungeonInfo.dungeon_type == DUNGEON_TYPE.ELITE then
                battleType = BattleTypeEnum.DUNGEON_ELITE
            elseif m_dungeonInfo ~= nil and m_dungeonInfo.dungeon_type == DUNGEON_TYPE.WELFARE then
                battleType = BattleTypeEnum.DUNGEON_WELFARE
            else
                local activeDungeonInfo = remote.activityInstance:getDungeonById(id)
                if activeDungeonInfo ~= nil and (activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME or activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_CHALLENGE) then
                    battleType = BattleTypeEnum.DUNGEON_ACTIVITY
                end
            end
            -- self._dungeonConfig
            app:getClient():fightFailRequest(battleType, id, self._dungeonConfig.verifyKey, function ()
                local dungeonType = remote.welfareInstance:getDungeonTypeByDungeonID(id)
                if dungeonType == DUNGEON_TYPE.WELFARE then
                    remote.welfareInstance:updateFailCount(remote.welfareInstance:getLostCount() + 1)
                else
                    remote.instance:addLostCountById(id)
                end
            end)
            self._dungeonConfig.lostCount = (self._dungeonConfig.lostCount or 0) + 1
        end
    end
end

-- @qinyuanji, it seems self._dungeonConfig.myInfo.heros is not the heros on battle field
-- So I have to find them from the team index, and get their properties
function QBattleScene:_constructArenaAttackHero(team)
    local attackHeroInfo = {}
    for k, v in ipairs(remote.teamManager:getActorIdsByKey(team or remote.teamManager.ARENA_ATTACK_TEAM, remote.teamManager.TEAM_INDEX_MAIN)) do
        local heroInfo = remote.herosUtil:getHeroByID(v)
        table.insert(attackHeroInfo, heroInfo)
    end

    return attackHeroInfo
end

function QBattleScene:_constructGloryAttackHero()
    local attackHeroInfo = {}
    for k, v in ipairs(remote.teamManager:getActorIdsByKey(remote.teamManager.GLORY_TEAM, remote.teamManager.TEAM_INDEX_MAIN)) do
        local heroInfo = remote.herosUtil:getHeroByID(v)
        table.insert(attackHeroInfo, heroInfo)
    end

    return attackHeroInfo
end

function QBattleScene:resultHandler(data, isEnd)
    if self._requestFail == true then return end --如果后台数据发送失败则不做操作
    if data ~= nil then
        self.battleResult = data
        if self.isEnd == true then
            app:hideLoading()
        end
    end
    if isEnd ~= nil then
        self.isEnd = isEnd
        if self.battleResult == nil and app:getClient():isServerAuthorized() then
            app:showLoading()
        end
    end
end

function QBattleScene:getDisableAIKey()
    local key
    local str = "_auto_move"
    if app.battle:isPVPMode() then
        if app.battle:isInSunwell() then
            key = "sun_well"..str
        elseif app.battle:isInGlory() then
            key = "glory"..str
        elseif app.battle:isInTotemChallenge() then
            key = "totem_challenge" .. str
        end
    else
        if app.battle:isInMetalCity() then
            key = "metal_city"..str
        elseif app.battle:isInSocietyDungeon() then
            key = "society_dungeon"..str
        elseif app.battle:isInThunder() then
            key = "thunder"..str
        elseif app.battle:isInRebelFight() then
            key = "rebel_fight"..str
        elseif app.battle:isInWorldBoss() then
            key = "word_boss"..str
        elseif app.battle:isActiveDungeon() then
            key = "active_dungeon"..str
        else
            key = QUserData.USER_AUTO_MOVE_DUNGEON
        end
    end
    return key
end

function QBattleScene:_onBattleStart(event)
    if not app.battle:isPVPMode() then
        self:_prepareHeroes()
    end

    if not app.battle:isInReplay() then
        local key = self:getDisableAIKey()
        if key then
            local auto_move = app:getUserData():getUserValueForKey(key)
            if auto_move ~= QUserData.STRING_FALSE then
                app.battle:setDisableAI(false)
            else
                app.battle:setDisableAI(true)
            end
        end
    end

    self._tip_cache:startCache()
    self._battle_started = true
    
    self:_onWaveStarted({wave = 1})
    self:showGodArmStartAnimation(true, 1)
    self:showGodArmStartAnimation(false, 1)
end

function QBattleScene:_onBattleCutsceneStart(event)
    self._topBar:setVisible(false)
    self._autoSkillBar:setVisible(false)
    if event.cutscene == global.cutscenes.KRESH_ENTRANCE then
        self._cutscene = QKreshEntrance.new(event.cutscene)
        self._overSkeletonLayer:addChild(self._cutscene:getView())
        self._cutscene:startAnimation()
    else
        assert(false, "invalid cutscene name:" .. event.cutscene)
    end
end

function QBattleScene:_onWaveStarted(event)
    -- self._labelWave:setString(string.format("%d/%d", event.wave, app.battle:getWaveCount()))
    if app.battle:isPVPMode() == true or app.battle:isInTutorial() == true or self:isInDragon() then
        return
    end

    if app.battle:isActiveDungeon() == true and app.battle:getActiveDungeonType() == DUNGEON_TYPE.ACTIVITY_TIME then
        return
    end

    self._waveBackground:setVisible(true)
    self._labelWave:setVisible(true)

    if app.battle:isPVEMultipleWave() then
        self:SetPVEMultipleWaveString(app.battle:getPVEMultipleCurWave())
    end

    -- change wave title
    local spriteFrame = nil
    local spriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()

    if app.battle:getWaveCount() == 1 then
        self._labelWave:setString("1/1")
    elseif app.battle:getWaveCount() == 2 then
        if event.wave == 1 then
            self._labelWave:setString("1/2")
        else
            self:onWavePlayBgm(2)
            self._labelWave:setString("2/2")
        end
    elseif app.battle:getWaveCount() == 3 then
        if event.wave == 1 then
            self._labelWave:setString("1/3")
        elseif event.wave == 2 then
            self:onWavePlayBgm(2)
            self._labelWave:setString("2/3")
        else
            self:onWavePlayBgm(3)
            self._labelWave:setString("3/3")
        end
    end
end

function QBattleScene:onWaveShowDungeonName()
    local dungeonType = remote.welfareInstance:getDungeonTypeByDungeonID(self._dungeonConfig.id)
    if self._topBar_ccbOwner.node_dungeon_name and dungeonType == DUNGEON_TYPE.NORMAL or dungeonType == DUNGEON_TYPE.ELITE or dungeonType == DUNGEON_TYPE.WELFARE then
         
        local dungeonInfo = QStaticDatabase.sharedDatabase():getDungeonConfigByID(self._dungeonConfig.id)
        local name = dungeonInfo["scene_name1"] or ""
        self._topBar_ccbOwner.node_dungeon_name:setVisible(true)
        self._topBar_ccbOwner.tf_dungeon_name:setOpacity(255)
        self._topBar_ccbOwner.sp_bg_1:setOpacity(255)
        self._topBar_ccbOwner.sp_bg_2:setOpacity(255)


        self._topBar_ccbOwner.tf_dungeon_name:setString(name or "")

        local ccArray = CCArray:create()
        ccArray:addObject(CCDelayTime:create(1))
        -- ccArray:addObject(CCFadeOut:create(1))
        -- self._topBar_ccbOwner.tf_dungeon_name:runAction(CCSequence:create(ccArray))

        ccArray:addObject(CCCallFunc:create(function() makeNodeFadeToByTimeAndOpacity(self._topBar_ccbOwner.node_dungeon_name, 1, 0) end))
        self._topBar_ccbOwner.node_dungeon_name:runAction(CCSequence:create(ccArray))

    end
end

function QBattleScene:onWavePlayBgm(index)
    if self._display_play_bgm then return end
    local bgms = string.split(self._dungeonConfig.bgm, ";")
    if bgms[index]  and bgms[index] ~= "" then
        app.sound:playMusic(bgms[index])
    end
end

function QBattleScene:_onWaveEnded(event)
    if app.battle:isPVPMode() == true or app.battle:isInTutorial() == true then
        return
    end

    -- cancel all skill and disable touch and drag hero 
    self._lastWaveSelectActorView = self._touchController:getSelectActorView()
    self._touchController:setSelectActorView(nil)
    self._touchController:disableTouchEvent()
    self._dragController:disableDragLine(true)
    self._wave_end_click = false
    for _, view in ipairs(self._heroViews) do
        view:setEnableTouchEvent(false)
    end

    for _, hero in ipairs(app.battle:getHeroes()) do
        hero:stopMoving()
    end

    for _, ghost in ipairs(app.battle._heroGhosts) do
        if not ghost.actor:isDead() and ghost.clean_new_wave then
            ghost.actor:suicide(ghost.is_no_deadAnimation)
            app.grid:removeActor(ghost.actor)
            app.battle:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = ghost.actor, is_hero = true, dead_delay = 0.8})
            app.battle:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = ghost.actor, is_hero = true})
        end
    end
    for _, ghost in ipairs(app.battle._enemyGhosts) do
        if not ghost.actor:isDead() and ghost.clean_new_wave then
            ghost.actor:suicide(ghost.is_no_deadAnimation)
            app.grid:removeActor(ghost.actor)
            app.battle:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = ghost.actor, dead_delay = 0.8})
            app.battle:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = ghost.actor})
        end
    end

    self._arrow:setVisible(true)

    if app.battle:isAutoNextWave() then
        self._arrow:setVisible(false)
        self:_onNextWaveClicked()
    else
        scheduler.scheduleGlobal(function()
            if self._wave_end_click  == false then
                self:_onNextWaveClicked()
            end
        end, 3)
    end
    self:removeAllDummyAsPositionViews()
end

function QBattleScene:_onNext()

end

function QBattleScene:_onUseManualSkill(event)
    if event.actor == nil or event.skill == nil then
        return
    end

    local actorView = self:getActorViewFromModel(event.actor)
    if actorView then
        actorView:hideHpView()  --大招期间隐藏血条
    end
    if event.skill:isSelectActor() == true and not event.auto then
        if self._touchController ~= nil then
            if actorView ~= nil then
                self._touchController:setSelectActorView(actorView)   
            end
        end
    end
    if string.find(INFO_SYSTEM_MODEL, "iPhone4") ~= nil or string.find(INFO_SYSTEM_MODEL, "iPod") ~= nil or string.find(INFO_SYSTEM_MODEL, "iPad2") ~= nil then
        app:setIsClearSkeletonData(true)
        app:cleanTextureCache()
        app:setIsClearSkeletonData(false)
    end

    -- if event.actor and event.actor == app.battle:getSupportSkillHero() then
    --     if app.battle:getSupportSkillHero2() then
    --         local view = self._supporterHeroStatusView2
    --         view:runAction(CCScaleTo:create(0.25, 1.0))
    --         view:runAction(CCMoveTo:create(0.25, ccp(self._ccbOwner.node_fujingButton:getPosition())))
    --     end
    -- end 
    if event.actor and event.actor == app.battle:getSupportSkillHero()
                    or event.actor == app.battle:getSupportSkillHero2() 
                    or event.actor == app.battle:getSupportSkillHero3() then
        local supportIcons = {}
        if app.battle:getSupportSkillHero() and event.actor ~= app.battle:getSupportSkillHero() then --在使用技能的一瞬间图标的visible是true所以要有个判断
            local view = self._supporterHeroStatusView
            if view and view:isVisible() then
                table.insert(supportIcons,view)
            end
        end
        if app.battle:getSupportSkillHero2() and event.actor ~= app.battle:getSupportSkillHero2() then
            local view = self._supporterHeroStatusView2
            if view and view:isVisible() then
                table.insert(supportIcons,view)
            end
        end
        if app.battle:getSupportSkillHero3() and event.actor ~= app.battle:getSupportSkillHero3() then
            local view = self._supporterHeroStatusView3
            if view and view:isVisible() then
                table.insert(supportIcons,view)
            end
        end
        local total = #supportIcons
        local offset = self:getSupportViewOffsetHero()
        for i,view in ipairs(supportIcons) do
            local x, y = self._ccbOwner["node_fujingButton" .. (total - i + 1)]:getPosition()
            x = view:getPositionX()
            y = y + offset
            view:runAction(CCMoveTo:create(0.25, ccp(x, y)))
        end        
    end

    if event.actor and event.actor == app.battle:getSupportSkillEnemy()
                    or event.actor == app.battle:getSupportSkillEnemy2() 
                    or event.actor == app.battle:getSupportSkillEnemy3() then
        local supportIcons = {}
        if app.battle:getSupportSkillEnemy() and event.actor ~= app.battle:getSupportSkillEnemy() then --在使用技能的一瞬间图标的visible是true所以要有个判断
            local view = self._supporterEnemyStatusView1
            if view and view:isVisible() then
                table.insert(supportIcons,view)
            end
        end
        if app.battle:getSupportSkillEnemy2() and event.actor ~= app.battle:getSupportSkillEnemy2() then
            local view = self._supporterEnemyStatusView2
            if view and view:isVisible() then
                table.insert(supportIcons,view)
            end
        end
        if app.battle:getSupportSkillEnemy3() and event.actor ~= app.battle:getSupportSkillEnemy3() then
            local view = self._supporterEnemyStatusView3
            if view and view:isVisible() then
                table.insert(supportIcons,view)
            end
        end
        local total = #supportIcons
        local offset = self:getSupportViewOffsetEnemy()
        for i,view in ipairs(supportIcons) do
            local x, y = self._ccbOwner["node_fujingButton" .. (total - i + 1)]:getPosition()
            x = view:getPositionX()
            y = y + offset
            view:runAction(CCMoveTo:create(0.25, ccp(x, y)))
        end        
    end
end

function QBattleScene:onUseSuperSkill(actor, skill)
    local strokesIcon = skill:getStrokesIcon()
    local deputyIDs = actor:getDeputyActorIDs()
    local isHero = actor:getType() ~= ACTOR_TYPES.NPC

    if deputyIDs then
        self:playDeputyAnimation(actor, deputyIDs, isHero)
    end
    
    if self._superSkillShakeHandle ~= nil then
        scheduler.unscheduleGlobal(self._superSkillShakeHandle)
        self._superSkillShakeHandle = nil         
    end
    if self._superSkillEffects ~= nil then
        for _, effect in ipairs(self._superSkillEffects) do
            effect:removeFromParentAndCleanup(true)
            effect:release()
        end
        self._superSkillEffects = nil
    end

    -- 震动屏幕
    if strokesIcon then
        self:shakeScreen(10, 0.2, 1)
        
        self._superSkillEffects = {}
        local heroView = self:getActorViewFromModel(actor)
        local effect = CCBuilderReaderLoad("Battle_Aid_Appear4.ccbi",CCBProxy:create(),{})
        effect:setPosition(0, heroView:getSize().height / 2)
        heroView:addChild(effect)
        self._superSkillEffects[#self._superSkillEffects + 1] = effect
        effect:retain()
        
        if self._superSkillShakeHandle ~= nil then
            scheduler.unscheduleGlobal(self._superSkillShakeHandle)
            self._superSkillShakeHandle = nil         
        end
        self._superSkillShakeHandle = scheduler.performWithDelayGlobal(function()
            if self._superSkillEffects ~= nil then
                for _, effect in ipairs(self._superSkillEffects) do
                    effect:removeFromParentAndCleanup(true)
                    effect:release()
                end
                self._superSkillEffects = nil
            end
            self._superSkillShakeHandle = nil
        end, 1.5)
        self:_onPlayStrokesAnimation(actor, strokesIcon, callback)
    end
end

function QBattleScene:_onPlayStrokesAnimation(actor, icon, callback)
    -- if not app.battle:isPaused() then
    --     app.battle:pause()
    -- end

    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local pos = actor:getCenterPosition()
    local height = actor:getRect().size.height / 2
    local animationNode = CCBuilderReaderLoad("effects/dazhaozhanshi_1.ccbi", ccbProxy, ccbOwner)
    self:addChild(animationNode)

    local spriteFrame = QSpriteFrameByPath(icon)
    ccbOwner.icon:setDisplayFrame(spriteFrame)
    local spriteRect = spriteFrame:getRect()
    local area_off = 0.5 - 0.05

    local x,y = pos.x,pos.y + height
    if x < (0 + spriteRect.size.width * area_off ) then
        x = (0 + spriteRect.size.width * area_off)
    elseif x > (display.width - spriteRect.size.width * area_off) then
        x = (display.width - spriteRect.size.width * area_off)
    end

    if y > (display.height - spriteRect.size.height * area_off) then
        y = (display.height - spriteRect.size.height * area_off)
    end

    animationNode:setPosition(x,y)

    local animationManager = tolua.cast(animationNode:getUserObject(), "CCBAnimationManager")
    animationManager:connectScriptHandler(function(animationName)
        -- if app.battle:isPaused() then
        --     app.battle:resume()
        -- end
        if callback then
            callback()
        end
        animationManager:disconnectScriptHandler()
        animationNode:removeFromParent()
    end)
end

function QBattleScene:_onSetTimeGear(event)
    local time_gear = event.time_gear
    for _, view in ipairs(self._heroViews) do
        view:setAnimationScale(time_gear, "time_gear")
    end
    for _, view in ipairs(self._enemyViews) do
        view:setAnimationScale(time_gear, "time_gear")
    end
end

function QBattleScene:_onChangeDamageCoefficient(event)
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local animationNode = CCBuilderReaderLoad("Battle_Buff.ccbi", ccbProxy, ccbOwner)
    animationNode:setPosition(display.cx, display.cy)
    local text = string.format("战斗疲劳，受到伤害增加%d%%", event.damage_coefficient * 100 - 100)
    ccbOwner.label_bai:setString(text)
    ccbOwner.label_huang:setString(text)
    self:addChild(animationNode)

    local animationManager = tolua.cast(animationNode:getUserObject(), "CCBAnimationManager")
    animationManager:connectScriptHandler(function(animationName)
        animationManager:disconnectScriptHandler()
        animationNode:removeFromParent()
    end)

    app.sound:playSound("PVPFlagTaken")
end

function QBattleScene:_onBulletTimeTurnStart()
    local preScale = self._killActorAnimation3:getSkeletonView():getAnimationScale()
    local preScale = self._killActorAnimation2:getSkeletonView():getAnimationScale()

    QSkeletonViewController.sharedSkeletonViewController():setAllEffectsAnimationScale(0)
    
    self._killActorAnimation3:getSkeletonView():setAnimationScale(preScale)
    self._killActorAnimation2:getSkeletonView():setAnimationScale(preScale)
end

function QBattleScene:_onBulletTimeTurnFinish( ... )
    QSkeletonViewController.sharedSkeletonViewController():resetAllEffectsAnimationScale()
end

function QBattleScene:_onPvpWaveEnd(event)
    -- body
    if not event then
        return
    end

    local info = {}
    local rivalsInfo = self._dungeonConfig.rivalsInfo 
    local myInfo = self._dungeonConfig.myInfo
    if not rivalsInfo or not myInfo then
        return
    end 

    local isWin = event.isWin
    local force1 = 0
    local force2 = 0
   
    info.team1Name = myInfo.name
    info.team2Name = rivalsInfo.name

    local fightScore = app.battle:getPVPMultipleWaveScore() or 0
    local curWave = app.battle:getCurrentPVPWave() - 1
    local team1Heros = {}
    local team2Heros = {}
    local team3Heros = {}
    
    local teamType = self._dungeonConfig.teamName

    if curWave == 1 then
        for k, v in ipairs(remote.teamManager:getActorIdsByKey(teamType, remote.teamManager.TEAM_INDEX_MAIN)) do
            local heroInfo = remote.herosUtil:getHeroByID(v)
            force1 = force1 + remote.herosUtil:createHeroProp(heroInfo):getBattleForce()
            table.insert(team1Heros, heroInfo)
        end
        team2Heros = rivalsInfo.heros;

    elseif curWave == 2 then
        for k, v in ipairs(remote.teamManager:getActorIdsByKey(teamType, remote.teamManager.TEAM_INDEX_HELP)) do
            local heroInfo = remote.herosUtil:getHeroByID(v)
            force1 = force1 + remote.herosUtil:createHeroProp(heroInfo):getBattleForce()
            table.insert(team1Heros, heroInfo)
        end
        team2Heros = rivalsInfo.subheros;
    elseif curWave == 3 then
        for k, v in ipairs(remote.teamManager:getActorIdsByKey(teamType, remote.teamManager.TEAM_INDEX_HELP2)) do
            local heroInfo = remote.herosUtil:getHeroByID(v)
            force1 = force1 + remote.herosUtil:createHeroProp(heroInfo):getBattleForce()
            table.insert(team1Heros, heroInfo)
        end
        team2Heros = rivalsInfo.sub2heros;
    else
        for k, v in ipairs(remote.teamManager:getActorIdsByKey(teamType, remote.teamManager.TEAM_INDEX_HELP3)) do
            local heroInfo = remote.herosUtil:getHeroByID(v)
            force1 = force1 + remote.herosUtil:createHeroProp(heroInfo):getBattleForce()
            table.insert(team1Heros, heroInfo)
        end
        team2Heros = rivalsInfo.sub3heros; 
    end

    for k, v in pairs(team2Heros) do
        force2 = force2 + (v.force or 0)
    end

    -- 魂灵
    local heroSoulSpirits = app.battle:getSoulSpiritHero()
    info.team1SoulSpirit = {}
    for _, soulSpirit in ipairs(heroSoulSpirits) do
        force1 = force1 + soulSpirit:getBattleForce()
        table.insert(info.team1SoulSpirit, {soulSpiritId = soulSpirit:getSoulSpiritId(),
            soulSpiritInfo = {grade = soulSpirit:getGradeValue(), level = soulSpirit:getLevel()}})
    end
    local enemySoulSpirits = app.battle:getSoulSpiritEnemy()
    info.team2SoulSpirit = {}
    for _, soulSpirit in ipairs(enemySoulSpirits) do
        force2 = force2 + soulSpirit:getBattleForce()
        table.insert(info.team2SoulSpirit, {soulSpiritId = soulSpirit:getSoulSpiritId(),
            soulSpiritInfo = {grade = soulSpirit:getGradeValue(), level = soulSpirit:getLevel()}})
    end

    info.team1Force = force1
    info.team2Force = force2

    info.team1Heros = team1Heros
    info.team2Heros = team2Heros
    info.team3Heros = team3Heros
    self.curModalDialog = QBattleDialogWaveResult.new({info = info, isWin = isWin, fightScore = fightScore, curWave = curWave,  callBack = event.callback})
end

-- return true if selece hero is changed
function QBattleScene:uiSelectHero(hero)
    if hero == nil then
        return false
    end

    local view = self:getActorViewFromModel(hero)
    if view == nil then
        return false
    end

    if self._touchController ~= nil then
        if self._dragController ~= nil then
            self._dragController:disableDragLine(true)
        end
        if self._touchController:getSelectActorView() == view then
            return true
        end
        self._touchController:setSelectActorView(view)
        return true
    end

    return false
end

function QBattleScene:setBattleEnded(isEnded, result) -- result: true for win, false for lose, nil for unknown
    self._ended = isEnded
    if self._ended == true then
        -- disable drag
        if self._dragController ~= nil then
            self._dragController:disableDragLine(true)
        end
    end

    if result ~= nil and DEBUG_ENABLE_REPLAY_LOG then
        QLogFile:debug("battle start", "replay_log")
        for _, sentence in ipairs(app.battle.actorHitAndAttackLogs) do
            QLogFile:debug(sentence, "replay_log")
        end
        QLogFile:debug("battle end", "replay_log")
    end

    app.battle:ended(result)
end

function QBattleScene:cancelMoveSchedule()
    if self._onWinScheduler and self._onWinHandle then
        self._onWinScheduler:unscheduleScriptEntry(self._onWinHandle)
        self._onWinHandle = nil
        self._onWinScheduler = nil
    end

    if self._onWinHandle1 then
        scheduler.unscheduleGlobal(self._onWinHandle1)
        self._onWinHandle1 = nil
    end

    if self._onWinHandle2 then
        scheduler.unscheduleGlobal(self._onWinHandle2)
        self._onWinHandle2 = nil
    end

    if self._onLoseHandle1 then
        scheduler.unscheduleGlobal(self._onLoseHandle1)
        self._onLoseHandle1 = nil
    end

    if self._onLoseHandle2 then
        scheduler.unscheduleGlobal(self._onLoseHandle2)
        self._onLoseHandle2 = nil
    end

    if self._onLoseHandle3 then
        scheduler.unscheduleGlobal(self._onLoseHandle3)
        self._onLoseHandle3 = nil
    end 

    if self._pvpWaveEndhandl then 
        scheduler.unscheduleGlobal(self._pvpWaveEndhandl)
        self._pvpWaveEndhandl = nil
    end

    if self._pveWaveEndHandl then
        scheduler.unscheduleGlobal(self._pveWaveEndHandl)
        self._pveWaveEndHandl = nil
    end

    if self._enterHandl1 then
        scheduler.unscheduleGlobal(self._enterHandl1)
        self._enterHandl1 = nil
    end

    if self._enterHandl2 then
        scheduler.unscheduleGlobal(self._enterHandl2)
        self._enterHandl2 = nil
    end
end

function QBattleScene:getHeroViews()
    return self._heroViews
end

function QBattleScene:getEnemyViews()
    return self._enemyViews
end

function QBattleScene:getEffectViewsTotal()
    local views = {}
    table.mergeForArray(views, self._frontEffectView)
    table.mergeForArray(views, self._effectViews)
    table.mergeForArray(views, self._groundEffectView)
    return views
end

function QBattleScene:getActorViewFromModel(model)
    if model == nil then
        return
    end
    for i, view in ipairs(self._heroViews) do
        if view:getModel() == model then
            return view
        end
    end
    for i, view in ipairs(self._enemyViews) do
        if view:getModel() == model then
            return view
        end
    end
    return nil
end

function QBattleScene:getEffectViews()
    return self._effectViews
end

-- isInFront: display in front when black layer is visible
function QBattleScene:addEffectViews(effect, options)
    if effect == nil then
        return
    end

    options = options or {}
    if options.isFrontEffect == true then
        table.insert(self._frontEffectView, effect)
    elseif options.isGroundEffect == true then
        table.insert(self._groundEffectView, effect)
    else
        table.insert(self._effectViews, effect)
    end
    self:addSkeletonContainer(effect)
end

function QBattleScene:removeEffectViews(effect)
    if effect == nil then
        return
    end

    for i, view in ipairs(self._effectViews) do
        if effect == view then
            effect:removeFromParent()
            table.remove(self._effectViews, i)
            return
        end
    end

    for i, view in ipairs(self._frontEffectView) do
        if effect == view then
            effect:removeFromParent()
            table.remove(self._frontEffectView, i)
            return
        end
    end

    for i, view in ipairs(self._groundEffectView) do
        if effect == view then
            effect:removeFromParent()
            table.remove(self._groundEffectView, i)
            return
        end
    end
end

function QBattleScene:removeAllDummyAsPositionViews()
    local db = QStaticDatabase:sharedDatabase()
    local rm_views = {}
    for i, view in ipairs(self._groundEffectView) do
        if view and view._dummy_as_position then
            table.insert(rm_views,view)
        end
    end
    for i,view in pairs(rm_views) do
        table.removebyvalue(self._groundEffectView,view)
        view:removeFromParent()
    end

    local rm_views = {}
    for i, view in ipairs(self._effectViews) do
        if view and view._dummy_as_position then
            table.insert(rm_views,view)
        end
    end
    for i,view in pairs(rm_views) do
        table.removebyvalue(self._effectViews,view)
        view:removeFromParent()
    end

    local rm_views = {}
    for i, view in ipairs(self._frontEffectView) do
        if view and view._dummy_as_position then
            table.insert(rm_views,view)
        end
    end
    for i,view in pairs(rm_views) do
        table.removebyvalue(self._frontEffectView,view)
        view:removeFromParent()
    end
end

function QBattleScene:removeAllEffectViews()
    for i, view in ipairs(self._groundEffectView) do
        if view then
            view:removeFromParent()
        end
    end
    self._groundEffectView = {}
    for i, view in ipairs(self._effectViews) do
        if view then
            view:removeFromParent()
        end
    end
    self._effectViews = {}
    for i, view in ipairs(self._frontEffectView) do
        if view then
            view:removeFromParent()
        end
    end
    self._frontEffectView = {}
end

function QBattleScene:replaceActorViewWithCharacterId(actor, characterId)
    if actor == nil then
        return
    end

    local actorView = self:getActorViewFromModel(actor)

    local isSelectedView = self._touchController and self._touchController:getSelectActorView() == actorView

    if isSelectedView then
        self._touchController:setSelectActorView(nil)
    end

    local positionX, positionY = actor:getPosition().x, actor:getPosition().y

    actor:willReplaceActorView()

    actor:setReplaceCharacterId(characterId)

    local newActorView = nil
    if actorView then
        local direction = actor:getDirection()

        if actor:getType() == ACTOR_TYPES.HERO or actor:getType() == ACTOR_TYPES.HERO_NPC then
            newActorView = QHeroActorView.new(actor)
            if direction ~= QActor.DIRECTION_LEFT then
                newActorView:getSkeletonActor():flipActor()
            end
            local totalAbsorb = actorView:getHpView():getAbsorbPercent()
            if not (actor:isPet() or (actor:isGhost() and not actor:isAttackedGhost())) then
                newActorView:getHpView():updateAbsorb(totalAbsorb)
            end
            newActorView:setAnimationScale(app.battle:getTimeGear(), "time_gear")
            table.insert(self._heroViews, table.indexof(self._heroViews, actorView), newActorView)
            table.removebyvalue(self._heroViews, actorView)
        else
            newActorView = QNpcActorView.new(actor)
            if direction ~= QActor.DIRECTION_LEFT then
                newActorView:getSkeletonActor():flipActor()
            end
            newActorView:setAnimationScale(app.battle:getTimeGear(), "time_gear")
            table.insert(self._enemyViews, table.indexof(self._enemyViews, actorView), newActorView)
            table.removebyvalue(self._enemyViews, actorView)
        end

        actorView:removeFromParentAndCleanup()
        actorView = nil
        self:addSkeletonContainer(newActorView)
        self:addHpAndDamageContainer(newActorView:getHpAndDamageNode())
        if not (actor:isPet() or (actor:isGhost() and not actor:isAttackedGhost())) then
            newActorView:displayHpView()
        end
    end

    actor:didReplaceActorView()
    
    if newActorView then
        if isSelectedView then
            self._touchController:setSelectActorView(newActorView)
        end
        if actor:isCopyHero() then 
            newActorView:setCanTouchBegin(false) 
            local copy_hero_color, copy_hero_color2 = actor:getCopyHeroColor()
            if copy_hero_color then
                local skeletonView = newActorView:getSkeletonActor()
                if not skeletonView.isFca then
                    skeletonView:setColor(copy_hero_color)
                    skeletonView:getSkeletonAnimation():setShaderProgram(qShader.Q_ProgramPositionTextureColorHSI)
                    if copy_hero_color2 then
                        skeletonView:setColor2(copy_hero_color2)
                    end
                else
                    skeletonView:getRenderTextureSprite():setColor(copy_hero_color)
                    setNodeShaderProgram(skeletonView:getRenderTextureSprite(), qShader.Q_ProgramPositionTextureColorHSI)
                    skeletonView:stopSetColorOffset(true)
                    if copy_hero_color2 then
                        local c2 = copy_hero_color2
                        skeletonView:getRenderTextureSprite():setColorOffset(ccc4f(c2.r/255, c2.g/255, c2.b/255, c2.a/255))
                    end
                end
            end
        end
    end


    actor:setActorPosition(qccp(positionX, positionY))
    actor:clearLastAttackee()
    app.battle:reloadActorAi(actor)
    app.grid:setActorTo(actor, actor:getPosition(), nil, true)
end

-- color is a CCColor4F value
function QBattleScene:displayRect(bottomLeftPos, topRightPos, duration, color)
    if bottomLeftPos == nil or topRightPos == nil then
        return
    end

    duration = duration or 2.0
    color = color or display.COLOR_BLUE_C4F

    if bottomLeftPos.x < BATTLE_AREA.left then
        bottomLeftPos.x = BATTLE_AREA.left
    end
    if bottomLeftPos.y < BATTLE_AREA.bottom then
        bottomLeftPos.y = BATTLE_AREA.bottom
    end
    if topRightPos.x > BATTLE_AREA.right then
        topRightPos.x = BATTLE_AREA.right
    end
    if topRightPos.y > BATTLE_AREA.top then
        topRightPos.y = BATTLE_AREA.top
    end

    local vertices = {}
    table.insert(vertices, {bottomLeftPos.x, bottomLeftPos.y})
    table.insert(vertices, {bottomLeftPos.x, topRightPos.y})
    table.insert(vertices, {topRightPos.x, topRightPos.y})
    table.insert(vertices, {topRightPos.x, bottomLeftPos.y})
    local param = {
        fillColor = ccc4f(0.0, 0.0, 0.0, 0.0),
        borderWidth = 2,
        borderColor = color
    }
    local drawNode = CCDrawNode:create()
    drawNode:clear()
    drawNode:drawPolygon(vertices, param) -- red color
    self._overSkeletonLayer:addChild(drawNode)

    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(duration - 0.3))
    arr:addObject(CCFadeOut:create(0.3))
    arr:addObject(CCRemoveSelf:create(true))
    drawNode:runAction(CCSequence:create(arr))
end

-- position is counter-clockwise
-- color is a CCColor4F value
function QBattleScene:displayTriangle(position1, position2, position3, duration, color)
    if position1 == nil or position2 == nil or position3 == nil then
        return
    end

    duration = duration or 2.0
    color = color or display.COLOR_BLUE_C4F

    local vertices = {}
    table.insert(vertices, {position1.x, position1.y})
    table.insert(vertices, {position2.x, position2.y})
    table.insert(vertices, {position3.x, position3.y})

    local param = {
        fillColor = ccc4f(0.0, 0.0, 0.0, 0.0),
        borderWidth = 2,
        borderColor = color
    }
    local drawNode = CCDrawNode:create()
    drawNode:clear()
    drawNode:drawPolygon(vertices, param) -- red color
    self._overSkeletonLayer:addChild(drawNode)

    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(duration - 0.3))
    arr:addObject(CCFadeOut:create(0.3))
    arr:addObject(CCRemoveSelf:create(true))
    drawNode:runAction(CCSequence:create(arr))
end

function QBattleScene:displayCircleRange(position, radius, duration, color)
    if position == nil or radius == nil then
        return 
    end
    duration = duration or 2.0
    color = color or display.COLOR_BLUE_C4F
    local drawNode = CCDrawNode:create()
    drawNode:clear()
    local param = {
        fillColor = ccc4f(0.0, 0.0, 0.0, 0.0),
        borderWidth = 2,
        borderColor = color,
        pos = position
    }
    drawNode:drawCircle(radius, param)
    self._overSkeletonLayer:addChild(drawNode)
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(duration - 0.3))
    arr:addObject(CCFadeOut:create(0.3))
    arr:addObject(CCRemoveSelf:create(true))
    drawNode:runAction(CCSequence:create(arr))
end

function QBattleScene:displayWarningZone(effect_id, position, radius, duration, color, scaleX, scaleY, degree)
    if position == nil or radius == nil then
        return
    end

    duration = duration or 3.0
    -- color = color or cc.c4f(1.0, 1.0, 1.0, 0.2)
    scaleX = scaleX or 1.0
    scaleY = scaleY or 1.0

    if effect_id then
        local frontEffect, backEffect = QBaseEffectView.createEffectByID(effect_id)
        local effect = frontEffect or backEffect
        local effectNode = CCNode:create()
        effectNode:addChild(effect)
        effectNode:setPositionX(position.x)
        effectNode:setPositionY(position.y)
        self._backgroundLayer:addChild(effectNode)
        effect:playAnimation(effect:getPlayAnimationName(), true)
        effect:playSoundEffect(false)
        effectNode:setScaleX(scaleX)
        effectNode:setScaleY(scaleY)

        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(duration - 0.3))
        arr:addObject(CCFadeOut:create(0.3))
        arr:addObject(CCCallFunc:create(function()
            effect:stopAnimation()
        end))
        arr:addObject(CCRemoveSelf:create(true))
        effectNode:runAction(CCSequence:create(arr))

        return effectNode
    end
end

-- function for tutorial

function QBattleScene:_onTouchForTutorial(event)
    if self._touchRect == nil then
        return
    end

    if event.name == "began" then
        return true
    elseif event.name == "ended" then
        if self._touchRect:containsPoint(ccp(event.x, event.y)) == true then
                        
            if self._tutorialForUseSkill == true then -- 技能点击引导
                app.battle:performWithDelay(handler(self._tutorialStatusView, self._tutorialStatusView._onClickSkillButton1), 0.2)

                self._tutorialTouchNode:setTouchEnabled(false)
                self._tutorialTouchNode:removeFromParent()
                self._tutorialTouchNode = nil
                self._touchRect = nil
                self._tutorialStatusView:dehighlightSkillIcon()
                self._tutorialStatusView = nil
                self._tutorialForUseSkill = nil

                app.battle:resume()

                if self._tutorialForUseSkillFinishCallback then
                    self._tutorialForUseSkillFinishCallback()
                    self._tutorialForUseSkillFinishCallback = nil
                end

                if self._tutorialForUseSkillIndex then
                    app:triggerBuriedPoint(QBuriedPoint:getDungeonTutorialBuriedPointID(self._dungeonConfig.id, self._tutorialForUseSkillIndex))
                    self._tutorialForUseSkillIndex = nil
                end 

            elseif self._tutorialForTouchActor == true then -- 角色点击引导
                local enemyView = self:getActorViewFromModel(self._tutorialEnemy)
                local heroes = app.battle:getHeroes()
                for _, hero in ipairs(heroes) do
                    if hero:isHealth() == false and enemyView then
                        local heroView = self:getActorViewFromModel(hero)
                        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTouchController.EVENT_TOUCH_END_FOR_ATTACK, heroView = heroView, targetView = enemyView, is_focus = true})
                    end
                end
                for _, enemy in ipairs(app.battle:getEnemies()) do
                    enemy:onUnMarked()
                end
                self._tutorialEnemy:onMarked()

                self:visibleBackgroundLayer(false, self._tutorialEnemy, 0.1, true)

                self._tutorialTouchNode:setTouchEnabled(false)
                self._tutorialTouchNode:removeFromParent()
                self._tutorialTouchNode = nil
                self._touchRect = nil
                self._tutorialEnemy = nil
                self._tutorialForTouchActor = nil
                
                app.battle:resume()

                if self._tutorialEnemyIndex then
                    app:triggerBuriedPoint(QBuriedPoint:getDungeonTutorialBuriedPointID(self._dungeonConfig.id, self._tutorialEnemyIndex))
                    self._tutorialEnemyIndex = nil
                end 

            else -- 角色对话
                if self.word ~= "" and self._tutorialDialogue ~= nil and self._tutorialDialogue._isSaying == true and self._tutorialDialogue:isVisible() then 
                  self._tutorialDialogue:printAllWord()
                  printInfo("is say")
                elseif #self._tutorialSentences > 0 then
                    local sentences = self._tutorialSentences
                    local imageFiles = self._tutorialImageFiles
                    local names = self._tutorialNames
                    local titleNames = self._tutorialTitleNames
                    local leftSides = self._tutorialLeftSides
                    local touchNode = self._tutorialTouchNode
                    local dialogIndice = self._tutorialDialogIndice

                    if dialogIndice then
                        app:triggerBuriedPoint(QBuriedPoint:getDungeonDialogBuriedPointID(self._dungeonConfig.id, dialogIndice[#dialogIndice]))
                        dialogIndice[#dialogIndice] = nil
                    end

                    local options = {isLeftSide = leftSides[#leftSides], isSay = true, name = names[#names], titleName = titleNames[#titleNames], sayFun = handler(self, QBattleScene.onDungeonDialogFinished)}

                    if nil ~= self._tutorialDialogue and self._tutorialDialogue:checkIsSameByOptions(options) then
                        options.text = sentences[#sentences]
                        self._tutorialDialogue:setOptions(options)
                        self._tutorialDialogue:sayByDefault()
                    else
                        options.text = sentences[#sentences]
                        local dialogue = self._tutorialDialogue
                        dialogue:removeFromParent()
                        local dialogue = QUIWidgetBattleTutorialDialogue.new(options)
                        dialogue:setActorImage(imageFiles[#imageFiles])
                        dialogue:setName(names[#names])
                        dialogue:setTitleName(titleNames[#titleNames])
                        touchNode:addChild(dialogue)
                        self._tutorialDialogue = dialogue
                    end
                    self.word = sentences[#sentences]
                    
                    sentences[#sentences] = nil
                    imageFiles[#imageFiles] = nil
                    names[#names] = nil
                    titleNames[#titleNames] = nil
                    leftSides[#leftSides] = nil

                    local checkLength = #self._tutorialSentences
                    app.battle:performWithDelay(function()
                        if self._tutorialSentences and checkLength == #self._tutorialSentences then
                            self:_onTouchForTutorial({name = "ended", x = 100, y = 100})
                        end
                    end, 2.0)
                else
                    local actor = self._tutorialActor

                    if actor and not app.battle:isInEditor() then 
                        app.tip:floatTip(string.format("%s加入战斗", actor:getDisplayName())) 
                    end

                    local dialogIndice = self._tutorialDialogIndice
                    if dialogIndice then
                        app:triggerBuriedPoint(QBuriedPoint:getDungeonDialogBuriedPointID(self._dungeonConfig.id, dialogIndice[#dialogIndice]))
                        dialogIndice[#dialogIndice] = nil
                    end

                    self._tutorialTouchNode:setTouchEnabled(false)
                    self._tutorialTouchNode:removeFromParent()
                    self._tutorialTouchNode = nil
                    self._touchRect = nil
                    self._tutorialDialogue = nil
                    self._tutorialSentences = nil
                    self._tutorialImageFiles = nil
                    self._tutorialNames = nil
                    self._tutorialTitleNames = nil
                    self._tutorialActor = nil
                    self._tutorialLeftSides = nil
                    self._tutorialDialogIndice = nil
                
                    app.battle:resume()
                    app.scene:showHeroStatusViews()

                    if self._tutorialFinishCallback ~= nil then
                        local cb = self._tutorialFinishCallback
                        self._tutorialFinishCallback = nil
                        cb(event.is_skip)
                    end
                end
            end
        else
            if self._handTouch and self._handTouch.showFocus then
                self._handTouch:showFocus( ccp(self._handTouch:getPosition()) )
            end
        end
    end
end

function QBattleScene:onDungeonDialogFinished()
    if self._tutorialDialogue then
        local time = db:getConfigurationValue("duihuakuang_auto") or 6
        local word = self.word
        scheduler.performWithDelayGlobal(function()
            if self._tutorialDialogue and self._tutorialDialogue._word == word then
                self:_onTouchForTutorial({name = "ended", x = 100, y = 100})
            end
        end, time)
    end
end

function QBattleScene:useSkill(actor, skill, word)
    if actor == nil or skill == nil then
        return
    end

    local statusView = nil
    for _, heroStatusView in ipairs(self._heroStatusViews) do
        local hero = heroStatusView:getActor()
        if hero == actor then
            statusView = heroStatusView
            break
        end
    end

    if statusView == nil then
        return
    end

    local skillNode = statusView._ccbOwner.node_skill1
    local positionX = statusView:getPositionX() + skillNode:getPositionX()
    local positionY = statusView:getPositionY() + skillNode:getPositionY()
    local wordInfo = string.split(word, "^")
    self._handTouch = QUIWidgetTutorialHandTouch.new({x = wordInfo[1], y = wordInfo[2], model = wordInfo[3], word = wordInfo[4], parentNode = app.scene, attack = true})
    self._handTouch:setPosition(positionX - 3, positionY + 14)
    self:addChild(self._handTouch)

    return self._handTouch
end

function QBattleScene:pauseBattleAndUseSkill(actor, skill, word, finishCallback, tutorialIndex)
    if actor == nil or skill == nil then
        return
    end

    local statusView = nil
    for _, heroStatusView in ipairs(self._heroStatusViews) do
        local hero = heroStatusView:getActor()
        if hero == actor then
            statusView = heroStatusView
            break
        end
    end

    if statusView == nil then
        return
    end

    self._tutorialStatusView = statusView

    local touchNode = CCNode:create()

    touchNode:addChild(CCLayerColor:create(ccc4(0, 0, 0, 0), display.width, display.height)) 
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    self:addChild(touchNode)
    touchNode:setTouchEnabled(true)
    touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QBattleScene._onTouchForTutorial))
    self._tutorialTouchNode = touchNode

    local skillNode = statusView._ccbOwner.node_skill1
    local positionX = statusView:getPositionX() + skillNode:getPositionX()
    local positionY = statusView:getPositionY() + skillNode:getPositionY()
    local wordInfo = string.split(word, "^")
    self._handTouch = QUIWidgetTutorialHandTouch.new({x = wordInfo[1], y = wordInfo[2], model = wordInfo[3], word = wordInfo[4], parentNode = app.scene, attack = true})
    self._handTouch:setPosition(positionX - 3, positionY + 14)

    statusView:hightlightSkillIconOn(touchNode)

--    self._handTouch:handRightUp()
--    self._handTouch:tipsLeftUp()
    touchNode:addChild(self._handTouch)

    self._touchRect = CCRectMake(positionX - 50, positionY - 50, 100, 100)
    self._tutorialForUseSkill = true
    self._tutorialForUseSkillFinishCallback = finishCallback
    self._tutorialForUseSkillIndex = tutorialIndex
    
    app.battle:pause()
end

function QBattleScene:attackEnemy(enemy, word, word2, down)
    if enemy == nil then
        return
    end

    local rect = enemy:getRect()
    local position = enemy:getCenterPosition_Stage()
    local wordInfo = string.split(word, "^")
    self._handTouch = QUIWidgetTutorialHandTouch.new({x = wordInfo[1], y = wordInfo[2], model = wordInfo[3], word = wordInfo[4], parentNode = app.scene, attack = true})
    -- handTouch:setPosition(0, rect.size.height / 2)
    -- local view = self:getActorViewFromModel(enemy)
    -- view:addChild(handTouch)
    self._handTouch:setPosition(position.x, position.y)
    self:addChild(self._handTouch)

    return self._handTouch
end

function QBattleScene:pauseBattleAndAttackEnemy(enemy, word, word2, down, tutorialIndex)
    if enemy == nil then
        return
    end

    self._tutorialEnemy = enemy
    self._tutorialEnemyIndex = tutorialIndex

    local touchNode = CCNode:create()
    touchNode:addChild(CCLayerColor:create(ccc4(0, 0, 0, 0), display.width, display.height)) 
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    self:addChild(touchNode)
    touchNode:setTouchEnabled(true)
    touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QBattleScene._onTouchForTutorial))
    self._tutorialTouchNode = touchNode

    local position = enemy:getCenterPosition_Stage()
    local wordInfo = string.split(word, "^")
    self._handTouch = QUIWidgetTutorialHandTouch.new({x = wordInfo[1], y = wordInfo[2], model = wordInfo[3], word = wordInfo[4], parentNode = app.scene, attack = true})
    self._handTouch:setPosition(position.x, position.y)
    touchNode:addChild(self._handTouch)

    local rect = enemy:getRect()
    self._touchRect = CCRectMake(position.x - rect.size.width * 0.5, position.y - rect.size.height * 0.5, rect.size.width, rect.size.height)
    self._tutorialForTouchActor = true

    self:visibleBackgroundLayer(true, enemy, 0.1, true)

    app.battle:pause()
end

function QBattleScene:pauseBattleAndDisplayDislog(sentences, imageFiles, names, titleNames, actor, finishCallback, leftSides, dialogIndice)
    if sentences == nil or imageFiles == nil or names == nil or #sentences == 0 or #imageFiles == 0 or #names == 0 then
        return
    end

    if leftSides == nil then
        leftSides = {}
        for i = 1, #sentences do
            table.insert(leftSides, true)
        end
    end

    assert(#sentences == #imageFiles and #imageFiles == #names and #names == #leftSides, "")

    self._tutorialSentences = sentences
    self._tutorialImageFiles = imageFiles
    self._tutorialNames = names
    self._tutorialTitleNames = titleNames
    self._tutorialActor = actor
    self._tutorialFinishCallback = finishCallback
    self._tutorialLeftSides = leftSides
    self._tutorialDialogIndice = dialogIndice

    local touchNode = CCNode:create()
    touchNode:addChild(CCLayerColor:create(ccc4(0, 0, 0, 128), display.width, display.height)) 
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    self:addChild(touchNode)
    touchNode:setTouchEnabled(true)
    touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QBattleScene._onTouchForTutorial))

    self._tutorialTouchNode = touchNode
    local dialogue = QUIWidgetBattleTutorialDialogue.new({isLeftSide = leftSides[#leftSides], isSay = true, text = sentences[#sentences], name = names[#names], titleName = titleNames[#titleNames], sayFun = handler(self, QBattleScene.onDungeonDialogFinished)})
    dialogue:setActorImage(imageFiles[#imageFiles])
    dialogue:setName(names[#names])
    dialogue:setTitleName(titleNames[#titleNames])
    touchNode:addChild(dialogue)

    local skip_button = CCSprite:create("ui/common/overtip.png")
    skip_button:setPosition(ccp(display.ui_width - 100, display.ui_height - 50))
    skip_button:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    skip_button:setTouchSwallowEnabled(true)
    skip_button:setTouchEnabled(true)
    skip_button:addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
        self.word = ""
        self._tutorialSentences = {}
        self._tutorialNames = {}
        self._tutorialImageFiles = {}
        self._tutorialTitleNames = {}
        self:_onTouchForTutorial({name = "ended", x = 100, y = 100, is_skip = true})
        return false 
    end)
    touchNode:addChild(skip_button, 1)

    self._tutorialDialogue = dialogue
    self.word = sentences[#sentences]

    sentences[#sentences] = nil
    imageFiles[#imageFiles] = nil
    names[#names] = nil
    titleNames[#titleNames] = nil
    leftSides[#leftSides] = nil

    self._touchRect = CCRectMake(0, 0, display.width, display.height)

    local checkLength = #self._tutorialSentences
    app.battle:performWithDelay(function()
        if self._tutorialSentences and checkLength == #self._tutorialSentences then
            self:_onTouchForTutorial({name = "ended", x = 100, y = 100})
        end
    end, 2.0)

    app.battle:pause()
    app.scene:hideHeroStatusViews()
end

function QBattleScene:_pauseBattleAndShowImageDialog(dialog)
    self.curModalDialog = QBattleDialogImageDialog.new({cfg = dialog})
end

function QBattleScene:_onSkipBattle(isWin)
    if isWin == true then
        self:_onWin()
    else
        self:_onLose()
    end
end

function QBattleScene:isInBlackLayer()
    return self._showBlackLayerReferenceCount > 0
end

function QBattleScene:isPVPMode()
    if self._dungeonConfig.isSilverMine then
        return self._dungeonConfig.mineOwnerId ~= nil
    else
        return self._dungeonConfig.isPVPMode or false
    end
end

function QBattleScene:getDungeonConfig()
    return self._dungeonConfig
end

function QBattleScene:getIsTimeOver()
    return self._isTimeOver
end

function QBattleScene:isInArena()
    return self._dungeonConfig.isArena or false
end

function QBattleScene:isInMetalAbyss()
    return self._dungeonConfig.isMetalAbyss
end

function QBattleScene:isInSilvesArena()
    return self._dungeonConfig.isSilvesArena or false
end

function QBattleScene:isInFightClub()
    return self._dungeonConfig.isFightClub or false
end

function QBattleScene:isInStormArena()
    return self._dungeonConfig.isStormArena or false
end
function QBattleScene:isInSunwell()
    return self._dungeonConfig.isSunwell or false
end

function QBattleScene:isInThunder()
    return self._dungeonConfig.isThunder or false
end

function QBattleScene:isInSparField()
    return self._dungeonConfig.isSparField or false
end

function QBattleScene:isInBlackRock()
    return self._dungeonConfig.isBlackRock or false
end

function QBattleScene:isInGlory()
    return self._dungeonConfig.isGlory or false
end

function QBattleScene:isInGloryArena()
    return self._dungeonConfig.isGloryArena or false
end

function QBattleScene:isInRebelFight()
    return self._dungeonConfig.isInRebelFight or false
end

function QBattleScene:isInSocietyDungeon()
    return self._dungeonConfig.isSocietyDungeon or false
end

function QBattleScene:isInFriend( ... )
    return self._dungeonConfig.isFriend or false
end

function QBattleScene:isInSilverMine()
    return self._dungeonConfig.isSilverMine or false
end

function QBattleScene:isInNightmare()
    return self._dungeonConfig.isNightmare or false
end

function QBattleScene:isInWorldBoss()
    return self._dungeonConfig.isInWorldBossFight or false
end

function QBattleScene:isInMaritime()
    return self._dungeonConfig.isMaritime or false
end
  
function QBattleScene:isInUnionDragonWar()
    return self._dungeonConfig.isUnionDragonWar or false
end

function QBattleScene:isInMetalCity()
    return self._dungeonConfig.isMetalCity or false
end

function QBattleScene:isInDragon()
    return self._dungeonConfig.isInDragon or false
end

function QBattleScene:isMazeExplore()
    return self._dungeonConfig.isMazeExplore or false
end

function QBattleScene:isLocalFight()
    return self._dungeonConfig.isLocalFight or false
end

function QBattleScene:getActiveDungeonInstanceId()
    return self._activeDungeonInfo.instance_id
end

function QBattleScene:getTip(ccb_name)
    return self._tip_cache.getTip(ccb_name)
end

function QBattleScene:returnTip(tip)
    self._tip_cache.returnTip(tip)
end

function QBattleScene:toScreenPos(pos)
    local w = BATTLE_AREA.width / global.screen_big_grid_width
    local h = BATTLE_AREA.height / global.screen_big_grid_height
    return {x = BATTLE_AREA.left + w * pos.x - w / 2, y = BATTLE_AREA.bottom + h * pos.y - h / 2}
end

-- WOW-3040 @qinyuanji
function QBattleScene:showTipsAnimation(value, node)
    local effectName = nil
    if value > 0 then
        effectName = "effects/Tips_add.ccbi"
    elseif value < 0 then 
        effectName = "effects/Tips_Decrease.ccbi"
    end

    if effectName then
        local content = (value > 0) and ("+" .. value) or value
        local effect = QUIWidgetAnimationPlayer.new()
        node:addChild(effect)
        effect:setPosition(ccp(0, -70))
        local tip = self:getTip(effectName)
        effect:playAnimation2(tip, tip.ccbOwner, function(ccbOwner)
            ccbOwner.content:setString(content)
        end, function()
            effect:removeFromParentAndCleanup(true)
            if tip.need_return then
                self:returnTip(tip)
            else
                tip:release()
            end
        end)
    end
end

function QBattleScene:nodeEffect(node)
    if node ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        node:runAction(ccsequence)
    end
end

function QBattleScene:_createBGFile(fileName)
    if fileName == nil or fileName == "" then
        return nil
    end

    if string.sub(fileName, string.len(fileName) - 4) == ".ccbi" then
        local bg_ccbProxy = CCBProxy:create()
        local bg_ccbOwner = {}
        return CCBuilderReaderLoad(fileName, bg_ccbProxy, bg_ccbOwner)
    else
        return CCSprite:create(fileName)
    end
end

function QBattleScene:replaceBGFile(fileName, node, isInit)
    if fileName == nil or fileName == "" then
        return
    end

    if node == nil then
        node = self:_createBGFile(fileName)
        if node == nil then
            return
        end
        node:retain()
    end

    -- self._backgroundImage
    -- self._backgroundCCB
    if string.sub(fileName, string.len(fileName) - 4) == ".ccbi" then
        local old_bg
        if self._backgroundCCB then
            old_bg = self._backgroundCCB
            self._backgroundCCB = nil
        end
        if self._backgroundImage then
            old_bg = self._backgroundImage
            self._backgroundImage = nil
        end
        self._backgroundCCB = node
        if isInit == true then
            CalculateUIBgSize(self._ccbOwner.node_background, 1280)
            CalculateBattleUIPosition(self._ccbOwner.node_background)
        end
        self._ccbOwner.node_background:addChild(self._backgroundCCB)
        node:release()

        -- 不知道为何，不跳过一帧移除old_bg的话，会有一帧渲染的很奇怪的东西出现
        if app.battle then
            app.battle:performWithDelay(function()
                if old_bg then
                    old_bg:removeFromParentAndCleanup()
                    old_bg = nil
                end
            end, 0, nil, nil, true)
        end

    else
        if self._backgroundCCB then
            self._backgroundCCB:removeFromParent()
            self._backgroundCCB = nil
        end
        if self._backgroundImage then
            self._backgroundImage:removeFromParentAndCleanup()
        end
        self._backgroundImage = node
        self._ccbOwner.node_background:setScale(1.25)

        if isInit == true then
            CalculateUIBgSize(self._ccbOwner.node_background, 1024)
            CalculateBattleUIPosition(self._ccbOwner.node_background)
        end
        self._ccbOwner.node_background:addChild(self._backgroundImage)
        node:release()
    end
end

function QBattleScene:replaceBGFileBOSSDungeon()
    -- BOSS变身背景
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local bossDungeonBG = CCBuilderReaderLoad("map/zdmap_deamine2_battle.ccbi", ccbProxy, ccbOwner)
    self._ccbOwner.node_background:addChild(bossDungeonBG)

    if bossDungeonBG == nil then
        return
    end

    local oldBg = self._backgroundImage or self._backgroundCCB
    if not oldBg then
        return
    end

    oldBg:setCascadeOpacityEnabled(true)
    bossDungeonBG:setVisible(true)
    bossDungeonBG:setCascadeOpacityEnabled(true)
    ccbOwner.dungeon_bg:setOpacity(0)

    local arr1 = CCArray:create()
    arr1:addObject(CCFadeTo:create(1.0, 255))
    ccbOwner.dungeon_bg:runAction(CCSequence:create(arr1))

    local arr2 = CCArray:create()
    arr2:addObject(CCFadeTo:create(1.0, 0))
    arr2:addObject(CCCallFunc:create(function()
        oldBg:removeFromParentAndCleanup(true)
        oldBg = self._bossDungeonBG
        self._bossDungeonBG = nil
    end))
    oldBg:runAction(CCSequence:create(arr2))
end

function QBattleScene:flipBG()
    if self._backgroundImage then
        self._backgroundImage:setScaleX(-1 * self._backgroundImage:getScaleX())
    elseif self._backgroundCCB then
        self._backgroundCCB:setScaleX(-1 * self._backgroundCCB:getScaleX())
    end
end

function QBattleScene:playRebelBuffs()
    -- 叛军攻击提升提示
    if app.battle:isInRebelFight() or app.battle:isInWorldBoss() then
        local function shuaBuff(view, attackPercent)
            if attackPercent then
                local ccbProxy = CCBProxy:create()
                local ccbOwner = {}
                local node = CCBuilderReaderLoad("effects/Buff_up_2.ccbi", ccbProxy, ccbOwner)
                view:addChild(node)
                node:setPositionY(view:getModel():getRect().size.height)
                ccbOwner.var_text_attack:setString(string.format("攻击力x%s倍", attackPercent + 1))
                node:retain()
                local animationManager = tolua.cast(node:getUserObject(), "CCBAnimationManager")
                animationManager:connectScriptHandler(function(animationName)
                    node:removeFromParentAndCleanup()
                    node:release()
                    node = nil
                end)
            end
        end
        local view = nil
        for _, actor in ipairs(app.battle:getHeroes()) do
            view = self:getActorViewFromModel(actor)
            shuaBuff(view, actor:getPropertyValue("attack_percent", "rebel_fight"))
        end
    end
end

function QBattleScene:playSupportBuffs()
    -- 刷buff
    local support_hero_count = #app.battle:getSupportHeroes() + #app.battle:getSupportHeroes2() + #app.battle:getSupportHeroes3()
    local support_enemy_count = #app.battle:getSupportEnemies() + #app.battle:getSupportEnemies2() + #app.battle:getSupportEnemies3()
    local heroBuffEffects = self._dungeonConfig.supportHeroBuffEffects
    local enemyBuffEffects = self._dungeonConfig.supportEnemyBuffEffects
    local function shuabuff(actor, actorBuffEffects)
        if actorBuffEffects then
            local view = self:getActorViewFromModel(actor)
            if view then
                local effects = actorBuffEffects[actor:getActorID()]
                if effects then
                    local effect1, effect2 = effects[1], effects[2]
                    view:attachEffectToDummy("dummy_bottom", effect1)
                    view:attachEffectToDummy("dummy_bottom", effect2)
                    effect1:playAnimation(effect1:getPlayAnimationName(), false)
                    effect2:playAnimation(effect2:getPlayAnimationName(), false)
                    effect1:retain()
                    effect2:retain()
                    effect1:afterAnimationComplete(function()
                        if view.getSkeletonActor and view:getSkeletonActor() and view:getSkeletonActor().detachNodeToBone then
                            view:getSkeletonActor():detachNodeToBone(effect1)
                        end
                        effect1:release()
                    end)
                    effect2:afterAnimationComplete(function()
                        if view.getSkeletonActor and view:getSkeletonActor() and view:getSkeletonActor().detachNodeToBone then
                            view:getSkeletonActor():detachNodeToBone(effect2)
                        end
                        effect2:release()
                    end)
                end
            end
        end
    end
    if support_hero_count > 0 then
        for _, actor in ipairs(app.battle:getHeroes()) do
            if not actor:isSupport() then
                shuabuff(actor, heroBuffEffects)
            end
        end
    end
    if support_enemy_count > 0 then
        for _, actor in ipairs(app.battle:getEnemies()) do
            if not actor:isSupport() then
                shuabuff(actor, enemyBuffEffects)
            end
        end
    end
    if heroBuffEffects then
        for _, effects in pairs(heroBuffEffects) do
            effects[1]:onCleanup()
            effects[1]:release()
            effects[2]:onCleanup()
            effects[2]:release()
            effects[1] = nil
            effects[2] = nil
        end
        self._dungeonConfig.supportHeroBuffEffects = nil
    end
    if enemyBuffEffects then
        for _, effects in pairs(enemyBuffEffects) do
            effects[1]:onCleanup()
            effects[1]:release()
            effects[2]:onCleanup()
            effects[2]:release()
            effects[1] = nil
            effects[2] = nil
        end
        self._dungeonConfig.supportEnemyBuffEffects = nil
    end
end

function QBattleScene:playDeputyAnimation(hero, deputyIDs, isHero) 
    local teamDeputyIDs = {}
    local isDeputy = false
    if deputyIDs then
        teamDeputyIDs = clone(deputyIDs)
        teamDeputyIDs[hero:getActorID()] = nil
        isDeputy = true
    end

    local showDeputyAni = function ()
        local aid_bust = hero:getAidBust()
        if not aid_bust or aid_bust == "" then
            return
        end

        local owner = {}
        local proxy = CCBProxy:create()
        local root
        if isHero then
            root = CCBuilderReaderLoad("Battle_Aid_Appear6.ccbi", proxy, owner)
            owner.bg_blue:setVisible(not isDeputy)
            owner.bg_yellow:setVisible(isDeputy)            
        else
            root = CCBuilderReaderLoad("Battle_Aid_Appear7.ccbi", proxy, owner)
            owner.bg_blue:setVisible(not isDeputy)
            owner.bg_yellow:setVisible(isDeputy)

            root:setPositionX(display.width)
        end
        self:addUI(root)
        root:setPositionY(550 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2)

        -- 隐藏
        for i = 1, 4 do
            local sprite = owner["sprite_bust"..i]
            if sprite then
                sprite:setVisible(false)
            end
        end

        local sprite = owner.sprite_bust1
        if sprite and aid_bust and aid_bust ~= "" then
            local spriteFrame = QSpriteFrameByPath(aid_bust)
            if spriteFrame then
                sprite:setDisplayFrame(spriteFrame)
                sprite:setVisible(true)
            end
        end

        local db = QStaticDatabase:sharedDatabase()
        local count = 1
        for id, v in pairs(teamDeputyIDs) do
            -- 只显示三个
            if count >= 4 then 
                break
            end
            local aid_bust
            if isHero then
                aid_bust = db:getHeroSkinConfigByID(app.battle:getHeroSkinById(id)).skin_aid_bust or db:getCharacterByID(id).aid_bust or ""
            else
                aid_bust = db:getHeroSkinConfigByID(app.battle:getEnemySkinById(id)).skin_aid_bust or db:getCharacterByID(id).aid_bust or ""
            end
            local sprite = owner["sprite_bust"..(count + 1)]
            if sprite and aid_bust and aid_bust ~= "" then
                local spriteFrame = QSpriteFrameByPath(aid_bust)
                if spriteFrame then
                    sprite:setDisplayFrame(spriteFrame)
                    sprite:setVisible(true)
                end
            end
            count = count + 1
        end

        local animationManager = tolua.cast(root:getUserObject(), "CCBAnimationManager")
        animationManager:runAnimationsForSequenceNamed(tostring(count))
        animationManager:connectScriptHandler(function(animationName)
            animationManager:disconnectScriptHandler()
            if root.removeFromParent then
                root:removeFromParent()
            end
        end)
    end

    showDeputyAni()
end

function QBattleScene:playGodSkillAnimation(hero, skill)
    if not (skill:getGodSkillLabel() and skill:get("zuoqi_label")) then return end
    local skillQueue = (hero:getType() == ACTOR_TYPES.HERO) and self._heroMountSkillQueue or self._enemyMountSkillQueue
    for i, oldSkill in ipairs(skillQueue) do
        if oldSkill == skill then
            -- 插到前面去
            for j = 1, i - 1 do
                local tmp = skillQueue[j]
                skillQueue[j] = skillQueue[i]
                skillQueue[i] = tmp
            end
            return
        end
    end
    skillQueue[#skillQueue + 1] = {skill:getGodSkillLabel(), skill:get("zuoqi_label"), true}
end

function QBattleScene:playMountSkillAnimation(hero, skill)
    if not (skill:getMountAnimationFileName() and skill:getMountLabelFileName()) then return end
    local skillQueue = (hero:getType() == ACTOR_TYPES.HERO) and self._heroMountSkillQueue or self._enemyMountSkillQueue
    for i, oldSkill in ipairs(skillQueue) do
        if oldSkill == skill then
            -- 插到前面去
            for j = 1, i - 1 do
                local tmp = skillQueue[j]
                skillQueue[j] = skillQueue[i]
                skillQueue[i] = tmp
            end
            return
        end
    end
    skillQueue[#skillQueue + 1] = {skill:getMountAnimationFileName(), skill:getMountLabelFileName()}
end

function QBattleScene:playGodArmAnimation(hero, skill, isSS)
    local node, owner, animName = nil, nil, nil
    if isSS then
        if hero:getType() ~= ACTOR_TYPES.HERO then
            node, owner, animName = self._enemyGodArmAnimationSS, self._enemyGodArmOwnerSS, "enemy"
        else
            node, owner, animName = self._godArmAnimationSS, self._godArmOwnerSS, "actor"
        end
    else
        if hero:getType() ~= ACTOR_TYPES.HERO then
            node, owner, animName = self._enemyGodArmAnimation, self._enemyGodArmOwner, "enemy"
        else
            node, owner, animName = self._godArmAnimation, self._godArmOwner, "actor"
        end
    end

    local godlable = skill:getGodSkillLabel()
    if godlable then
        local texture = CCTextureCache:sharedTextureCache():addImage(godlable)
        local size = texture:getContentSize()
        local rect = CCRectMake(0, 0, size.width, size.height)
        owner.icon:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
    end
    local lableSprite = skill:get("zuoqi_label")
    if lableSprite then
        local texture = CCTextureCache:sharedTextureCache():addImage(lableSprite)
        local size = texture:getContentSize()
        local rect = CCRectMake(0, 0, size.width, size.height)
       owner.name:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
       owner.name2:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
    end
    node:setVisible(true)
    local animationManager = tolua.cast(node:getUserObject(), "CCBAnimationManager")
    animationManager:runAnimationsForSequenceNamed(animName)
    animationManager:connectScriptHandler(function(animationName)
        animationManager:disconnectScriptHandler()
        node:setVisible(false)
    end)
end

function QBattleScene:_onBlackRockPassInfo(event)
    local infos = event.passInfo
    local blackRockInfos = self._blackRockInfos or {}
    table.mergeForArray(blackRockInfos, infos)
    self._blackRockInfos = blackRockInfos
end

function QBattleScene:_updateBlackRockInfoAnimation()
    local blackRockInfos = self._blackRockInfos or {}
    if #blackRockInfos > 0 then
        local info = blackRockInfos[1]
        table.remove(blackRockInfos, 1)
        self:_playBlackRockInfoAnimation(info)
    end
end

function QBattleScene:_playBlackRockInfoAnimation(info)
    local owner = {}
    local proxy = CCBProxy:create()
    local node = CCBuilderReaderLoad("ccb/Battle_Blackmountain_Appear.ccbi", proxy, owner)
    node:setZOrder(1)
    node:setPositionY(550 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2)
    self:addDialog(node)
    local animationManager = tolua.cast(node:getUserObject(), "CCBAnimationManager")
    animationManager:connectScriptHandler(function(animationName)
        animationManager:disconnectScriptHandler()
        if node.removeFromParent then
            node:removeFromParent()
        end
    end)
    owner.tf_name:setString(tostring(info.fighter.name))
    -- owner.node_headPicture:addChild(QUIWidgetAvatar.new(info.fighter.avatar))
    if info.isPass then
        owner.node_tongguan:setVisible(true)
    else
        if info.stepInfo.isNpc then
            owner.node_jisha:setVisible(true)
        else
            owner.node_huode:setVisible(true)
        end
        local bossHead = QUIWidgetBlackRockTeamDungeon.new()
        bossHead:setRoleSize(22)
        bossHead:setDungeonId(info.stepInfo.stepId, info.stepInfo.isNpc)
        owner.node_boss:addChild(bossHead)
    end
end

function QBattleScene:isInDeputyAnimation()
    if self._deputyAnimationNumber and self._deputyAnimationNumber > 0 then
        return true
    else
        return false
    end
end

function QBattleScene:playSupportAnimation()
    -- 副将半身像动画
    local function prepareBustAnimation(node, owner, actors)
        -- 隐藏
        for i = 1, 4 do
            local sprite = owner["sprite_bust"..i]
            if sprite then
                sprite:setVisible(false)
            end
        end

        local count = #actors
        local force = 0
        for index, actor in ipairs(actors) do
            local sprite = owner["sprite_bust" .. tostring(index)]
            local aid_bust = actor:getAidBust()
            if sprite and aid_bust and aid_bust ~= "" then
                local spriteFrame = QSpriteFrameByPath(aid_bust)
                if spriteFrame then
                    sprite:setDisplayFrame(spriteFrame)
                    sprite:setVisible(true)
                end
            end
            force = force + actor:getBattleForce()
        end
        if owner.label_force then
            local num, unit = q.convertLargerNumber(force)
            owner.label_force:setString("援助战力：" .. num .. unit)
        end
        local animationManager = tolua.cast(node:getUserObject(), "CCBAnimationManager")
        if count > 4 then count = 4 end
        animationManager:runAnimationsForSequenceNamed(tostring(count))
        animationManager:connectScriptHandler(function(animationName)
            animationManager:disconnectScriptHandler()
            if node.removeFromParent then
                node:removeFromParent()
            end
        end)
    end
    -- if app.battle:isPVPMultipleWaveNew() then
        local hero_supports = {}
        table.mergeForArray(hero_supports, app.battle:getSupportHeroes())
        table.mergeForArray(hero_supports, app.battle:getSupportHeroes2())
        table.mergeForArray(hero_supports, app.battle:getSupportHeroes3())
        if #hero_supports > 0 then
            local root, owner, proxy = nil, nil, nil
            if self._dungeonConfig.supportHeroBustView == nil then
                owner = {}
                proxy = CCBProxy:create()
                root = CCBuilderReaderLoad("Battle_Aid_Appear.ccbi", proxy, owner)
                root.owner = owner
            else
                root, owner, proxy = self._dungeonConfig.supportHeroBustView, nil, nil
            end
            owner = root.owner
            
            root:setPositionY(550 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2)
            self:addUI(root)
            prepareBustAnimation(root, owner, hero_supports)
        end
        local enemy_supports = {}
        table.mergeForArray(enemy_supports, app.battle:getSupportEnemies())
        table.mergeForArray(enemy_supports, app.battle:getSupportEnemies2())
        table.mergeForArray(enemy_supports, app.battle:getSupportEnemies3())
        if #enemy_supports > 0 then
            local root, owner, proxy = nil, nil, nil
            if self._dungeonConfig.supportEnemyBustView == nil then
                owner = {}
                proxy = CCBProxy:create()
                root = CCBuilderReaderLoad("Battle_Aid_Appear2.ccbi", proxy, owner)
                root.owner = owner
            else
                root, owner, proxy = self._dungeonConfig.supportEnemyBustView, nil, nil
            end
            owner = root.owner
            
            root:setPositionY(550 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2)
            root:setPositionX(display.width)
            self:addUI(root, nil, true)
            prepareBustAnimation(root, owner, enemy_supports)
        end
    -- else
    --     -- 己方副将动画
    --     if #app.battle:getSupportHeroes() --[[+ #app.battle:getSupportHeroes2()]] > 0 then
    --         local root, owner, proxy = nil, nil, nil
    --         if self._dungeonConfig.supportHeroBustView == nil then
    --             owner = {}
    --             proxy = CCBProxy:create()
    --             root = CCBuilderReaderLoad("Battle_Aid_Appear.ccbi", proxy, owner)
    --             root.owner = owner
    --         else
    --             root, owner, proxy = self._dungeonConfig.supportHeroBustView, nil, nil
    --         end
    --         owner = root.owner
    --         self:addUI(root)
    --         root:setPositionY(550 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2)
    --         prepareBustAnimation(root, owner, app.battle:getSupportHeroes())
    --     end
    --     -- 敌方副将动画
    --     if #app.battle:getSupportEnemies() --[[+ #app.battle:getSupportEnemies2()]] > 0 then
    --         local root, owner, proxy = nil, nil, nil
    --         if self._dungeonConfig.supportEnemyBustView == nil then
    --             owner = {}
    --             proxy = CCBProxy:create()
    --             root = CCBuilderReaderLoad("Battle_Aid_Appear2.ccbi", proxy, owner)
    --             root.owner = owner
    --         else
    --             root, owner, proxy = self._dungeonConfig.supportEnemyBustView, nil, nil
    --         end
    --         owner = root.owner
    --         self:addUI(root)
    --         root:setPositionY(550 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2)
    --         root:setPositionX(display.cx * 2)
    --         prepareBustAnimation(root, owner, app.battle:getSupportEnemies())
    --     end
    -- end
    if self._dungeonConfig.supportHeroBustView then
        self._dungeonConfig.supportHeroBustView:release()
        self._dungeonConfig.supportHeroBustView = nil
    end
    if self._dungeonConfig.supportEnemyBustView then
        self._dungeonConfig.supportEnemyBustView:release()
        self._dungeonConfig.supportEnemyBustView = nil
    end
end

function QBattleScene:prompHeroIntroduction(actor)
    if actor == nil then
        return
    end
    app.battle:pause()
    local wait_time = 0.65
    self:setSceneScale(wait_time, 1.2)
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local effectNode = CCBuilderReaderLoad("effects/hunshijieshao_biaoji_1.ccbi", ccbProxy, ccbOwner)
    local actorView = self:getActorViewFromModel(actor)
    if actorView then
        local size = actorView:getSize()
        effectNode:setPosition(ccp(0, size.height/2))
        actorView:addChild(effectNode)
    end

    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(wait_time))
    arr:addObject(CCCallFunc:create(function ()
        effectNode:removeFromParent()
        self:resetSceneScale()
        self.curBossIntroDialog = QBattleDialogBossIntroduction.new(nil, {actor = actor})
    end))
    self:runAction(CCSequence:create(arr))
end

function QBattleScene:checkAutoSkillButtonHighlight()
    if app.battle == nil then
        return 
    end

    local highLight = false
    local heroes = app.battle:getHeroes()
    for _, hero in ipairs(heroes) do
        if hero and hero:isForceAuto() then
            highLight = true
            break
        end
    end
    self:highlightAutoSkillButton(highLight)
end

function QBattleScene:_updateAutoSkillButton()
    if app.battle then
        local needUpdate = true
        if app.battle:isPVPMode() then
            if (app.battle:isInSunwell() and not app.battle:isSunwellAllowControl()) or (app.battle:isInArena() and not app.battle:isArenaAllowControl()) then
                needUpdate = false
            end
        end
        if needUpdate then
            self:_checkAutoSkill()
        end
    end
end

function QBattleScene:_checkAutoSkill()
    local hasAuto = false
    local heroes = app.battle:getHeroes()
    for _, hero in ipairs(heroes) do
        if hero and hero:isForceAuto() then
            hasAuto = true
            break
        end
    end
    if not hasAuto then
        local supportSkillHero = app.battle:getSupportSkillHero()
        if supportSkillHero and supportSkillHero:isForceAuto() then
            hasAuto = true
        end
    end
    if not hasAuto then
        local supportSkillHero2 = app.battle:getSupportSkillHero2()
        if supportSkillHero2 and supportSkillHero2:isForceAuto() then
            hasAuto = true
        end
    end
    if not hasAuto then
        local supportSkillHero3 = app.battle:getSupportSkillHero3()
        if supportSkillHero3 and supportSkillHero3:isForceAuto() then
            hasAuto = true
        end
    end
    local button = self._autoSkill_ccbowner.btn_autoskill
    if hasAuto then
        button:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_auto_skill_an"), CCControlStateNormal)
        button:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_auto_skill_an"), CCControlStateHighlighted)
        self._autoSkill_ccbowner.node_autoSkillLight:setVisible(false)
    else
        if app.unlock:getUnlockAutoSkill() then
            self._autoSkill_ccbowner.node_autoSkillLight:setVisible(true)
        else
            self._autoSkill_ccbowner.node_autoSkillLight:setVisible(false)
        end
        button:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_auto_skill"), CCControlStateNormal)
        button:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_auto_skill"), CCControlStateHighlighted)
    end
end

function QBattleScene:highlightAutoSkillButton(isHighlight)
    if isHighlight == nil then isHighlight = false end
    self._autoSkill_ccbowner.btn_autoskill:setHighlighted(isHighlight)
    -- if self._autoSkill_ccbowner.node_autoSkillLight then
    --      self._autoSkill_ccbowner.node_autoSkillLight:setVisible(not isHighlight)
    -- end
end

function QBattleScene:_updateThunderConditionDisplay()
    if self._ended then
        return
    end

    if app.battle:isInThunder() and self._topBar_ccbOwner.node_thunder then
        self._topBar_ccbOwner.node_thunder:setVisible(true)
    else
        return
    end

    local condition, text_target, text_value, failure, value_gap_zero = app.battle:getThunderConditionTexts()
    self._topBar_ccbOwner.label_thunder1:setString(condition)
    self._topBar_ccbOwner.label_thunder2:setString(text_target)
    self._topBar_ccbOwner.label_thunder3:setString(text_value)
    self._topBar_ccbOwner.label_thunder3:setColor(failure and UNITY_COLOR_LIGHT.red or UNITY_COLOR_LIGHT.white)
    -- self._topBar_ccbOwner.label_thunder1:setGap(-4)
    -- self._topBar_ccbOwner.label_thunder2:setGap(-4)
    -- self._topBar_ccbOwner.label_thunder3:setGap(value_gap_zero and 0 or -4)
end

function QBattleScene:_updateMazeExploreDisplay()
    if self._ended then
        return
    end

    if app.battle:isMazeExplore() and self._topBar_ccbOwner.node_thunder then
        self._topBar_ccbOwner.node_thunder:setVisible(true)
    else
        return
    end

    self._topBar_ccbOwner.label_thunder3:setVisible(false)
    self._topBar_ccbOwner.label_thunder4:setVisible(true)

    local passTime = app.battle:getDungeonDuration() - app.battle:getTimeLeft()
    local condition = "存活20s获得1星"
    if passTime >= 20 and passTime < 40 then
        condition = "存活40s获得2星"
    elseif passTime >= 40 then
        condition = "存活60s获得3星"
    end
    self._topBar_ccbOwner.label_thunder1:setString(condition)
    self._topBar_ccbOwner.label_thunder2:setString("存活时间:")
    self._topBar_ccbOwner.label_thunder4:setString(string.format("%0.2fs", passTime))
    self._topBar_ccbOwner.label_thunder4:setColor(UNITY_COLOR_LIGHT.white)
end

function QBattleScene:_udpateRebelFightAndSocietyDungeonDeathExplosion()
    -- 叛军和宗门boss最后一秒的火焰之雨
    local battle = app.battle
    if battle and not self._rebelFightAndSocietyDungeonDeathExploded then
        if battle:isInWorldBoss() and battle:getTimeLeft() < 0.75 then
            local view = QBaseEffectView.createEffectByID("bosaixi_attack13_3")
            view:setPositionX(display.cx)
            view:setPositionY(display.cy)
            app.scene:addEffectViews(view, {isFrontEffect = true})
            view:playAnimation(view:getPlayAnimationName())
            view:playSoundEffect()
            self._rebelFightAndSocietyDungeonDeathExploded = true
        elseif (battle:isInSocietyDungeon() or battle:isInRebelFight() or battle:isInUnionDragonWar()) and battle:getTimeLeft() < 1 then
            local view = QBaseEffectView.createEffectByID("quanpingtx_3")
            view:setPositionX(630)
            view:setPositionY(400)
            app.scene:addEffectViews(view, {isFrontEffect = true})
            view:playAnimation(view:getPlayAnimationName())
            view:playSoundEffect()
            self._rebelFightAndSocietyDungeonDeathExploded = true
        end
    end
end

function QBattleScene:_updateMountSkillAnimations()
    if #self._heroMountSkillQueue > 0 then
        for _, heroMountSkillView in ipairs(self._heroMountSkillViews) do
            if heroMountSkillView:isAvailable() then
                local cfg = self._heroMountSkillQueue[1]
                table.remove(self._heroMountSkillQueue, 1)
                heroMountSkillView:playAnimation(cfg[1], cfg[2], cfg[3])
                break
            end
        end
    end
    if #self._enemyMountSkillQueue > 0 then
        for _, enemyMountSkillView in ipairs(self._enemyMountSkillViews) do
            if enemyMountSkillView:isAvailable() then
                local cfg = self._enemyMountSkillQueue[1]
                table.remove(self._enemyMountSkillQueue, 1)
                enemyMountSkillView:playAnimation(cfg[1], cfg[2], cfg[3])
                break
            end
        end
    end
end

function QBattleScene:_updateRebelStatsDisplay()
    if self._ended then
        return
    end

    if app.battle:isInRebelFight() and self._topBar_ccbOwner.node_thunder then
        self._topBar_ccbOwner.node_thunder:setVisible(true)
    else
        return
    end

    local dHP = math.floor(app.battle:getRebelFightBossHpReduce())
    local work = math.floor(dHP/1000)
    if dHP < 1000000 then
        self._topBar_ccbOwner.label_thunder1:setString("伤害："..dHP)
    else
        self._topBar_ccbOwner.label_thunder1:setString("伤害："..math.floor(dHP/10000).."万")
    end

    if self._dungeonConfig.rebelScoreRate then
        work = work * self._dungeonConfig.rebelScoreRate
    end

    if work < 1000000 then
        self._topBar_ccbOwner.label_thunder2:setString("积分："..work)
    else
        self._topBar_ccbOwner.label_thunder2:setString("积分："..math.floor(work/10000).."万")
    end

    self._topBar_ccbOwner.label_thunder3:setVisible(false)
end

function QBattleScene:_updateSocietyDungeonStatsDisplay()
    if self._ended then
        return
    end

    if app.battle:isInSocietyDungeon() and self._topBar_ccbOwner.node_thunder then
        self._topBar_ccbOwner.node_thunder:setVisible(true)
    else
        return
    end

    local dHP = math.floor(app.battle:getSocietyDungeonBossHpReduce())
    local work = math.floor(dHP/1000)
    if dHP < 1000000 then
        self._topBar_ccbOwner.label_thunder1:setString("伤害："..dHP)
    else
        self._topBar_ccbOwner.label_thunder1:setString("伤害："..math.floor(dHP/10000).."万")
    end

    self._topBar_ccbOwner.label_thunder2:setVisible(false)
    self._topBar_ccbOwner.label_thunder3:setVisible(false)
end

function QBattleScene:_updateUnionDragonWarStatsDisplay()
    if not DISPLAY_UNION_GRAGON_WAR_DAMAGE then
        return
    end

    if self._ended then
        return
    end

    if app.battle:isInUnionDragonWar() and self._topBar_ccbOwner.node_thunder and self._battle_started then
        self._topBar_ccbOwner.node_thunder:setVisible(true)
    else
        return
    end

    local dHP = math.floor(app.battle:getUnionDragonWarFightBossHpReduce())
    local work = math.floor(dHP/1000)
    if dHP < 1000000 then
        self._topBar_ccbOwner.label_thunder1:setString("伤害："..dHP)
    else
        self._topBar_ccbOwner.label_thunder1:setString("伤害："..math.floor(dHP/10000).."万")
    end

    self._topBar_ccbOwner.label_thunder2:setVisible(false)
    self._topBar_ccbOwner.label_thunder3:setVisible(false)
end

function QBattleScene:_updateWorldBossStatsDisplay()
    if self._ended then
        return
    end

    if app.battle:isInWorldBoss() and self._topBar_ccbOwner.node_thunder then
        self._topBar_ccbOwner.node_thunder:setVisible(true)
    else
        return
    end

    local dHP = math.floor(app.battle:getWorldBossFightBossHpReduce())
    local work = math.floor(dHP/1000)
    if dHP < 1000000 then
        self._topBar_ccbOwner.label_thunder1:setString("伤害："..dHP)
    else
        self._topBar_ccbOwner.label_thunder1:setString("伤害："..math.floor(dHP/10000).."万")
    end

    if self._dungeonConfig.worldBossScoreRate then
        work = work * self._dungeonConfig.worldBossScoreRate
    end

    if work < 1000000 then
        self._topBar_ccbOwner.label_thunder2:setString("荣誉："..work)
    else
        self._topBar_ccbOwner.label_thunder2:setString("荣誉："..math.floor(work/10000).."万")
    end

    self._topBar_ccbOwner.label_thunder3:setVisible(false)
end

function QBattleScene:_updateDailyBossAwards()
    self._daily_boss_awards_cache = self._daily_boss_awards_cache or {}
    if self:_isBossHpViewMultiLayer() and self._bossHpBar and self._bossHpBar:getActor() and not self._dungeonConfig.boss_hp_infinite then
        local actor = self._bossHpBar:getActor()
        local maxCount = self._bossHpBar:getHpPerLayer() and math.ceil(actor:getMaxHp()/self._bossHpBar:getHpPerLayer())
        local config = self:getDungeonConfig()
        if maxCount and config and config.dailyAwards then
            local curCount = self._bossHpBar:getHpPerLayer() and math.ceil(actor:getHp() / self._bossHpBar:getHpPerLayer())
            local view = self:getActorViewFromModel(actor)
            local direction
            if view:getModel():isFlipX() == true then
                direction = QActor.DIRECTION_RIGHT
            else
                direction = QActor.DIRECTION_LEFT
            end
            local index = maxCount - curCount
            if index and index ~= 0 then
                for idx = 1,index,1 do
                    local scale = self._skeletonLayer:getScale()
                    local awards = config.dailyAwards[idx].awards
                    if self._daily_boss_awards_cache[idx] ~= true then
                        self._daily_boss_awards_cache[idx] = true
                        local deltaPos = {{80, 80}, {0, 0}, {80, 0}, {80, -80}, {0, -80}, {-80, -80}, {-80, 0}, {-80, 80}, {0, 80}}
                        local delayTime = 0
                        local _i = 0
                        for i, award in ipairs(awards) do
                            if award.droped then
                                break
                            end
                            _i = _i + 1
                            award.droped = true
                            local index = i % 9 + 1
                            local position = ccp(view:getPosition())
                            position.x = math.min(math.max(position.x, BATTLE_AREA.left + 80), BATTLE_AREA.right - 80)
                            position.x = position.x * scale + deltaPos[index][1]
                            position.y = position.y * scale + deltaPos[index][2]
                            app.battle:performWithDelay(function()
                                local rewardInfo = {reward = award, isGarbage = false}
                                self:_onGetReward(rewardInfo, direction, position)
                            end, delayTime)
                            delayTime = delayTime + 0.1
                        end
                    end
                end
            end
        end
    end
end

function QBattleScene:_updateBlackRockStatsDisplay()
    if self._ended then
        return
    end

    if app.battle:isInBlackRock() and self._topBar_ccbOwner.node_thunder then
        self._topBar_ccbOwner.node_thunder:setVisible(true)
    else
        return
    end

    local countdown = app.battle:getBlackRockCountDown()
    local text = string.format("%02d:%02d", math.floor(countdown / 60), math.floor(math.fmod(countdown, 60)))
    self._topBar_ccbOwner.label_thunder2:setString("队伍结束倒计时：")
    self._topBar_ccbOwner.label_thunder3:setVisible(true)
    self._topBar_ccbOwner.label_thunder3:setString(text)
    self._topBar_ccbOwner.label_thunder3:setColor((countdown <= 10) and UNITY_COLOR_LIGHT.red or UNITY_COLOR_LIGHT.white)
    self._topBar_ccbOwner.label_thunder1:setVisible(false)
    q.autoLayerNode({self._topBar_ccbOwner.label_thunder2, self._topBar_ccbOwner.label_thunder3}, "x")
end

function QBattleScene:_updatePVPScore()
    if (app.battle and app.battle:isPVPMultipleWave()) and self._topBar_ccbOwner.sprite_cup_hero_1 then
        local owner = self._topBar_ccbOwner
        local heroScore, enemyScore = app.battle:getPVPMultipleWaveScore()
        owner.sprite_cup_hero_1:setVisible(heroScore >= 1)
        owner.sprite_cup_hero_2:setVisible(heroScore >= 2)
        owner.sprite_cup_enemy_1:setVisible(enemyScore >= 1)
        owner.sprite_cup_enemy_2:setVisible(enemyScore >= 2)
    end
end

function QBattleScene:_defaultSelectHero()
    if ENABLE_AUTO_SELECT_HERO then
        for index = #self._heroViews, 1, -1 do
            local view = self._heroViews[index]
            if not view:getModel():isSupport() and not view:getModel():isPet() and view:isVisible() then
                self:uiSelectHero(view:getModel())
                break
            end
        end
    end
end

function QBattleScene:isEnded()
    return self._ended
end

function QBattleScene:_prepareLostCount()
    local lostCount = self._dungeonConfig.lostCount or 0
    
    if lostCount <= 0 or remote.instance:checkIsPassByDungeonId("wailing_caverns_12") == false then
        self._lostCount:setVisible(false)
    else
        self._lostCount:setVisible(true)
        self._lostCountOwner.label_count:setString(tostring(math.min(lostCount, 5)))
        local isClicked = app:getUserData():getUserValueForKey(QUserData.CLICK_LOST_COUNT)
        if isClicked == QUserData.STRING_TRUE then
            self._lostCountOwner.node_light:setVisible(false)
        else
            self._lostCountOwner.node_light:setVisible(true)
        end
    end
end

function QBattleScene:_onClickLostCountInfo(event)
    if tonumber(event) == CCControlEventTouchDown then
        local isClicked = app:getUserData():getUserValueForKey(QUserData.CLICK_LOST_COUNT)
        if isClicked ~= QUserData.STRING_TRUE then
            app:getUserData():setUserValueForKey(QUserData.CLICK_LOST_COUNT, QUserData.STRING_TRUE)
            self._lostCountOwner.node_light:setVisible(false)
        end
        local lostCount = math.min(self._dungeonConfig.lostCount or 0, 5)
        self._lostCountInfoOwner.label_info:setString(string.format("因为您坚韧不拔的毅力，所有上阵魂师属性提升%d%%（上阵魂师总战力达到关卡推荐战力后，战斗每失败1次，可获得1次属性加成，最多可叠加5次）", lostCount * (self._dungeonConfig.defeat_buff or 0) * 100))
        self._lostCountInfo:setVisible(true)
    else
        self._lostCountInfo:setVisible(false)
    end
end

function QBattleScene:speakWarning(word)
    if string.find(word, "将在") and string.find(word, "秒后狂暴") then
        local owner = {}
        local proxy = CCBProxy:create()
        local root = CCBuilderReaderLoad("Battle_Buff2.ccbi", proxy, owner)
        local second = string.sub(word, string.find(word, "%d+"))
        second = tonumber(second)
        if second > 9 then
            local copy_back = CCSprite:createWithSpriteFrame(owner.label_back_second:getDisplayFrame())
            copy_back:setAnchorPoint(ccp(0, 0))
            copy_back:setPosition(-copy_back:getContentSize().width * 0.75, 0)
            copy_back:setColor(CCNode.getColor(owner.label_back_second))
            owner.label_back_second:setPositionX(owner.label_back_second:getPositionX() + owner.label_back_second:getContentSize().width * 0.375)
            owner.label_back_second:addChild(copy_back)
            owner.label_back_second:setCascadeOpacityEnabled(true)
            owner.label_back_second:setOpacity(owner.label_back_second:getOpacity())
            owner.copy_back = copy_back
            local copy_front = CCSprite:createWithSpriteFrame(owner.label_front_second:getDisplayFrame())
            copy_front:setAnchorPoint(ccp(0, 0))
            copy_front:setPosition(-copy_front:getContentSize().width * 0.75, 0)
            copy_front:setColor(CCNode.getColor(owner.label_front_second))
            owner.label_front_second:setPositionX(owner.label_front_second:getPositionX() + owner.label_front_second:getContentSize().width * 0.375)
            owner.label_front_second:addChild(copy_front)
            owner.label_front_second:setCascadeOpacityEnabled(true)
            owner.copy_front = copy_front
        end
        local spriteFrame = QSpriteFrameByKey("fight_buff_zi", math.fmod(second, 10)+1)
        if spriteFrame then
            owner.label_front_second:setDisplayFrame(spriteFrame)
            owner.label_back_second:setDisplayFrame(spriteFrame)
        end
        if second > 9 then
            local spriteFrame = QSpriteFrameByKey("fight_buff_zi", math.floor(second / 10)+1)
            if spriteFrame then
                owner.copy_front:setDisplayFrame(spriteFrame)
                owner.copy_back:setDisplayFrame(spriteFrame)
            end
        end
        self:addChild(root)
        root:setPosition(display.cx, display.cy)

        local animationManager = tolua.cast(root:getUserObject(), "CCBAnimationManager")
        animationManager:connectScriptHandler(function(animationName)
            animationManager:disconnectScriptHandler()
            root:removeFromParent()
        end)
    end
end

function QBattleScene:showBossTips(duration, word, cfg)
    local owner = {}
    local proxy = CCBProxy:create()
    local node = CCBuilderReaderLoad("Battle_boss_tips.ccbi", proxy, owner)
    if cfg.ccb_img then
        local texture = CCTextureCache:sharedTextureCache():addImage(cfg.ccb_img)
        if texture then
            owner.background_node:setTexture(texture)
        end
    end
    if cfg.bg_scale_x then
        owner.background_node:setScaleX(cfg.bg_scale_x)
    end
    node:setPosition(ccp(display.cx, display.height * 0.85))
    --因为后来的需求 这里的要用以前的rich_text来替换以前的cclabelttf控件
    local font_color = ccc3(255,255,255)
    local rich_text = QRichText.new(word,nil,{defaultColor = font_color,defaultSize = 22,stringType = 1})
    rich_text:setAnchorPoint(ccp(0.5,0.5))
    rich_text:setVisible(false)
    owner.node_text:addChild(rich_text)
    
    self:addUI(node, false)

    owner.node:setCascadeOpacityEnabled(true)
    owner.node:setOpacity(0)
    local arr = CCArray:create()
    arr:addObject(CCFadeTo:create(1/3, 255))
    arr:addObject(CCCallFunc:create(function()
        rich_text:setVisible(true)
    end))
    arr:addObject(CCDelayTime:create(duration or 2.0))
    arr:addObject(CCCallFunc:create(function()
        rich_text:setVisible(false)
    end))
    arr:addObject(CCFadeTo:create(1/3, 0))
    arr:addObject(CCCallFunc:create(function()
        node:removeFromParentAndCleanup(true)    
    end))
    owner.node:runAction(CCSequence:create(arr))
end

function QBattleScene:togglePlaySpeedAndSkipVisibility()
    if self._jiasuBar then
        self._jiasuBar:setVisible(not self._jiasuBar:isVisible())
    end
    if self._tiaoguoBar then
        self._tiaoguoBar:setVisible(not self._tiaoguoBar:isVisible())
    end
end

function QBattleScene:_isReplayRecord(config)
    return config.isReplay and not config.isQuick
end

function QBattleScene:_initReplayRecordSpeedButton()
    local jiasu_ccbProxy = CCBProxy:create()
    local jiasu_ccbOwner = {}
    jiasu_ccbOwner.onClickJiasu = handler(self, QBattleScene._onJiasuReplayClicked)
    self._jiasuReplayBar = CCBuilderReaderLoad("Battle_But_Jiasu.ccbi", jiasu_ccbProxy, jiasu_ccbOwner)
    self._jiasuReplayBar:setPosition(self._ccbOwner.node_jiasu:getPosition())
    self._jiasuReplayccbOwner = jiasu_ccbOwner
    self:addUI(self._jiasuReplayBar)
    self._jiasuReplayEnabled = false
    local isClicked = app:getUserData():getUserValueForKey(QUserData.CLICK_SPEED_REPLAY)
    if isClicked ~= QUserData.STRING_TRUE then
        self._jiasuReplayccbOwner.node_autoSkillLight:setVisible(true)
    end
    local btnJiasu = self._jiasuReplayccbOwner.btn_jiasu
    btnJiasu:setBackgroundSpriteFrameForState(QSpriteFrameByKey("but_jiasu4_an"), CCControlStateHighlighted)
    btnJiasu:setBackgroundSpriteFrameForState(QSpriteFrameByKey("but_jiasu4_an"), CCControlStateDisabled)

    -- 点一次之后要一直保持
    local isKeeped = app:getUserData():getUserValueForKey(QUserData.KEEP_SPEED_REPLAY_UP)
    if isKeeped == QUserData.STRING_TRUE then
        self:_onJiasuReplayClicked()
    end
end

function QBattleScene:_onJiasuReplayClicked()
    local isClicked = app:getUserData():getUserValueForKey(QUserData.CLICK_SPEED_REPLAY)
    local btnJiasu = self._jiasuReplayccbOwner.btn_jiasu
    if self._jiasuReplayEnabled == false then
        btnJiasu:setBackgroundSpriteFrameForState(QSpriteFrameByKey("but_jiasu4"), CCControlStateNormal)
        self._jiasuReplayEnabled = true
        local speed = db:getConfigurationValue("speed_replay") or 3.2
        if speed ~= math.floor(speed) then
            app:setSpeedGear(1, speed)
        else
            app:setSpeedGear(speed, 1)
        end
        app:getUserData():setUserValueForKey(QUserData.KEEP_SPEED_REPLAY_UP, QUserData.STRING_TRUE)
    else
        btnJiasu:setBackgroundSpriteFrameForState(QSpriteFrameByKey("but_jiasu4_an"), CCControlStateNormal)
        self._jiasuReplayEnabled = false
        app:setSpeedGear(1, 1)
        app:getUserData():setUserValueForKey(QUserData.KEEP_SPEED_REPLAY_UP, QUserData.STRING_FALSE)
    end
    self._jiasuReplayccbOwner.node_autoSkillLight:setVisible(false)
    app:getUserData():setUserValueForKey(QUserData.CLICK_SPEED_REPLAY, QUserData.STRING_TRUE)
end

function QBattleScene:_initPlaySpeedAndSkip(config)
    if not ENABLE_BATTLE_SPEED_UP and
        (config.isTutorial 
        -- or (config.isReplay and not config.isQuick)
        -- or config.isThunder
        -- or config.isActiveDungeon
        -- or config.isPvpMultipleNew
        ) then
        return
    end

    if self:_isReplayRecord(config) then
        self:_initReplayRecordSpeedButton()
        return
    end

    local db = QStaticDatabase:sharedDatabase()
    if ENABLE_BATTLE_SPEED_UP
        or CURRENT_MODE == EDITOR_MODE
        or (not config.isPVPMode and not config.isInRebelFight and not config.isSocietyDungeon and not config.isInWorldBossFight)
        or (config.isPVPMode and (config.isSunwell or config.isGlory or config.isFriend or config.isTotemChallenge))
        or config.isActiveDungeon
    then
        -- speed up
        local condition = db:getUnlock().UNLOCK_SPEED
        local condition_vip = condition.vip_level or 0
        local condition_team_level = condition.team_level or 0
        local vip = QVIPUtil:VIPLevel()
        local team_level = remote.user.level or 0
        if ENABLE_BATTLE_SPEED_UP
            or CURRENT_MODE == EDITOR_MODE 
            or vip >= condition_vip or team_level >= condition_team_level 
        then
            local jiasu_ccbProxy = CCBProxy:create()
            local jiasu_ccbOwner = {}
            jiasu_ccbOwner.onClickJiasu = handler(self, QBattleScene._onJiasuClicked)
            self._jiasuBar = CCBuilderReaderLoad("Battle_But_Jiasu.ccbi", jiasu_ccbProxy, jiasu_ccbOwner)
            self._jiasuBar:setPosition(self._ccbOwner.node_jiasu:getPosition())
            self._jiasu_ccbOwner = jiasu_ccbOwner
            
            self:addUI(self._jiasuBar)
            self._jiasuEnabled = false
            local isClicked = app:getUserData():getUserValueForKey(QUserData.CLICK_SPEED_UP)
            if isClicked ~= QUserData.STRING_TRUE then
                self._jiasu_ccbOwner.node_autoSkillLight:setVisible(true)
            end
            -- 点一次之后要一直保持
            local isKeeped = app:getUserData():getUserValueForKey(QUserData.KEEP_SPEED_UP)
            if isKeeped == QUserData.STRING_TRUE then
                self:_onJiasuClicked()
            end
        else--[[if vip >= 5 or team_level >= 28 then]]
            local jiasu_ccbProxy = CCBProxy:create()
            local jiasu_ccbOwner = {}
            jiasu_ccbOwner.onClickJiasu = function()
                app.tip:floatTip(string.format("魂师大人，%d级或VIP%d开启战斗加速功能哦~", condition_team_level, condition_vip))
            end
            self._jiasuBar = CCBuilderReaderLoad("Battle_But_Jiasu.ccbi", jiasu_ccbProxy, jiasu_ccbOwner)
            jiasu_ccbOwner.sprite_lock:setVisible(true)
            self._jiasuBar:setPosition(self._ccbOwner.node_jiasu:getPosition())
            local btnJiasu = jiasu_ccbOwner.btn_jiasu
            btnJiasu:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_jiasu_an"), CCControlStateHighlighted)
            self._jiasu_ccbOwner = jiasu_ccbOwner
            
            self:addUI(self._jiasuBar)
            self._jiasuEnabled = false
        end
    else
        -- skip
        local vip = QVIPUtil:VIPLevel()
        local team_level = remote.user.level or 1
        local condition = db:getUnlock().UNLOCK_SKIP_VISIBLE

        if CURRENT_MODE == EDITOR_MODE or team_level >= condition.team_level then
            if config.isArena then
                if config.isStormArena or config.isMaritime then
                    condition = db:getUnlock().STORM_ARENA_UNLOCK_SKIP
                else
                    condition = db:getUnlock().ARENA_UNLOCK_SKIP
                end
            else
                condition = db:getUnlock().UNLOCK_SKIP
            end
            local condition_vip = condition.vip_level
            local condition_team_level = condition.team_level
            if CURRENT_MODE == EDITOR_MODE or vip >= condition_vip or team_level >= condition_team_level then
                local tiaoguo_ccbProxy = CCBProxy:create()
                local tiaoguo_ccbOwner = {}
                tiaoguo_ccbOwner.onClickTiaoguo = handler(self, QBattleScene._onTiaoguoClicked)
                self._tiaoguoBar = CCBuilderReaderLoad("Battle_But_Tiaoguo.ccbi", tiaoguo_ccbProxy, tiaoguo_ccbOwner)
                self._tiaoguoBar:setPosition(self._ccbOwner.node_tiaoguo:getPosition())
                self._tiaoguo_ccbOwner = tiaoguo_ccbOwner
                
                self:addUI(self._tiaoguoBar)
                local isClicked = app:getUserData():getUserValueForKey(QUserData.CLICK_SKIP)
                if isClicked ~= QUserData.STRING_TRUE then
                    self._tiaoguo_ccbOwner.node_autoSkillLight:setVisible(true)
                end
            else
                local tiaoguo_ccbProxy = CCBProxy:create()
                local tiaoguo_ccbOwner = {}
                tiaoguo_ccbOwner.onClickTiaoguo = function()
                    app.tip:floatTip(string.format("魂师大人，VIP%d或%d级开启战斗跳过功能哦~", condition_vip, condition_team_level))
                end
                self._tiaoguoBar = CCBuilderReaderLoad("Battle_But_Tiaoguo.ccbi", tiaoguo_ccbProxy, tiaoguo_ccbOwner)
                tiaoguo_ccbOwner.sprite_lock:setVisible(true)
                self._tiaoguoBar:setPosition(self._ccbOwner.node_tiaoguo:getPosition())
                local btn_tiaoguo = tiaoguo_ccbOwner.btn_tiaoguo
                btn_tiaoguo:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_tiaoguo_an"), CCControlStateHighlighted)
                self.tiaoguo_ccbOwner = tiaoguo_ccbOwner
                
                self:addUI(self._tiaoguoBar)
            end
        end
    end
end

function QBattleScene:_onJiasuClicked()
    local isClicked = app:getUserData():getUserValueForKey(QUserData.CLICK_SPEED_UP)
    local btnJiasu = self._jiasu_ccbOwner.btn_jiasu
    if self._jiasuEnabled == false then
        btnJiasu:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_jiasu"), CCControlStateNormal)
        self._jiasuEnabled = true
        local speed = db:getConfigurationValue("speed_severalfold") or 1.5
        if speed ~= math.floor(speed) then
            app:setSpeedGear(1, speed)
        else
            app:setSpeedGear(speed, 1)
        end
        app:getUserData():setUserValueForKey(QUserData.KEEP_SPEED_UP, QUserData.STRING_TRUE)
    else
        btnJiasu:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_jiasu_an"), CCControlStateNormal)
        self._jiasuEnabled = false
        app:setSpeedGear(1, 1)
        app:getUserData():setUserValueForKey(QUserData.KEEP_SPEED_UP, QUserData.STRING_FALSE)
    end
    self._jiasu_ccbOwner.node_autoSkillLight:setVisible(false)
    app:getUserData():setUserValueForKey(QUserData.CLICK_SPEED_UP, QUserData.STRING_TRUE)
end

function QBattleScene:_onTiaoguoClicked()

    if app.battle:hasWinOrLose() then
        return
    end

    local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
    local btnTiaoguo = self._tiaoguo_ccbOwner.btn_tiaoguo

    if app.battle and app.battle:isPVPMode() then
        btnTiaoguo:setEnabled(false)
        btnTiaoguo:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_tiaoguo"), CCControlStateDisabled)
        app.battle:pause()
        if self._dungeonConfig.isTotemChallenge and not self._dungeonConfig.isTotemChallengeQuick then
            local recordList = {}
            table.insert(recordList, app.battle._record)
            app:saveBattleRecordIntoProtobuf(recordList)
        end

        if app.battle:isInQuick() then
            if self._resultProxy then
                if app.battle:isInSilvesArenaReplayBattleModule() then
                    local scoreList = remote.silvesArena.fightInfo.scoreList or {}
                    local isWin = scoreList[self._dungeonConfig.index] == 1
                    local isHandler = self._resultProxy:onResult(isWin)
                    if isHandler == true then
                        self._resultProxy:onMoveCompleted()
                        self:resultHandler({}, true)
                    end
                else
                    local data = self._dungeonConfig.fightEndResponse
                    local quickFightResult = self._dungeonConfig.quickFightResult
                    local isWin, scoreList = quickFightResult.isWin, quickFightResult.scoreList
                    if type(isWin) == "number" then
                        isWin = isWin == 1
                    end
                    local isHandler = self._resultProxy:onResult(isWin)
                    if isHandler == true then
                        self._resultProxy:onMoveCompleted()
                        self:resultHandler(data, true)
                    end
                end
            end
        else
            
        end
    else
        btnTiaoguo:setEnabled(false)
        btnTiaoguo:setBackgroundSpriteFrameForState(QSpriteFrameByKey("fight_tiaoguo"), CCControlStateDisabled)
        app.battle:pause()
        -- 保存战报，如果金属之城需要跳过，则需要重新修改此处代码。
        local recordList = {}
        table.insert(recordList, app.battle._record)
        app:saveBattleRecordIntoProtobuf(recordList)

        if self._resultProxy then
            local isHandler = self._resultProxy:onResult()
            if isHandler == true then
                self._resultProxy:onMoveCompleted()
                self:resultHandler({}, true)
            end
        end
    end
    self._tiaoguo_ccbOwner.node_autoSkillLight:setVisible(false)
    app:getUserData():setUserValueForKey(QUserData.CLICK_SKIP, QUserData.STRING_TRUE)

    scheduler.setTimeFunction(function(dt)
        return dt
    end)
end

--[[
    debug functions
]]
local _debug_invincible = false
local _debug_accelarate = false
local _qactor_getAttack = QActor.getAttack
local _qactor_decreaseHp = QActor.decreaseHp
local function _debug_getAttack(self)
    if self:getType() ~= ACTOR_TYPES.NPC then
        return 99999999
    else
        return 0
    end 
end
local function _debug_decreaseHp(self, ...)
    if self:getType() ~= ACTOR_TYPES.NPC then
        return self, 0, 0
    else
        return _qactor_decreaseHp(self, ...)
    end
end
local function _debug_update(self)
    if _debug_accelarate and app.battle then
        app:setSpeedGear(4, 1)
    else
        if app.scene and (app.scene._jiasuEnabled or app.scene._jiasuReplayEnabled)
            and app.battle and not app.battle:isBattleEnded() then
            
            local speed = db:getConfigurationValue("speed_severalfold") or 1.5
            if app.scene:_isReplayRecord(app.scene._dungeonConfig) then
                speed = db:getConfigurationValue("speed_replay") or 3.2
            end
            if speed ~= math.floor(speed) then
                app:setSpeedGear(1, speed)
            else
                app:setSpeedGear(speed, 1)
            end
        else
            app:setSpeedGear(1, 1)
        end
    end

    if _debug_invincible and app.battle then
        QActor.getAttack = _debug_getAttack
        QActor.decreaseHp = _debug_decreaseHp
    else
        QActor.getAttack = _qactor_getAttack
        QActor.decreaseHp = _qactor_decreaseHp
    end
end
function QBattleScene:_debugCheat()
    if CURRENT_MODE == EDITOR_MODE then
        return
    end

    local isMobile = device.platform ~= "mac" and device.platform ~= "windows"
    local enableDebugCheat = not isMobile or DEBUG_SKIP_BATTLE
    if not enableDebugCheat then
        return
    end
    
    local menu = CCMenu:create()
    self:addChild(menu, 999999)

    -- GM(userType = 1), 福利号(userType = 3)
    if remote and (remote.user.userType == 1) then
        local button = CCMenuItemFont:create("跳过")
        button:setPosition(-500, 200)
        button:setEnabled(true)
        button:registerScriptTapHandler(function()
            app.battle:_onWin({isAllEnemyDead = true, skipMove = true})
        end)
        menu:addChild(button)
    end

    -- local button = CCMenuItemFont:create("无敌")
    -- button:setColor(_debug_invincible and ccc3(255, 0, 0) or ccc3(255, 255, 255))
    -- button:setPosition(-400, 200)
    -- button:setEnabled(true)
    -- button:registerScriptTapHandler(function()
    --     _debug_invincible = not _debug_invincible
    --     button:setColor(_debug_invincible and ccc3(255, 0, 0) or ccc3(255, 255, 255))
    -- end)
    -- menu:addChild(button)

    -- GM(userType = 1), 福利号(userType = 3)
    if remote and (remote.user.userType == 1 or remote.user.userType == 3) then
        local button3 = CCMenuItemFont:create("加速")
        button3:setColor(_debug_accelarate and ccc3(255, 0, 0) or ccc3(255, 255, 255))
        button3:setPosition(-300, 200)
        button3:setEnabled(true)
        button3:registerScriptTapHandler(function()
            _debug_accelarate = not _debug_accelarate
            button3:setColor(_debug_accelarate and ccc3(255, 0, 0) or ccc3(255, 255, 255))
        end)
        menu:addChild(button3)
    end

    if _debug_update then
        scheduler.scheduleGlobal(_debug_update, 0)
        _debug_update = nil
    end
end

function QBattleScene:_debugQuickBattle(config)
    if config.isReplay or CURRENT_MODE == EDITOR_MODE or (not config.isInRebelFight and (not (config.isArena and not config.isGlory))) then
        return
    end

    local menu = CCMenu:create()
    self:addChild(menu, 999999)
    local button = CCMenuItemFont:create("跳过战斗")
    button:setPosition(-500, -150)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
        self:_onTiaoguoClicked()
    end)
    menu:addChild(button)
end

function QBattleScene:_checkArenaConsistency(data)
    if ENVIRONMENT_NAME == "alpha" then
        return
    else
        -- if data and data.arenaResponse and app.battle:hasWinOrLose() then
        --     local isWin = data.arenaResponse.isWin
         if data and data.gfEndResponse and app.battle:hasWinOrLose() then
            local isWin = data.gfEndResponse.isWin and 1 or 0
            if isWin == 1 and app.battle._onWin_Time == nil 
                or isWin == 0 and app.battle._onLose_Time == nil
            then
                self:_writeLogFile()
            end
        end
    end
end

function QBattleScene:_writeLogFile()
    local logNamePrefix = "bl"

    local content = readFromBinaryFile("last.reppb")
    local msg = crypto.encodeBase64(content)
    QLogFile:debug(msg, logNamePrefix)

    QActorProp.setLogFunc(function (msg)
        QLogFile:debug(msg, logNamePrefix)
    end)
    -- c/s inconsistency on arena result, log some information
    for _, actor in ipairs(app.battle:getHeroes()) do
        QLogFile:debug("QActorProp Dump: "..actor:getId().." "..actor:getType(), logNamePrefix)
        local actorProp = QActorProp.new()
        actorProp:setPrint(true)
        actorProp:setHeroInfo(actor._actorProp._heroInfo, {})
    end
    for _, actor in ipairs(app.battle:getDeadHeroes()) do
        QLogFile:debug("QActorProp Dump: "..actor:getId().." "..actor:getType(), logNamePrefix)
        local actorProp = QActorProp.new()
        actorProp:setPrint(true)
        actorProp:setHeroInfo(actor._actorProp._heroInfo, {})
    end
    for _, actor in ipairs(app.battle:getSupportHeroes()) do
        QLogFile:debug("QActorProp Dump: "..actor:getId().." "..actor:getType(), logNamePrefix)
        local actorProp = QActorProp.new()
        actorProp:setPrint(true)
        actorProp:setHeroInfo(actor._actorProp._heroInfo, {})
    end
    for _, actor in ipairs(app.battle:getSupportHeroes2()) do
        QLogFile:debug("QActorProp Dump: "..actor:getId().." "..actor:getType(), logNamePrefix)
        local actorProp = QActorProp.new()
        actorProp:setPrint(true)
        actorProp:setHeroInfo(actor._actorProp._heroInfo, {})
    end
    for _, actor in ipairs(app.battle:getSupportHeroes3()) do
        QLogFile:debug("QActorProp Dump: "..actor:getId().." "..actor:getType(), logNamePrefix)
        local actorProp = QActorProp.new()
        actorProp:setPrint(true)
        actorProp:setHeroInfo(actor._actorProp._heroInfo, {})
    end
    for _, actor in ipairs(app.battle:getEnemies()) do
        QLogFile:debug("QActorProp Dump: "..actor:getId().." "..actor:getType(), logNamePrefix)
        local actorProp = QActorProp.new()
        actorProp:setPrint(true)
        actorProp:setHeroInfo(actor._actorProp._heroInfo, {})
    end
    for _, actor in ipairs(app.battle:getSupportEnemies()) do
        QLogFile:debug("QActorProp Dump: "..actor:getId().." "..actor:getType(), logNamePrefix)
        local actorProp = QActorProp.new()
        actorProp:setPrint(true)
        actorProp:setHeroInfo(actor._actorProp._heroInfo, {})
    end
    for _, actor in ipairs(app.battle:getSupportEnemies2()) do
        QLogFile:debug("QActorProp Dump: "..actor:getId().." "..actor:getType(), logNamePrefix)
        local actorProp = QActorProp.new()
        actorProp:setPrint(true)
        actorProp:setHeroInfo(actor._actorProp._heroInfo, {})
    end
    for _, actor in ipairs(app.battle:getSupportEnemies3()) do
        QLogFile:debug("QActorProp Dump: "..actor:getId().." "..actor:getType(), logNamePrefix)
        local actorProp = QActorProp.new()
        actorProp:setPrint(true)
        actorProp:setHeroInfo(actor._actorProp._heroInfo, {})
    end
    for _, sentence in ipairs(app.battle.actorHitAndAttackLogs) do
        QLogFile:debug(sentence, logNamePrefix)
    end
    QActorProp.setLogFunc(nil)
end

function QBattleScene:_onPvpMultipleWaveEnd(event)
    if not event then
        return
    end

    -- direction
    for i, view in ipairs(self._heroViews) do
        if view_filter(view) then
            view:getModel():setDirection(QActor.DIRECTION_RIGHT)
        end
    end

    -- show victory
    for i, view in ipairs(self._heroViews) do
        if view_filter(view) then
            view:getModel():onVictory()
            view:showName()
        end
    end

    local event_call_back = function()  
        local newConfig = app.battle:getPVPMultipleNextConfig()
        if app.battle:isInTotemChallenge() and not app.battle:isTotemChallengeQuick() then
            if app.battle:isInReplay() then
                local record = app:getBattleRecordList()[2]
                local dungeonConfig = record.dungeonConfig
                dungeonConfig.replayTimeSlices = record.recordTimeSlices
                dungeonConfig.replayRandomSeed = record.recordRandomSeed
                dungeonConfig._newPvpMultipleScoreInfo = newConfig._newPvpMultipleScoreInfo
                dungeonConfig.pvpMultipleWave = newConfig.pvpMultipleWave
                dungeonConfig.isReplay = true
                newConfig = dungeonConfig
            else
                newConfig.timeGearChange = nil
                newConfig.playerAction = nil
                newConfig.forceAutoChange = nil
                newConfig.disableAIChange = nil
            end
        end
        self._dungeonConfig = newConfig
        self:_onRestart() 
    end
    self._pvpWaveEndhandl = scheduler.performWithDelayGlobal(function()
        self._pvpWaveEndhandl = nil
        local rivalsInfo = self._dungeonConfig.rivalsInfo 
        local myInfo = self._dungeonConfig.myInfo
        if not rivalsInfo or not myInfo then
            event_call_back()
        else 
            self.curModalDialog = QBattleDialogPVPWaveResult.new({
                callBack = event_call_back, 
                    isWin = event.isWin
                })
        end
    end, event.skipMove and 0 or global.victory_animation_duration)
end

function QBattleScene:_onPveMultipleWaveEnd(event)
    if not event then
        return
    end

    -- direction
    for i, view in ipairs(self._heroViews) do
        if view_filter(view) then
            view:getModel():setDirection(QActor.DIRECTION_RIGHT)
        end
    end

    -- show victory
    for i, view in ipairs(self._heroViews) do
        if view_filter(view) then
            view:getModel():onVictory()
            view:showName()
        end
    end

    self._pveWaveEndHandl = scheduler.performWithDelayGlobal(function()
        --因为view在下一波就会被移除，所以不用enable view的事件监听
        self._pveWaveEndHandl = nil
        self._touchController:setSelectActorView(nil)
        self._touchController:enableTouchEvent()
        self.curModalDialog = QBattleDialogPVEWaveEnd.new({dungeonConfig = event.dungeonConfig, battleLog1 = event.battleLog, callback = handler(self, self._onRestart)})
        self._bossDeadTimeGear = 1.0
        self:_onSkeletonActorAnimationEvent3()
    end, event.skipMove and 0 or global.victory_animation_duration)
end

function QBattleScene:playSkillVideo(image_src, video_src, end_callback)
    app.battle:pause()
    local bg = CCLayerColor:create(ccc4(0, 0, 0, 0), display.width, display.height)
    -- bg:setPosition(ccp(- display.cx, -display.cy))
    -- bg:setAnchorPoint(ccp(0.5,0.5))
    -- bg:setPosition(ccp(0,0))
    self:addUI(bg, false)
    local arr = CCArray:create()
    arr:addObject(CCFadeTo:create(0.3, 255 * 0.7))
    arr:addObject(CCCallFunc:create(function()
        local proxy = CCBProxy:create()
        local owner = {}
        local ccbNode = CCBuilderReaderLoad("Battle_Widget_wuhunzhenshen.ccbi", proxy, owner)
        ccbNode:setPosition(ccp(display.cx, display.cy))
        self:addUI(ccbNode, false)
        if image_src then
            local texture = CCTextureCache:sharedTextureCache():addImage(image_src)
            if texture then
                owner.hero_image:setTexture(texture)
            end
        end

        local animationManager = tolua.cast(ccbNode:getUserObject(), "CCBAnimationManager")
        local _callback = function()
                        local arr2 = CCArray:create()
                        arr2:addObject(CCCallFunc:create(function() app.battle:resume() end))
                        arr2:addObject(CCFadeOut:create(1))
                        arr2:addObject(CCCallFunc:create(function()
                            end_callback()
                            self:enablePlayBGM()
                            bg:removeFromParentAndCleanup()
                            ccbNode:removeFromParentAndCleanup()
                        end))
                        bg:runAction(CCSequence:create(arr2))
                    end
        bg:runAction(CCFadeTo:create(0.7, 255))
        animationManager:connectScriptHandler(function()
            animationManager:disconnectScriptHandler()
            self:disablePlayBGM()
            if video_src and VideoPlayer then
                local sharedFileUtils = CCFileUtils:sharedFileUtils()
                local path = sharedFileUtils:fullPathForFilename(video_src)
                if sharedFileUtils:isFileExist(path) then
                    videoPlayer = QVideoPlayer.new()
                    videoPlayer:setCompletedCallback(function()
                        if self._isSkipVideo then return end
                        self._isSkipVideo = true
                        local arr2 = CCArray:create()
                        arr2:addObject(CCDelayTime:create(0.1))
                        arr2:addObject(CCCallFunc:create(function()
                            videoPlayer:stop()
                            videoPlayer:removeFromParentAndCleanup(true)
                            _callback()
                        end))
                        self:runAction(CCSequence:create(arr2))
                    end)
                    videoPlayer:setPosition(ccp(0, 0))
                    videoPlayer:setFullScreenEnabled(true)
                    videoPlayer:setFileName(video_src)
                    self:addChild(videoPlayer)
                    videoPlayer:play() 
                    self._isSkipVideo = false
                else
                    _callback()
                end
            else
                _callback()
            end
        end)
    end))
    bg:runAction(CCSequence:create(arr))
end

function QBattleScene:playWeatherEffect(duration)
    if not app.battle:isInUnionDragonWar() then
        return 
    end
    local cfg = QStaticDatabase:sharedDatabase():getDragonWarWeatherById(app.battle:getUnionDragonWarWeatherId())
    local icon = cfg.weather_icon
    local effectId = cfg.effect_id
    if self._weather_icon == nil and icon then
        local owner = {}
        local node = CCBuilderReaderLoad("battle_weather_icon.ccbi", CCBProxy:create(), owner)
        local texture = CCTextureCache:sharedTextureCache():addImage(icon)
        if texture then
            owner.sp_weather:setTexture(texture)
        end
        local _pos = self._labelCountDown:convertToWorldSpace(ccp(0,0))
        node:setPosition(ccp(_pos.x, _pos.y - 40))
        node:setScale(5/8)
        self:addOverlay(node)
        local animationManager = tolua.cast(node:getUserObject(), "CCBAnimationManager")
        animationManager:runAnimationsForSequenceNamed("Default Timeline")
        self._weather_icon = node
        if effectId then
            local view = QBaseEffectView.createEffectByID(effectId)
            local effectConfig = QStaticDatabase:sharedDatabase():getEffectConfigByID(effectId)
            view:setPositionX(display.cx + effectConfig.offset_x)
            view:setPositionY(display.cy + effectConfig.offset_y)
            view:getSkeletonView():setScale(1.5)
            app.scene:addEffectViews(view, {isFrontEffect = true})
            view:afterAnimationComplete(function() app.scene:removeEffectViews(view) end)
            view:playAnimation(view:getPlayAnimationName(), true)
            view:playSoundEffect()
        end
    end
    if cfg.battle_description then
        local owner = {}
        local proxy = CCBProxy:create()
        local node = CCBuilderReaderLoad("Battle_boss_tips.ccbi", proxy, owner)
        local percent = CCNode:create()
        node = owner.node
        
        node:removeFromParent()
        node:setScaleY(1 + 0.8)
        node:setAnchorPoint(ccp(0.5,0.5))
        node:setCascadeOpacityEnabled(true)
        --因为后来的需求 这里的要用以前的rich_text来替换以前的cclabelttf控件
        local font_color = ccc3(255,255,255)
        local str = cfg.battle_description:gsub("\n", [[\n]])
        local rich_text = QRichText.new(str, 661, {defaultColor = font_color,defaultSize = 22,stringType = 1, autoCenter = true})
        rich_text:setAnchorPoint(ccp(0.5,0.5))
        percent:addChild(node)
        percent:addChild(rich_text)
        percent:setPosition(ccp(display.cx, display.height * 0.8))
        rich_text:setCascadeOpacityEnabled(true)
        rich_text:setPosition(ccp(0,5))
        self:addOverlay(percent)

        percent:setCascadeOpacityEnabled(true)
        percent:setOpacity(0)
        local arr = CCArray:create()
        arr:addObject(CCFadeTo:create(1/3, 255))
        arr:addObject(CCDelayTime:create(duration))
        arr:addObject(CCFadeTo:create(1/3, 0))
        arr:addObject(CCCallFunc:create(function()
            percent:removeFromParentAndCleanup(true)    
        end))
        percent:runAction(CCSequence:create(arr))
    end
end

function QBattleScene:playSceneEffect(effectId, pos, is_lay_on_the_ground, isLoop)
    local view1, view2 = QBaseEffectView.createEffectByID(effectId)
    local view = view1 or view2
    local effectConfig = QStaticDatabase:sharedDatabase():getEffectConfigByID(effectId)
    view:setPositionX(pos.x)
    view:setPositionY(pos.y)
    if is_lay_on_the_ground then
        self:addEffectViews(view, {isGroundEffect = true})
    else
        self:addEffectViews(view, {isFrontEffect = true})
    end
    if not isLoop then
        view:afterAnimationComplete(function() self:removeEffectViews(view) end)
    end
    view:playAnimation(view:getPlayAnimationName(), isLoop)
    view:playSoundEffect()
    return view
end

function QBattleScene:isMoneyDungeon()
    return self._isActiveDungeon and self._dungeonConfig.instanceId == "activity1_1"
end

function QBattleScene:getHeroSKillBtnPos(count, index)
    if app.unlock:checkLock("UNLOCK_SOUL_SPIRIT") and count == 4 then
        count = 5
    end
    local nodeName = "btnSkill" .. tostring(count) .. "_" .. tostring(index)
    local viewPos = ccp(self._ccbOwner[nodeName]:getPosition())

    return viewPos
end

function QBattleScene:appendCandidateAnimation(dead_actor, candidate_actor, isHero)
    local animation_node = nil
    local animation_owner = nil
    local list = nil
    if isHero then
        if self._candidateHeroAnimation == nil then
            local candidateEnter_ccbProxy = CCBProxy:create()
            self._candidateHeroEnter_ccbOwner = {}
            self._candidateHeroAnimation = CCBuilderReaderLoad("Battle_sototeam.ccbi", candidateEnter_ccbProxy, self._candidateHeroEnter_ccbOwner)
            self._candidateHeroAnimation:setPositionY(550 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2)
            self._candidateHeroAnimation:setPositionX(0)
            self._candidateHeroAnimation:setVisible(false)
            self._candidateHeroAnimation:setZOrder(100)
            
            self:addUI(self._candidateHeroAnimation, false)
        end
        animation_node = self._candidateHeroAnimation
        animation_owner = self._candidateHeroEnter_ccbOwner
        list = self._candidateHeroAnimationList
    else
        if self._candidateEnemyAnimation == nil then
            local candidateEnter_ccbProxy = CCBProxy:create()
            self._candidateEnemyEnter_ccbOwner = {}
            self._candidateEnemyAnimation = CCBuilderReaderLoad("Battle_sototeam.ccbi", candidateEnter_ccbProxy, self._candidateEnemyEnter_ccbOwner)
            self._candidateEnemyAnimation:setPositionY(550 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2)
            self._candidateEnemyAnimation:setPositionX(display.width)
            self._candidateEnemyAnimation:setVisible(false)
            self._candidateEnemyAnimation:setScaleX(-1)
            self._candidateEnemyEnter_ccbOwner.spirit_ruchang:setScaleX(self._candidateEnemyEnter_ccbOwner.spirit_ruchang:getScaleX() * -1)
            self._candidateEnemyAnimation:setZOrder(100)
            
            self:addUI(self._candidateEnemyAnimation, false)
        end
        animation_node = self._candidateEnemyAnimation
        animation_owner = self._candidateEnemyEnter_ccbOwner
        list = self._candidateEnemyAnimationList
    end

    if list == nil or animation_node == nil or animation_owner == nil or dead_actor == nil or candidate_actor == nil then
        return
    end

    table.insert(list, function()
        local deadActorIconFrame1 = QSpriteFrameByPath(dead_actor:getAidBust())
        local deadActorIconFrame2 = QSpriteFrameByPath(dead_actor:getAidBust())
        local candidateActorIconFrame1 = QSpriteFrameByPath(candidate_actor:getAidBust())
        local candidateActorIconFrame2 = QSpriteFrameByPath(candidate_actor:getAidBust())
        animation_owner.dead_actor1:setDisplayFrame(deadActorIconFrame1)
        animation_owner.dead_actor2:setDisplayFrame(deadActorIconFrame2)
        animation_owner.candidate_actor1:setDisplayFrame(candidateActorIconFrame1)
        animation_owner.candidate_actor2:setDisplayFrame(candidateActorIconFrame2)
        makeNodeFromNormalToGray(animation_owner.dead_actor1)
        makeNodeFromNormalToGray(animation_owner.dead_actor2)
    end)


    
    if animation_node:isVisible() == false then
        local cb = table.remove(list)
        if cb == nil then
            return
        end
        cb()
        animation_node:setVisible(true)
        local animationManager = tolua.cast(animation_node:getUserObject(), "CCBAnimationManager")
        animationManager:runAnimationsForSequenceNamed("Default Timeline")
        animationManager:connectScriptHandler(function(animationName)
            local cb = table.remove(list)
            if cb then
                cb()
                animationManager:runAnimationsForSequenceNamed("Default Timeline")
            else
                animationManager:disconnectScriptHandler()
                animation_node:setVisible(false)
            end
        end)
    end
end

function QBattleScene:_onCandidate_enter(event)
    self:appendCandidateAnimation(event.dead_actor, event.candidate_actor, event.isHero)

    if self._allStatusViewPos == nil then
        self._allStatusViewPos = {}
        for k, view in ipairs(self._heroStatusViews) do
            local x, y = view:getPosition()
            self._allStatusViewPos[k] = ccp(x, y)
        end
    end

    if self._allEnemyStatusViewPos == nil then
        self._allEnemyStatusViewPos = {}
        for k, view in ipairs(self._enemyStatusViews) do
            local x, y = view:getPosition()
            self._allEnemyStatusViewPos[k] = ccp(x, y)
        end
    end

    local allStatusViewPos, actorStatusViews = self._allStatusViewPos, self._heroStatusViews
    local candidateHandle = self._candidateHandle
    if not event.isHero then
        allStatusViewPos = self._allEnemyStatusViewPos
        actorStatusViews = self._enemyStatusViews
        candidateHandle = self._candidateEnemyHandle
    end

    for k, view in ipairs(actorStatusViews) do
        if view:getHero():getActorID() == event.dead_actor:getActorID() then
            view:setCandidateHero(event.candidate_actor)
            local arr = CCArray:create()
            arr:addObject(CCMoveTo:create(0.2, ccp(view:getPositionX(), -130)))
            view:runAction(CCSequence:create(arr))
        end
    end
    if candidateHandle then
        scheduler.unscheduleGlobal(candidateHandle)
        candidateHandle = nil
    end
    candidateHandle = scheduler.scheduleGlobal(function()
        local tab = {}
        for _, view in ipairs(actorStatusViews) do
            local isFind = false
            for i, actor in ipairs(event.isHero and app.battle:getHeroes() or app.battle:getEnemies()) do
                if actor:getActorID() == view:getHero():getActorID()
                    or (view:getCandidateHero() and actor:getActorID() == view:getCandidateHero():getActorID()) then
                    if view:getPositionY() > 0 then
                        view:stopAllActions()
                        local arr = CCArray:create()
                        arr:addObject(CCMoveTo:create(0.2, allStatusViewPos[i]))
                        view:runAction(CCSequence:create(arr))
                    else
                        view:stopAllActions()
                        local arr = CCArray:create()
                        -- arr:addObject(CCDelayTime:create(0.2))
                        arr:addObject(CCCallFunc:create(function()
                            if view:getCandidateHero() then
                                view:setHero(view:getCandidateHero())
                                view:setCandidateHero(nil)
                            end
                        end))
                        arr:addObject(CCMoveTo:create(0.1, ccp(allStatusViewPos[i].x, view:getPositionY())))
                        arr:addObject(CCMoveTo:create(0.1, allStatusViewPos[i]))
                        view:runAction(CCSequence:create(arr))
                    end
                    isFind = true
                end
            end
            if not isFind then
                table.insert(tab, view)
            end
        end
        local index = #allStatusViewPos
        for k, view in ipairs(tab) do
            view:stopAllActions()
            local arr = CCArray:create()
            arr:addObject(CCMoveTo:create(0.2, allStatusViewPos[index]))
            view:runAction(CCSequence:create(arr))
            index = index - 1
        end
        scheduler.unscheduleGlobal(candidateHandle)
        candidateHandle = nil
        if event.isHero then
            self._candidateHandle = nil
        else
            self._candidateEnemyHandle = nil
        end
    end, 0.2)

    if event.isHero then
        self._candidateHandle = candidateHandle
    else
        self._candidateEnemyHandle = candidateHandle
    end
end

function QBattleScene:showGodArmStartAnimation(isHero, wave)
    if app.battle == nil then return end
    local ccbFile = "ccb/effects/shenqi_charu_hero.ccbi"
    local idList = app.battle:getHeroGodArmIdList()
    if not isHero then idList = app.battle:getEnemyGodArmIdList() end
    if not isHero then ccbFile = "ccb/effects/shenqi_charu_enemy.ccbi" end
    for i, id in ipairs(idList) do
        local lis = string.split(id, ";")
        local proxy = CCBProxy:create()
        local ccbOwner = {}        
        local ccbView = CCBuilderReaderLoad(ccbFile, proxy, ccbOwner)
        local config = db:getCharacterByID(lis[1])
        local imgPath = config.aid_bust
        local texture = CCTextureCache:sharedTextureCache():addImage(imgPath)
        if texture then
            local size = texture:getContentSize()
            local rect = CCRectMake(0, 0, size.width, size.height)
            ccbOwner.sprite_portrait:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
        end

        local imgPath = config.show_name
        local texture = CCTextureCache:sharedTextureCache():addImage(imgPath)
        if texture then
            local size = texture:getContentSize()
            local rect = CCRectMake(0, 0, size.width, size.height)
            ccbOwner.sprite_skill:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
        end

        ccbView:setVisible(false)
        self:addUI(ccbView, false)
        ccbView:setPositionY(450 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2 - (i - 1) * 80)
        if isHero then
            ccbView:setPositionX(0)
        else
            ccbView:setPositionX(display.cx * 2)
        end

        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create((i- 1) * 0.1 + 2.2))
        arr:addObject(CCCallFunc:create(function()
            ccbView:setVisible(true)
            local animationManager = tolua.cast(ccbView:getUserObject(), "CCBAnimationManager")
            if animationManager ~= nil then
                animationManager:stopAnimation()
                animationManager:runAnimationsForSequenceNamed("actor")
                animationManager:connectScriptHandler(function(...)
                    animationManager:disconnectScriptHandler()
                    ccbView:setVisible(false)
                end)
            end
        end))
        ccbView:runAction(CCSequence:create(arr))
    end
end

function QBattleScene:isHideDamageNumber()
    if self._hide_damage_number == nil then
        self._hide_damage_number = app:getUserData():getUserValueForKey("hide_damage_number") == QUserData.STRING_TRUE and true or false
    end
    return self._hide_damage_number
end

function QBattleScene:setHideDamageNumber(value)
    if value ~= self._hide_damage_number then
        self._hide_damage_number = value
        app:getUserData():setUserValueForKey("hide_damage_number", value and QUserData.STRING_TRUE or QUserData.STRING_FALSE)
    end
end

function QBattleScene:isAutoTwoWavePVP()
    if self._dungeonConfig.isPVPMode then
        if (self._dungeonConfig.isArena and (not (self._dungeonConfig.isTotemChallenge or self._dungeonConfig.isGlory))) or
            self._dungeonConfig.isSotoTeam or
            self._dungeonConfig.is_sociaty_war or
            self._dungeonConfig.isFightClub or
            self._dungeonConfig.isMockBattle or
            self._dungeonConfig.isSilverMine or
            self._dungeonConfig.isStormArena or
            self._dungeonConfig.isSilvesArena or
            self._dungeonConfig.isMetalAbyss or
            self._dungeonConfig.isGloryArena then
            return true
        end
    end
end

function QBattleScene:getEnemySkillBtnPos(count, index)
    if app.unlock:checkLock("UNLOCK_SOUL_SPIRIT") and count == 4 then
        count = 5
    end
    local nodeName = "btnSkill" .. tostring(count) .. "_" .. tostring(index) .. "_e_autoPvp"
    local x, y = self._ccbOwner[nodeName]:getPosition()
    local viewPos = {x = x ,y = y}

    return viewPos
end

function QBattleScene:getSupportViewOffsetEnemy()
    local offset = 0
    if self._dungeonConfig.enemySoulSpirits and #self._dungeonConfig.enemySoulSpirits > 1 then
        offset = QBattleScene.TSPRTOFFSET
    end

    return offset
end

function QBattleScene:getSupportViewOffsetHero()
    local offset = 0
    if self:isAutoTwoWavePVP() and self._dungeonConfig.userSoulSpirits and #self._dungeonConfig.userSoulSpirits > 1 then
        offset = QBattleScene.TSPRTOFFSET
    end

    return offset
end

function QBattleScene:_createEnmeyStatusView()
    if not self:isAutoTwoWavePVP() then return end

    local offset = self:getSupportViewOffsetEnemy()

    local function getEnemyStatusView(enemy)
        if enemy == nil then return nil end

        local view = QHeroStatusView.new(enemy:isNeedComboPoints())
        view:setHero(enemy)
        view:retain()
        return view
    end

    local function getSupportView(supportUIcount, enemy)
        local posNode = self._ccbOwner["node_fujingButton" .. supportUIcount .. "_e_autoPvp"]
        local view = QSupporterStatusView.new()
        view:setSupporter(enemy)
        view:setPositionX(posNode:getPositionX())
        view:setPositionY(posNode:getPositionY() + offset)
        view:setScale(posNode:getScale())
        
        self:addUI(view)
    end

    local enemies = app.battle:getEnemies()
    local count = #enemies
    for i, enemy in ipairs(enemies) do
        local enemyStatusView = getEnemyStatusView(enemy)
        local viewPos = self:getEnemySkillBtnPos(count, i)
        enemyStatusView:setPosition(viewPos.x, viewPos.y)
        
        self:addUI(enemyStatusView)
        enemyStatusView:release()
        table.insert(self._enemyStatusViews, enemyStatusView)
    end

    local sprtSkillEnemy1 = app.battle:getSupportSkillEnemy()
    local sprtSkillEnemy2 = app.battle:getSupportSkillEnemy2()
    local sprtSkillEnemy3 = app.battle:getSupportSkillEnemy3()

    local supportUIcount = 0
    if sprtSkillEnemy3 then
        supportUIcount = supportUIcount + 1
        self._supporterEnemyStatusView3 = getSupportView(supportUIcount, sprtSkillEnemy3)
    end
    if sprtSkillEnemy2 then
        supportUIcount = supportUIcount + 1
        self._supporterEnemyStatusView2 = getSupportView(supportUIcount, sprtSkillEnemy2)
    end
    if sprtSkillEnemy1 then
        supportUIcount = supportUIcount + 1
        self._supporterEnemyStatusView1 = getSupportView(supportUIcount, sprtSkillEnemy1)
    end
end

function QBattleScene:changeUIViewPos()
    self:calculatePosition()

    makeNodeRefreshCCBPos(self._ccbNode)
    if self._topBar then
        self._topBar:setPosition(0, display.ui_height)
    end
    if self._autoSkillBar then
        self._autoSkillBar:setPosition(self._ccbOwner.node_autoSkillButton:getPosition())
    end
    if self._bossHpBar then
        self._bossHpBar:setPosition(display.width * 0.75, display.height * 0.92)
    end
    if self._labelCountDown then
        self._labelCountDown:setPositionX(0)
    end
    if self._arrow then
        self._arrow:setPosition(self._ccbOwner.node_arrow:getPosition())
    end
    if self._fireWall then
        self._fireWall:setPosition(ccp(display.cx, display.cy))
    end
    if self._lostCount then
        self._lostCount:setPosition(ccp(60, display.height - 120))
    end
    if self._lostCountInfo then
        self._lostCountInfo:setPosition(ccp(0, display.height - 180))
    end
    if self._heroMountSkillViews then
        for i = 1, 2 do
            self._heroMountSkillViews[i]:setPositionY(470 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2 - (i - 1) * 80)
        end
    end
    if self._enemyMountSkillViews then
        for i = 1, 2 do
            self._enemyMountSkillViews[i]:setPositionY(470 + (BATTLE_SCREEN_WIDTH * display.height / display.width - BATTLE_SCREEN_HEIGHT) / 2 - (i - 1) * 80)
            self._enemyMountSkillViews[i]:setPositionX(display.cx * 2)
        end
    end
    if self._enemyGodArmAnimationSS then
        self._enemyGodArmAnimationSS:setPosition(ccp(display.width, 170))
    end
    if self._enemyGodArmAnimation then
        self._enemyGodArmAnimation:setPosition(ccp(display.width, 170))
    end
    if self._newEnemyTipsNode then
        self._newEnemyTipsNode:setPosition(display.cx + display.width * 0.5 - 70, display.cy + display.height * 0.5 - 150 )
    end
    if self._bossAnimationNode then
        self._bossAnimationNode:setPosition(display.cx, display.cy)
    end
    if self._jiasuBar then
        self._jiasuBar:setPosition(self._ccbOwner.node_jiasu:getPosition())
    end
    if self._tiaoguoBar then
        self._tiaoguoBar:setPosition(self._ccbOwner.node_tiaoguo:getPosition())
    end

    if self._backgroundCCB then
        CalculateUIBgSize(self._ccbOwner.node_background, 1280)
    elseif self._backgroundImage then
        CalculateUIBgSize(self._ccbOwner.node_background, 1024)
    end

    CalculateBattleUIPosition(self._ccbOwner.autoPvpUI)

    local children = self._uiLayer:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
        local child = tolua.cast(children:objectAtIndex(i), "CCNode")
        if child then
            local tag = child:getTag()
            if tag ~= nil and tag > 0 then
                local isRight = tag == 2
                CalculateBattleUIPosition(child, isRight)
            end
        end
    end
end

return QBattleScene
