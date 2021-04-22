
--[[
    Class name QSBDirector
    Create by julian 
--]]

local QSBDirector = class("QSBDirector")

local QSBNode = import(".QSBNode")
local QFileCache = import("..utils.QFileCache")
local QBattleManager = import("..controllers.QBattleManager")

local function traverseBehaviorNode(node, f)
    f(node)
    local children = node:getChildrenCount()
    local count = node:getChildrenCount()
    for i = 1, count do
        traverseBehaviorNode(node:getChildAtIndex(i), f)
    end
end

function QSBDirector:ctor(attacker, target, skill, options)
    self._attacker = attacker
    self._target = target
    self._skill = skill
    self._castPosition = clone(attacker:getPosition())
    if self._target ~= nil then
        self._targetPosition = clone(self._target:getPosition())
    end
    if skill:getSkillType() == skill.MANUAL then
        self._baoqi = skill:getBaoqi()
    end

    self._skillBehavior = nil
    self._behaviorName = skill:getSkillBehaviorName()
    if self:_createSkillBehavior(self._behaviorName) == false then
        assert(false, self._skill:getName() ..  " can not find a skill behavior named after:" .. tostring(self._behaviorName))
        return
    end

    if skill:isPeriodByTarget() then
        skill:changePeriodTarget(target)
    end

    -- something for cancle
    self._attackerBuffIds = {}
    self._targetBuffIds = {}
    self._loopEffectIds = {}
    self._soundEffects = {}
    self._retainBuffs = {}

    self._hasAction = {}

    self._triggerTargetHistory = {}

    self._isSkillFinished = false
    self._init_target = target
    -- 契约事件的handler
    self._strikeAgreementHandler = nil
    -- 契约事件的延迟handler
    self._strikeAgreementDelayHandler = nil
    self._plunderTotalRage = 0
end

function QSBDirector:getInitTarget()
    return self._init_target
end

function QSBDirector:changeAllNodeTarget(target)
    self._target = target
    traverseBehaviorNode(self._skillBehavior, function(node) node._target = target end)
end

function QSBDirector:chooseTarget()
    if self._target and self._target:isDead() then
        local actor = self._attacker
        local skill = self._skill
        local currentTarget = actor:getTarget()
        if currentTarget and not currentTarget:isDead() then
            self._target = currentTarget
            traverseBehaviorNode(self._skillBehavior, function(node) node._target = currentTarget end)
        else
            local range_min = 0
            local range_max = 9999
            range_min = range_min * range_min * global.pixel_per_unit * global.pixel_per_unit
            range_max = range_max * range_max * global.pixel_per_unit * global.pixel_per_unit
            local target = actor:getTarget()
            local actors
            if skill:getAttackType() == skill.TREAT then
                actors = app.battle:getMyTeammates(actor, true)
            else
                actors = app.battle:getMyEnemies(actor)
            end
            local candidates = {}
            local target_as_candidate = nil
            for _, enemy in ipairs(actors) do
                if not enemy:isDead() and not enemy:isSupport() then
                    local x = enemy:getPosition().x - actor:getPosition().x
                    local y = enemy:getPosition().y - actor:getPosition().y
                    local d = x * x + y * y * 4
                    if d <= range_max and d >= range_min then
                        if enemy == target then
                            target_as_candidate = enemy
                        else
                            table.insert(candidates, enemy)
                        end
                    end
                end
            end
            if #candidates > 0 then
                self._target = candidates[app.random(1, #candidates)]
                if skill:disableChangeTargetWithBehavior() ~= true then
                    actor:setTarget(self._target)
                    actor:_verifyFlip()
                end
            elseif target_as_candidate then
            end
            local target = self._target
            traverseBehaviorNode(self._skillBehavior, function(node) node._target = target end)
        end
    end
end

function QSBDirector:isSkillFinished()
    return self._isSkillFinished
end

local function containAction(config, action)
    for k, v in pairs(config) do
        if k == "CLASS" then
            if v == "action."..action then
                return true
            end
        elseif k == "ARGS" then
            for _, subConfig in ipairs(v) do
                if containAction(subConfig, action) then
                    return true
                end
            end
        end
    end

    return false
end

local function containBulletTime(config)
    for k, v in pairs(config) do
        if k == "CLASS" then
            if v == "action.QSBBulletTime" or v == "action.QSBBulletTimeArena" then
                return true
            end
        elseif k == "ARGS" then
            for _, subConfig in ipairs(v) do
                if containBulletTime(subConfig) then
                    return true
                end
            end
        end
    end

    return false
end

function QSBDirector:_createSkillBehavior(name)
    if name == nil then
        return false
    end

    local config = QFileCache.sharedFileCache():getSkillConfigByName(name)
    if config[1] then
        if config[2] and self._attacker:getReplaceCharacterId() then
            config = config[2]
        else
            config = config[1]
        end
    end
    if config ~= nil then
        if self._skill:getSkillType() == self._skill.MANUAL then
            self._hasBulletTime = containBulletTime(config)
        end
        if self._attacker:getDeputyActorIDs() then
            if --[[not app.battle:isPVPMode() and-]] self._skill:getSkillType() == self._skill.MANUAL 
                and self._skill:getId() ~= self._attacker:getDeadSkillID()
                and self._skill ~= self._attacker:getVictorySkill() then
                local delay_time = 0.5 + (self._hasBulletTime and 0 or 0.3)
                config = {
                    CLASS = "composite.QSBSequence",
                    OPTIONS = {forward_mode = true},
                    ARGS = {
                        {
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.2, revertable = true},
                        },
                        {
                            CLASS = "action.QSBShowActorArena",
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.2, revertable = true},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBBulletTimeArena",
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBAnimationScale",
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = delay_time},
                        },
                        {
                            CLASS = "action.QSBAnimationScale",
                            OPTIONS = {turn_on = false},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = false},
                        },
                        {
                            CLASS = "action.QSBBulletTimeArena",
                            OPTIONS = {turn_on = false},
                        },
                        {
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = false},
                        },
                        {
                            CLASS = "action.QSBShowActorArena",
                            OPTIONS = {is_attacker = true, turn_on = false},
                        },
                        config,
                    },
                }
            end
        else
            if self._baoqi and self._baoqi >= 0 then
                config = {
                    CLASS = "composite.QSBSequence",
                    OPTIONS = {forward_mode = true},
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "Ultrakill_1", ignore_animation_scale = true, ignore_animation_scale = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = math.floor(self._baoqi)},
                        },
                        config,
                    },
                }
            end
        end

        if self._attacker:isSupportHero() and self._skill:getSkillType() == self._skill.MANUAL then
            config = {
                CLASS = "composite.QSBSequence",
                OPTIONS = {forward_mode = true},
                ARGS = {
                    {
                        CLASS = "action.QSBManualMode",
                        OPTIONS = {enter = true},
                    },
                    {
                        CLASS = "composite.QSBParallel",
                        ARGS = {
                            {
                                CLASS = "action.QSBPlayEffect",
                                OPTIONS = {is_hit_effect = false, effect_id = "flash_out_1"},
                            },
                            {
                                CLASS = "action.QSBFlashAppear",
                                OPTIONS = {color = ccc3(255, 255, 255), wait_time = 18 / 30, fade_in_time = 4 / 30},
                            },
                        },
                    },
                    {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 6},
                    },
                    {
                        CLASS = "action.QSBManualMode",
                        OPTIONS = {exit = true},
                    },

                    -- {
                    --     CLASS = "action.QSBManualMode",
                    --     OPTIONS = {enter = true},
                    -- },
                    -- {
                    --     CLASS = "action.QSBTransferAppear",
                    --     OPTIONS = {effect_id = "transfer_matrix_1", color = ccc3(128, 128, 128)},
                    -- },
                    -- {
                    --     CLASS = "action.QSBManualMode",
                    --     OPTIONS = {exit = true},
                    -- },

                    config,
                },
            }
        end

        if (self._skill:isNeedRage() or self._skill:isNeedComboPoints()) and not self._is_triggered then
            config = {
                CLASS = "composite.QSBSequence",
                OPTIONS = {forward_mode = true},
                ARGS = {
                    {
                        CLASS = "action.QSBUseManualSkill"
                    },
                    config,
                }
            }
        end

        self._skillBehavior = self:_createSkillBehaviorNode(config)
    end

    self._config = config

    return (self._skillBehavior ~= nil)
end

function QSBDirector:_createSkillBehaviorNode(config)
    if config == nil or type(config) ~= "table" then
        return nil
    end

    local skillClass = QFileCache.sharedFileCache():getSkillClassByName(config.CLASS)
    local options = clone(config.OPTIONS)
    local node = skillClass.new(self, self._attacker, self._target, self._skill, options)

    local args = config.ARGS
    if args ~= nil then
        for k, v in pairs(args) do
            local child = self:_createSkillBehaviorNode(v)
            if child ~= nil then
                node:addChild(child)
            end
        end
    end

    return node
end

function QSBDirector:visit(dt)
    if self._isSkillFinished == true then
        return
    end

    if self._attacker:isDead() == true and not self._attacker:isDoingDeadSkill() then
        self:cancel()
        return
    end

    if self._skillBehavior:getState() == QSBNode.STATE_FINISHED then
        self._isSkillFinished = true
    elseif self._skillBehavior:getState() == QSBNode.STATE_EXECUTING then
        self._skillBehavior:visit(dt)
    elseif self._skillBehavior:getState() == QSBNode.STATE_WAIT_START then
        self._skillBehavior:start()
        self._skillBehavior:visit(0)
    end
end

function QSBDirector:cancel()

    if self._attacker:isDead() == false then
        for _, buffId in ipairs(self._attackerBuffIds) do
            self._attacker:removeBuffByID(buffId)
        end
    end

--  assert(self._target ~= nil, "QSBDirector:cancel() _target is nil!")
    if self._target and self._target:isDead() == false then
        for _, buffId in ipairs(self._targetBuffIds) do
            self._target:removeBuffByID(buffId)
        end
    end

    self._skillBehavior:cancel()
    if self._skillBehavior.revert then 
        self._skillBehavior:revert()
    end
    if self._attacker:isAttacking() == true then
        self._attacker:onAttackFinished(true, self._skill)
    end

    if not IsServerSide then
        if self._isVisibleSceneBlackLayer == true and app.scene:getBackgroundOverLayer():isVisible() == true then
            app.scene:visibleBackgroundLayer(false, self._showActor)
        end
    end

    if self._actorScale ~= nil and self._actorScale ~= 1.0 then
        if self._attacker ~= nil then
            self._attacker:setScale(1.0)
        end
    end

    for _, loopEffectId in ipairs(self._loopEffectIds) do
        self._attacker:stopSkillEffect(loopEffectId)
    end

    if self._isActorKeepAnimation == true then
        if self._attacker and self._attacker:isDead() == false then
            if not IsServerSide then
                local view = app.scene:getActorViewFromModel(self._attacker)
                view:setIsKeepAnimation(false)
                view:getSkeletonActor():resetActorWithAnimation(ANIMATION.STAND, true)
            end
        end
    end

    for _, soundEffect in ipairs(self._soundEffects) do
        if soundEffect:isLoop() == true then
            soundEffect:stop()
            table.removebyvalue(app.scene._loopSkillSoundEffects, soundEffect)
        end
    end

    if self._isInBulletTime == true then
        app.battle:dispatchEvent({name = QBattleManager.EVENT_BULLET_TIME_TURN_OFF, actor = self._attacker})
    end

    for _, buff in pairs(self._retainBuffs) do
        buff:releaseBuff(self)
    end
    self._retainBuffs = {}

    if not IsServerSide then
        local actorView = app.scene:getActorViewFromModel(self._attacker)
        if actorView then
            if self._scaleHandle then
                scheduler.unscheduleGlobal(self._scaleHandle)
                self._scaleHandle = nil
            end
            if actorView.setSizeScale then
                actorView:setSizeScale(1, "show_actor")
            end
        end
    end

    self._isSkillFinished = true
end

function QSBDirector:getTargetPosition()
    return self._targetPosition
end

function QSBDirector:getCastPosition()
    return self._castPosition
end

function QSBDirector:getTarget()
    return self._target
end

function QSBDirector:setTarget(target)
    self._target = target
end

function QSBDirector:getSkill()
    return self._skill
end

function QSBDirector:addBuffId(buffId, actor)
    if buffId ~= nil and actor ~= nil then
        if actor == self._attacker then
            table.insert(self._attackerBuffIds, buffId)
        else
            table.insert(self._targetBuffIds, buffId)
        end
    end
end

function QSBDirector:removeBuffId(buffId)
    if buffId ~= nil and actor ~= nil then
        if actor == self._attacker then
            table.removebyvalue(self._attackerBuffIds, buffId)
        else
            table.removebyvalue(self._targetBuffIds, buffId)
        end
    end
end

function QSBDirector:setVisibleSceneBlackLayer(visible, actor)
    self._isVisibleSceneBlackLayer = visible
    if self._isVisibleSceneBlackLayer == true then
        self._showActor = actor
    else
        self._showActor = nil
    end
end

function QSBDirector:getShowActor()
    return self._showActor
end

function QSBDirector:setIsPlayLoopEffect(effectID)
    table.insert(self._loopEffectIds, effectID)
end

function QSBDirector:setActorKeepAnimation(isKeep)
    self._isActorKeepAnimation = isKeep
end

function QSBDirector:setActorScale(scale)
    self._actorScale = scale
end

function QSBDirector:setIsInBulletTime(isInBulletTime)
    if self._isInBulletTime and not isInBulletTime then
        self._isBulletTimeOver = true
    end
    self._isInBulletTime = isInBulletTime
end

function QSBDirector:isInBulletTime()
    return self._isInBulletTime
end

function QSBDirector:addSoundEffect(soundEffect)
    if soundEffect ~= nil then
        table.insert(self._soundEffects, soundEffect)
        if soundEffect:isLoop() == true then
            table.insert(app.scene._loopSkillSoundEffects, soundEffect)
        end
    end
end

function QSBDirector:stopSoundEffectById(id)
    if id == nil then
        return
    end
    
    for _, soundEffect in ipairs(self._soundEffects) do
        if soundEffect:getSoundId() == id then
            soundEffect:stop()
            if soundEffect:isLoop() == true then
                table.removebyvalue(app.scene._loopSkillSoundEffects, soundEffect)
            end
        end
    end
end

function QSBDirector:isUncancellable()
    return self._isUncancellable
end

function QSBDirector:setUncancellable(uncancellable)
    self._isUncancellable = uncancellable
end

function QSBDirector:retainBuff(buff_id)
    local retainBuffs = self._retainBuffs
    local attacker = self._attacker
    if retainBuffs[buff_id] ~= nil then
        return
    end
    local buff = attacker:getBuffByID(buff_id)
    if buff then
        retainBuffs[buff_id] = buff
        buff:retainBuff(self)
    end
end

function QSBDirector:releaseBuff(buff_id)
    local retainBuffs = self._retainBuffs
    if retainBuffs[buff_id] == nil then
        return
    end
    local buff = retainBuffs[buff_id]
    buff:releaseBuff(self)
    retainBuffs[buff_id] = nil
end

function QSBDirector:hasBulletTime()
    return self._hasBulletTime
end

function QSBDirector:isBulletTimeOver()
    return self._isBulletTimeOver
end

function QSBDirector:hasAction(action)
    local hasAction = self._hasAction
    if hasAction[action] == nil then
        hasAction[action] = containAction(self._config, action)
    end
    return hasAction[action]
end

function QSBDirector:scaleActor(scale, duration)
    if not IsServerSide then
        local actorView = app.scene:getActorViewFromModel(self._attacker)
        if actorView and actorView.setSizeScale then
            if self._scaleHandle then
                scheduler.unscheduleGlobal(self._scaleHandle)
                self._scaleHandle = nil
            end
            local curTime = 0
            local scale1 = actorView:getSizeScale("show_actor")
            local scale2 = scale
            self._scaleHandle = scheduler.scheduleGlobal(function ( dt )
                curTime = math.min(curTime + dt, duration)
                if actorView.setSizeScale then
                    actorView:setSizeScale(math.sampler2(scale1, scale2, 0.0, duration, curTime), "show_actor")
                end
                if curTime == duration then
                    scheduler.unscheduleGlobal(self._scaleHandle)
                    self._scaleHandle = nil
                end
            end, 0)
        end
    end
end

function QSBDirector:getTriggerTargetHistory(passiveSkill, target)
    local triggerTargetHistory = self._triggerTargetHistory
    if triggerTargetHistory[passiveSkill] then
        return triggerTargetHistory[passiveSkill][target]
    end
end

function QSBDirector:setTriggerTargetHistory(passiveSkill, target)
    local triggerTargetHistory = self._triggerTargetHistory
    if triggerTargetHistory[passiveSkill] == nil then
        triggerTargetHistory[passiveSkill] = {}
    end
    triggerTargetHistory[passiveSkill][target] = true
end

function QSBDirector:setAddtionArguments(argument)
    local func = function(node)
        local node_arg = node:getOptions()
        node_arg = node_arg or {}
        for k, v in pairs(argument) do
            node_arg[k] = v
        end
    end
    traverseBehaviorNode(self._skillBehavior, func)
end

function QSBDirector:setStrikeAgreementHandler(handler)
    self._strikeAgreementHandler = handler
end

function QSBDirector:getStrikeAgreementHandler()
    return self._strikeAgreementHandler
end

function QSBDirector:setStrikeAgreementDelayHandler(handler)
    self._strikeAgreementDelayHandler = handler
end

function QSBDirector:getStrikeAgreementDelayHandler()
    return self._strikeAgreementDelayHandler
end

function QSBDirector:setPlunderTotalRage(rage)
    self._plunderTotalRage = self._plunderTotalRage + rage
end

function QSBDirector:getPlunderTotalRage()
    return self._plunderTotalRage
end

return QSBDirector
