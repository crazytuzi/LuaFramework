local QBattleScene = import(".QBattleScene")
local QTutorialBattleScene = class("QTutorialBattleScene", QBattleScene)

local QBaseActorView = import("..views.QBaseActorView")
local QHeroStatusView = import("..ui.battle.QHeroStatusView")
local QMissionBase = import("..tracer.mission.QMissionBase")
local QEntranceBase = import("..cutscenes.QEntranceBase")
local QTouchActorView = import("..views.QTouchActorView")
local QDragLineController = import("..controllers.QDragLineController")
local QTouchController = import("..controllers.QTouchController")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QBaseEffectView = import("..views.QBaseEffectView")
local QHeroActorView = import("..views.QHeroActorView")
local QNpcActorView = import("..views.QNpcActorView")
local QOneTrackView = import("..views.QOneTrackView")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QSkill = import("..models.QSkill")

function QTutorialBattleScene:ctor(config)
	self.super.ctor(self, config)
    self._layer = display.newLayer()
    self:addChild(self._layer)
    self._tutorialLayer = display.newLayer()
    self:addChild(self._tutorialLayer)
    self:setVisible(false)
end

function QTutorialBattleScene:onExit()
    if #self._enemyViews > 0 then
        table.remove(self._enemyViews, 1)
    end
    QTutorialBattleScene.super.onExit(self)
end

function QTutorialBattleScene:onEnter()
    QTutorialBattleScene.super.onEnter(self)

    -- 悬崖
    local ground = CCSprite:create("map/kaichangjuqing_4.png")
    self._rootLayer:addChild(ground, -1)
    ground:setAnchorPoint(ccp(0.5, 0.5))
    local w = BATTLE_AREA.width / global.screen_big_grid_width
    local h = BATTLE_AREA.height / global.screen_big_grid_height
    local x = BATTLE_AREA.left + 2.2 * w
    local y = BATTLE_AREA.bottom + 1.3 * h
    ground:setPosition(ccp(x, y + (display.height - 640)*640.0/display.height))
    self._ground = ground

    self._smokeEffect = self:playSmokeEffect()

    -- 下雨
    local frontEffect = QBaseEffectView.new("fca/xuzhang_xiayu")
    frontEffect:playAnimation(frontEffect:getPlayAnimationName(), true)
    frontEffect:playSoundEffect(false)
    frontEffect:setPosition(ccp(-569, 522))
    self:addChild(frontEffect, 2000)

    -- self:_defaultSelectHero()
    -- 为了让泰坦巨猿可以走到屏幕之外
    function app.grid:moveActorTo(actor, screenPos, nomove, inrange, noreposition)
        if self:hasActor(actor) == false then
            return
        end

        screenPos.x = math.round(screenPos.x)
        screenPos.y = math.round(screenPos.y)
        local _, gridPos = self:_toGridPos(screenPos.x, screenPos.y)

        -- 在目标点附近寻找一个合适的位置
        local bestPos
        if noreposition then
            bestPos = gridPos
        else
            bestPos = self:_findBestPositionByRadius(actor, gridPos)
        end

        -- 如果bestPos不在范围内，则看是否需要移动过去，目标位置只是设置一个位置，
        -- 则可以直接设置过去，比如actor的初始位置可能在屏幕外，否则如果是需要
        -- 移动过去的位置，则需要调整到屏幕内。
        if (nomove ~= true or inrange == true) and not self:_isInRange(bestPos.x, bestPos.y)
            and actor:getActorID() ~= 50010 and actor:getActorID() ~= 50011
            and actor:getActorID() ~= 50012 then
            if bestPos.x < 1 then bestPos.x = 1 end
            if bestPos.y < 1 then bestPos.y = 1 end

            if bestPos.x > self._nx then bestPos.x = self._nx end
            if bestPos.y > self._ny then bestPos.y = self._ny end
        end

        local oldGridPos = actor.gridPos
        self:_resetActorFollowStatus(actor) -- 由于人工或者AI指定了actor的新位置，在这里记录的所有状态都需要重置，等待下一帧重新判断
        self:_setActorGridPos(actor, bestPos, nil, nomove)
        if noreposition == true then
            if nomove then
                actor:setActorPosition(self:_toScreenPos(bestPos))
            else
                actor:setActorPosition(screenPos)
            end
        else
            if oldGridPos ~= nil then
                self:_handleRepositionCheck(actor, oldGridPos)
            end
        end

        return self:_toScreenPos(bestPos)
    end

    -- 马红俊超出范围时可以攻击
    local toGridPos = app.grid._toGridPos
    function app.grid:_toGridPos(x, y)
        local isOutOfRange, pos = toGridPos(app.grid, x, y)
        isOutOfRange = false
        return isOutOfRange, pos
    end
end

function QTutorialBattleScene:registerEvent(actor)
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
    self:uiSelectHero(actor)
    -- self:_defaultSelectHero()
end

function QTutorialBattleScene:unRegisterEvent()
    if self._touchController ~= nil then
        self._touchController:disableTouchEvent()
    end

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchActorView.EVENT_ACTOR_TOUCHED_BEGIN, self.onEvent, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_MOVE, self.onEvent, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QDragLineController.EVENT_DRAG_LINE_END_FOR_ATTACK, self.onEvent, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchController.EVENT_TOUCH_END_FOR_SELECT, self.onEvent, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchController.EVENT_TOUCH_END_FOR_MOVE, self.onEvent, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QTouchController.EVENT_TOUCH_END_FOR_ATTACK, self.onEvent, self)

    self._dragController:removeFromParentAndCleanup(true)
    self._dragController = nil
    self._touchController:removeFromParentAndCleanup(true)
    self._touchController = nil
end

function QTutorialBattleScene:_onNpcCreated(event)
	-- if self._first_entered_ then
	-- 	return self.super._onNpcCreated(self, event)
	-- else
	-- 	self._first_entered_ = true
	-- end

    local targetPos
    if event.isBoss == true then
        if self._bossCount == nil then
            self._bossCount = 0
        end
        self._bossCount = self._bossCount + 1
        if self._bossHpBar:getActor() == nil then
            if self._dungeonConfig.activity_date == nil then
                local hp_per_layer = QStaticDatabase:sharedDatabase():getHPPerLayerByLevel(event.npc:getLevel())
                self._bossHpBar:setHPPerLayer(hp_per_layer) 
            end
            self._bossHpBar:setActor(event.npc)
            self._bossHpBar:setVisible(true)
            self._labelWave:setVisible(false)
            self._waveBackground:setVisible(false)
            self._starRoot:setVisible(false)
        end
    end

    local view = QNpcActorView.new(event.npc, event.skeletonView)
    self:addHpAndDamageContainer(view:getHpAndDamageNode())

    view:setAnimationScale(app.battle:getTimeGear(), "time_gear")
    local w = BATTLE_AREA.width / global.screen_big_grid_width
    local h = BATTLE_AREA.height / global.screen_big_grid_height
    -- event.screen_pos = event.pos
    if event.screen_pos ~= nil then
        targetPos = clone(event.screen_pos)
    else
        targetPos = {x = BATTLE_AREA.left + w * event.pos.x - w / 2, y = BATTLE_AREA.bottom + h * event.pos.y - h / 2}
    end

    if event.npc:getActorID() == 50006 then
        self._layer:addChild(view, 1)
        self._bossView = view
        self:resetBossViewFunc(view)
    else
        self:addSkeletonContainer(view)
    end
    if not event.is_hero then
        table.insert(self._enemyViews, view)
    else
        table.insert(self._heroViews, view)
    end

    app.grid:addActor(event.npc) -- 注意要在view创建后加入app.grid，否则只有model，没有view的情况下，有些状态消息会miss掉
    app.grid:setActorTo(event.npc, targetPos, false, event.screen_pos ~= nil)
end

function QTutorialBattleScene:resetBossViewFunc(bossView)
    local preFunc = bossView._attachEffectForSkill
    function bossView:_attachEffectForSkill(event, effect, isAtBackSide)
        if effect._effectID == "bbd_cha_1" then
            app.scene._chargeEffect = effect
        end
        preFunc(bossView, event, effect, isAtBackSide)
    end
end

function QTutorialBattleScene:_updateActorZOrder()
    local allActorView = {}
    for i, view in ipairs(self._heroViews or {}) do
        if self._updateTangsanZOrder then
            table.insert(allActorView, view)
        else
            if view:getModel():getActorID() ~= 50001 then
                table.insert(allActorView, view)
            end
        end
    end
    for i, view in ipairs(self._enemyViews) do
        if i ~= 1 then
            table.insert(allActorView, view)
        end
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

        for _, view in ipairs(sortedActorView) do
            if self._showActorView and self._showActorView.__cname == "QNpcActorView" then
                if view == self._showActorView then
                    view:setZOrder(zOrder)
                    zOrder = zOrder + 1
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
                                        if targetView and targetView ~= self._bossView then
                                            targetView:setZOrder(zOrder)
                                            zOrder = zOrder + 1
                                        end
                                    end
                                end
                            elseif skill:getRangeType() == skill.MULTIPLE then
                                local targets = actor:getMultipleTargetWithSkill(skill, actor:getCurrentSkillTarget())
                                for _, target in ipairs(targets) do
                                    local targetView = self:getActorViewFromModel(target)
                                    if targetView and targetView ~= self._bossView then
                                        targetView:setZOrder(zOrder)
                                        zOrder = zOrder + 1
                                    end
                                end
                            end
                        end

                        view:setZOrder(zOrder)
                        zOrder = zOrder + 1
                    end
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

function QTutorialBattleScene:showHeroStatusViews()
    for _, view in ipairs(self._heroStatusViews or {}) do
        -- view:getParent():setVisible(true)
        view:getParent():setPositionY(0)
    end
end

function QTutorialBattleScene:hideHeroStatusViews()
    for _, view in ipairs(self._heroStatusViews or {}) do
        -- view:getParent():setVisible(false)
        view:getParent():setPositionY(-999999)
    end
end

function QTutorialBattleScene:_prepareHeroes()
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

    local heros = app.battle:getHeroes()
    local heroCount = 0
    for _, hero in ipairs(heros) do
        if hero:getActorID() ~= 50010 and hero:getActorID() ~= 50011 and hero:getActorID() ~= 50012 then
            heroCount = heroCount + 1
        end
    end
    for i, hero in ipairs(heros) do
        local view = QHeroActorView.new(hero)
        table.insert(views, view)
        -- 成年唐三在做技能碰撞的时候需要在比比东上方
        if hero:getActorID() ~= 50001 then
            self:addSkeletonContainer(view)
        else
            self._layer:addChild(view, 2)
            self._tangSanView = view
        end
        self:addHpAndDamageContainer(view:getHpAndDamageNode())

        -- manual skill button, hero hp and icon
        if hero:getActorID() ~= 50010 and hero:getActorID() ~= 50011 and hero:getActorID() ~= 50012 then
            local j = heroCount - i + 1
            local heroStatusView = getHeroStatusView(hero)
            local nodeName = nil
            if heroCount == 1 then
                nodeName = "node_skill2_odd"
            elseif heroCount == 2 then
                nodeName = "node_skill" .. tostring(j + 1)
            elseif heroCount == 3 then
                nodeName = "node_skill" .. tostring(j) .. "_odd"
            elseif heroCount == 4 then
                nodeName = "node_skill" .. tostring(j)
            else
                nodeName = "node_skill" .. tostring(j) .. "_sp"
            end
            heroStatusView:setPosition(ccp(self._ccbOwner[nodeName]:getPosition()))
            self:addUI(heroStatusView)
            heroStatusView:release()
            table.insert(self._heroStatusViews, heroStatusView)
        end
    end

    table.mergeForArray(self._heroViews, views);
end

function QTutorialBattleScene:toggleHeroVisibility()
    for _, view in ipairs(self._heroViews or {}) do
        view:setVisible(not view:isVisible())
    end
end

function QTutorialBattleScene:resetScene(new_view)
    local new_pos = self:convertToNodeSpace(self._skeletonLayer:convertToWorldSpace(ccp(new_view:getPosition())))
    new_pos.y = new_pos.y
    new_pos.x = new_pos.x
    new_view:setPosition(new_pos.x, new_pos.y)

    local views = {}
    table.mergeForArray(views, self._heroViews);
    table.mergeForArray(views, self._enemyViews)
    if self._heroStatusViews then
        table.mergeForArray(views, self._heroStatusViews)
    end

    self._bossHpBar:setNodeEventEnabled(false)
    for _, v in ipairs(views) do
        if v._oneTrackView then
            v._oneTrackView:setNodeEventEnabled(false)
        end
        if v._actorEventProxy then    
            v._actorEventProxy:removeAllEventListeners()
            v._actorEventProxy = nil
        end
        if v._skillEventProxy1 ~= nil then
            v._skillEventProxy1:removeAllEventListeners()
            v._skillEventProxy1 = nil
        end

        if v._skillEventProxy3 ~= nil then
            v._skillEventProxy3:removeAllEventListeners()
            v._skillEventProxy3 = nil
        end

        if v._heroEventProxy ~= nil then
            v._heroEventProxy:removeAllEventListeners()
            v._heroEventProxy = nil
        end
        v:setNodeEventEnabled(false)
    end

    local root = self._rootLayer
    root:retain()
    root:removeFromParentAndCleanup(false)

    new_view:getSkeletonActor():addCustomeNode(root, "dftjki59")
    self._bossView = new_view

    local scale = new_view:getModel():getActorScale()
    root:setScale(1/scale)
    root:setScaleX(-root:getScaleX())
    root:release()

    self._uiLayer:retain()
    self._uiLayer:removeFromParentAndCleanup(false)
    self._layer:addChild(self._uiLayer, 203)
    self._uiLayer:release()

    self._overlayLayer:retain()
    self._overlayLayer:removeFromParentAndCleanup(false)
    self._layer:addChild(self._overlayLayer, 200)
    self._overlayLayer:release()

    self._dialogLayer:retain()
    self._dialogLayer:removeFromParentAndCleanup(false)
    self._layer:addChild(self._dialogLayer, 201)
    self._dialogLayer:release()

    self._damageLayer:retain()
    self._damageLayer:removeFromParentAndCleanup(false)
    self._layer:addChild(self._damageLayer, 201)
    self._damageLayer:release()
    
    self._bossHpBar:setNodeEventEnabled(true)
    for _, v in ipairs(views) do
        if v._oneTrackView then
            v._oneTrackView:setNodeEventEnabled(true)
        end
        v:registerEvent()
    end
end

function QTutorialBattleScene:onEvent(event)
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

        local heroViews = {}
        for i, view in ipairs(self._heroViews or {}) do
            table.insert(heroViews, view)
        end

        local sortedActorView = q.sortNodeZOrder(heroViews, true)
        local actorView = QBattle.getTouchingActor(sortedActorView, event.positionX, event.positionY)
        if actorView == nil then
            local actorView = event.actorView
        end
        if actorView and actorView:getModel():isDead() == false then
            self._dragController:enableDragLine(actorView, {x = event.positionX, y = event.positionY})
        end

    elseif eventName == QDragLineController.EVENT_DRAG_LINE_END_FOR_MOVE then
        local heroView = event.heroView
        local pos = {x = BATTLE_AREA.left + 300 + 50, y = BATTLE_AREA.top - 200 + 50}
        local eventPos = {x = event.positionX, y = event.positionY}
        if eventPos.x > pos.x - 200 and eventPos.x < pos.x + 75 and eventPos.y > pos.y - 125 and eventPos.y < pos.y + 125 then
            if heroView.getModel and heroView:getModel():isDead() == false and self._dragController and not self._dragController:isSameWithTouchStartPosition({x = event.positionX, y = event.positionY}) then
                heroView:getModel():onDragMove(qccp(event.positionX, event.positionY))
                self._touchController:setSelectActorView(heroView)
            end
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
        if heroView.getModel and heroView:getModel():isDead() == false and self._dragController and not self._dragController:isSameWithTouchStartPosition({x = event.positionX, y = event.positionY}) then
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
            for _, heroStatusView in ipairs(self._heroStatusViews or {}) do
                heroStatusView:onSelectHero(newSelectView:getModel())
            end
        else
            for _, heroStatusView in ipairs(self._heroStatusViews or {}) do
                heroStatusView:onSelectHero(nil)
            end

        end
    end
end

function QTutorialBattleScene:playSmokeEffect()
    local frontEffect = QBaseEffectView.new("fca/bbdboss_lvyan_1")

    frontEffect:playAnimation(frontEffect:getPlayAnimationName(), true)
    frontEffect:playSoundEffect(false)

    frontEffect:setPosition(ccp(display.width, 0))
    self:addChild(frontEffect, 200)

    return frontEffect
end

local zOrder = 9000
function QTutorialBattleScene:playFanShuEffect(effectId, node)
    local frontEffect = QBaseEffectView.new(effectId)

    frontEffect:setScaleX(1.25)
    frontEffect:setScaleY(1.25)
    frontEffect:playAnimation(frontEffect:getPlayAnimationName(), false)
    frontEffect:playSoundEffect(false)

    frontEffect:setPosition(ccp(-(1280 - display.width)/2, (852 - display.height)/2 + display.height))
    -- frontEffect:setPosition(ccp(-display.width * 0.07, display.height * 1.15))
    if nil ~= node then
        node:addChild(frontEffect)
    else
        self:addChild(frontEffect, zOrder)
        zOrder = zOrder + 1
    end

    return frontEffect
end

function QTutorialBattleScene:playDiyimuEffect()
    self._baishuye = self:playFanShuEffect("fca/fanshu_baishuye")
    self._baishuye:afterAnimationComplete(function()
        if self._baishuye then
            self._baishuye:setVisible(false)
        end
    end)

    self._disiye2 = self:playFanShuEffect("fca/fanshu_disiye2")
    self._disiye2:afterAnimationComplete(function()
        if self._disiye2 then
            self._disiye2:setVisible(false)
        end
    end)

    self._disiye = self:playFanShuEffect("fca/fanshu_disiye")
    self._disiye:afterAnimationComplete(function()
        if self._disiye then
            self._disiye:setVisible(false)
        end
    end)

    self._disanye = self:playFanShuEffect("fca/fanshu_disanye")
    self._disanye:afterAnimationComplete(function()
        if self._disanye then
            self._disanye:setVisible(false)
        end
    end)

    self._dierye = self:playFanShuEffect("fca/fanshu_dierye")
    self._dierye:afterAnimationComplete(function()
        if self._dierye then
            self._dierye:setVisible(false)
        end
    end)

    self._diyiye = self:playFanShuEffect("fca/fanshu_diyiye")
    self._diyiye:afterAnimationComplete(function()
        if self._diyiye then
            self._diyiye:setVisible(false)
        end
    end)

    self._shujia = self:playFanShuEffect("fca/fanshu_shujia")
    self._shujia:afterAnimationComplete(function()
        if self._shujia then
            self._shujia:setVisible(false)
        end
    end)

    self._fanye1 = self:playFanShuEffect("fca/fanshu_fanye1")
    self._fanye1:afterAnimationComplete(function()
        if self._fanye1 then
            self._fanye1:setVisible(false)
        end
    end)

    self._diyimu = self:playFanShuEffect("fca/fanshu_diyimu")
    self._diyimu:afterAnimationComplete(function()
        if self._diyimu then
            self._diyimu:setVisible(false)
        end
    end)

    self._shangcengguangy = self:playFanShuEffect("fca/fanshu_shangchenggy1")
    self._shangcengguangy:afterAnimationComplete(function()
        if self._shangcengguangy then
            self._shangcengguangy:setVisible(false)
        end
    end)

    self._fanshu_zimu = self:playFanShuEffect("fca/fanshu_zimu")
    local x, y = self._fanshu_zimu:getPosition()
    self._fanshu_zimu:setPosition(ccp(x, y - (display.height - 640) * 0.5))
    for i = 1, 6 do
        self["_fanshu_zimu" .. i] = self:playFanShuEffect("fca/fanshu_zimu" .. i)
        self["_fanshu_zimu" .. i]:afterAnimationComplete(function()
            self["_soundPangbai" .. i] = app.sound:playSound("xuzhang_pangbai_" .. i)
        end)
    end
end

function QTutorialBattleScene:playDiermuEffect()
    self._chushu3 = self:playFanShuEffect("fca/fanshu_huishu_chushu3")
    self._chushu2 = self:playFanShuEffect("fca/fanshu_huishu_chushu2")
    self._chushu = self:playFanShuEffect("fca/fanshu_huishu_chushu")

    self._huishu_zimu = self:playFanShuEffect("fca/fanshu_huishu_chushu_zimu")
    local x, y = self._huishu_zimu:getPosition()
    self._huishu_zimu:setPosition(ccp(x, y - (display.height - 640) * 0.5))
    for i = 1, 4 do
        self["_huishu_zimu" .. i] = self:playFanShuEffect("fca/fanshu_huishu_chushu_zimu" .. i)
        self["_huishu_zimu" .. i]:afterAnimationComplete(function()
            self["_soundPangbai" .. (6 + i)] = app.sound:playSound("xuzhang_pangbai_" .. (6 + i))
        end)
    end
    -- self._layer:runAction(CCScaleTo:create(0.5, 0.6))
end

function QTutorialBattleScene:_createBGFile(fileName)
    if fileName == nil or fileName == "" then
        return nil
    end

    if string.sub(fileName, string.len(fileName) - 4) == ".ccbi" then
        local bg_ccbProxy = CCBProxy:create()
        local bg_ccbOwner = {}
        return CCBuilderReaderLoad(fileName, bg_ccbProxy, bg_ccbOwner)
    else
        local spr = CCSprite:create(fileName)
        spr:setScale(1.3)
        return spr
    end
end

function QTutorialBattleScene:_onPause(event)
    self.super._onPause(self, event)
    -- 唐三和比比东的view需要特殊处理
    self:_pauseNode(self._bossView, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_pauseNode(self._tangSanView, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
end

function QTutorialBattleScene:_onResume(event)
    self.super._onResume(self, event)
    -- 唐三和比比东的view需要特殊处理
    self:_resumeNode(self._bossView, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_resumeNode(self._tangSanView, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
end

function QTutorialBattleScene:setTutorialBulletTime(animationScale)
    for _, hero in ipairs(app.battle:getHeroes()) do
        hero:setAnimationScale(animationScale, "tutorial_bullet_time")
    end
    for _, enemy in ipairs(app.battle:getEnemies()) do
        enemy:setAnimationScale(animationScale, "tutorial_bullet_time")
    end
    if self._zhuangjiEffect then
        self._zhuangjiEffect._skeletonView:setAnimationScale(animationScale)
    end
end

function QTutorialBattleScene:playDashedEffect1()
    local frontEffect = nil

    local arr = CCArray:create()
    arr:addObject(CCMoveBy:create(0.0005, ccp(100, -100)))
    arr:addObject(CCScaleTo:create(0.1, 1.7))
    arr:addObject(CCDelayTime:create(1.5))
    arr:addObject(CCCallFunc:create(function()
        -- app.scene:removeEffectViews(frontEffect)
        frontEffect:removeFromParentAndCleanup(true)
        self._zhuangjiEffect:removeFromParentAndCleanup(true)
        self._zhuangjiEffect = nil
    end))
    arr:addObject(CCMoveBy:create(0.0005, ccp(-100, 100)))
    arr:addObject(CCScaleTo:create(0.1, 1.0))
    self:runAction(CCSequence:create(arr))

    frontEffect = QBaseEffectView.createEffectByID("suduxian_1_1")
    frontEffect:setPosition(display.width * 0.5, display.height * 0.5 + 50)
    frontEffect:setScale(1.2 * 1280 / 1024)
    -- self:addEffectViews(frontEffect, {isFrontEffect = true})
    self:addChild(frontEffect, 2001)

    frontEffect:playAnimation(frontEffect:getPlayAnimationName(), true)
    frontEffect:playSoundEffect(false)

    self._zhuangjiEffect = QBaseEffectView.new("fca/tangsan_zhangji_1")
    self._zhuangjiEffect:playAnimation(self._zhuangjiEffect:getPlayAnimationName(), false)
    self._zhuangjiEffect:playSoundEffect(false)
    self._zhuangjiEffect:setPosition(ccp(display.width * 0.5 - 100, display.height * 0.5 + 100))
    self:addChild(self._zhuangjiEffect, 2000)
end

function QTutorialBattleScene:resetTangSanViewOrder()
    local v = self._tangSanView
    if v._oneTrackView then
        v._oneTrackView:setNodeEventEnabled(false)
    end
    if v._actorEventProxy then    
        v._actorEventProxy:removeAllEventListeners()
        v._actorEventProxy = nil
    end
    if v._skillEventProxy1 ~= nil then
        v._skillEventProxy1:removeAllEventListeners()
        v._skillEventProxy1 = nil
    end

    if v._skillEventProxy3 ~= nil then
        v._skillEventProxy3:removeAllEventListeners()
        v._skillEventProxy3 = nil
    end

    if v._heroEventProxy ~= nil then
        v._heroEventProxy:removeAllEventListeners()
        v._heroEventProxy = nil
    end
    v:setNodeEventEnabled(false)
    v:retain()
    v:removeFromParentAndCleanup(false)
    self:addSkeletonContainer(v)
    v:release()
    if v._oneTrackView then
        v._oneTrackView:setNodeEventEnabled(true)
    end
    v:registerEvent()
end

function QTutorialBattleScene:setDiyimuScale()
    do return end
    self._layer:setScale(0.6)
    self._layer:runAction(CCScaleTo:create(0.5, 1.0))
end

function QTutorialBattleScene:pauseEffectAncTangsan()
    self:_pauseNode(self._tangSanView, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_pauseNode(self._bossView, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    if self._chargeEffect and self._chargeEffect._frameId then
        scheduler.unscheduleGlobal(self._chargeEffect._frameId)
        self._chargeEffect._frameId = nil
    end
end

return QTutorialBattleScene
