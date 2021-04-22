-- **************************************************
-- Author               : wanghai
-- FileName             : QSoulSpiritStatusView.lua
-- Description          : 
-- Create time          : 2019-06-19 10:41
-- Last modified        : 2019-06-20 18:14
-- **************************************************

local QSoulSpiritStatusView = class("QSoulSpiritStatusView", function()
    return display.newNode()
end)

local QCircleUiMask = import(".QCircleUiMask")
local QFullCircleUiMask = import(".QFullCircleUiMask")
local QUserData = import("...utils.QUserData")
local QSkill = import("...models.QSkill")

local RP_SPEED = 1

function QSoulSpiritStatusView:ctor()
    local ccbFile = "ccb/Battle_soulspirit_skill.ccbi"
    local proxy = CCBProxy:create()
    self._ccbOwner = {}
    self._ccbOwner.clickSkill1 = handler(self, QSoulSpiritStatusView._onClickSkillButton1)

    local ccbView = CCBuilderReaderLoad(ccbFile, proxy, self._ccbOwner)
    if ccbView == nil then
        assert(false, "load ccb file:" .. ccbFile .. "faild!")
    end
    self:addChild(ccbView)

    self._ccbOwner.fca_shanshuo:stopAnimation()
    self._ccbOwner.fca_shanshuo:setVisible(false)
    self._ccbOwner.fca_liuguang:stopAnimation()
    self._ccbOwner.fca_liuguang:setVisible(false)

    self:setNodeEventEnabled(true)
end

function QSoulSpiritStatusView:getHero()
    return self._hero
end

function QSoulSpiritStatusView:setIndex(index)
    if not self:haveTwoSpirit() then
        self._ccbOwner.sprite_hun2:setVisible(false)
        self._ccbOwner.sprite_hun1:setVisible(false)

        return
    end
    
    if index == 1 then
        self._ccbOwner.sprite_hun2:setVisible(false)
        self._ccbOwner.sprite_hun1:setVisible(true)
    else
        self._ccbOwner.sprite_hun1:setVisible(false)
        self._ccbOwner.sprite_hun2:setVisible(true)
    end
end

function QSoulSpiritStatusView:haveTwoSpirit()
    if self._hero:getType() == ACTOR_TYPES.NPC then
        return #app.battle:getDungeonConfig().enemySoulSpirits > 1
    else
        return #app.battle:getDungeonConfig().userSoulSpirits > 1
    end
end

function QSoulSpiritStatusView:setHero(hero)
    self:disconnect()

    if hero == nil then
        self._hero = nil
        self._skill = nil
        self:setVisible(false)
        return
    else
        self._hero = hero
        self:setVisible(true)
    end

    self._skill = self._hero:getFirstManualSkill() 
    local icon = hero:getIcon()
    
    if icon == nil then
        icon = global.ui_skill_icon_placeholder
    end

    if icon ~= nil then
        local texture = CCTextureCache:sharedTextureCache():addImage(icon)
        assert(texture, "icon : " .. icon .. "file is not exist!")
        self._ccbOwner.sprite_skillIcon1_1:setTexture(texture)
        self._ccbOwner.sprite_skillIcon1_1:setScale(0.75)
        self._ccbOwner.sprite_skillIcon1_1:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
        local size = texture:getContentSize()
        local rect = CCRectMake(0, 0, size.width, size.height)
        self._ccbOwner.sprite_skillIcon1_1:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
    end

    if icon == global.ui_skill_icon_placeholder then
        self._ccbOwner.button_skill1_1:setEnabled(false)
    else
        self._ccbOwner.button_skill1_1:setEnabled(true)
    end

    self._suffix = "-autoUseSkill"
    local dungeonConfig = app.battle:getDungeonConfig()
    local dungeonInfo = remote.activityInstance:getDungeonById(dungeonConfig.id)
    if dungeonInfo ~= nil then
        self._suffix = "-autoUseSkill-active"
    end
    if app.battle:isPVPMode() == true and app.battle:isInSunwell() == true then
        self._suffix = "-autoUseSkill-sunwell"
    end
    if app.battle:isPVPMode() == true and app.battle:isInArena() == true then
        self._suffix = "-autoUseSkill-Arena"
    end

    local autoUseSkill = app:getUserData():getUserValueForKey(self._hero:getActorID() .. self._suffix)
    if autoUseSkill == nil or autoUseSkill ~= QUserData.STRING_TRUE then
        self._hero:setForceAuto(false)
        self._ccbOwner.sprite_zidong:setVisible(false)
    else
        self._hero:setForceAuto(true)
        self._ccbOwner.sprite_zidong:setVisible(true)
    end

    if app.battle:isPVPMode() == true and ((app.battle:isInArena() == true and app.battle:isInGlory() == false and app.battle:isInTotemChallenge() == false) or app.battle:isInSilverMine()) then
        self._hero:setForceAuto(true)
        self._ccbOwner.sprite_zidong:setVisible(true)
    end

    local sprite = CCSprite:create(icon)
    sprite:updateDisplayedColor(global.ui_skill_icon_disabled_overlay)
    sprite:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
    self._cd1 = QCircleUiMask.new()
    self._cd1:setMaskSize(sprite:getContentSize())
    self._cd1:addChild(sprite)
    self._cd1:update(1)
    self._cd1_node = display.newNode()
    self._cd1_node:addChild(self._cd1)
    self._ccbOwner.sprite_skillIcon1_1:addChild(self._cd1_node)
    local size = self._ccbOwner.sprite_skillIcon1_1:getContentSize()
    self._cd1:setPosition(size.width * 0.5, size.height * 0.5)

    self._cd1_node:setVisible(false)
    self._cd1:update(1.0)

    local sprite = CCSprite:createWithTexture(self._ccbOwner.sprite_rage:getTexture())
    local node = self._ccbOwner.rage_node
    self._cdRage = QCircleUiMask.new()
    self._cdRage:setMaskSize(sprite:getContentSize())
    self._cdRage:addChild(sprite)
    self._cdRage:update(1)
    self._cdRage_node = display.newNode()
    self._cdRage_node:addChild(self._cdRage)
    node:addChild(self._cdRage_node)
    self._cdRage:setPosition(self._ccbOwner.sprite_rage:getPosition())
    self._ccbOwner.sprite_rage:setVisible(false)
    self._sprite_rage_clip = sprite

    self._cdRage:update(1.0)
    self._cdRage_node:setVisible(false)

    self._target_rage = 0
    self._current_rage = 0

    self._already_play_skill_animation = false
    
    self._ccbOwner.fca_shanshuo:stopAnimation()
    self._ccbOwner.fca_shanshuo:setVisible(false)
    self:connect()

    if app.scene:isAutoTwoWavePVP() then
        self._ccbOwner.sprite_zidong:setVisible(false)
    end
end

function QSoulSpiritStatusView:connect()
    if self._skill ~= nil then
        local skill = self._skill
        self._skillEventProxy = cc.EventProxy.new(self._skill)
        self._skillEventProxy:addEventListener(QDEF.EVENT_CD_CHANGED, handler(self, self.onCdChanged))
        self._skillEventProxy:addEventListener(QDEF.EVENT_CD_STARTED, handler(self, self.onCdStarted))
        self._skillEventProxy:addEventListener(QDEF.EVENT_CD_STOPPED, handler(self, self.onCdStopped))
        self._skillEventProxy:addEventListener(QSkill.EVENT_SKILL_DISABLE, handler(self, self.onSkillDisable))
        self._skillEventProxy:addEventListener(QSkill.EVENT_SKILL_ENABLE, handler(self, self.onSkillEnable))
    end

    if self._hero ~= nil then
        self._heroEventProxy = cc.EventProxy.new(self._hero)
        self._heroEventProxy:addEventListener(self._hero.USE_MANUAL_SKILL_EVENT, handler(self, self.onUseSkill))
        self._heroEventProxy:addEventListener(self._hero.FORCE_AUTO_CHANGED_EVENT, handler(self, self.onForceChanged))
        self._heroEventProxy:addEventListener(self._hero.RP_CHANGED_EVENT, handler(self, self.onRpChanged))
    end

    self._already_play_skill_animation = false
    self._ccbOwner.fca_liuguang:stopAnimation()
    self._ccbOwner.fca_liuguang:setVisible(false)
end

function QSoulSpiritStatusView:disconnect()
    if self._skillEventProxy ~= nil then
        self._skillEventProxy:removeAllEventListeners()
        self._skillEventProxy = nil
    end

    if self._heroEventProxy ~= nil then
        self._heroEventProxy:removeAllEventListeners()
        self._heroEventProxy = nil
    end
    
    if self._ccbOwner.sprite_skillIcon1_1 then
        self._ccbOwner.sprite_skillIcon1_1:removeAllChildren()
    end
end

function QSoulSpiritStatusView:getActor()
    return self._hero
end

function QSoulSpiritStatusView:onSkillDisable(event)
    if event.skill ~= self._skill then
        return
    end

    local texture = CCTextureCache:sharedTextureCache():addImage(global.ui_skill_icon_placeholder)
    self._ccbOwner.sprite_skillIcon1_1:setTexture(texture)
    local size = texture:getContentSize()
    local rect = CCRectMake(0, 0, size.width, size.height)
    self._ccbOwner.sprite_skillIcon1_1:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
end

function QSoulSpiritStatusView:onSkillEnable(event)
    if event.skill ~= self._skill then
        return
    end

    if self._skill and self._skill:getIcon() then
        local texture = CCTextureCache:sharedTextureCache():addImage(self._skill:getIcon())
        self._ccbOwner.sprite_skillIcon1_1:setTexture(texture)
        local size = texture:getContentSize()
        local rect = CCRectMake(0, 0, size.widh, size.height)
        self._ccbOwner.sprite_skillIcon1_1:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
    end
end

function QSoulSpiritStatusView:onCdStarted(event)
    if event and event.skill == self._skill then
        self._cd1_node:setVisible(true)
    end
end

function QSoulSpiritStatusView:onCdStopped(event)
    if self._hero:isDead() == true then
        return
    end

    if event.skill == self._skill then
        self:playSkillReadyAnimation()   
    end 
end

function QSoulSpiritStatusView:playSkillReadyAnimation()
    if self._skill:isReady() and self._hero:isRageEnough() and self._already_play_skill_animation ~= true then
        self._already_play_skill_animation = true
        local fca = self._ccbOwner.fca_shanshuo
        fca:stopAnimation()
        fca:connectAnimationEventSignal(function(eventType, trackIndex, animationName, loopCount)
                if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
                    fca:disconnectAnimationEventSignal()
                    fca:setVisible(false)
                end
            end)
        fca:setVisible(true)
        fca:playAnimation("animation", false)
        self._ccbOwner.fca_liuguang:playAnimation("animation", true)
        self._ccbOwner.fca_liuguang:setVisible(true)
    end
end

function QSoulSpiritStatusView:onUseSkill(event)
    if event == nil or event.skill == nil then
        return
    end
    
    local skillNode = nil
    if event.skill == self._skill then
        self._already_play_skill_animation = false
        self._ccbOwner.fca_liuguang:stopAnimation()
        self._ccbOwner.fca_liuguang:setVisible(false)
    end
end

function QSoulSpiritStatusView:_onClickSkillButton1()
    if app.battle:isPausedBetweenWave() == true then
        return
    end

    if app.battle:isInReplay() or app.battle:isInQuick() then
        app.tip:floatTip(global.replay_warning)
        return
    end

    if self._skill ~= nil and self._hero:isDead() == false and self._skill:isReadyAndConditionMet()
        and self._hero:canAttack(self._skill) and self._skill:isCDOK() then
        self._hero:onUseManualSkill(self._skill)
    end
end

function QSoulSpiritStatusView:onForceChanged(event)
    if app.scene:isAutoTwoWavePVP() then return end
    if event.forceAuto == true then
        self._ccbOwner.sprite_zidong:setVisible(true)
    else
        self._ccbOwner.sprite_zidong:setVisible(false)
    end
end

function QSoulSpiritStatusView:onCdChanged(event)
    if self._hero:isDead() == true then
        return
    end

    if event.skill == self._skill then
        local percent = 1 - event.cd_progress
        if event.skill:isCDOK() then
            -- self._cd1:update(0)
            self._cd1_node:setVisible(false)
        else
            self._cd1:update(percent)
            self._cd1_node:setVisible(true)
        end
    end
end

function QSoulSpiritStatusView:onRpChanged(event)
    local percent = self._hero:getRage() / self._hero:getRageTotal()
    self._target_rage = math.clamp(percent, 0, 1)
    if self._target_rage >= 1 then
        self:playSkillReadyAnimation()   
    end
    -- do return end

    -- if event and event.showTip then
    --     local dRage = event.new_rage - event.old_rage
    --     if dRage > 0 then
    --         local labeltip = CCLabelTTF:create("", global.font_default, 20)
    --         labeltip:setString(string.format("击杀奖励\n能量 +%d", dRage))
    --         labeltip:setColor(ccc3(0, 0.7765 * 255, 0.9098 * 255))
    --         self:addChild(labeltip)
    --         labeltip = setShadow4(labeltip)
    --         labeltip:setPositionY(-37)
    --         labeltip:setScale(0.1)
    --         local arr = CCArray:create()
    --         arr:addObject(CCMoveBy:create(0.5, ccp(0, 62)))
    --         arr:addObject(CCDelayTime:create(1.5))
    --         arr:addObject(CCCallFunc:create(function()
    --             local handle, time = nil, 0
    --             local duration = 0.175
    --             handle = scheduler.scheduleGlobal(function(dt)
    --                 time = time + dt
    --                 if time > duration then
    --                     labeltip:removeFromParentAndCleanup(true)
    --                     labeltip:release()
    --                     scheduler.unscheduleGlobal(handle)
    --                 else
    --                     labeltip:setOpacity(math.sampler2(255, 0, 0, duration, time))
    --                 end
    --             end, 0)
    --         end))
    --         labeltip:runAction(CCSequence:create(arr))
    --         labeltip:runAction(CCScaleTo:create(0.5, 1.0))
    --         labeltip:retain()
    --     end
    -- end

    -- if DEBUG_RAGE and event and event.old_rage ~= event.new_rage then
    --     local dRage = event.new_rage - event.old_rage
    --     labeltip = CCLabelTTF:create("", global.font_default, 20)
    --     labeltip:setString(string.format("怒气变化 %d", dRage))
    --     labeltip:setPositionX(50)
    --     self:addChild(labeltip)
    --     local arr = CCArray:create()
    --     if self._debug_time ~= nil then
    --         if self._debug_time > q.time()  then
    --             arr:addObject(CCDelayTime:create(self._debug_time - q.time()))
    --         else 
    --             self._debug_time = q.time()
    --         end
    --     else
    --         self._debug_time = q.time()
    --     end
    --     self._debug_time = self._debug_time + 0.135
    --     arr:addObject(CCMoveBy:create(3, ccp(0, 400)))
    --     arr:addObject(CCRemoveSelf:create())
    --     labeltip:runAction(CCSequence:create(arr))
    -- end
end

function QSoulSpiritStatusView:_onFrame(dt)
    if self._hero == nil then return end
    if self._current_rage == 1 and self._target_rage == 1 then
        self._cdRage_node:setVisible(false)
        self._cdRage:update(1)
        self._ccbOwner.sprite_full:setVisible(true)
        self._cdRage:setInverted(true)
    elseif self._target_rage > self._current_rage then
        self._current_rage = math.clamp(self._current_rage + dt * RP_SPEED, 0, self._target_rage)
        local percent = self._current_rage
        self._cdRage:update(1-percent)
        self._ccbOwner.sprite_full:setVisible(false)
        if percent > 0 then
            self._cdRage_node:setVisible(true)
            self._sprite_rage_clip:setRotation(360*percent)
        end
        self._cdRage:setInverted(true)
    else
        self._current_rage = math.clamp(self._target_rage, 0, 1)
        local percent = self._current_rage
        self._cdRage:update(1-percent)
        self._ccbOwner.sprite_full:setVisible(false)
        if percent > 0 then
            self._cdRage_node:setVisible(true)
            self._sprite_rage_clip:setRotation(360*percent)
        end
        self._cdRage:setInverted(true)
    end
end

function QSoulSpiritStatusView:onEnter()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self._ccbOwner.sprite_full:setVisible(false)
    self:scheduleUpdate_()
end

function QSoulSpiritStatusView:onExit()
    self:disconnect()
    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
    self:unscheduleUpdate()
end

return QSoulSpiritStatusView

