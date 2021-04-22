--[[
    Class name QBaseActorView 
    Create by julian 
    This class is a base class of actor.
    Other actor class is inherit from this.
--]]

local QBaseActorView = class("QBaseActorView", function()
    return display.newNode()
end)

local QSkeletonViewController = import("..controllers.QSkeletonViewController")
local QActorHpView = import("..ui.battle.QActorHpView")
local QActorSkillView = import("..ui.battle.QActorSkillView")
local QBaseEffectView = import(".QBaseEffectView")
local QSkill = import("..models.QSkill")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QOneTrackView = import(".QOneTrackView")
local QActorDamageView = import("..ui.battle.QActorDamageView")
local QFollowNode = import("..ui.battle.QFollowNode")
local QLogFile = import("..utils.QLogFile")
local QChatDialog = import("..utils.QChatDialog")
local QIncompleteCircleUiMask = import("..ui.battle.QIncompleteCircleUiMask")

QBaseActorView.HIDE_CIRCLE = "HIDE_CIRCLE"
QBaseActorView.SOURCE_CIRCLE = "SOURCE_CIRCLE"
QBaseActorView.TARGET_CIRCLE = "TARGET_CIRCLE"
QBaseActorView.HEALTH_CIRCLE = "HEALTH_CIRCLE"

QBaseActorView.SELECT_EFFECT_SOURCE_FILE = "circle_hero_select"
QBaseActorView.ENEMY_SELECT_EFFECT_SOURCE_FILE = "circle_hero_select_1"
QBaseActorView.HERO_ENEMY_EFFECT_SOURCE_FILE = "hostile_halo_3"

local NAME_CCB = "ccb/Dialog_battle_heroname.ccbi"
local NAME_CCB_OFFSET_Y = 10

local HIT_TIP_INTERVAL_MINIMUM = nil
local SKILL_LABLE_OFFSET_Y = 25
local BACK_SOUL_ANIMATION_NAME = "variant"

local SOUL_ANIMATION_SCALE = {
                                [1] = 0.8, [2] = 0.85,
                                [3] = 0.9, [4] = 0.93,
                                [5] = 0.96, [6] = 1
                            }

--[[
    actor: actor object
--]]
function QBaseActorView:ctor(actor, skeletonView, followNode)
    if HIT_TIP_INTERVAL_MINIMUM == nil then
        local value = 0.3
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.HIT_TIP_INTERVAL_MINIMUM ~= nil and globalConfig.HIT_TIP_INTERVAL_MINIMUM.value ~= nil then
            value = globalConfig.HIT_TIP_INTERVAL_MINIMUM.value 
        end
        HIT_TIP_INTERVAL_MINIMUM = value
    end

    self._isClear = false

    self._actor = actor

    local actorScale, sign = actor:getActorScale()
    local isFlipActor = false
    if sign < 0 then
        isFlipActor = true
    end

    self._firsttime_walking = true
    self._currentAnimation = nil
    self._buffEffects = {}
    self._skillAttackEffects = {}
    self._skillLoopEffects = {}
    self._skillEffectsTimeStop = {}

    self._selectSourceCircle = QBaseEffectView.new(QBaseActorView.SELECT_EFFECT_SOURCE_FILE, nil, nil, {scale = 1, sizeRenderTexture = CCSize(96, 32)})
    self._selectSourceCircle:setScale(1.2)
    self:addChild(self._selectSourceCircle, -1)
    self._selectSourceCircle:setVisible(false)

    self._selectcircle = CCSprite:create(global.ui_drag_line_green_circle1)
    self._selectcircle:setScale(0.5)
    self:addChild(self._selectcircle, -1)
    self._selectcircle:setVisible(false)

    self._targetCircle = CCSprite:create(global.ui_actor_select_target)
    self._targetCircle:setScale(actorScale*0.5)
    self._targetCircle:setScale(0.5)
    self:addChild(self._targetCircle, -2)
    self._targetCircle:setVisible(false)

    self._targetHealthCircle = CCSprite:create(global.ui_actor_select_target_health)
    self._targetHealthCircle:setScale(actorScale*0.5)
    self:addChild(self._targetHealthCircle, -2)
    self._targetHealthCircle:setVisible(false)

    self._animationQueue = {}
    local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
    local isShowEnchant = true
    if not app.battle:isPVPMode() and not app.battle:isPVPMultipleWave() and actor:getType() == ACTOR_TYPES.NPC then
        isShowEnchant = false
    end
    self._skeletonActor = skeletonViewController:createSkeletonActorWithFile(actor:getActorFile(), isShowEnchant)
    self._skeletonActor:setSkeletonScaleX(actorScale)
    self._skeletonActor:setSkeletonScaleY(actorScale)

    if isFlipActor == true then
        self._skeletonActor:flipActor()
    end
    self:addChild(self._skeletonActor:getNode())

    self:showBackSoulEffect()

    local weaponFile = actor:getActorWeaponFile()
    if weaponFile ~= nil then
        local parentBone = self._skeletonActor:getParentBoneName(DUMMY.WEAPON)
        self._skeletonActor:replaceSlotWithFile(weaponFile, parentBone, ROOT_BONE, EFFECT_ANIMATION)
    end

    local replaceBone = actor:getActorReplaceBone()
    local replaceFile = actor:getActorReplaceFile()
    if replaceBone ~= nil and replaceFile ~= nil then
        self._skeletonActor:replaceSlotWithFile(replaceFile, replaceBone, ROOT_BONE, EFFECT_ANIMATION)
    end

    self._HpNode = QFollowNode.createWithFollowedNode(self)
    self._HpNode:retain()
    self._DamageNode = QFollowNode.createWithFollowedNode(self)
    self._DamageNode:retain()

    self._hpViewNode = display.newNode()
    self._hpView = QActorHpView.new(actor, self)
    -- 用于技能名显示的文字条
    self._labelSkill = QActorSkillView.new()
    self._labelSkill:setVisible(false)
    -- 魂灵的技能名称为黄色
    if self._actor:isSoulSpirit() then
        self._labelSkill:setColor(COLORS.G)
    end
    self._damageViewNode = display.newNode():addTo(self._DamageNode)

    -- cache for future use
    local width = self:getModel():getSelectRectWidth()
    local height = self:getModel():getSelectRectHeight()
    local rect = CCRectMake(-width*0.5, 0, width, height)
    if actorScale ~= 1.0 then
        rect.origin.x = rect.origin.x * actorScale
        rect.size.width = rect.size.width * actorScale
        rect.size.height = rect.size.height * actorScale
    end
    self:setSize( CCSizeMake(width * actorScale, height * actorScale) )
    self._actor:setRect(rect)
    local coreScale = 0.8
    local coreRect = CCRectMake(rect.origin.x * coreScale, 0, rect.size.width * coreScale, rect.size.height * coreScale)
    self._actor:setCoreRect(coreRect)
    local touchScale = 0.4
    local touchRect = CCRectMake(rect.origin.x * touchScale, 0, rect.size.width * touchScale, rect.size.height * touchScale)
    self._actor:setTouchRect(touchRect)

    self._hpView:setPosition(0, self:getSize().height)
    self._hpViewNode:addChild(self._hpView)
    -- self:addChild(self._hpViewNode)
    self._HpNode:addChild(self._hpViewNode)

    if actor:hasHpGroup() and app.battle:isInUnionDragonWar() then
        self._HpNode:setVisible(false)
    end

    self._labelSkill:setPosition(0, self:getSize().height + SKILL_LABLE_OFFSET_Y)
    self:addChild(self._labelSkill, 10)

    -- 用于显示被动技能触发sprite frame的父节点
    self._nodePassiveSkill = CCNode:create()
    self._nodePassiveSkill:setPosition(0, self:getSize().height)
    self:addChild(self._nodePassiveSkill, 10)

    self:registerEvent()

    self._disabledAnimation = {}
    self._isKeepAnimation = false
    if skeletonView ~= nil then
        local animation = skeletonView:getCurrentAnimationName()
        local time = skeletonView:getCurrentAnimationTime()
        if animation ~= nil then
            self._animationQueue = {animation}
            self:_changeAnimation()
            self._skeletonActor:updateAnimation(time)
        end
    else
        self._animationQueue = {ANIMATION.STAND}
        self:_changeAnimation()
    end

    self._colorBuffStack = {}
    self._colorOverlay = display.COLOR_WHITE

    self._lastTipTime = app.battle:getTime() --上次显示伤害数值的时间，不要设置为0，因为os.clock可能返回负值（在小米2A上出现的问题）
    self._lastBuffTipTime = app.battle:getTime() --上次显示buff数值的时间，不要设置为0，因为os.clock可能返回负值（在小米2A上出现的问题）

    if DISPLAY_ACTOR_MOVE then
        self._moveDirection = CCDrawNode:create()
        self:addChild(self._moveDirection)
    end

    self._oneTrackView = QOneTrackView.new(actor)
    self._oneTrackView:setPosition(0, self:getSize().height + 20)
    self:addChild(self._oneTrackView)

    if skeletonView ~= nil then
        skeletonView:release()
    end

    self._waitingHitTips = {}

    self._bullshits = {}
    self._bullshitNode = nil
    self._bullshitCD = 0
    self._bullshitRoot = display.newNode()
    app.scene:addOverlay(self._bullshitRoot)
    self._bullshitRoot:retain()

    self._scales = {}
    self._sizeScales = {}
    self._outGlows = {}

    self:_processAdditionalEffects()

    self._ccbList = {}
    self._mutativeRadiusBuff = {}
    setmetatable(self._mutativeRadiusBuff, {__mode="kv"})


    -- 需要替换的动作，目前只作用于ANIMATION
    self._replaceAction = {}
    -- 战斗开始前显示的人物的名字
    local owner = {}
    self._nameView = CCBuilderReaderLoad(NAME_CCB, CCBProxy:create(), owner)
    self._nameView:retain()
    owner.nameLabel:setString(actor:getDisplayName())
    self:addChild(self._nameView)
    self._nameView:setPositionY(self:getSize().height + NAME_CCB_OFFSET_Y)
    self._nameView:setVisible(false)
    if ACTOR_TYPES.NPC ~= self:getModel():getType() and not app.battle:isInTutorial() then
        self:showName()
    end
end

function QBaseActorView:getModel()
    return self._actor
end

function QBaseActorView:getSkeletonActor()
    return self._skeletonActor
end

function QBaseActorView:onEnter()
    if app.battle:isPVPMode() == true then
        -- local effectID = nil
        -- if self:getModel():getType() == ACTOR_TYPES.HERO or self:getModel():getType() == ACTOR_TYPES.HERO_NPC then
        --     effectID = global.alliance_arena_flag_effect
        -- else
        --     effectID = global.horde_arena_flag_effect
        -- end
        -- local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, self)
        -- -- ignore frontEffect
        -- local dummy = (QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID) or DUMMY.BODY)
        -- local isFlipWithActor = QStaticDatabase.sharedDatabase():getEffectIsFlipWithActorByID(effectID)
        -- if backEffect ~= nil then
        --     self:attachEffectToDummy(dummy, backEffect, true, isFlipWithActor)
        --     backEffect:playAnimation(EFFECT_ANIMATION, true)
        --     self._flagEffect = backEffect
        -- end
    end

    self._skeletonActor:connectAnimationEventSignal(handler(self, self._onSkeletonActorAnimationEvent))
    if self._skeletonActor.connectAnimationUpdateEventSignal then
        self._skeletonActor:connectAnimationUpdateEventSignal(handler(self, self._onSkeletonActorAnimationUpdateEvent))
    end
    -- 注册帧事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()

    -- local maskRect = CCRect(-200, -200, 400, 500)
    -- self:setScissorEnabled(true)
    -- self:setScissorRects(
    --     maskRect,
    --     CCRect(0, 0, 0, 0),
    --     CCRect(0, 0, 0, 0),
    --     CCRect(0, 0, 0, 0)
    -- )
    -- local func = ccBlendFunc()
    -- func.src = GL_DST_ALPHA
    -- func.dst = GL_DST_ALPHA
    -- self:setScissorBlendFunc(func)
    -- self:setScissorColor(ccc3(255, 255, 255))
    -- self:setScissorOpacity(0)
    -- func.src = GL_SRC_ALPHA
    -- func.dst = GL_ONE_MINUS_SRC_ALPHA
    -- self:setRenderTextureBlendFunc(func)
    -- self:setOpacityActor(16)
end

function QBaseActorView:onExit()
    if app.battle:isPVPMode() == true and self._flagEffect ~= nil then
        self._skeletonActor:detachNodeToBone(self._flagEffect)
        self._flagEffect = nil
    end

    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
    self:unscheduleUpdate()
    self._skeletonActor:disconnectAnimationEventSignal()
    if self._skeletonActor.disconnectAnimationUpdateEventSignal then
        self._skeletonActor:disconnectAnimationUpdateEventSignal()
    end

    self:_releaseAllReplaceEffectc()
end

function QBaseActorView:onCleanup()
    if self._isClear then return end --mark is cleared
    self._isClear = true
    QSkeletonViewController.sharedSkeletonViewController():removeSkeletonActor(self._skeletonActor)
    if self._actorEventProxy then
        self._actorEventProxy:removeAllEventListeners()
        self._actorEventProxy = nil
    end
    
    self._selectcircle:removeFromParent()
    self._selectSourceCircle:removeFromParent()
    self._targetCircle:removeFromParent()
    self._targetHealthCircle:removeFromParent()
    self._skeletonActor:removeFromParent()
    self._skeletonActor = nil
    self._hpView:cleanup()
    self._hpView:removeFromParent()
    self._oneTrackView:removeFromParent()
    self:displayFuncMark(nil)
    if self._DamageNode then 
        self._DamageNode:removeFromParent()
        self._DamageNode:release()
        self._DamageNode = nil
    end
    if self._HpNode then
        self._HpNode:removeFromParent()
        self._HpNode:release()
        self._HpNode = nil
    end

    if self._nameView then
        self._nameView:removeFromParentAndCleanup()
        self._nameView:release()
        self._nameView = nil
    end

    if self._bullshitNode then
        self._bullshitNode:removeFromParent()
        self._bullshitNode = nil
    end
    -- order!
    self._bullshitRoot:removeFromParentAndCleanup()
    self._bullshitRoot:release()

    if self._outGlowContainer then
        self._outGlowContainer:release()
        self._outGlowContainer = nil
    end

    if self._outGlowClip then
        self._outGlowClip:release()
        self._outGlowClip = nil
    end

    if self._backSoulAnim then
        QSkeletonViewController.sharedSkeletonViewController():removeSkeletonActor(self._backSoulAnim)
    end

    self:_clearBullshits()
    self:_clearTips()
end

function QBaseActorView:setSize(size)
    self._size = size
end

function QBaseActorView:getSize()
    return self._size
end

function QBaseActorView:setIsKeepAnimation(isKeepAnimation)
    if isKeepAnimation == nil then
        isKeepAnimation = false
    end
    self._isKeepAnimation = isKeepAnimation
end

function QBaseActorView:visibleSelectCircle(circleMode, dragHeroView)
    if self._isClear then return end
    if circleMode ~= QBaseActorView.HEALTH_CIRCLE then
        if not (app.battle:isInSunwell() and app.battle:isSunwellAllowControl()) or self:getModel():getType() == ACTOR_TYPES.HERO then
            self._selectSourceCircle:setVisible(false)
            self._selectcircle:setVisible(false)
        end
    end
    self._targetCircle:setVisible(false)
    self._targetHealthCircle:setVisible(false)
    self._selectcircle:setVisible(false)

    if circleMode == QBaseActorView.SOURCE_CIRCLE then
        -- self._selectSourceCircle:setVisible(true)
        -- self._selectSourceCircle:playAnimation(EFFECT_ANIMATION)

        local textureCache = CCTextureCache:sharedTextureCache()
        self._selectcircle:setTexture(textureCache:addImage(global.ui_drag_line_green_circle1))
        self._selectcircle:setVisible(true)
    elseif circleMode == QBaseActorView.TARGET_CIRCLE then
        if dragHeroView and not dragHeroView._isClear then
            local textureCache = CCTextureCache:sharedTextureCache()
            dragHeroView._selectcircle:setTexture(textureCache:addImage(global.ui_drag_line_yellow_circle1))
        end

        self._targetCircle:setVisible(true)
        self._targetCircle:stopAllActions()
        self._targetCircle:setScale(0)

        local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(0.1, 0.7))
        arr:addObject(CCScaleTo:create(0.05, 0.5))
        self._targetCircle:runAction(CCSequence:create(arr))
    elseif circleMode == QBaseActorView.HEALTH_CIRCLE then
        if dragHeroView then
            local textureCache = CCTextureCache:sharedTextureCache()
            dragHeroView._selectcircle:setTexture(textureCache:addImage(global.ui_drag_line_white_circle1))
        end

        self._targetHealthCircle:setVisible(true)
        self._targetHealthCircle:stopAllActions()
        self._targetHealthCircle:setScale(0)

        local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(0.1, 0.7))
        arr:addObject(CCScaleTo:create(0.05, 0.5))
        self._targetHealthCircle:runAction(CCSequence:create(arr))
    end
end

function QBaseActorView:invisibleSelectCircle(circleMode, dragHeroView)
    if self._isClear then return end
    if circleMode == QBaseActorView.TARGET_CIRCLE then
        self._targetCircle:setVisible(true)
        self._targetCircle:stopAllActions()
        -- self._targetCircle:setScale(2)
        self._targetCircle:runAction(CCScaleTo:create(0.1, 0))

    elseif circleMode == QBaseActorView.HEALTH_CIRCLE then
        self._targetHealthCircle:setVisible(true)
        self._targetHealthCircle:stopAllActions()
        -- self._targetHealthCircle:setScale(2)
        self._targetHealthCircle:runAction(CCScaleTo:create(0.1, 0, 0))
    end
    if dragHeroView and dragHeroView._selectcircle then
        local textureCache = CCTextureCache:sharedTextureCache()
        dragHeroView._selectcircle:setTexture(textureCache:addImage(global.ui_drag_line_green_circle1))
        dragHeroView._selectcircle:setVisible(true)
    end
end

function QBaseActorView:displayHpView()
    --满血，不掉血的情况下不显示
    local hpBeforeLastChange = self._actor:getHpBeforeLastChange()
    if hpBeforeLastChange == self._actor:getMaxHp() and self._actor:getHp() == self._actor:getMaxHp() then
        return
    end
    if self._actor:getHp() >= 0 and self._actor:isDead() == false and self._actor:isExile() ~= true then
        self._hpView:update(self._actor:getHp()/self._actor:getMaxHp())
    end
end

function QBaseActorView:hideHpView()
    self._hpView:hide()
end

-- 接口，不能删除
function QBaseActorView:_displaySkillName()
end

function QBaseActorView:_onFrame(dt)
    if self._skeletonActor.isFca then
        self._skeletonActor:updateAnimation(dt)
    end
    if self._backSoulAnim and self._backSoulAnim.isFca then
        self._backSoulAnim:updateAnimation(dt)
    end

    local actor = self._actor
    if ENABLE_SKILL_DISPLAY then
        self:_displaySkillName()
    end

    -- Weak status code
    if actor:isWeak() and not actor:isDead() then
        self._skeletonActor:setOpacity(127)
    end

    self._HpNode:onFrame(dt)
    self._DamageNode:onFrame(dt)

    if app.scene:isEnded() or self._actor:isCopyHero() then
        self._hpViewNode:setVisible(false)
    end

    if self._actor:isInTimeStop() then
        return
    end

    dt = dt * app.battle:getTimeGear()

    if DISPLAY_ACTOR_MOVE then
        if self._moveDirection and self:getModel():isWalking() then
            self._moveDirection:clear()
            local to = self._actor:getTargetPosition()
            if to ~= nil then
                local x, y = self:getPosition()
                self._moveDirection:drawSegment(ccp(0,0), ccp(to.x - x, to.y - y), 3, ccc4f(1, 0, 0, 0.5))
            end
        end
    end

    if self._storageView and self._showStorageBuffId then
        local buffs = self._actor:getBuffs()
        local value = 0
        for _, buff in ipairs(buffs) do
            if buff:getId() == self._showStorageBuffId then
                value = buff:getSaveTreat() + value
            end
        end
        self._storageView:update(value / self._maxStorage)
    end

    self:_updateSprint(dt)
    self:_updateSpeak(dt)
    self:_updateFuncMark(dt)
    self:_updateCCB(dt)
    self:_updateMutativeBuffEffect()

    for _, v in ipairs(self._buffEffects) do
        if v.isGroundEffect then
            if v.front_effect then
                v.front_effect:setPosition(self:getPosition())
                if v.isFlipWithActor then
                    v.front_effect:setSizeScaleX(self:getModel():isFlipX() and 1 or -1, v)
                end
            end
            if v.back_effect then
                v.back_effect:setPosition(self:getPosition())
                if v.isFlipWithActor then
                    v.back_effect:setSizeScaleX(self:getModel():isFlipX() and 1 or -1, v)
                end
            end
        end
    end

    if app.battle:isPVPMode() == true and self._flagEffect ~= nil then
        makeNodeOpacity(self._flagEffect, self._skeletonActor:getOpacity())
    end
end

function QBaseActorView:_onAttack(event)
    -- play the attack animation of the actor for the specified skill
    if event.skill:getSkillType() == QSkill.MANUAL 
        and self._skeletonActor:isHitAnimationPlaying() == true then
        self._skeletonActor:stopHitAnimation()
    end
end

function QBaseActorView:_onHit(event)
    if HIDE_DAMAGE_VIEW then return end
    if app.scene:isHideDamageNumber() then return end
    if event.tip == "0" or event.tip == "+" then return end
    
    local font = global.ui_hp_change_font_damage_hero
    if self:getModel():getType() == ACTOR_TYPES.NPC then
        font = global.ui_hp_change_font_damage_npc
    end
    if event.isTreat == false then
        if DISPLAY_HIT_ANIMATION == true
            and self:getModel():isDead() == false  
            and self:getModel():isWalking() == false 
            and self._skeletonActor:isHitAnimationPlaying() == false
            and self._isKeepAnimation == false then

            if self:getModel():getCurrentSkill() == nil 
                or self:getModel():getCurrentSkill():getSkillType() ~= QSkill.MANUAL then

                --if app.battle:isInBulletTime() == false then
                --    self._skeletonActor:playHitAnimation(ANIMATION.HIT)
                --end
            end
        end

        if not self._skeletonActor.isFca or not self._isGlow then
            if not self:getModel():isCopyHero() then
                local arr = CCArray:create()
                arr:addObject(CCTintTo:create(0.1, 255, 100, 100))
                arr:addObject(CCTintTo:create(0.1, self._colorOverlay.r, self._colorOverlay.g, self._colorOverlay.b))
                self._skeletonActor:runAction(CCSequence:create(arr))
            end
        end
    else
        font = global.ui_hp_change_font_treat
    end

    local tip = nil
    local ccbOwner = {}
    local appearDistance = 8 -- 伤害数字向上移动出现的距离
    if event.isCritical then
        if event.isTreat then
            -- tip = CCBuilderReaderLoad("effects/Attack_shanbi.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
            tip = app.scene:getTip("effects/Attack_shanbi.ccbi"):addTo(self._damageViewNode)
            ccbOwner = tip.ccbOwner
            tip:setPosition(0, self:getSize().height - appearDistance)
       else
            if self:getModel():getType() == ACTOR_TYPES.NPC then
                -- tip = CCBuilderReaderLoad("effects/Attack_Ybaoji.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                tip = app.scene:getTip("effects/Attack_Ybaoji.ccbi"):addTo(self._damageViewNode)
                ccbOwner = tip.ccbOwner
            else
                -- tip = CCBuilderReaderLoad("effects/Attack_baoji.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                tip = app.scene:getTip("effects/Attack_baoji.ccbi"):addTo(self._damageViewNode)
                ccbOwner = tip.ccbOwner
            end
        end
        tip:setPosition(-10, self:getSize().height)
    else
        if event.isTreat then
            -- tip = CCBuilderReaderLoad("effects/Heal_number.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
            tip = app.scene:getTip("effects/Heal_number.ccbi"):addTo(self._damageViewNode)
            ccbOwner = tip.ccbOwner
            tip:setScale(0.8)
        else
            if string.find(event.tip, "闪避") then
                if self:getModel():getType() == ACTOR_TYPES.NPC then
                    -- tip = CCBuilderReaderLoad("effects/Attack_Ynumber.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                    tip = app.scene:getTip("effects/Attack_Ynumber.ccbi"):addTo(self._damageViewNode)
                    ccbOwner = tip.ccbOwner
                    tip:setScale(0.8)
                else
                    -- tip = CCBuilderReaderLoad("effects/Attack_shanbi.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                tip = app.scene:getTip("effects/Attack_shanbi.ccbi"):addTo(self._damageViewNode)
                ccbOwner = tip.ccbOwner
                end
            else
                if self:getModel():getType() == ACTOR_TYPES.NPC then
                    -- tip = CCBuilderReaderLoad("effects/Attack_Ynumber.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                    tip = app.scene:getTip("effects/Attack_Ynumber.ccbi"):addTo(self._damageViewNode)
                    ccbOwner = tip.ccbOwner
                else
                    -- tip = CCBuilderReaderLoad("effects/Attack_number.ccbi", CCBProxy:create(), ccbOwner):addTo(self)
                    tip = app.scene:getTip("effects/Attack_number.ccbi"):addTo(self._damageViewNode)
                    ccbOwner = tip.ccbOwner
                end
                tip:setScale(0.8)
            end
        end
        tip:setPosition(0, self:getSize().height - appearDistance)
    end
    if event.rawTip then
        local rawTip = event.rawTip
        QActorDamageView.createWithLabel(ccbOwner.var_text, rawTip.isHero, rawTip.isDodge, rawTip.isBlock, rawTip.isCritical, rawTip.isTreat, rawTip.isAbsorb, rawTip.isImmune, rawTip.isRage, rawTip.number, event.tip_modifiers, rawTip.isExecute)
        ccbOwner.var_text:setVisible(false)
    else
        QActorDamageView.clearLabel(ccbOwner.var_text)
        ccbOwner.var_text:setString(event.tip)
        ccbOwner.var_text:setVisible(true)
    end

    self:_popNumberTip(tip)
end

function QBaseActorView:_popNumberTip(tip)
    -- 计算上一次伤害到这一次伤害数字冒出需要等待的时间，避免重复
    local wait = HIT_TIP_INTERVAL_MINIMUM - (app.battle:getTime() - self._lastTipTime)

    local sequence = CCArray:create()

    if wait < 0 then
        wait = 0
    end
    self._waitingHitTips[tip] = tip
    self._lastTipTime = app.battle:getTime() + wait

    tip:setVisible(false)

    sequence:addObject(CCDelayTime:create(wait))
    sequence:addObject(CCCallFunc:create(function ()
        tip:setVisible(true)
        local animationManager = tolua.cast(tip:getUserObject(), "CCBAnimationManager")
        animationManager:runAnimationsForSequenceNamed("Default Timeline")
        animationManager:connectScriptHandler(function(animationName)
            animationManager:disconnectScriptHandler()
            tip:removeFromParentAndCleanup(false)
            if tip.need_return then
                if app.scene then
                    app.scene:returnTip(tip)
                else
                    tip:release()
                end
            end
            self._waitingHitTips[tip] = nil
            -- CCRemoveSelf:create(true)
        end)
    end))
   
    tip:runAction(CCSequence:create(sequence))
end

function QBaseActorView:_clearTips()
    for _, tip in pairs(self._waitingHitTips) do
        tip:removeFromParent()
        tip:cleanup()
        if tip.need_return then
            if app.scene then
                app.scene:returnTip(tip)
            else
                tip:release()
            end
        end
        self._waitingHitTips[tip] = nil
    end
    self._waitingHitTips = {}
end

function QBaseActorView:_onStateChanged(event)
    -- printf("=================QBaseActorView %s: state change from %s to %s", self:getModel():getId(), event.from, event.to)
    -- if event.from == "blowingup" or (event.from == "beatbacking" and self:getModel().beatbackHeight > 0) then
    --     self:_removeReplacedShadow("shadow")
    -- end

    if event.to == "idle" then
        self._animationQueue = {ANIMATION.STAND}
        self:_changeAnimation()
    elseif event.to == "walking" then
        -- self:_playWalkingAnimation()
    elseif event.to == "dead" then
        self:_removeAllEffectForSkill()
        self._hpView:setVisible(false)
        self:stopAllActions()

        self:_clearTips()
        self:_clearBullshits()

        if not self:getModel():isNoDeadSkillOrAnimation() then
            if nil ~= self:getModel():getDeadBehaviorFile() and not self:getModel():isBoss()
               and not self:getModel():isEliteBoss() then
                self:getModel():doDeadBehavior()
            else
                if self._isKeepAnimation == true then
                    self._isKeepAnimation = false
                    self._skeletonActor:resetActorWithAnimation(ANIMATION.DEAD, false)
                else
                    self._animationQueue = {ANIMATION.DEAD}
                    self:_changeAnimation()
                end

                -- 死亡音效
                local actor_display = QStaticDatabase:sharedDatabase():getCharacterByID(self:getModel():getActorID())
                if actor_display then
                    if actor_display.dead then
                        local front, back = QBaseEffectView.createEffectByID(actor_display.dead)
                        local view = front or back
                        if view then view:playSoundEffect() end
                    end
                end
                -- 死亡特效
                self:_playDeadEffect()
            end
        else
            self:setVisible(false)
        end
        
    elseif event.to == "victorious" then
        self._hpView:setVisible(false)
        self:stopAllActions()
        local endEgg = self:_getEndEggs()
        if endEgg then
            self:_playVictoryEffect()
            if endEgg.egg_skill then
                self:getModel():registerVictorySkill(endEgg.egg_skill)
                self:getModel():playVictorySkill()
            elseif endEgg.egg_animation then
                self._animationQueue = {endEgg.egg_animation}
                self:_changeAnimation(true)
            end
        elseif self:getModel():getVictorySkill() ~= nil then
            self:_playVictoryEffect()
            self:getModel():playVictorySkill()
        else
            self._animationQueue = {ANIMATION.VICTORY--[[, ANIMATION.STAND]]}
            self:_changeAnimation(true)
            self:_playVictoryEffect()
        end
        self._victory = true
    -- elseif event.to == "beatbacking" then
    elseif event.to == "blowingup" or (event.to == "beatbacking" --[[and self:getModel().beatbackHeight > 0]]) then
        -- self:_replaceShadowWithFile("ui/shadow.png")
        self._animationQueue = {ANIMATION.HIT}
        self:_changeAnimation()
    end
end

function QBaseActorView:_onHpChanged(event)
    if app.scene:isEnded() or (event.dHP > 0 and event.hpBeforeLastChange == event.hp) then
        return
    end

    self:displayHpView()
end

function QBaseActorView:_onRpChanged(event)
    if event.showTip and self._actor:getType() == ACTOR_TYPES.HERO then
        local dRage = event.new_rage - event.old_rage
        if dRage < 1 then
            return
        end

        local appearDistance = 20
        local tip, ccbOwner
        tip = app.scene:getTip("effects/Heal_number2.ccbi"):addTo(self)
        ccbOwner = tip.ccbOwner
        tip:setScale(0.8)
        tip:setPosition(0, self:getSize().height - appearDistance)
        QActorDamageView.createWithLabel(ccbOwner.var_text, true, false, false, false, false, false, false, true, math.floor(dRage))
        ccbOwner.var_text:setVisible(false)

        self:_popNumberTip(tip)
    end
end

local RomanNumerals = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"}

function QBaseActorView:_onTriggerPassiveSkill(event)
    local skill = event.skill
    if not skill then return end
    if skill:isTriggerDisplayName() or skill:getTriggerSpriteFrame() then
        if skill:isTriggerDisplayName() then
            -- local tip = string.format("%s·%s", skill:getName(), RomanNumerals[skill:getSkillLevel()])
            -- ccbOwner.label_skill_name:setVisible(true)
            -- ccbOwner.label_skill_name:setString(tip)
            local tip = skill:getName()
            if skill:isDisplayNameWithLevel() then
                tip = string.format("%s·%s", skill:getName(), RomanNumerals[skill:getSkillLevel()])
            end
            self:playMountSkillLabel(tip)
        end

        if skill:getTriggerSpriteFrame() then
            local parentNode = self._nodePassiveSkill
            parentNode:removeAllChildren()
            local ccbi = "Widget_TriggerSprite.ccbi"
            local ccbProxy = CCBProxy:create()
            local ccbOwner = {}
            local ccbNode = CCBuilderReaderLoad(ccbi, ccbProxy, ccbOwner)
            
            ccbOwner.sprite_skill_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(skill:getTriggerSpriteFrame()))
            ccbOwner.icon_node:setVisible(true)
            
            ccbNode:setScale(0.618)
            parentNode:addChild(ccbNode)
            local animationManager = tolua.cast(ccbNode:getUserObject(), "CCBAnimationManager")
            animationManager:runAnimationsForSequenceNamed("start")
        end
    end

    local mountId = skill:getMountId()
    if mountId and skill:isTriggerDisplayName() then
        self:playMountSkillLabel(skill:getName())
    end
end

function QBaseActorView:_onPositionChanged(event)
    if event.position ~= nil then
        self:setPosition(event.position.x, event.position.y)
    end 
end

function QBaseActorView:_onHeightChanged(event)
    local height = event.height
    if height ~= nil then
        self:getSkeletonActor():setPositionY(height)
        self._hpViewNode:setPositionY(height)
        self._labelSkill:setPositionY(self:getSize().height + SKILL_LABLE_OFFSET_Y + height)
        self._nodePassiveSkill:setPositionY(self:getSize().height + height)
        self._damageViewNode:setPositionY(height)
    end
end

function QBaseActorView:_onMove(event)
    if event.from == nil then
        event.from = self._actor:getPosition()
    end
end

function QBaseActorView:_playWalkingAnimation()
    local actor = self._actor
    local self_pos = actor:getPosition()
    local target_pos = actor:getTargetPosition()

    if self._firsttime_walking == true or target_pos == nil or target_pos.x - self_pos.x == 0 or ((target_pos.x - self_pos.x < 0) == (actor:getDirection() == actor.DIRECTION_LEFT)) then
        self._animationQueue = {ANIMATION.WALK}
        self._firsttime_walking = false
    else
        self._animationQueue = {ANIMATION.REVERSEWALK}
    end
    self:_changeAnimation()
end

function QBaseActorView:_onSkeletonActorAnimationEvent(eventType, trackIndex, animationName, loopCount)
    -- if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
    --     self:getModel():onAnimationEnded(eventType, trackIndex, animationName, loopCount)
    -- end

    if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
        
    elseif eventType == SP_ANIMATION_START then
        self._currentAnimation = animationName
    end
    
end

function QBaseActorView:_changeAnimation(isLoop)
    if self._isKeepAnimation == true then
        return
    end

    if table.nums(self._animationQueue) == 0 then
        return
    end

    local _animationQueue = {}
    for _, animation in ipairs(self._animationQueue) do
        if not self._disabledAnimation[animation] then
            _animationQueue[#_animationQueue + 1] = animation
        end
    end
    self._animationQueue = _animationQueue

    -- stand and walk is loop
    if self._animationQueue[1] == self._currentAnimation 
        and (self._currentAnimation == ANIMATION.STAND or self._currentAnimation == ANIMATION.WALK or self._currentAnimation == ANIMATION.REVERSEWALK) then
        return
    end

    for i, animation in ipairs(self._animationQueue) do
        local isLoop = (isLoop or animation == ANIMATION.STAND or animation == ANIMATION.WALK or animation == ANIMATION.REVERSEWALK)
        -- 替换动画
        animation = self:getReplaceStandardAction(animation)
        if i == 1 then
            self._skeletonActor:playAnimation(animation, isLoop)
        else
            self._skeletonActor:appendAnimation(animation, isLoop)
        end
    end

    if app.battle._battleVCR then
        app.battle._battleVCR:_onChangeAnimation(self._actor, self._animationQueue, isLoop)
    end
end

function QBaseActorView:_onChangeAnimationForSkill(event)
    self._animationQueue = event.animations
    self:_changeAnimation(event.isLoop)
end

-- use for leave battle scene 
function QBaseActorView:changToWalkAnimation()
    self._animationQueue = {ANIMATION.WALK}
    self:_changeAnimation(true)
end

function QBaseActorView:_onPlayEffectForSkill(event)
    if event == nil then
        return
    end

    local effectID = event.effectID
    if effectID == nil then
        return
    end

    local options = {}
    if event.options.rotateToPosition ~= nil then
        local positionX, positionY = self:getPosition()
        local dummy = QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID)
        if dummy == DUMMY.BOTTOM or dummy == DUMMY.TOP or dummy == DUMMY.CENTER then
            dummy = nil
        end
        local bonePosition = self:getSkeletonActor():getBonePosition(dummy)
        positionX = positionX + bonePosition.x
        positionY = positionY + bonePosition.y
        local deltaX = event.options.rotateToPosition.x - positionX
        local deltaY = event.options.rotateToPosition.y - positionY
        if self:getModel():isFlipX() then
            options.externalRotate = math.deg(math.atan2(deltaY, deltaX))
        else
            options.externalRotate = math.deg(math.atan2(deltaY, -deltaX))
        end
    end

    options.time_scale = event.options.time_scale
    options.rotation = event.options.rotation
    options.front_layer = event.options.front_layer
    options.ground_layer = event.options.ground_layer
    options.scale_actor_face = event.options.scale_actor_face
    options.ignore_animation_scale = event.options.ignore_animation_scale

    local frontEffect = nil
    local backEffect = nil
    frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, self, QBaseEffectView, options)

    if event.options.haste then
        local coefficient = self:getModel():getMaxHasteCoefficient()
        if frontEffect then
            frontEffect:getSkeletonView():setAnimationScaleOriginal(coefficient)
        end
        if backEffect then
            backEffect:getSkeletonView():setAnimationScaleOriginal(coefficient)
        end
    end

    if event.options.isRandomPosition == true then
        local size = self:getModel():getCoreRect().size
        local deltaX = math.random(math.floor(size.width * 0.8)) - size.width * 0.8 * 0.5
        local deltaY = math.random(math.floor(size.height * 0.8)) - size.height * 0.8 * 0.5
        if frontEffect ~= nil and frontEffect:getSkeletonView() ~= nil then
            local positionX, positionY = frontEffect:getSkeletonView():getPosition()
            positionX = positionX + deltaX
            positionY = positionY + deltaY
            frontEffect:getSkeletonView():setPosition(positionX, positionY)
        end
        if backEffect ~= nil and backEffect:getSkeletonView() ~= nil then
            local positionX, positionY = backEffect:getSkeletonView():getPosition()
            positionX = positionX + deltaX
            positionY = positionY + deltaY
            backEffect:getSkeletonView():setPosition(positionX, positionY)
        end
    end

    if frontEffect ~= nil then
        self:_attachEffectForSkill(event, frontEffect, false)
    end
    if backEffect ~= nil then
        self:_attachEffectForSkill(event, backEffect, true)
    end
end

function QBaseActorView:_attachEffectForSkill(event, effect, isAtBackSide)
    if event == nil or effect == nil then
        return
    end

    local effectID = event.effectID
    if effectID == nil then
        return
    end
    
    local effectConfig = QStaticDatabase:sharedDatabase():getEffectConfigByID(effectID)

    if event.options.isFlipX == true then
        effect:setSizeScaleX(-1, "isFlipX")
    end
    if event.options.isFlipY == true then
        effect:setSizeScaleY(-1, "isFlipY")
    end

    if event.options.scale_actor_face then
        local scale = event.options.attacker:isFlipX() and event.options.scale_actor_face or -event.options.scale_actor_face
        effect:setSizeScaleX(scale, "scale_actor_face")
    end

    -- attach to dummy
    local dummy = QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID)
    local isFlipWithActor = QStaticDatabase.sharedDatabase():getEffectIsFlipWithActorByID(effectID)
    if event.options.targetPosition == nil and dummy ~= nil then
        self:attachEffectToDummy(dummy, effect, isAtBackSide, isFlipWithActor, QStaticDatabase:sharedDatabase():getEffectConfigByID(effectID), event.options.attacker, event.options.attackee, event.options.isFumo)
    else
        if event.options.targetPosition ~= nil then
            effect:setPosition(event.options.targetPosition.x, event.options.targetPosition.y)
        else
            effect:setPosition(self:getPosition())
        end
        effect:setActorView(self)
        app.scene:addEffectViews(effect, {isFrontEffect = event.options.front_layer, isGroundEffect = event.options.ground_layer})
    end

    -- play animation and sound
    effect:playAnimation(effect:getPlayAnimationName(), event.options.isLoop or false, QStaticDatabase:sharedDatabase():getEffectConfigByID(effectID).replace)
    effect:playSoundEffect(false)

    -- callback when animation complete
    
    if event.options.isLoop == true then
        table.insert(self._skillLoopEffects, {effectId = effectID, effect = effect, dummy = dummy, func = func})
    else
        local func = event.callFunc
        local isAttackEffect = event.options.isAttackEffect
        local skillId = event.options.skillId
        if isAttackEffect == true then
            if self._skillAttackEffects[skillId] == nil then
                self._skillAttackEffects[skillId] = {}
            end
            table.insert(self._skillAttackEffects[skillId], effect)
        end
        effect:afterAnimationComplete(function()
            if not self._skillAttackEffects then
                if dummy ~= nil then
                    app.scene:removeEffectViews(effect)
                    if func ~= nil then
                        func()
                    end
                    return
                end
            end
            if isAttackEffect == true and self._skillAttackEffects then
                for i, attackEffect in ipairs(self._skillAttackEffects[skillId] or {}) do
                    if effect == attackEffect then
                        table.remove(self._skillAttackEffects[skillId], i)
                        break
                    end
                end
            end

            if event.options.targetPosition == nil and dummy ~= nil and effectConfig.dummy_as_position == nil then
                if self:getSkeletonActor() then
                    if effectConfig.replace then
                        self.getSkeletonActor():removeReplaceSkeleton(self:_getReplaceBoneName(effectConfig, dummy))

                    end
                    self:getSkeletonActor():detachNodeToBone(effect)
                end
            else
                app.scene:removeEffectViews(effect)
            end

            if func ~= nil then
                func()
            end
        end)
    end

    if event.options.followActorAnimation then
        effect:setFollowActor(self._actor)
    end
    if event.options.followActorPosition and effectConfig.dummy_as_position then
        effect:setPositionActor(self._actor)
    end
end

function QBaseActorView:_onSkillCancel(event)
    local skillId = event.skillId
    if self._skillAttackEffects and self._skillAttackEffects[skillId] ~= nil then
        while(table.nums(self._skillAttackEffects[skillId]) > 0) do
            local effect = self._skillAttackEffects[skillId][1]
            if effect ~= nil and effect.stopAnimation ~= nil then 
                effect:stopAnimation()
            else
                table.remove(self._skillAttackEffects[skillId], 1)
            end
        end
    end
end

function QBaseActorView:_onRemoveEffectForSkill(event)
    if event == nil then
        return
    end

    local effectID = event.effectID
    if effectID == nil then
        return
    end

    local index = 1
    while index > 0 do
        index = 0
        for i, skillEffect in ipairs(self._skillLoopEffects) do
            if skillEffect.effectId == effectID then
                index = i
                break
            end
        end
        if index > 0 then
            local skillEffect = self._skillLoopEffects[index]
            if skillEffect.effect ~= nil and not tolua.isnull(skillEffect.effect) then
                skillEffect.effect:stopAnimation()
                if skillEffect.dummy ~= nil and skillEffect.effect._dummy_as_position == nil then
                    self:getSkeletonActor():detachNodeToBone(skillEffect.effect)
                else
                    app.scene:removeEffectViews(skillEffect.effect)
                end
                if skillEffect.func ~= nil then
                    skillEffect.func()
                end
            end
            table.remove(self._skillLoopEffects, index)
        end
    end
end

function QBaseActorView:_removeAllEffectForSkill()
    while table.nums(self._skillLoopEffects) > 0 do
        self:_onRemoveEffectForSkill({effectID = self._skillLoopEffects[1].effectId})
    end
end

function QBaseActorView:_onBuffStarted(event)
    if self.getSkeletonActor == nil then
        return
    end

    local buff = event.buff
    if buff == nil then
        return
    end

    if buff:isImmuned() then
        return
    end

    local replaceAction = buff:getReplaceStandardAction()
    if replaceAction ~= nil and replaceAction ~= "" then
        self:parseReplaceStandardAction(replaceAction, buff:getId())
    end

    local hasSameBuff = false
    for _, old_buff in ipairs(self._actor._buffs) do
        if old_buff ~= buff and old_buff:getId() == buff:getId() then
            hasSameBuff = true
            break
        end
    end

    local visible_list = {}
    local hasBeginEffect = false

    -- play begin effect
    local effectID = buff:getBeginEffectID()
    if effectID ~= nil and event.replace ~= true and not hasSameBuff then
        hasBeginEffect = true
        local effectConfig = QStaticDatabase.sharedDatabase():getEffectConfigByID(effectID)
        local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, self)
        local dummy = (QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID) or DUMMY.BODY)
        local isFlipWithActor = QStaticDatabase.sharedDatabase():getEffectIsFlipWithActorByID(effectID)
        local front_finish = frontEffect == nil
        local back_finish = backEffect == nil
        if frontEffect ~= nil then
            self:insertMutativeBuff(buff, frontEffect)
            self:attachEffectToDummy(dummy, frontEffect, false, isFlipWithActor, effectConfig, self:getModel())
            frontEffect:playAnimation(frontEffect:getPlayAnimationName(), false)
            frontEffect:playSoundEffect(false)
            frontEffect:afterAnimationComplete(function()

                if dummy ~= nil and effectConfig.dummy_as_position == nil then
                    if self.getSkeletonActor then
                        if effectConfig.replace then
                            self._skeletonActor:removeReplaceSkeleton(self:_getReplaceBoneName(effectConfig, dummy))
                        end
                        pcall(function() self:getSkeletonActor():detachNodeToBone(frontEffect) end)
                    end
                else
                    app.scene:removeEffectViews(frontEffect)
                end

                if back_finish then
                    for _,effect in ipairs(visible_list) do
                        if not tolua.isnull(effect) then --这里有可能在回调之前特效就被cleanup了所以要判空
                            effect:setVisible(true)
                        end
                    end
                end

            end)
        end
        if backEffect ~= nil then
            self:insertMutativeBuff(buff, backEffect)
            self:attachEffectToDummy(dummy, backEffect, true, isFlipWithActor, effectConfig, self:getModel())
            backEffect:playAnimation(backEffect:getPlayAnimationName(), false)
            backEffect:afterAnimationComplete(function()
                if dummy ~= nil and effectConfig.dummy_as_position == nil then
                    if self.getSkeletonActor then
                        if effectConfig.replace then
                            self._skeletonActor:removeReplaceSkeleton(self:_getReplaceBoneName(effectConfig, dummy))
                        end
                        pcall(function() self:getSkeletonActor():detachNodeToBone(backEffect) end)
                    end
                else
                    app.scene:removeEffectViews(backEffect)
                end

                if front_finish then
                    for _,effect in ipairs(visible_list) do
                        if not tolua.isnull(effect) then --这里有可能在回调之前特效就被cleanup了所以要判空
                            effect:setVisible(true)
                        end
                    end
                end

            end)
        end
    end  
    
    -- play procedure effect
    local createBuffEffectView = function(effectID, effectIndex)
        if effectID ~= nil --[[and (not hasSameBuff or effectIndex > 1)]] then
            local effectConfig = QStaticDatabase.sharedDatabase():getEffectConfigByID(effectID)

            -- backward compatibility
            if QSkeletonActor.replaceSlotWithSkeletonAnimation3 == nil and effectConfig.replace and effectConfig.draw_original then
                effectConfig.offset_y = (effectConfig.offset_y or 0) + 14
                effectConfig.replace = nil
            end

            local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, self)
            local dummy = (QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID) or DUMMY.BODY)
            local isFlipWithActor = QStaticDatabase.sharedDatabase():getEffectIsFlipWithActorByID(effectID)
            local isGroundEffect = QStaticDatabase.sharedDatabase():getEffectIsLayOnTheGroundByID(effectID)
            local isDummyAsPosition = effectConfig.dummy_as_position and true
            if (dummy == DUMMY.BOTTOM or dummy == DUMMY.TOP or dummy == DUMMY.CENTER) and isGroundEffect then -- on the ground
                local actorScale = self:getModel():getActorScale()
                if frontEffect and frontEffect:getSkeletonView() ~= nil then
                    self:insertMutativeBuff(buff, frontEffect)

                    local skeletonPositionX, skeletonPositionY = frontEffect:getSkeletonView():getPosition()
                    if dummy == DUMMY.TOP then
                        if isFlipWithActor == true then
                            skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height / actorScale
                        else
                            skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height
                        end
                    elseif dummy == DUMMY.CENTER then
                        if isFlipWithActor == true then
                            skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height * 0.5 / actorScale
                        else
                            skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height * 0.5
                        end
                    end
                    frontEffect:getSkeletonView():setPosition(skeletonPositionX, skeletonPositionY)
                    app.scene:addEffectViews(frontEffect, {isGroundEffect = isGroundEffect})
                    frontEffect:setPosition(self:getPosition())
                    frontEffect:playAnimation(frontEffect:getPlayAnimationName(), true)
                    frontEffect:playSoundEffect(true)
                end
                if backEffect and backEffect:getSkeletonView() ~= nil then
                    self:insertMutativeBuff(buff, backEffect)

                    local skeletonPositionX, skeletonPositionY = backEffect:getSkeletonView():getPosition()
                    if dummy == DUMMY.TOP then
                        if isFlipWithActor == true then
                            skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height / actorScale
                        else
                            skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height
                        end
                    elseif dummy == DUMMY.CENTER then
                        if isFlipWithActor == true then
                            skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height * 0.5 / actorScale
                        else
                            skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height * 0.5
                        end
                    end
                    backEffect:getSkeletonView():setPosition(skeletonPositionX, skeletonPositionY)
                    app.scene:addEffectViews(backEffect, {isGroundEffect = isGroundEffect})
                    backEffect:setPosition(self:getPosition())
                    backEffect:playAnimation(backEffect:getPlayAnimationName(), true)
                end
            else
                if frontEffect ~= nil then
                    self:attachEffectToDummy(dummy, frontEffect, false, isFlipWithActor, effectConfig, self:getModel())
                    frontEffect:playAnimation(frontEffect:getPlayAnimationName(), true)
                    frontEffect:playSoundEffect(true)
                end
                if backEffect ~= nil then
                    self:attachEffectToDummy(dummy, backEffect, true, isFlipWithActor, effectConfig, self:getModel())
                    backEffect:playAnimation(backEffect:getPlayAnimationName(), true)
                end
            end
            table.insert(self._buffEffects, {obj = buff, front_effect = frontEffect, back_effect = backEffect, isGroundEffect = isGroundEffect or isDummyAsPosition, effectConfig = effectConfig, isFlipWithActor = isFlipWithActor})
            if hasBeginEffect then
                if frontEffect ~= nil then
                    table.insert(visible_list, frontEffect)
                    frontEffect:setVisible(false)
                end
                if backEffect ~= nil then
                    table.insert(visible_list, backEffect)
                    backEffect:setVisible(false)
                end
            end
        end
    end
    for i = 1, 2 do
        local effectID, effectIndex = nil, nil
        if i == 1 then
            effectID, effectIndex = buff:getEffectID()
        elseif i == 2 then
            effectID, effectIndex = buff:getEffectID2()
        end
        if nil ~= effectID then
            createBuffEffectView(effectID, effectIndex)
        end
    end

    if not hasSameBuff then
        local color = buff:getColor()
        if color ~= nil and not self:getModel():isCopyHero() then
            self._colorOverlay = color
            self:_pushBuffColor(buff, color)
            self._skeletonActor:runAction(CCTintTo:create(0.1, self._colorOverlay.r, self._colorOverlay.g, self._colorOverlay.b))
        end

        local gray = buff:getGray()
        if gray then
            makeNodeFromNormalToGrayStone(self._skeletonActor)
            local sprite = CCSprite:create("ui/stone.png")
            if sprite then
                sprite:setNodeIsAutoBatchNode(false)
                sprite:setPositionY(128)
                local func = ccBlendFunc()
                -- func.src = GL_SRC_ALPHA
                func.src = GL_ONE
                func.dst = GL_ONE_MINUS_SRC_ALPHA
                sprite:setBlendFunc(func)
                self:setBlendNode(sprite)
            end
        end
    end

    -- buff的文字提示
    if not buff:isNoTip() and event.is_remove ~= true then
        local tips = buff:getTips()
        for _, tip_word in ipairs(tips) do
            self:_showBuffTip(buff, tip_word)
        end
    end
end

function QBaseActorView:showRuneTip(trap, buff, all)
    local tip = nil
    local prefix = all and "全队" or ""
    if buff.effects.rage_value > 0 then
        tip = prefix .. "回复怒气"
    elseif buff.effects.attackspeed_chance or buff.effects.haste_rating then
        tip = prefix .. "攻速提升"
    elseif buff.effects.treat_damage_value > 0 then
        tip = prefix .. "恢复血量"
    end
    if tip then
        self:_showBuffTip(buff, tip)
    end
end

function QBaseActorView:_showBuffTip(buff, tip_word)
    local buff_caster = buff:getAttacker()
    local isHero = table.indexof(app.battle:getHeroes(), buff_caster, 1)
    local ccbOwner = {}
    local appearDistance = 20 -- 伤害数字向上移动出现的距离
    local tip = app.scene:getTip(isHero and "effects/Buff_red.ccbi" or "effects/Buff_blue.ccbi"):addTo(self)
    ccbOwner = tip.ccbOwner
    tip:setPosition(0, self:getSize().height - appearDistance)
    ccbOwner.var_text:setString(tip_word)

    -- local appearTime = 0.2 -- 冒伤害数字的时间
    -- local stayTimeScale = 0.9 -- 数字的停留时间
    -- local stayTimeDelay = 0.1 -- 数字的停留时间
    -- local elapseTime = 0.5 -- 伤害数字的消失时间

    -- 计算上一次伤害到这一次伤害数字冒出需要等待的时间，避免重复
    local wait = HIT_TIP_INTERVAL_MINIMUM - (app.battle:getTime() - self._lastBuffTipTime)

    local sequence = CCArray:create()

    if wait < 0 then
        wait = 0
    end
    self._waitingHitTips[tip] = tip
    self._lastBuffTipTime = app.battle:getTime() + wait

    tip:setVisible(false)

    sequence:addObject(CCDelayTime:create(wait))
    sequence:addObject(CCCallFunc:create(
    function ()
        tip:setVisible(true)
        local animationManager = tolua.cast(tip:getUserObject(), "CCBAnimationManager")
        animationManager:runAnimationsForSequenceNamed("Default Timeline")
        animationManager:connectScriptHandler(function(animationName)
            animationManager:disconnectScriptHandler()
            tip:removeFromParentAndCleanup(false)
            if tip.need_return then
                if app.scene then
                    app.scene:returnTip(tip)
                else
                    tip:release()
                end
            end
            self._waitingHitTips[tip] = nil
            -- CCRemoveSelf:create(true)
        end)
    end))
   
    tip:runAction(CCSequence:create(sequence))
end

function QBaseActorView:_onBuffTrigger(event)
    local buff = event.buff
    if buff == nil then
        return
    end

    if buff:isImmuned() or not buff:isAura() then
        return
    end

    local auraEffectID = buff:getAuraTargetEffectID()
    if auraEffectID ~= "" then
        local frontEffect, backEffect = QBaseEffectView.createEffectByID(auraEffectID, self)
        local dummy = (QStaticDatabase.sharedDatabase():getEffectDummyByID(auraEffectID) or DUMMY.BODY)
        local isFlipWithActor = QStaticDatabase.sharedDatabase():getEffectIsFlipWithActorByID(auraEffectID)
        if frontEffect ~= nil then
            self:insertMutativeBuff(buff, frontEffect)

            self:attachEffectToDummy(dummy, frontEffect, false, isFlipWithActor)
            frontEffect:playAnimation(frontEffect:getPlayAnimationName(), false)
            frontEffect:playSoundEffect(true)
            frontEffect:afterAnimationComplete(function()
                if dummy ~= nil then
                    if self.getSkeletonActor then
                        pcall(function() self:getSkeletonActor():detachNodeToBone(frontEffect) end)
                    end
                else
                    app.scene:removeEffectViews(frontEffect)
                end
            end)
        end
        if backEffect ~= nil then
            self:insertMutativeBuff(buff, backEffect)

            self:attachEffectToDummy(dummy, backEffect, true, isFlipWithActor)
            backEffect:playAnimation(backEffect:getPlayAnimationName(), false)
            backEffect:afterAnimationComplete(function()
                if dummy ~= nil then
                    if self.getSkeletonActor then
                        pcall(function() self:getSkeletonActor():detachNodeToBone(backEffect) end)
                    end
                else
                    app.scene:removeEffectViews(backEffect)
                end
            end)
        end
        table.insert(self._buffEffects, {obj = buff, front_effect = frontEffect, back_effect = backEffect})
    end

    if app.battle._battleVCR then
        app.battle._battleVCR:_onBuffTrigger(event, self._actor)
    end
end

function QBaseActorView:_onBuffEnded(event)
    local buff = event.buff
    if buff == nil then
        return
    end
    
    if buff:isImmuned() then
        return
    end

    if self._replaceAction.stub == buff:getId() then
        self:cleanReplaceStandardAction()
    end

    local hasSameBuff = false
    for _, old_buff in ipairs(self._actor._buffs) do
        if old_buff ~= buff and old_buff:getId() == buff:getId() then
            hasSameBuff = true
            break
        end
    end

    local removeEffecIds = {}
    for i, v in ipairs(self._buffEffects) do
        if v.obj == buff then
            if v.isGroundEffect then
                if v.front_effect ~= nil then
                    v.front_effect:stopSoundEffect()
                    app.scene:removeEffectViews(v.front_effect)
                end
                if v.back_effect ~= nil then
                    app.scene:removeEffectViews(v.back_effect)
                end
            else
                if v.front_effect ~= nil then
                    if v.front_effect.stopSoundEffect then
                        v.front_effect:stopSoundEffect()
                    end
                    if v.front_effect._dummy_as_position then
                        app.scene:removeEffectViews(v.front_effect)
                    else
                       self._skeletonActor:detachNodeToBone(v.front_effect)
                    end
                end
                if v.back_effect ~= nil and self._skeletonActor.detachNodeToBone then
                    self._skeletonActor:detachNodeToBone(v.back_effect)
                end
            end
            if v.effectConfig and v.effectConfig.replace then
                self._skeletonActor:removeReplaceSkeleton(self:_getReplaceBoneName(v.effectConfig, v.effectConfig.dummy))
            end
            -- table.remove(self._buffEffects, i)
            removeEffecIds[#removeEffecIds + 1] = i
        end
    end
    for i, v in ipairs(removeEffecIds) do
        table.remove(self._buffEffects, v)
    end

    if not hasSameBuff then
        local color = buff:getColor()
        if color ~= nil then
            local currentColor = self:_removeBuffColor(buff)
            if currentColor and not self:getModel():isCopyHero() then
                self._colorOverlay = currentColor
                self._skeletonActor:runAction(CCTintTo:create(0.1, self._colorOverlay.r, self._colorOverlay.g, self._colorOverlay.b))
            end
        end

        local gray = buff:getGray()
        if gray then
            makeNodeFromGrayToNormal(self._skeletonActor)
            self:setBlendNode(nil)
        end
    end

    -- play finish effect
    if not buff:isMuted() then
        local effectID = buff:getFinishEffectID()
        if effectID ~= nil and not hasSameBuff then
            local effectConfig = QStaticDatabase.sharedDatabase():getEffectConfigByID(effectID)
            local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, self)
            local dummy = (QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID) or DUMMY.BODY)
            local isFlipWithActor = QStaticDatabase.sharedDatabase():getEffectIsFlipWithActorByID(effectID)
            if frontEffect ~= nil then
                self:insertMutativeBuff(buff, frontEffect)

                self:attachEffectToDummy(dummy, frontEffect, false, isFlipWithActor, effectConfig)
                frontEffect:playAnimation(frontEffect:getPlayAnimationName(), false)
                frontEffect:playSoundEffect(false)
                frontEffect:afterAnimationComplete(function()
                    if dummy ~= nil and effectConfig.dummy_as_position == nil then
                        if self.getSkeletonActor then
                            if effectConfig.replace then
                                self._skeletonActor:removeReplaceSkeleton(self:_getReplaceBoneName(effectConfig, dummy))
                            end
                            pcall(function() self:getSkeletonActor():detachNodeToBone(frontEffect) end)
                        end
                    else
                        app.scene:removeEffectViews(frontEffect)
                    end
                end)
            end
            if backEffect ~= nil then
                self:insertMutativeBuff(buff, backEffect)

                self:attachEffectToDummy(dummy, backEffect, true, isFlipWithActor, effectConfig)
                backEffect:playAnimation(backEffect:getPlayAnimationName(), false)
                backEffect:afterAnimationComplete(function()
                    if dummy ~= nil and effectConfig.dummy_as_position == nil then
                        if self.getSkeletonActor then
                            if effectConfig.replace then
                                self._skeletonActor:removeReplaceSkeleton(self:_getReplaceBoneName(effectConfig, dummy))
                            end
                            pcall(function() self:getSkeletonActor():detachNodeToBone(backEffect) end)
                        end
                    else
                        app.scene:removeEffectViews(backEffect)
                    end
                end)
            end
        end
    end
end

function QBaseActorView:_onBuffMuted(event)
    local buff = event.buff
    if buff == nil then
        return
    end
    
    if buff:isImmuned() then
        return
    end

    local hasSameBuff = false
    for _, old_buff in ipairs(self._actor._buffs) do
        if old_buff ~= buff and old_buff:getId() == buff:getId() then
            hasSameBuff = true
            break
        end
    end

    for i, v in ipairs(self._buffEffects) do
        if v.obj == buff then
            if v.isGroundEffect then
                if v.front_effect ~= nil then
                    v.front_effect:stopSoundEffect()
                    app.scene:removeEffectViews(v.front_effect)
                end
                if v.back_effect ~= nil then
                    app.scene:removeEffectViews(v.back_effect)
                end
            else
                if v.front_effect ~= nil then
                    if v.front_effect.stopSoundEffect then
                        v.front_effect:stopSoundEffect()
                    end
                    self._skeletonActor:detachNodeToBone(v.front_effect)
                end
                if v.back_effect ~= nil and self._skeletonActor.detachNodeToBone then
                    self._skeletonActor:detachNodeToBone(v.back_effect)
                end
            end
            if v.effectConfig and v.effectConfig.replace then
                self._skeletonActor:removeReplaceSkeleton(self:_getReplaceBoneName(v.effectConfig, v.effectConfig.dummy))
            end
            table.remove(self._buffEffects, i)
            break
        end
    end

    if not hasSameBuff then
        local color = buff:getColor()
        if color ~= nil then
            local currentColor = self:_removeBuffColor(buff)
            if currentColor and not self:getModel():isCopyHero() then
                self._colorOverlay = currentColor
                self._skeletonActor:runAction(CCTintTo:create(0.1, self._colorOverlay.r, self._colorOverlay.g, self._colorOverlay.b))
            end
        end

        local gray = buff:getGray()
        if gray then
            makeNodeFromGrayToNormal(self._skeletonActor)
            self:setBlendNode(nil)
        end
    end
end

function QBaseActorView:_onMarkStarted(event)
    -- self:enableOutGlow("mark")
end

function QBaseActorView:_onMarkEnded(event)
    -- self:disableOutGlow("mark")
end

function QBaseActorView:_forceUpdateAnimation()
    local timeScale = self._skeletonActor:getAnimationScale()
    self._skeletonActor:setAnimationScale(1.0)
    self._skeletonActor:updateAnimation(0) -- force attached node reposition (in QSkeletonActor::skeletonAnimationDidUpdated)
    self._skeletonActor:setAnimationScale(timeScale)
end

function QBaseActorView:attachEffectToDummy(dummy, effectView, isBackSide, isFlipWithActor, effectConfig, attacker, attackee, isFumo)
    if effectView == nil then
        return
    end
    
    if effectConfig and effectConfig.replace then
        assert(dummy and dummy ~= DUMMY.BOTTOM and dummy ~= DUMMY.TOP and dummy ~= DUMMY.CENTER and effectConfig.dummy_as_position == nil, "")
        assert(not(effectConfig.file and effectConfig.file_back), "")
    end

    if app.battle:isInTutorial() and dummy == "dummy_body"
        and self._skeletonActor:isBoneExist(dummy) == false
            and effectView.getSkeletonView and effectView:getSkeletonView() ~= nil then
                dummy = DUMMY.TOP
                local skeletonPositionX, skeletonPositionY = effectView:getSkeletonView():getPosition()
                skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height
                effectView:getSkeletonView():setPosition(skeletonPositionX - 96 + math.random(0, 20), skeletonPositionY + 8 + math.random(0, 20))
                self._skeletonActor:attachNodeToBone(nil, effectView, isBackSide, isFlipWithActor)
                self:_forceUpdateAnimation()
                return
    end

    dummy = dummy or DUMMY.BOTTOM
    -- modiy for support flash translate to spine
    if effectView:getSkeletonView() and effectView:getSkeletonView().isFca ~= true and not isFumo then
        if dummy == DUMMY.BODY then
            dummy = DUMMY.CENTER
        elseif dummy == DUMMY.HEAD then
            dummy = DUMMY.TOP
        end
    end
    if dummy == DUMMY.BOTTOM or dummy == DUMMY.TOP or dummy == DUMMY.CENTER then
        local actorScale = self:getModel():getActorScale()
        if effectView:getSkeletonView() ~= nil then
            local skeletonPositionX, skeletonPositionY = effectView:getSkeletonView():getPosition()
            if effectView:isFcaEffect() == true and self:isFcaActor() ~= true then
                skeletonPositionX = skeletonPositionX * (0.21 / self:getModel():getActorScale())
                skeletonPositionY = skeletonPositionY * (0.21 / self:getModel():getActorScale())
            end 
            if dummy == DUMMY.TOP then
                if not self._skeletonActor.isFca and effectView:getSkeletonView().isFca and isFlipWithActor then
                    skeletonPositionY = -skeletonPositionY 
                end
                if isFlipWithActor == true then
                    skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height / actorScale
                else
                    skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height
                end
            elseif dummy == DUMMY.CENTER then
                if isFlipWithActor == true then
                    skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height * 0.5 / actorScale
                else
                    skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height * 0.5
                end
            end
            if effectConfig and effectConfig.dummy_as_position then
                effectView:setPosition(self:getPositionX(), self:getPositionY())
                effectView:getSkeletonView():setPosition(skeletonPositionX, skeletonPositionY)
                app.scene:addEffectViews(effectView, {isFrontEffect = not isBackSide, isGroundEffect = isBackSide})
                effectView:setActorView(self)
                if effectConfig.dummy_as_position == "attacker" and attacker then
                    if effectConfig.follow_actor then
                        effectView:setPositionActor(attacker)
                        effectView:setFollowActor(attacker)
                        if QStaticDatabase:sharedDatabase():getEffectIsFlipWithActorByID(effectConfig.id) then
                            effectView:setFollowScaleActor(attacker)
                            local view = app.scene:getActorViewFromModel(attacker)
                            if view and view._skeletonActor.isFca then
                                effectView:setSizeScale(view._skeletonActor:getRootScale(), attacker)
                            end
                        end
                    elseif attacker:isFlipX() then
                        effectView:getSkeletonView():setScaleX(-effectView:getSkeletonView():getScaleX())
                    end
                elseif effectConfig.dummy_as_position == "attackee" and attackee then
                    if effectConfig.follow_actor then
                        effectView:setPositionActor(attackee)
                        effectView:setFollowActor(attackee)
                        if QStaticDatabase:sharedDatabase():getEffectIsFlipWithActorByID(effectConfig.id) then
                            effectView:setFollowScaleActor(attackee)
                            local view = app.scene:getActorViewFromModel(attackee)
                            if view and view._skeletonActor.isFca then
                                effectView:setSizeScale(view._skeletonActor:getRootScale(), attackee)
                            end
                        end
                    elseif attackee:isFlipX() then
                        effectView:getSkeletonView():setScaleX(-effectView:getSkeletonView():getScaleX())
                    end
                end
            else
                -- modiy for support flash translate to spine
                -- 大部分flash都是放缩0.21倍
                local effectSkeletonView = effectView:getSkeletonView()
                if effectView:isFcaEffect() == true and self:isFcaActor() ~= true and isFlipWithActor then
                    if effectView:isCalcOffset() then
                        skeletonPositionY = skeletonPositionY /(0.21/self:getModel():getActorScale())
                    end
                    effectView:setScale(0.21/self:getModel():getActorScale())
                    effectView:setScaleX(-effectView:getScaleX())
                elseif effectView:isFcaEffect() ~= true and self:isFcaActor() == true then 
                    effectSkeletonView:setSkeletonScaleX(effectView:getConfigScale() / 0.21)
                    effectSkeletonView:setSkeletonScaleY(effectView:getConfigScale() / 0.21)
                elseif effectView:isFcaEffect() ~= true and self:isFcaActor() ~= true and not isFlipWithActor then
                    effectSkeletonView:setSkeletonScaleX(effectView:getConfigScale() / 0.21)
                    effectSkeletonView:setSkeletonScaleY(effectView:getConfigScale() / 0.21)
                end
                effectSkeletonView:setPosition(skeletonPositionX, skeletonPositionY)
                self._skeletonActor:attachNodeToBone(nil, effectView, isBackSide, isFlipWithActor)
                self:_forceUpdateAnimation()
            end
        end
    else
        if self._skeletonActor:isBoneExist(dummy) == false then
            if self._skeletonActor.isFca then
                return
            end
            if app.battle:isInTutorial() then
                return
            end
            local errmsg = "Bone node not found: <" .. dummy .. "> does not exist in the bone provided by <" .. self._actor:getActorID() .. "> (character_display) provides. The effect is <" .. effectView._effectID .. ".".. effectView._frontAndBack .. ">"
            QLogFile:error(errmsg)
            if DEBUG > 0 then
                assert(false, errmsg)
            end
        end
        if effectConfig and effectConfig.dummy_as_position then
            effectView:setPosition(self:getPositionX(), self:getPositionY())
            local bone_position = self:getBonePosition(dummy)
            effectView:getSkeletonView():setPosition(bone_position.x, bone_position.y)
            app.scene:addEffectViews(effectView, {isFrontEffect = not isBackSide, isGroundEffect = isBackSide})
            effectView:setActorView(self)
            if effectConfig.dummy_as_position == "attacker" and attacker then
                if effectConfig.follow_actor then
                    effectView:setPositionActor(attacker)
                    effectView:setFollowActor(attacker)
                    if QStaticDatabase:sharedDatabase():getEffectIsFlipWithActorByID(effectConfig.id) then
                        effectView:setFollowScaleActor(attacker)
                        local view = app.scene:getActorViewFromModel(attacker)
                        if view and view._skeletonActor.isFca then
                            effectView:setSizeScale(view._skeletonActor:getRootScale(), attacker)
                        end
                    end
                elseif attacker:isFlipX() then
                    effectView:getSkeletonView():setScaleX(-effectView:getSkeletonView():getScaleX())
                end

            elseif effectConfig.dummy_as_position == "attackee" and attackee then
                if effectConfig.follow_actor_position then
                    effectView:setPositionActor(attackee)
                    effectView:setFollowActor(attackee)
                    if QStaticDatabase:sharedDatabase():getEffectIsFlipWithActorByID(effectConfig.id) then
                        effectView:setFollowScaleActor(attackee)
                        local view = app.scene:getActorViewFromModel(attackee)
                        if view and view._skeletonActor.isFca then
                            effectView:setSizeScale(view._skeletonActor:getRootScale(), attackee)
                        end
                    end
                elseif attackee:isFlipX() then
                    effectView:getSkeletonView():setScaleX(-effectView:getSkeletonView():getScaleX())
                end
            end
        elseif effectConfig and effectConfig.replace then
            if self._skeletonActor.replaceSlotWithSkeletonAnimation3 then
                local hue = math.floor(((effectConfig.hue or 0) + 180) / 360 * 255)
                local saturation = ((effectConfig.saturation or 0) + 1) / 2 * 255
                local intensity = ((effectConfig.intensity or 0) + 1) / 2 * 255
                self._skeletonActor:replaceSlotWithSkeletonAnimation3(effectView:getSkeletonView(), self:_getReplaceBoneName(effectConfig, dummy), ROOT_BONE, "animation", 
                                                                    effectConfig.offset_x or 0, effectConfig.offset_y or 0, effectConfig.scale or 1.0, effectConfig.rotation or 0.0,
                                                                    effectConfig.is_hsi_enabled or false, ccc4(hue, saturation, intensity, 0), effectConfig.draw_original or false)
            elseif self._skeletonActor.replaceSlotWithSkeletonAnimation2 then
                local hue = math.floor(((effectConfig.hue or 0) + 180) / 360 * 255)
                local saturation = ((effectConfig.saturation or 0) + 1) / 2 * 255
                local intensity = ((effectConfig.intensity or 0) + 1) / 2 * 255
                self._skeletonActor:replaceSlotWithSkeletonAnimation2(effectView:getSkeletonView(), self:_getReplaceBoneName(effectConfig, dummy), ROOT_BONE, "animation", 
                                                                    effectConfig.offset_x or 0, effectConfig.offset_y or 0, effectConfig.scale or 1.0, effectConfig.rotation or 0.0,
                                                                    effectConfig.is_hsi_enabled or false, ccc4(hue, saturation, intensity, 0))
            else
                self._skeletonActor:replaceSlotWithSkeletonAnimation(effectView:getSkeletonView(), self:_getReplaceBoneName(effectConfig, dummy), ROOT_BONE, "animation")
            end
            self:_retainReplaceEffect(effectView)
        else
            self._skeletonActor:attachNodeToBone(dummy, effectView, isBackSide, isFlipWithActor)
            self:_forceUpdateAnimation()
        end
    end

end

function QBaseActorView:_playVictoryEffect()
    local effectId = self:getModel():getVictoryEffect()
    if effectId ~= nil and string.len(effectId) > 0 then
        local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectId, self)
        local dummy = (QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID) or DUMMY.CENTER)
        local isFlipWithActor = QStaticDatabase.sharedDatabase():getEffectIsFlipWithActorByID(effectID)
        if frontEffect ~= nil then
            self:attachEffectToDummy(dummy, frontEffect, false, isFlipWithActor)
            frontEffect:playAnimation(frontEffect:getPlayAnimationName(), false)
            frontEffect:afterAnimationComplete(function()
                if dummy ~= nil then
                    if self.getSkeletonActor then
                        pcall(function() self:getSkeletonActor():detachNodeToBone(frontEffect) end)
                    end
                else
                    app.scene:removeEffectViews(frontEffect)
                end
            end)
        end
        if backEffect ~= nil then
            self:attachEffectToDummy(dummy, backEffect, true, isFlipWithActor)
            backEffect:playAnimation(backEffect:getPlayAnimationName(), false)
            backEffect:afterAnimationComplete(function()
                if dummy ~= nil then
                    if self.getSkeletonActor then
                        pcall(function() self:getSkeletonActor():detachNodeToBone(backEffect) end)
                    end
                else
                    app.scene:removeEffectViews(backEffect)
                end
            end)
        end
    end
end

function QBaseActorView:_playDeadEffect()
    local effectId = self:getModel():getDeadEffect()
    if effectId ~= nil and string.len(effectId) > 0 then
        local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectId, self)
        local dummy = (QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID) or DUMMY.CENTER)
        local isFlipWithActor = QStaticDatabase.sharedDatabase():getEffectIsFlipWithActorByID(effectID)
        if frontEffect ~= nil then
            self:attachEffectToDummy(dummy, frontEffect, false, isFlipWithActor)
            frontEffect:playAnimation(frontEffect:getPlayAnimationName(), false)
            frontEffect:afterAnimationComplete(function()
                if dummy ~= nil then
                    if self.getSkeletonActor then
                        pcall(function() self:getSkeletonActor():detachNodeToBone(frontEffect) end)
                    end
                else
                    app.scene:removeEffectViews(frontEffect)
                end
            end)
        end
        if backEffect ~= nil then
            self:attachEffectToDummy(dummy, backEffect, true, isFlipWithActor)
            backEffect:playAnimation(backEffect:getPlayAnimationName(), false)
            backEffect:afterAnimationComplete(function()
                if dummy ~= nil then
                    if self.getSkeletonActor then
                        pcall(function() self:getSkeletonActor():detachNodeToBone(backEffect) end)
                    end
                else
                    app.scene:removeEffectViews(backEffect)
                end
            end)
        end
    end
end

function QBaseActorView:pauseSoundEffect()
    for _, effect in ipairs(self._buffEffects) do
        if effect.front_effect and effect.front_effect.pauseSoundEffect then effect.front_effect:pauseSoundEffect() end
        if effect.back_effect and effect.back_effect.pauseSoundEffect then effect.back_effect:pauseSoundEffect() end
    end
    for _, skill in pairs(self._skillAttackEffects) do
        for _, effect in ipairs(skill) do
            if effect.pauseSoundEffect then effect:pauseSoundEffect() end
        end
    end
    for _, effect in ipairs(self._skillLoopEffects) do
        if effect.effect and effect.effect.pauseSoundEffect then effect.effect:pauseSoundEffect() end
    end
end

function QBaseActorView:resumeSoundEffect()
    for _, effect in ipairs(self._buffEffects) do
        if effect.front_effect and effect.front_effect.resumeSoundEffect then effect.front_effect:resumeSoundEffect() end
        if effect.back_effect and effect.back_effect.resumeSoundEffect then effect.back_effect:resumeSoundEffect() end
    end
    for _, skill in pairs(self._skillAttackEffects) do
        for _, effect in ipairs(skill) do
            if effect.resumeSoundEffect then effect:resumeSoundEffect() end
        end
    end
    for _, effect in ipairs(self._skillLoopEffects) do
        if effect.effect and effect.effect.resumeSoundEffect then effect.effect:resumeSoundEffect() end
    end
end

function QBaseActorView:setAnimationScale(scale, reason)
	if reason == nil then
        self._skeletonActor:setAnimationScale(scale)

        if app.battle._battleVCR then
            app.battle._battleVCR:_onChangeAnimationScale(self._actor, scale)
        end

	else
		if scale == 1.0 then
			self._scales[reason] = nil
		else
			self._scales[reason] = scale
		end
		local final_scale = 1.0
		for _, v in pairs(self._scales) do
			final_scale = final_scale * v
		end
	    self._skeletonActor:setAnimationScale(final_scale)

        local currentSkill = self._actor:getCurrentSkill()
        if currentSkill and self._skillAttackEffects[currentSkill:getId()] then
            for _, effect in pairs(self._skillAttackEffects[currentSkill:getId()]) do
                if tolua.isnull(effect) then
                    effect:getSkeletonView():setAnimationScale(final_scale)
                end
            end
        end

        if app.battle._battleVCR then
            local time_gear = self._scales["time_gear"]
            if time_gear then
                final_scale = final_scale / time_gear
            end
            app.battle._battleVCR:_onChangeAnimationScale(self._actor, final_scale)
        end
	end
end

function QBaseActorView:jumpAnimationTime(totime)
    if self._skeletonActor.jumpTime then
        self._skeletonActor:jumpTime(totime)
    end
end

function QBaseActorView:pauseAnimation()
    self._skeletonActor:pauseAnimation()
end

function QBaseActorView:resumeAnimation()
    self._skeletonActor:resumeAnimation()
end

function QBaseActorView:startSprint()
    self._sprintOn = true
end

function QBaseActorView:endSprint()
    self._sprintOn = false
end

function QBaseActorView:_updateSprint(dt)
    if self._shadow == nil then
        self._shadow = {}
    end

    if self._shadowNode == nil then
        self._shadowNode = CCNode:create()
        app.scene:addChild(self._shadowNode)
    end

    local actor = self._actor
    -- 更新拖影的前端
    if self._sprintOn then
        local shadow = self._shadow
        local lastFront = shadow[#shadow]
        local height = 60
        local currentPos = actor:getPosition()
        local scene = self:getParent()
        local parent = self._shadowNode:getParent()
        local currentPos = parent:convertToNodeSpace(scene:convertToWorldSpace(ccp(currentPos.x, currentPos.y)))
        local width = lastFront == nil and 0 or math.abs(lastFront.pos.x - currentPos.x)

        if lastFront == nil then
            local node = CCNode:create()
            node:retain()
            node:setPosition(currentPos.x, currentPos.y)
            self._shadowNode:addChild(node)
            local pos = currentPos
            local time = q.time()
            local newFront = 
            {
                node = node,
                pos = pos,
                time = time,
            }
            table.insert(self._shadow, newFront)

        elseif lastFront and lastFront.pos.x ~= currentPos.x then
            local unit_width = 5
            local tan = (lastFront.pos.y - currentPos.y) / (lastFront.pos.x - currentPos.x)
            local skewY = math.deg(math.atan2(lastFront.pos.y - currentPos.y, lastFront.pos.x - currentPos.x))
            local startx = lastFront.pos.x
            local starty = lastFront.pos.y
            local currentTime = q.time()
            local lastTime = lastFront.time
            while width > unit_width do
                local thiswidth = math.min(unit_width, width)
                local node = CCLayerColor:create(ccc4(255, 255, 255, 64))
                node:retain()
                node:setContentSize(CCSize(thiswidth, height))
                if lastFront.pos.x > currentPos.x then
                    node:setAnchorPoint(ccp(0, 0.5))
                    node:setSkewY(skewY)
                    startx = startx - thiswidth
                    starty = starty + tan * (-thiswidth)
                    node:setPosition(startx, starty + 80 - height)
                else
                    node:setAnchorPoint(ccp(1.0, 0.5))
                    node:setSkewY(skewY)
                    startx = startx + thiswidth
                    starty = starty + tan * (thiswidth)
                    node:setPosition(startx, starty + 80 - height)
                end
                self._shadowNode:addChild(node)
                local pos = currentPos

                local newFront = 
                {
                    node = node,
                    pos = {x = startx, y = starty},
                    time = lastTime + (currentTime - lastTime) * (math.abs(startx - lastFront.pos.x) / math.abs(currentPos.x - lastFront.pos.x)),
                }
                table.insert(self._shadow, newFront)

                width = width - thiswidth
            end
        end
    end

    -- 更新拖影的后端
    local currentTime = q.time()
    local deleteCount = 0
    for i, ex in ipairs(self._shadow) do
        local node = ex.node
        local pos = ex.pos
        local time = ex.time

        local coefficient = (0.5 - (currentTime - time)) / 0.5
        -- coefficient = 1
        if coefficient > 0 then
            node:setOpacity(64 * coefficient)
        else
            node:removeFromParent()
            node:release()
            deleteCount = i
        end
    end
    local shadow = self._shadow
    local newShadow = {}
    for i = deleteCount + 1, #shadow do
        table.insert(newShadow, shadow[i])
    end
    self._shadow = newShadow
end

function QBaseActorView:setScissorEnabled(enabled)
    if self._skeletonActor.setScissorEnabled then
        self._skeletonActor:setScissorEnabled(enabled)
    end
end

function QBaseActorView:setScissorRects(mask1, grad1, grad2, mask2)
    if self._skeletonActor.setScissorRects then
        self._skeletonActor:setScissorRects(mask1, grad1, grad2, mask2)
    end
end

function QBaseActorView:setOpacityActor(opacity)
    if self._skeletonActor.setOpacityActor then
        self._skeletonActor:setOpacityActor(opacity)
    end
end

function QBaseActorView:setScissorBlendFunc(func)
    if self._skeletonActor.setScissorBlendFunc then
        self._skeletonActor:setScissorBlendFunc(func)
    end
end

function QBaseActorView:setScissorColor(color)
    if self._skeletonActor.setScissorColor then
        self._skeletonActor:setScissorColor(color)
    end
end

function QBaseActorView:setScissorOpacity(opacity)
    if self._skeletonActor.setScissorOpacity then
        self._skeletonActor:setScissorOpacity(opacity)
    end
end

function QBaseActorView:setRenderTextureBlendFunc(func)
    if self._skeletonActor.setRenderTextureBlendFunc then
        self._skeletonActor:setRenderTextureBlendFunc(func)
    end
end

function QBaseActorView:reloadSkeleton()
    if self:getModel():isCopyHero() then return end
    if self._skeletonActor and not self._skeletonActor.isFca then
        self._skeletonActor:reloadWithFile(self._actor:getActorFile())
        local scale, _ = self._actor:getActorScale()
        self._skeletonActor:setSkeletonScaleX(scale)
        self._skeletonActor:setSkeletonScaleY(scale)
    end
end

function QBaseActorView:getBonePosition(dummy)
    if dummy == DUMMY.BOTTOM or dummy == DUMMY.TOP or dummy == DUMMY.CENTER then
        local actorScale = self:getModel():getActorScale()
        local skeletonPositionX, skeletonPositionY = 0, 0
        if dummy == DUMMY.TOP then
            if isFlipWithActor == true then
                skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height / actorScale
            else
                skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height
            end
        elseif dummy == DUMMY.CENTER then
            if isFlipWithActor == true then
                skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height * 0.5 / actorScale
            else
                skeletonPositionY = skeletonPositionY + self:getModel():getRect().size.height * 0.5
            end
        end
        return ccp(skeletonPositionX, skeletonPositionY)
    else
        return self:getSkeletonActor():getBonePosition(dummy)
    end
end

function QBaseActorView:enableOutGlow(reason)
    local hadGlow = next(self._outGlows)
    self._outGlows[reason] = reason
    if not hadGlow and reason then
        -- self:setScissorRects(
        --     CCRect(0, 0, 0, 0),
        --     CCRect(0, 0, 0, 0),
        --     CCRect(0, 0, 0, 0),
        --     CCRect(0, 0, 0, 0)
        -- )
        -- self:setScissorEnabled(true)
        -- self:getSkeletonActor():getRenderTextureSprite():setShaderProgram(qShader.Q_ProgramPositionTextureColorOutline)
        -- local func = ccBlendFunc()
        -- func.src = GL_SRC_ALPHA
        -- func.dst = GL_ONE_MINUS_SRC_ALPHA
        -- self:getSkeletonActor():getRenderTextureSprite():setBlendFunc(func)


        -- local dummyNode = display.newNode()
        -- local dummy = QDummyNode:create(self:getSkeletonActor())
        -- local scale = 1.15
        -- dummy:setScale(scale)
        -- dummy:setPositionY(0 - self:getSize().height * (scale - 1.0) * 0.5)
        -- dummyNode:addChild(dummy)

        -- local container = display.newNode()
        -- self:addChild(container, -1)

        -- local layerLength = 768

        -- local layer = CCLayerColor:create(ccc4(255, 255, 255, 0), layerLength, layerLength)
        -- layer:setPosition(-layerLength/2, -layerLength/4)
        -- local func = ccBlendFunc()
        -- func.src = GL_ONE
        -- func.dst = GL_ZERO
        -- layer:setBlendFunc(func)
        -- container:addChild(layer, -1)

        -- if self:getSkeletonActor().getSkeletonAnimation then
        --     local func = ccBlendFunc()
        --     func.src = GL_SRC_ALPHA
        --     func.dst = GL_ONE_MINUS_SRC_ALPHA
        --     self:getSkeletonActor():getSkeletonAnimation():setBlendFunc(func)
        -- end
        -- container:addChild(dummyNode)

        -- local layer = CCLayerColor:create(ccc4(0.937255 * 255, 0.843137 * 255, 0, 255), layerLength, layerLength)
        -- layer:setPosition(-layerLength/2, -layerLength/4)
        -- local func = ccBlendFunc()
        -- func.src = GL_DST_ALPHA
        -- func.dst = GL_ONE_MINUS_DST_ALPHA
        -- layer:setBlendFunc(func)
        -- container:addChild(layer, 1)

        -- local layer = CCLayerColor:create(ccc4(0, 0, 0, 255), layerLength, layerLength)
        -- layer:setPosition(-layerLength/2, -layerLength/4)
        -- local func = ccBlendFunc()
        -- func.src = GL_ONE
        -- func.dst = GL_ONE
        -- layer:setBlendFunc(func)
        -- container:addChild(layer, 1)

        -- container:retain()
        -- self._outGlowContainer = container


        local layerLength = 1500
        local scale = 1.15

        local skeletonActor = self:getSkeletonActor()
        local dummy = QDummyNode:create(skeletonActor:getNode())
        dummy:setScale(scale)
        dummy:setPositionY(0 - self:getSize().height * (scale - 1.0) * 0.5)
        local clip = CCClippingNode:create(dummy)
        clip:setAlphaThreshold(0.8)
        local layer = CCLayerColor:create(ccc4(0.937255 * 255, 0.843137 * 255, 0, 255), layerLength, layerLength)
        layer:setPosition(-layerLength/2, -layerLength/4)
        clip:addChild(layer)

        -- 由于dummy并不是skeletonActor的父节点，因此CCClippingNode无法通过遍历设置alpha test shader，这里要手动设置
        local shader = CCShaderCache:sharedShaderCache():programForKey(qShader.kCCShader_PositionTextureColorAlphaTest)
        traverseNode(skeletonActor, function(node)
            local program = node:getShaderProgram()
            node:setShaderProgram(shader)
            q.setNodePreviousShader(node, program)
        end)

        self:addChild(clip, -1)
        clip:retain()
        self._outGlowClip = clip
    end
end

function QBaseActorView:disableOutGlow(reason)
    local hadGlow = next(self._outGlows)
    self._outGlows[reason] = nil
    if hadGlow and next(self._outGlows) == nil then
        -- self:setScissorEnabled(false)
        -- self:getSkeletonActor():getRenderTextureSprite():setShaderProgram(qShader.CC_ProgramPositionTextureColor)
        -- local func = ccBlendFunc()
        -- func.src = GL_ONE
        -- func.dst = GL_ONE_MINUS_SRC_ALPHA
        -- self:getSkeletonActor():getRenderTextureSprite():setBlendFunc(func)
        -- self._skeletonActor:setColor(ccc3(self._colorOverlay.r, self._colorOverlay.g, self._colorOverlay.b))

        -- self._outGlowContainer:removeFromParentAndCleanup()
        -- self._outGlowContainer:release()
        -- self._outGlowContainer = nil
        
        self._outGlowClip:removeFromParentAndCleanup()
        self._outGlowClip:release()
        self._outGlowClip = nil

        local skeletonActor = self:getSkeletonActor()
        -- local shader = CCShaderCache:sharedShaderCache():programForKey(qShader.kCCShader_PositionTextureColor)
        traverseNode(skeletonActor, function(node)
            local shader = q.getNodePreviousShader(node)
            if nil ~= shader then
                node:setShaderProgram(shader)
            end
        end)
    end
end

function QBaseActorView:enableSelectable(selected)
    if not selected then
        self:disableSelectable()
        do return end

        -- if self._enableSeletable then
        --     self:getSkeletonActor():getRenderTextureSprite():setShaderProgram(qShader.Q_ProgramPositionTextureColorOutlineWeak)
        --     return
        -- end

        -- self:setScissorRects(
        --     CCRect(0, 0, 0, 0),
        --     CCRect(0, 0, 0, 0),
        --     CCRect(0, 0, 0, 0),
        --     CCRect(0, 0, 0, 0)
        -- )
        -- self:setScissorEnabled(true)
        -- self:getSkeletonActor():getRenderTextureSprite():setShaderProgram(qShader.Q_ProgramPositionTextureColorOutlineWeak)
        -- local func = ccBlendFunc()
        -- func.src = GL_SRC_ALPHA
        -- func.dst = GL_ONE_MINUS_SRC_ALPHA
        -- self:getSkeletonActor():getRenderTextureSprite():setBlendFunc(func)

        -- self._enableSeletable = true
    else
        if self._enableSeletable then
            -- self:getSkeletonActor():getRenderTextureSprite():setShaderProgram(qShader.Q_ProgramPositionTextureColorOutline)
            return
        end

        self:enableOutGlow("selected")
        -- self:setGlowColor(ccc4(255 * 0.625, 200 * 0.625, 0, 192))

        self._enableSeletable = true
    end
end

function QBaseActorView:disableSelectable()
    if not self._enableSeletable then
        return
    end

    self:disableOutGlow("selected")
    -- self:setGlowColor(nil)

    self._enableSeletable = false
end

-- 打开stencil方式渲染，角色作为stencile去模刻印toppingNode，角色本身作为topping还会再绘制一次
function QBaseActorView:enableClipping(toppingNode, zOrder)
    if self._toppingRootNode == nil then
        self._toppingRootNode = display.newNode()
        self._skeletonActor:enableClipping(self._toppingRootNode, 0)
    end
    if self._toppingRootNode:getParent() == nil then
        self._skeletonActor:enableClipping(self._toppingRootNode, 0)
    end
    if toppingNode then
        local root = self._toppingRootNode
        root:addChild(toppingNode, zOrder)
    end
end

function QBaseActorView:disableClipping(toppingNode)
    if self._toppingRootNode then
        local root = self._toppingRootNode
        if toppingNode:getParent() == root then
            toppingNode:removeFromParent()
            if root:getChildrenCount() == 0 then
                self._skeletonActor:disableClipping()
                self._toppingRootNode = nil
            end
        end
    end
end

function QBaseActorView:setGlowColor(color)
    if self._skeletonActor.isFca then
        if color then
            self._isGlow = true
            self._skeletonActor:setColor(ccc3(255 * 0.6,255 * 0.6,255 * 0.6))
            self._skeletonActor:stopSetColorOffset(true)
            self._skeletonActor:setColorOffset(ccc4f(153/255, 153/255, 0, 0))
            -- setNodeShaderProgram(self._skeletonActor, qShader.Q_ProgramGlow)
        else
            self._isGlow = false
            self._skeletonActor:setColorOffset(ccc4f(0, 0, 0, 0))
            self._skeletonActor:stopSetColorOffset(false)
            -- setNodeShaderProgram(self._skeletonActor, qShader.CC_ProgramPositionTextureColor)
        end
        return
    end

    if color == nil then
        if self._glowColor then
            self:disableClipping(self._glowColor)
            self._glowColor = nil
        end
    else
        if self._glowColor == nil then
            local glow = CCLayerColor:create(color, 512, 512)
            local func = ccBlendFunc()
            func.src = GL_DST_ALPHA
            func.dst = GL_DST_ALPHA -- GL_SRC_ALPHA GL_DST_ALPHA GL_ONE
            -- func.src = GL_SRC_ALPHA
            -- func.dst = GL_ONE
            glow:setBlendFunc(func)
            glow:setPositionX(-256)
            glow:setPositionY(-128)
            self:enableClipping(glow, 1)
            self._glowColor = glow
        else
            self._glowColor:setColor(ccc3(color.r, color.g, color.b))
            self._glowColor:setOpacity(color.a)
        end
    end
end

function QBaseActorView:setBlendNode(node)
    do return end
    if self._skeletonActor.isFca then
        -- todo fca需要支持石头渲染
        return
    end

    if node == nil then
        if self._blendNode then
            self:disableClipping(self._blendNode)
            self._blendNode = nil
        end
    else
        if self._blendNode then
            self:disableClipping(self._blendNode)
        end
        self:enableClipping(node, 0)
        self._blendNode = node
    end
end

function QBaseActorView:setSizeScale(scale, reason)
    if not reason then
        self:setScale(scale)
    else
        if scale == 1 then
            scale = nil
        end
        self._sizeScales[reason] = scale
        local result_scale = 1
        for _, sub_scale in pairs(self._sizeScales) do
            result_scale = result_scale * sub_scale
        end
        self:setScale(result_scale)
    end
    self._hpView:setPosition(0, self:getSize().height * self:getScaleY())
end

function QBaseActorView:getSizeScale( reason )
    return self._sizeScales[reason] or 1
end

function QBaseActorView:_onSpeak(event)
    table.insert(self._bullshits, {string = event.bullshit,
        duration = event.duration or 3,type = event.type,
        offset = event.offset or {x = 0, y = 0}, scale = event.scale or 0})
end

function QBaseActorView:_popSpeak(bullshit, offset, scale, type, duration)
    if self._bullshitNode == nil then
        self._bullshitNode = QChatDialog.new()
        self._bullshitNode:setInfo({useRichText = true})
        self._bullshitRoot:addChild(self._bullshitNode)
    end
    self._bullshitNode:setScale(scale+1)
    self._bullshitNode:setString(bullshit)

    if tonumber(type) == 1 then
        self._bullshitNode:setDuration(duration)
    end
    
    function self._bullshitUpdate(isUp)
        if isUp then
            self._bullshitNode:setScaleY(1)
            q.setScreenPosition(self._bullshitRoot, self, {x = offset.x, y = self:getSize().height + offset.y})
        else
            self._bullshitNode:setScaleY(-1)
            q.setScreenPosition(self._bullshitRoot, self, {x = offset.x, y = offset.y})
        end
    end
end

function QBaseActorView:_updateSpeak(dt)
    if self._bullshitNode ~= nil and self._bullshitCD == 0 then
        self._bullshitNode:removeFromParent()
        self._bullshitNode = nil
        self._bullshitUpdate = nil
    end

    local bullshits = self._bullshits
    if #bullshits > 0 then
        if self._bullshitCD == 0 then
            local bullshit = bullshits[1]
            table.remove(bullshits, 1)
            if bullshit.type == 1 then
                self:_popSpeak(bullshit.string, bullshit.offset, bullshit.scale, bullshit.type, bullshit.duration)
                self._bullshitCD = bullshit.duration
            elseif bullshit.type == 2 then
                app.scene:speakWarning(bullshit.string)
            end
        end
    end


    if self._bullshitCD > 0 then
        self._bullshitCD = math.max(0, self._bullshitCD - dt)
    end

    if self._bullshitUpdate then
        self._bullshitUpdate(true--[[self:getPositionY() < BATTLE_AREA.top - 150]])
    end
end

function QBaseActorView:_onTriggerShowCCB(event)
    local ccbOwner = {}
    local ccbView = CCBuilderReaderLoad(event.ccb, CCBProxy:create(), ccbOwner)
    
    self._bullshitRoot:addChild(ccbView)
    q.setScreenPosition(self._bullshitRoot, self, {x = -15, y = self:getSize().height})
    ccbView:retain()
    table.insert(self._ccbList,{view = ccbView,duration = event.ccbDuration})
    if event.animation then
        local animationManager = tolua.cast(ccbView:getUserObject(), "CCBAnimationManager")
        animationManager:runAnimationsForSequenceNamed(event.animation)
    end
end

function QBaseActorView:_updateCCB(dt)
    for k,v in pairs(self._ccbList) do
        v.duration = v.duration - dt
        if v.duration <= 0 then
            v.view:removeFromParentAndCleanup()
            v.view:release()
            self._ccbList[k] = nil
        end
    end
end

function QBaseActorView:_updateMutativeBuffEffect()
    if self._skeletonActor:getAnimationScale() == 0 then
        return
    end
    for effect, buff in pairs(self._mutativeRadiusBuff) do
        if not tolua.isnull(effect) then
            local scaleX = effect:getSkeletonView():getScaleX()
            if scaleX < 0 then
                effect:getSkeletonView():setScaleX(scaleX - buff:getAuraScaleByTimeEffect())
            else
                effect:getSkeletonView():setScaleX(scaleX + buff:getAuraScaleByTimeEffect())
            end
            local scaleY = effect:getSkeletonView():getScaleY()
            if scaleY < 0 then
                effect:getSkeletonView():setScaleY(scaleY - buff:getAuraScaleByTimeEffect())
            else
                effect:getSkeletonView():setScaleY(scaleY + buff:getAuraScaleByTimeEffect())
            end
        end
    end
end

function QBaseActorView:_updateFuncMark(dt)
    local duration = self._funcMarkEffectDuration
    if self._funcMarkEffect and duration then
        if not app.battle:isActorAppearing(self._actor) then
            duration = duration - dt
            if duration <= 0 then
                self:displayFuncMark(nil)
            else
                self._funcMarkEffectDuration = duration
                self._funcMarkEffect:setVisible(true)
            end
        end
    end
end

function QBaseActorView:_clearBullshits()
    self._bullshits = {}
    if self._bullshitNode then
        self._bullshitNode:removeFromParent()
        self._bullshitNode = nil
        self._bullshitUpdate = nil
    end
end

function QBaseActorView:_onSkeletonActorAnimationUpdateEvent(eventType)
    if eventType == 1 then
        self._actor:onAnimationWillUpdate(self)
    elseif eventType == 2 then
        self._actor:onAnimationDidUpdatedBeforeWorldTransform(self)
    end
end

function QBaseActorView:getRootBonePosition()
    if self._skeletonActor.getRootBonePosition == nil then
        return {x = 0, y = 0}
    end
    return self._skeletonActor:getRootBonePosition()
end

function QBaseActorView:setRootBonePosition(p)
    if self._skeletonActor.setRootBonePosition == nil then
        return
    end
    self._skeletonActor:setRootBonePosition(ccp(p.x, p.y))
end

function QBaseActorView:displayFuncMark(effect_file, time)
    if self._funcMarkEffect then
        self._funcMarkEffect:stopAnimation()
        self._funcMarkEffect:removeFromParentAndCleanup()
        self._funcMarkEffect:release()
        self._funcMarkEffect = nil
        self._funcMarkEffectDuration = time
    end

    if effect_file == nil then
        return
    end

    local effect = QBaseEffectView.new(effect_file)
    if effect then
        self:addChild(effect)
        effect:retain()
        self._funcMarkEffect = effect
        effect:setPositionY(self:getSize().height + 30)
        effect:playAnimation(effect:getPlayAnimationName(), true)
        self._funcMarkEffectDuration = time
        self._funcMarkEffect:setVisible(not app.battle:isActorAppearing(self._actor))
    end
end

function QBaseActorView:_processAdditionalEffects()
    if not ENABLE_ENCHANT_EFFECT then
        return
    end
    
    local effects = string.split(self._actor:getAdditionalEffects(), ";")
    for _, effectID in ipairs(effects) do
        if effectID ~= "" then
            self:_onPlayEffectForSkill({effectID = effectID, options = {skillId = -1, isLoop = true}})
        end
    end

    local staticDatabase = QStaticDatabase:sharedDatabase()
    -- get weapon enchant level
    local heroInfo = self:getModel()._actorProp._heroInfo
    local actorInfo = staticDatabase:getCharacterByID(self:getModel():getActorID())
    local talent = actorInfo.talent
    local skin_info = self:getModel():getSkinInfo()
    local enchant_components = actorInfo.enchant_components
    local enchant_effect = actorInfo.enchant_effect
    if skin_info and not self:getModel():getReplaceCharacterId() then
        if skin_info.skins_enchant_effect then
            enchant_effect = skin_info.skins_enchant_effect
            enchant_components = nil
        elseif skin_info.skins_enchant_components then
            enchant_components = skin_info.skins_enchant_components
            enchant_effect = nil
        end
    end
    if talent then
        local enchant_effects = {}
        local breakConfig = staticDatabase:getBreakthroughByTalent(talent)
        local weaponEquipment = nil
        for _, breakInfo in pairs(breakConfig or {}) do
            for _, equipment in ipairs(heroInfo.equipments or {}) do
                if breakInfo[EQUIPMENT_TYPE.WEAPON] == equipment.itemId then
                    weaponEquipment = equipment
                    break
                end
            end
        end
        if weaponEquipment then
            local enchant_level = weaponEquipment.enchants or 0
            if enchant_level >= 1 and enchant_level < 3 then
                enchant_level = 1
            elseif enchant_level >= 3 and enchant_level < 5 then
                enchant_level = 2
            elseif enchant_level >= 5 then
                enchant_level = 3
            end
            if enchant_components then
                enchant_effects = string.split(enchant_components, ";")
                if enchant_effects[enchant_level] then
                    self._skeletonActor:setEnchantComponents(enchant_effects[enchant_level])
                else
                    self._skeletonActor:setEnchantComponents("")
                end
            elseif enchant_effect then
                enchant_effects = string.split(enchant_effect, ";")
                if enchant_effects[enchant_level] then
                    local effects = string.split(enchant_effects[enchant_level], ",")
                    for _, effectID in ipairs(effects) do
                        self:_onPlayEffectForSkill({effectID = effectID, options = {skillId = -1, isLoop = true, isFumo = true}})
                    end
                end
            end
        else
            if enchant_components then
                self._skeletonActor:setEnchantComponents("")
            end
        end
    end
end

function QBaseActorView:_getReplaceBoneName(config, dummy)
    if type(config.replace) == "string" then
        return config.replace
    else 
        return self._skeletonActor:getParentBoneName(dummy)
    end
end

function QBaseActorView:_retainReplaceEffect(effect)
    if self._retainedReplaceEffects == nil then
        self._retainedReplaceEffects = {}
    end

    effect:retain()
    effect:getSkeletonView():retain()
    effect:getSkeletonView():getSkeletonAnimation():retain()
    self._retainedReplaceEffects[#self._retainedReplaceEffects + 1] = effect
end

function QBaseActorView:_releaseReplaceEffect(effect)
    if self._retainedReplaceEffects == nil then
        self._retainedReplaceEffects = {}
    end

    for index, _effect in ipairs(self._retainedReplaceEffects) do
        if effect == _effect then
            effect:getSkeletonView():getSkeletonAnimation():release()
            effect:getSkeletonView():release()
            effect:onCleanup()
            effect:release()
            table.remove(self._retainedReplaceEffects, index)
            break
        end
    end
end

function QBaseActorView:_releaseAllReplaceEffectc()
    if self._retainedReplaceEffects == nil then
        self._retainedReplaceEffects = {}
    end

    for index, _effect in ipairs(self._retainedReplaceEffects) do
        _effect:getSkeletonView():getSkeletonAnimation():release()
        _effect:getSkeletonView():release()
        _effect:onCleanup()
        _effect:release()
    end
    self._retainedReplaceEffects = {}
end

function QBaseActorView:getHpAndDamageNode()
    return self._HpNode, self._DamageNode
end

function QBaseActorView:playMountSkillLabel(text)
    if ENABLE_SKILL_DISPLAY then
        self._labelSkill:setString(text)
        self._labelSkill:setVisible(true)
        self._labelSkillLockTime = q.time()
    end
end

function QBaseActorView:_pushBuffColor(buff, color)
    local colorBuffStack = self._colorBuffStack
    colorBuffStack[#colorBuffStack + 1] = {buff = buff, color = color}
end

function QBaseActorView:_removeBuffColor(removedBuff)
    local colorBuffStack = self._colorBuffStack
    local len = #colorBuffStack
    for i, obj in ipairs(colorBuffStack) do
        if obj.buff == removedBuff then
            table.remove(colorBuffStack, i)
            if i == len then
                if #colorBuffStack == 0 then
                    return display.COLOR_WHITE
                else
                    return colorBuffStack[#colorBuffStack].color
                end
            else
                return
            end
        end
    end
end

function QBaseActorView:_replaceShadowWithFile(file)
    if self._spriteShadow == nil then
        self:getSkeletonActor():replaceSlotWithFile("empty", "shadow", "root", EFFECT_ANIMATION)
        local shadow = CCSprite:create(file)
        shadow:setAnchorPoint(ccp(0.5, 0.5))
        shadow:setScaleX(2.0)
        self:addChild(shadow)
        self._spriteShadow = shadow
        self._spriteShadowFile = file
    end
end

function QBaseActorView:_replaceShadowWithEffect(effectId)
    if self._spriteShadow == nil then
        self:getSkeletonActor():replaceSlotWithFile("empty", "shadow", "root", EFFECT_ANIMATION)
        local effectFront, effectBack = QBaseEffectView.createEffectByID(effectId)
        local shadow = effectFront or effectBack
        shadow:playAnimation(shadow:getPlayAnimationName(), true)
        shadow:setAnchorPoint(ccp(0.5, 0.5))
        self:addChild(shadow, -1)
        self._spriteShadow = shadow
        self._spriteShadowFile = effectId
    end
end

function QBaseActorView:_removeReplacedShadow(file)
    if file == self._spriteShadowFile and self._spriteShadow then
        self:getSkeletonActor():removeReplaceSkeleton("shadow")
        self:removeChild(self._spriteShadow)
        self._spriteShadow = nil
        self._spriteShadowFile = nil
    end
end

function QBaseActorView:_disableAnimation(animation)
    self._disabledAnimation[animation] = true
end

function QBaseActorView:_enableAnimation(animation)
    self._disabledAnimation[animation] = nil
end

function QBaseActorView:flipActor()
    self:getSkeletonActor():flipActor()
    if self._spriteShadow and self._spriteShadow.setScaleX then
        self._spriteShadow:setScaleX(-self._spriteShadow:getScaleX())
    end
end

function QBaseActorView:registerEvent()
    self:setNodeEventEnabled(true)

    local actor = self:getModel()
    self._actorEventProxy = cc.EventProxy.new(actor, self)
    self._actorEventProxy:addEventListener(actor.CHANGE_STATE_EVENT, handler(self, self._onStateChanged))
    self._actorEventProxy:addEventListener(actor.ATTACK_EVENT, handler(self, self._onAttack))
    self._actorEventProxy:addEventListener(actor.UNDER_ATTACK_EVENT, handler(self, self._onHit))
    self._actorEventProxy:addEventListener(actor.HP_CHANGED_EVENT, handler(self, self._onHpChanged))
    self._actorEventProxy:addEventListener(actor.SET_POSITION_EVENT, handler(self, self._onPositionChanged))
    self._actorEventProxy:addEventListener(actor.SET_HEIGHT_EVENT, handler(self, self._onHeightChanged))
    self._actorEventProxy:addEventListener(actor.MOVE_EVENT, handler(self, self._onMove))
    self._actorEventProxy:addEventListener(actor.BUFF_STARTED, handler(self, self._onBuffStarted))
    self._actorEventProxy:addEventListener(actor.BUFF_ENDED, handler(self, self._onBuffEnded))
    self._actorEventProxy:addEventListener(actor.BUFF_MUTED, handler(self, self._onBuffMuted))
    self._actorEventProxy:addEventListener(actor.MARK_STARTED, handler(self, self._onMarkStarted))
    self._actorEventProxy:addEventListener(actor.MARK_ENDED, handler(self, self._onMarkEnded))
    self._actorEventProxy:addEventListener(actor.PLAY_SKILL_ANIMATION, handler(self, self._onChangeAnimationForSkill))
    self._actorEventProxy:addEventListener(actor.PLAY_SKILL_EFFECT, handler(self, self._onPlayEffectForSkill))
    self._actorEventProxy:addEventListener(actor.STOP_SKILL_EFFECT, handler(self, self._onRemoveEffectForSkill))
    self._actorEventProxy:addEventListener(actor.CANCEL_SKILL, handler(self, self._onSkillCancel))
    self._actorEventProxy:addEventListener(actor.SPEAK_EVENT, handler(self, self._onSpeak))
    self._actorEventProxy:addEventListener(actor.RP_CHANGED_EVENT, handler(self, self._onRpChanged))
    self._actorEventProxy:addEventListener(actor.TRIGGER_PASSIVE_SKILL, handler(self, self._onTriggerPassiveSkill))
    self._actorEventProxy:addEventListener(actor.SHOW_CCB, handler(self, self._onTriggerShowCCB))
    self._actorEventProxy:addEventListener(actor.ABSORB_CHANGE_EVENT, handler(self, self._onAbsorbChanged))
    self._actorEventProxy:addEventListener(actor.MAX_HP_CHANGED_EVENT, handler(self, self._onMaxHpChanged))
    self._actorEventProxy:addEventListener(actor.END, handler(self, self._onBattleEnd))
end

function QBaseActorView:showName()
    if self._actor:isPet() or (self._actor:isGhost() and not self._actor:isAttackedGhost()) then return end
    if self._nameView then
        self._nameView:setVisible(true)
        local animationManager = tolua.cast(self._nameView:getUserObject(), "CCBAnimationManager")
        animationManager:runAnimationsForSequenceNamed("Default Timeline")
    end
end

function QBaseActorView:parseReplaceStandardAction(actionStr, buffId)
    self._replaceAction.stub = buffId
    if self._replaceAction.actionDict == nil then
        self._replaceAction.actionDict = {}
    end

    local actionDict =  string.split(actionStr, ";")
    if actionDict ~= nil and #actionDict > 0 then
        for _, action in ipairs(actionDict) do
            action = string.split(action, ":")
            self._replaceAction.actionDict[action[1]] = action[2]
        end
    end
end

function QBaseActorView:getReplaceStandardAction(action)
    local result = nil
    if self._replaceAction and self._replaceAction.actionDict then
        result = self._replaceAction.actionDict[action]
    end

    if result == nil then
        return action
    else
        return result
    end
end

function QBaseActorView:cleanReplaceStandardAction()
    if self._replaceAction then
        self._replaceAction.stub = nil
        if self._replaceAction.actionDict then
            self._replaceAction.actionDict = nil
        end
    end
end

function QBaseActorView:_onAbsorbChanged(event)
    if self._actor:getHp() >= 0 and self._actor:isDead() == false and self._actor:isExile() ~= true then
        self._hpView:updateAbsorb(event.absorb/self._actor:getMaxHp())
    end
end

function QBaseActorView:_onMaxHpChanged(event)
    if self._actor:getHp() >= 0 and self._actor:isDead() == false and self._actor:isExile() ~= true then
        self._hpView:updateAbsorb(0, event.hpMaxBefore)
    end
end

function QBaseActorView:_onBattleEnd(event)
    if not self._actor:isDead() and self._actor:getType() == ACTOR_TYPES.HERO then
        self._skeletonActor:setOpacity(255)
    end
end

function QBaseActorView:getHpView()
    return self._hpView
end

function QBaseActorView:insertMutativeBuff(buff, effect)
    if buff and buff:isTimeEffectRadius() then
        self._mutativeRadiusBuff[effect] = buff
    end
end

function QBaseActorView:isFcaActor()
    return self._skeletonActor.isFca
end

-- 入场时的武魂真身
function QBaseActorView:showBackSoulEffect()
    if self._actor:isCopyHero() then return end
    local staticDatabase = QStaticDatabase:sharedDatabase()
    local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
    local actor = self._actor
    local actorInfo = staticDatabase:getCharacterByID(actor:getActorID())
    
    local isScaleWithActor = false
    local backSoulEffect = {}
    if actorInfo.backSoulFile and actor:isOpenArtifact() and (actor.__is_shown_back_soul ~= true) and not (actor:isStoryActor()) then
        actor.__is_shown_back_soul = true
        self._backSoulAnim = skeletonViewController:createSkeletonActorWithFile(actorInfo.backSoulFile, false)
        self._backSoulAnim:setVisible(false)
        local scale = SOUL_ANIMATION_SCALE[actor:getArtifactBreakthrough()] or 1
        if not self._skeletonActor.isFca and self._backSoulAnim.isFca then
            self._backSoulAnim:setScale(0.25)
            self._backSoulAnim:flipActor()
            isScaleWithActor = true
        elseif self._skeletonActor.isFca and self._backSoulAnim.isFca then
            isScaleWithActor = true
        else
            if actor:getType() == ACTOR_TYPES.HERO then
                self._backSoulAnim:flipActor()
            end
        end

        self._backSoulAnim:setScale(self._backSoulAnim:getScale() * scale)
        self._skeletonActor:attachNodeToBone(nil, self._backSoulAnim, true, isScaleWithActor)
        self._backSoulAnim:connectAnimationEventSignal(function(eventType, trackIndex, animationName, loopCount)
            if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
                self._backSoulAnim:disconnectAnimationEventSignal()
                self._skeletonActor:detachNodeToBone(self._backSoulAnim)
                skeletonViewController:removeSkeletonActor(self._backSoulAnim)
                self._backSoulAnim = nil
            end
        end)
        if self._backSoulAnim:canPlayAnimation(BACK_SOUL_ANIMATION_NAME) then
            app.battle:performWithDelay(function()
                self._backSoulAnim:setVisible(true)
                self._backSoulAnim:playAnimation(BACK_SOUL_ANIMATION_NAME, false)
                for _, effectView in ipairs(backSoulEffect) do
                    effectView:playAnimation(effectView:getPlayAnimationName(), false)
                end
            end, 0.8)
        else
            self._backSoulAnim:disconnectAnimationEventSignal()
            self._skeletonActor:detachNodeToBone(self._backSoulAnim)
            skeletonViewController:removeSkeletonActor(self._backSoulAnim)
            self._backSoulAnim = nil
        end
        
        if actorInfo.backSoulEffect ~= nil then
            local effectIdList = string.split(actorInfo.backSoulEffect, ";")
            for _, effectId in ipairs(effectIdList) do
                local effectView = QBaseEffectView.createEffectByID(effectId) 
                if effectView then
                    local dummy = staticDatabase:getEffectDummyByID(effectId, false)
                    local bone_position = self._backSoulAnim:getBonePosition(dummy)
                    local posx, posy = effectView:getSkeletonView():getPosition()
                    effectView:getSkeletonView():setPosition(bone_position.x + posx, bone_position.y + posy)
                    self._backSoulAnim:attachNodeToBone(dummy, effectView, false, true)
                    table.insert(backSoulEffect, effectView)
                end
            end
        end
    end
end

function QBaseActorView:showStorage(limit, offset, scale, buffId)
    self._storageView = QIncompleteCircleUiMask.new()
    app.scene:addEffectViews(self._storageView, {isFrontEffect = true})
    local x, y = self:getPosition()
    if offset ~= nil then
        x ,y = x + offset.x, y + offset.y
    end
    self._storageView:setPosition(ccp(x, y))
    if scale ~= nil then
        self._storageView:setScale(scale)
    end
    self._maxStorage = self._actor:getMaxAttack() * limit
    self._showStorageBuffId = buffId
end

function QBaseActorView:hideStorage()
    app.scene:removeEffectViews(self._storageView)
    self._storageView = nil
end

function QBaseActorView:_getEndEggs()
    local dataBase = QStaticDatabase:sharedDatabase()
    local eggList = dataBase:getSkinsEggByType(1)
    for _, config in ipairs(eggList) do
        local skinId = self:getModel():getSkinId()
        if config.skins_id_1 == skinId then
            for _, actor in ipairs(app.battle:getHeroes()) do
                if actor:getSkinId() == config.skins_id_2 then
                    return {egg_skill = config.skins1_easter_egg_skill,
                        egg_animation = config.skins1_animation}
                end
            end
        elseif config.skins_id_2 == skinId then
            for _, actor in ipairs(app.battle:getHeroes()) do
                if actor:getSkinId() == config.skins_id_1 then
                    return {egg_skill = config.skins2_easter_egg_skill,
                        egg_animation = config.skins2_animation}
                end
            end  
        end
    end
end

return QBaseActorView

