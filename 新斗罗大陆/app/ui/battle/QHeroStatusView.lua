
local QHeroStatusView = class("QHeroStatusView", function()
    return display.newNode()
end)

local QCircleUiMask = import(".QCircleUiMask")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QUserData = import("...utils.QUserData")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QHeroSkillCoolDown = import(".QHeroSkillCoolDown")

function QHeroStatusView:ctor(isNeedComboPoints)
    local ccbFile = "ccb/Battle_Skill4.ccbi"
    local proxy = CCBProxy:create()
    self._ccbOwner = {}        
    self._ccbOwner.clickSkill1 = handler(self, QHeroStatusView._onClickSkillButton1)
    self._ccbOwner.clickHead = handler(self, QHeroStatusView._onClickHeroHead)


    local ccbView = CCBuilderReaderLoad(ccbFile, proxy, self._ccbOwner)
    if ccbView == nil then
        assert(false, "load ccb file:" .. ccbFile .. " faild!")
    end
    self:addChild(ccbView)

    self.stencil = q.createHpBar(self._ccbOwner.sprite_mpFront)

    self.hpBackStencil = q.createHpBar(self._ccbOwner.sprite_hpBack)
    
    self.hpStencil = q.createHpBar(self._ccbOwner.sprite_hpFront)
    self._hpPercent = 1.0

    self._hplimitStencil = q.createHpBarRevers(self._ccbOwner.sprite_hplimit)
    self._hplimitStencil:update(1)

    self.absorbStencil = q.createHpBar(self._ccbOwner.sprite_absorb)

    self._mpLimitStencil = q.createHpBar(self._ccbOwner.sprite_mpLimitBack)

    if not isNeedComboPoints or true then
        self._ccbOwner.node_skill1:setVisible(true)
        self._ccbOwner.node_skill2:setVisible(false)
        self._ccbOwner.sprite_skillIcon1 = self._ccbOwner.sprite_skillIcon1_1
        self._ccbOwner.sprite_highlight1 = self._ccbOwner.sprite_highlight1_1
        self._ccbOwner.node_gray1 = self._ccbOwner.node_gray1_1
        self._ccbOwner.node_ok1 = self._ccbOwner.node_ok1_1
        self._ccbOwner.ccb_animationSkill1 = self._ccbOwner.ccb_animationSkill1_1
        self._ccbOwner.ccb_animationAutoSkill1 = self._ccbOwner.ccb_animationAutoSkill1_1
        self._ccbOwner.button_skill1 = self._ccbOwner.button_skill1_1
    else
        self._ccbOwner.node_skill1:setVisible(false)
        self._ccbOwner.node_skill2:setVisible(true)
        self._ccbOwner.sprite_skillIcon1 = self._ccbOwner.sprite_skillIcon1_2
        self._ccbOwner.sprite_highlight1 = self._ccbOwner.sprite_highlight1_2
        self._ccbOwner.node_gray1 = self._ccbOwner.node_gray1_2
        self._ccbOwner.node_ok1 = self._ccbOwner.node_ok1_2
        self._ccbOwner.ccb_animationSkill1 = self._ccbOwner.ccb_animationSkill1_2
        self._ccbOwner.ccb_animationAutoSkill1 = self._ccbOwner.ccb_animationAutoSkill1_2
        self._ccbOwner.button_skill1 = self._ccbOwner.button_skill1_2
    end

    self.stencil:setVisible(true)
    self._ccbOwner.node_mpFulls:setVisible(false)

    self._ccbOwner.ccb_animationCoolDown:setVisible(false)
    self._ccbOwner.ccb_animationSelectHero:setVisible(false)
    self._ccbOwner.ccb_chooseAnimationNode:setVisible(false)
    self._ccbOwner.ccb_attentionAnimationNode:setVisible(false)

    if app.scene:isAutoTwoWavePVP() then
        self._nodeHeadScaleX = self._ccbOwner.node_head:getScaleX()
    end

    self._ccbOwner.ccb_animationCoolDown:setPositionY(self._ccbOwner.ccb_animationCoolDown:getPositionY() - 25)
end

function QHeroStatusView:getHero()
    return self._hero
end

function QHeroStatusView:setHero(hero)
    self._hero = hero

    local name = hero:getDisplayName()
    if name == nil then
        name = ""
    end
    self._ccbOwner.label_shadow:setString("已选中" .. name)
    self._ccbOwner.label_name:setString("已选中" .. name)

    if not hero:isNeedComboPoints() or true then
        self._ccbOwner.node_skill1:setVisible(true)
        self._ccbOwner.node_skill2:setVisible(false)
        self._ccbOwner.sprite_skillIcon1 = self._ccbOwner.sprite_skillIcon1_1
        self._ccbOwner.sprite_highlight1 = self._ccbOwner.sprite_highlight1_1
        self._ccbOwner.node_gray1 = self._ccbOwner.node_gray1_1
        self._ccbOwner.node_ok1 = self._ccbOwner.node_ok1_1
        self._ccbOwner.ccb_animationSkill1 = self._ccbOwner.ccb_animationSkill1_1
        self._ccbOwner.ccb_animationAutoSkill1 = self._ccbOwner.ccb_animationAutoSkill1_1
        self._ccbOwner.button_skill1 = self._ccbOwner.button_skill1_1
    else
        self._ccbOwner.node_skill1:setVisible(false)
        self._ccbOwner.node_skill2:setVisible(true)
        self._ccbOwner.sprite_skillIcon1 = self._ccbOwner.sprite_skillIcon1_2
        self._ccbOwner.sprite_highlight1 = self._ccbOwner.sprite_highlight1_2
        self._ccbOwner.node_gray1 = self._ccbOwner.node_gray1_2
        self._ccbOwner.node_ok1 = self._ccbOwner.node_ok1_2
        self._ccbOwner.ccb_animationSkill1 = self._ccbOwner.ccb_animationSkill1_2
        self._ccbOwner.ccb_animationAutoSkill1 = self._ccbOwner.ccb_animationAutoSkill1_2
        self._ccbOwner.button_skill1 = self._ccbOwner.button_skill1_2
    end
    
    self._isChooseAnimationPlaying = false
    self._isAttentionAnimationPlaying = false

    -- hero icon
    if self._ccbOwner.node_head then
        if self._heroHead == nil then
            self._heroHead = QUIWidgetHeroHead.new()
            self._ccbOwner.node_head:addChild(self._heroHead)
            self._godSkillScaleX = self._heroHead._ccbOwner.sp_god_skill:getScaleX()
        end
        self._heroHead:setHeroSkinId(hero:getSkinInfo().skins_id)
        self._heroHead:setHero(hero:getActorID(), hero:getLevel())
        self._heroHead:setLevelVisible(false)
        self._heroHead:setStar(hero:getGradeValue())
        self._heroHead:setBreakthrough(hero:getBreakthroughValue())
        local heroInfo = hero:getActorInfo()
        self._heroHead:setGodSkillShowLevel(heroInfo.godSkillGrade or 0)
        if app.battle:isInTutorial() then
            self._heroHead:hideSabc()
        end
    end

    -- hero skills
    local icons = {}
    self._skills = {}
    for _, skill in pairs(self._hero:getManualSkills()) do
        table.insert(icons, skill:getIcon())
        table.insert(self._skills, skill)
        break
    end

    if table.nums(icons) == 0 then
        table.insert(icons, global.ui_skill_icon_placeholder)
    end

    if icons[1] ~= nil then
        local texture = CCTextureCache:sharedTextureCache():addImage(icons[1])
        assert(texture,"icon : "..icons[1].." file is not exist!")
        self._ccbOwner.sprite_skillIcon1:setTexture(texture)
        local size = texture:getContentSize()
        local rect = CCRectMake(0, 0, size.width, size.height)
        self._ccbOwner.sprite_skillIcon1:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))

        if self._ccbOwner.sprite_highlight1 then
            self._ccbOwner.sprite_highlight1:setVisible(false)
        end
    end

    if icons[1] == global.ui_skill_icon_placeholder then
        self._ccbOwner.node_gray1:setVisible(true)
        self._ccbOwner.node_ok1:setVisible(false)
        self._ccbOwner.button_skill1:setEnabled(false)
        self._ccbOwner.ccb_animationSkill1:setVisible(false)
    else
        self._ccbOwner.node_gray1:setVisible(false)
        self._ccbOwner.node_ok1:setVisible(true)
        self._ccbOwner.button_skill1:setEnabled(true)
        self._ccbOwner.ccb_animationSkill1:setVisible(true)
        self._skill1 = self._skills[1]

        if self._cd1 == nil then
            local sprite = CCSprite:create(icons[1])
            sprite:updateDisplayedColor(global.ui_skill_icon_disabled_overlay)
            self._cd1 = QCircleUiMask.new({hideWhenFull = true})
            self._cd1:setMaskSize(sprite:getContentSize())
            self._cd1:addChild(sprite)
            self._cd1:update(1)
            self._cd1_node = display.newNode()
            self._cd1_node:addChild(self._cd1)
            self._ccbOwner.sprite_skillIcon1:addChild(self._cd1_node)
            local size = self._ccbOwner.sprite_skillIcon1:getContentSize()
            self._cd1:setPosition(size.width * 0.5, size.height * 0.5)
        end
    end


    for _, skill in pairs(hero:getActiveSkills()) do
        if (skill:getTriggerCondition() == "drag" or skill:getTriggerCondition() == "drag_attack")
            and self._nodeSkillCooling == nil then

            local dungeonConfig = app.battle:getDungeonConfig()
            if dungeonConfig.activeSkillCoolDownView == nil or table.nums(dungeonConfig.activeSkillCoolDownView) == 0 then
                self._nodeSkillCooling = QHeroSkillCoolDown.new()
                self._nodeSkillCooling:setSkill(skill)
                self:addChild(self._nodeSkillCooling)
            else
                self._nodeSkillCooling = dungeonConfig.activeSkillCoolDownView[1]
                table.remove(dungeonConfig.activeSkillCoolDownView, 1)
                self._nodeSkillCooling:setSkill(skill)
                self:addChild(self._nodeSkillCooling)
                self._nodeSkillCooling:release()
            end

            self._skillActive = skill
            break
        end
    end

    self._needRefreshHp = false
    self._needRefreshSkillCD = false
    
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
        self._ccbOwner.ccb_animationAutoSkill1:setVisible(false)
    else
        self._hero:setForceAuto(true)
        self._ccbOwner.ccb_animationAutoSkill1:setVisible(true)
    end

    if app.battle:isForceAuto() or (app.battle:isPVPMode() == true and ((app.battle:isInArena() == true and app.battle:isInGlory() == false and app.battle:isInTotemChallenge() == false) or app.battle:isInSilverMine())) then
        self._hero:setForceAuto(true)
        self._ccbOwner.ccb_animationAutoSkill1:setVisible(true)
    end

    if hero:isNeedComboPoints() then
        -- self._ccbOwner.ccb_animationSkill1:setPosition(ccp(10000, 10000))
        self._ccbOwner.node_combo:setVisible(true)
        self._ccbOwner.sprite_mpFront:getParent():setVisible(false)
        if self._cd1_node then
            self._cd1_node:setVisible(true)
        end
    else
        self._ccbOwner.node_combo:setVisible(false)
        self._ccbOwner.sprite_mpFront:getParent():setVisible(true)
        if self._cd1_node then
            -- 非盗贼魂师没有cd进度
            self._cd1_node:setVisible(false)
        end
        self:onRpChanged()
    end

    -- 是否为合体技
    self._ccbOwner.sprite_heti:setVisible(hero:getDeputyActorIDs() ~= nil)
    self._ccbOwner.sprite_heti_2:setVisible(hero:getDeputyActorIDs() ~= nil)

    self._absorb_percent = 0
    self:updateAbsorb(0)

    self._hplimitStencil:update(1)

    self:_onFrame(0)
    self:onHpChanged()
    self:registerEvent()

    if app.scene:isAutoTwoWavePVP() then
        self._ccbOwner.node_skill1:setVisible(false)
        self._ccbOwner.node_skill2:setVisible(false)
        self._ccbOwner.sprite_heti:setVisible(false)
        self._ccbOwner.xuetiao:setScaleX(0.33)
        self._ccbOwner.xuetiao2:setScaleX(0.33)
        self._ccbOwner.xuetiao:setScaleY(0.6)
        self._ccbOwner.xuetiao2:setScaleY(0.6)
        if hero:getType() == ACTOR_TYPES.NPC then
            self._ccbOwner.node_head:setScaleX(-self._nodeHeadScaleX)
            local sp_god_skill = self._heroHead._ccbOwner.sp_god_skill
            sp_god_skill:setScaleX(-self._godSkillScaleX)
        end
    end
end

function QHeroStatusView:onEnter()
    -- self:registerEvent()
    if self._ccbOwner.sprite_combo_11 then
        local cp = self._hero:getComboPoints()
        self._ccbOwner.sprite_combo_11:setVisible(cp >= 1)
        self._ccbOwner.sprite_combo_22:setVisible(cp >= 2)
        self._ccbOwner.sprite_combo_33:setVisible(cp >= 3)
        self._ccbOwner.sprite_combo_44:setVisible(cp >= 4)
        self._ccbOwner.sprite_combo_55:setVisible(cp >= 5)
    end
    
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()
end

function QHeroStatusView:_onTouchEvent(event)
    if not app.scene._dragController then
        return
    end

    local x, y = event.x, event.y
    local pos = self._ccbOwner.button_skill1:convertToNodeSpace(ccp(x, y))
    local inrange = pos.x >= 0 and pos.x <= 100 and pos.y >= 0 and pos.y <= 100
    
    local scale = BATTLE_SCREEN_WIDTH / UI_DESIGN_WIDTH
    if event.x ~= nil then
        event.x = event.x * scale
    end
    if event.y ~= nil then
        event.y = event.y * scale
    end

    if event.name == "began" then
        if inrange then
            self._touch_began = true
        end
    elseif event.name == "moved" then
        if self._touch_began and not self._touch_out then
            self._touch_out = not inrange
        end
        if self._touch_out then
            local actorView = app.scene:getActorViewFromModel(self._hero)
            if actorView and actorView:getModel():isDead() == false then
                local drag = app.scene._dragController
                if not drag._enableDrag then
                    drag:enableDragLine(actorView, {x = event.x, y = event.y})
                else
                    actorView:onTouchMoved( nil, event.x, event.y )
                end
            end
        end
    elseif event.name == "ended" then
        if self._touch_out then
            local drag = app.scene._dragController
            if drag._enableDrag then
                local actorView = app.scene:getActorViewFromModel(self._hero)
                if actorView and actorView:getModel():isDead() == false then
                    actorView:onTouchEnd( nil, event.x, event.y )
                end
            end
            drag:disableDragLine()
        end

        self._touch_began = false
        self._touch_out = false
    end
end

function QHeroStatusView:onExit()
    if self._skillEventProxy1 ~= nil then
        self._skillEventProxy1:removeAllEventListeners()
        self._skillEventProxy1 = nil
    end

    if self._skillEventProxy3 ~= nil then
        self._skillEventProxy3:removeAllEventListeners()
        self._skillEventProxy3 = nil
    end

    if self._heroEventProxy ~= nil then
        self._heroEventProxy:removeAllEventListeners()
        self._heroEventProxy = nil
    end

    -- TODO: test code for fore auto
    if self._btnAuto then
        local _btnAuto = self._btnAuto
        _btnAuto:removeFromParent()
        _btnAuto:release()
        self._btnAuto = nil
        _btnAuto = nil
    end
    if self._labelCombo then
        local _labelCombo = self._labelCombo
        _labelCombo:removeFromParent()
        _labelCombo:release()
        self._labelCombo = nil
        _labelCombo = nil
    end

    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
    -- self:unscheduleUpdate()

    if self._touchNode then
        self._touchNode:removeAllNodeEventListeners()
        self._touchNode:removeFromParent()
        self._touchNode = nil
    end

    self:dehighlightSkillIcon()
end

function QHeroStatusView:_onFrame(dt)
    if self._skill1 then
        local isRogue = self._hero:isNeedComboPoints()
        if isRogue then
            if self._skill1:isReady() then
                if (not self._hero:canAttack(self._skill1) or not self._hero:canAttackWithBuff(self._skill1)) then
                    makeNodeFromNormalToGray(self._ccbOwner.sprite_skillIcon1)
                else
                    makeNodeFromGrayToNormal(self._ccbOwner.sprite_skillIcon1)
                end
            else
                makeNodeFromNormalToGray(self._ccbOwner.sprite_skillIcon1)
            end
        end

        local ready = false
        if self._skill1:isReady() and (not isRogue or self._hero:getComboPoints() == self._hero:getComboPointsMax()) then
            if app.battle:isPausedBetweenWave() or (not self._hero:canAttack(self._skill1) or not self._hero:canAttackWithBuff(self._skill1)) then
                self._ccbOwner.ccb_animationSkill1:setVisible(false)
                if not isRogue then
                    self._ccbOwner.sprite_skillIcon1:updateDisplayedColor(global.ui_skill_icon_disabled_overlay)
                end
            else
                self._ccbOwner.ccb_animationSkill1:setVisible(true)
                if not isRogue then
                    self._ccbOwner.sprite_skillIcon1:updateDisplayedColor(global.ui_skill_icon_enabled_overlay)
                end
                ready = true
            end
        else
            self._ccbOwner.ccb_animationSkill1:setVisible(false)
            if not isRogue then
                self._ccbOwner.sprite_skillIcon1:updateDisplayedColor(global.ui_skill_icon_disabled_overlay)
            end
        end

        local last_ready = self._last_ready
        if ready and not self._last_ready then     
            local animationManager = tolua.cast(self._ccbOwner.ccb_animationSkill1:getUserObject(), "CCBAnimationManager")
            if animationManager ~= nil then 
                animationManager:runAnimationsForSequenceNamed(global.ui_skill_icon_effect_cdok)
            end
        end
        self._last_ready = ready
    end

    if app.battle:isInTutorial() then
        self._ccbOwner.button_skill1:setVisible(false)
        self._ccbOwner.button_head:setVisible(false)
    end

    -- 不知道为何死亡时的消息会没有穿过来，这里补个漏
    if self._hero:isDead() then
        self._cd1:update(1)
        self._ccbOwner.sprite_skillIcon1:updateDisplayedColor(global.ui_skill_icon_enabled_overlay)
        self._ccbOwner.node_mpFulls:setVisible(false)
        self.hpStencil:update(0)
        self.hpBackStencil:update(0)
        makeNodeFromNormalToGray(self)
        self._ccbOwner.ccb_animationSkill1:setVisible(false)
        self._isGrayView = true
        local dRage = math.min(self._hero:getRage(), dt * 1000)
        self._hero:changeRage(-dRage)
    end

    -- 血条中间消失动画
    if self._lastUpdate == nil then return end

    local speed = 0.5 -- 每秒消退血条的速度 1 = 100%
    local hang = 0.1 -- 在开始消退动画前停顿的时间

    local cur = self._lastHpPercent - (app.battle:getTime() - self._lastUpdate - hang) * speed 
    if cur > self._lastHpPercent then return end -- 尚在停顿期内

    if cur < self._hpPercent then
        -- 已经消退到当前血条，停止动画
        cur = self._hpPercent
        -- 重置时间等待下次掉血
        self._lastUpdate = nil
    end

    self.hpBackStencil:update(cur)
end

function QHeroStatusView:getActor()
    return self._hero
end

function QHeroStatusView:onSkillDisable(event)
    if event.skill == self._skill1 then
        local texture = CCTextureCache:sharedTextureCache():addImage(global.ui_skill_icon_placeholder)
        self._ccbOwner.sprite_skillIcon1:setTexture(texture)
        local size = texture:getContentSize()
        local rect = CCRectMake(0, 0, size.width, size.height)
        self._ccbOwner.sprite_skillIcon1:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
        -- self._ccbOwner.sprite_highlight1:setVisible(false)
        self._ccbOwner.ccb_animationSkill1:setVisible(false)
    end
end

function QHeroStatusView:onSkillEnable(event)
    if event.skill == self._skill1 then
        if self._skill1 and self._skill1:getIcon() then
            local texture = CCTextureCache:sharedTextureCache():addImage(self._skill1:getIcon())
            self._ccbOwner.sprite_skillIcon1:setTexture(texture)
            local size = texture:getContentSize()
            local rect = CCRectMake(0, 0, size.width, size.height)
            self._ccbOwner.sprite_skillIcon1:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
            -- self._ccbOwner.sprite_highlight1:setVisible(true)
            self._ccbOwner.ccb_animationSkill1:setVisible(true)
        end
    end
end

function QHeroStatusView:onCdStarted(event)
    
end

function QHeroStatusView:onCdStopped(event)
    if self._hero:isDead() == true then
        return
    end
    
	if event.skill == self._skill1 then
        local animationManager = tolua.cast(self._ccbOwner.ccb_animationSkill1:getUserObject(), "CCBAnimationManager")
        if animationManager ~= nil then 
            animationManager:runAnimationsForSequenceNamed(global.ui_skill_icon_effect_cdok)
        end
	elseif event.skill == self._skillActive then
        self._ccbOwner.ccb_animationCoolDown:setVisible(false)
        self._nodeSkillCooling:playCCBAnimation()
    end
    
end

function QHeroStatusView:onCdChanged(event)
    if self._hero:isDead() == true then
        return
    end
    
	if event.skill == self._skill1 then
	    local percent = 1 - event.cd_progress
        if event.skill:isReadyAndConditionMet() then
            self._cd1:update(1)
        else
            self._cd1:update(percent)
        end
	end
end

function QHeroStatusView:updateAbsorb(percent)
    self._absorb_percent = self._absorb_percent + percent
    self.absorbStencil:update(math.clamp(self._absorb_percent,0,1))
end

function QHeroStatusView:onAbsorbChanged( event )
    if self._hero:getHp() >= 0 and self._hero:isDead() == false then
        self:updateAbsorb(event.absorb/self._hero:getMaxHp())
    end
end

function QHeroStatusView:onMaxHpChanged(event)
    local totalAbsorb = event.hpMaxBefore * self._absorb_percent
    local newPercent = totalAbsorb / self._hero:getMaxHp()
    self._absorb_percent = newPercent
    self.absorbStencil:update(math.clamp(self._absorb_percent,0,1))
end

function QHeroStatusView:onHpLimitHChanged(event)
    -- print(self._hero:getDisplayName(), "reciver onHpLimitHChanged event", event.value)
    if app.scene:isEnded() then
        return
    end

    local percent = self._hero:getRecoverHpLimit() / self._hero:getMaxHp()
    self._hplimitStencil:update(1 - percent)
end

function QHeroStatusView:onHpChanged(event)
    if app.scene:isEnded() then
        return
    end

    if self._hero:getHp() <= 0 and self._hero:isDead() then
        self._cd1:update(1)
        self._ccbOwner.node_mpFulls:setVisible(false)
        self.hpStencil:update(0)
        self.hpBackStencil:update(0)
        makeNodeFromNormalToGray(self)
        self._ccbOwner.ccb_animationSkill1:setVisible(false)
        self._isGrayView = true
    else
        if self._isGrayView == true then
            makeNodeFromGrayToNormal(self)
            self._ccbOwner.ccb_animationSkill1:setVisible(true)
            self._isGrayView = false
        end

        if self._lastUpdate == nil then
            self._lastUpdate = app.battle:getTime()
            self._lastHpPercent = self._hpPercent
            self.hpBackStencil:update(self._hpPercent)
        end

        local precent = self._hero:getHp() / self._hero:getMaxHp()
        if precent and precent < 0.01 then precent = 0.01 end -- 防止血量太少，玩家以为hero死掉了
        self._hpPercent = precent
        self.hpStencil:update(precent)

        if precent < 0.2 and self._isAttentionAnimationPlaying == false then
            local node = self._ccbOwner.ccb_attentionAnimationNode
            node:setVisible(true)
            local animationManager = tolua.cast(node:getUserObject(), "CCBAnimationManager")
            animationManager:runAnimationsForSequenceNamed("attention")
            self._isAttentionAnimationPlaying = true
        elseif precent >= 0.2 and self._isAttentionAnimationPlaying == true then
            local node = self._ccbOwner.ccb_attentionAnimationNode
            local animationManager = tolua.cast(node:getUserObject(), "CCBAnimationManager")
            animationManager:runAnimationsForSequenceNamed("normal")
            node:setVisible(false)
            self._isAttentionAnimationPlaying = false
        end
    end

end

function QHeroStatusView:onCpChanged(event)
    if self._labelCombo then
        self._labelCombo:setString(string.format("%d 连击点数", self._hero:getComboPoints()))
    end

    if self._ccbOwner.sprite_combo_11 then
    	local cp = self._hero:getComboPoints()
    	self._ccbOwner.sprite_combo_11:setVisible(cp >= 1)
    	self._ccbOwner.sprite_combo_22:setVisible(cp >= 2)
    	self._ccbOwner.sprite_combo_33:setVisible(cp >= 3)
    	self._ccbOwner.sprite_combo_44:setVisible(cp >= 4)
    	self._ccbOwner.sprite_combo_55:setVisible(cp >= 5)
    end
end

function QHeroStatusView:onRpChanged(event)
    local percent = self._hero:getRage() / self._hero:getRageTotal()
    self.stencil:update(percent)

    self._ccbOwner.node_mpFulls:setVisible(percent >= 1.0)
    self._ccbOwner.sprite_mpBack:setVisible(percent >= 1.0)

    if self._hero:getRage() > self._hero:getRageTotal() then
        local addtionRage = self._hero:getRage() - self._hero:getRageTotal()
        local addtionPercent = addtionRage / self._hero:getRageTotal()
        self._mpLimitStencil:update(addtionPercent)
        self._ccbOwner.sprite_mpLimitBack:setVisible(true)
    else
        self._ccbOwner.sprite_mpLimitBack:setVisible(false)
    end

    if event and event.showTip then
        local dRage = event.new_rage - event.old_rage
        if dRage > 0 then
            local labeltip = CCLabelTTF:create("", global.font_default, 20)
            labeltip:setString(string.format("击杀奖励\n能量 +%d", dRage))
            labeltip:setColor(ccc3(0, 0.7765 * 255, 0.9098 * 255))
            self:addChild(labeltip)
            labeltip = setShadow4(labeltip)
            labeltip:setPositionY(-37)
            labeltip:setScale(0.1)
            local arr = CCArray:create()
            arr:addObject(CCMoveBy:create(0.5, ccp(0, 62)))
            arr:addObject(CCDelayTime:create(1.5))
            arr:addObject(CCCallFunc:create(function()
                local handle, time = nil, 0
                local duration = 0.175
                handle = scheduler.scheduleGlobal(function(dt)
                    time = time + dt
                    if time > duration then
                        labeltip:removeFromParentAndCleanup(true)
                        labeltip:release()
                        scheduler.unscheduleGlobal(handle)
                    else
                        labeltip:setOpacity(math.sampler2(255, 0, 0, duration, time))
                    end
                end, 0)
            end))
            labeltip:runAction(CCSequence:create(arr))
            labeltip:runAction(CCScaleTo:create(0.5, 1.0))
            labeltip:retain()
        end
    end

    if DEBUG_RAGE and event and event.old_rage ~= event.new_rage then
        local dRage = event.new_rage - event.old_rage
        labeltip = CCLabelTTF:create("", global.font_default, 20)
        labeltip:setString(string.format("怒气变化 %d", dRage))
        labeltip:setPositionX(50)
        self:addChild(labeltip)
        local arr = CCArray:create()
        if self._debug_time ~= nil then
            if self._debug_time > q.time()  then
                arr:addObject(CCDelayTime:create(self._debug_time - q.time()))
            else 
                self._debug_time = q.time()
            end
        else
            self._debug_time = q.time()
        end
        self._debug_time = self._debug_time + 0.135
        arr:addObject(CCMoveBy:create(3, ccp(0, 400)))
        arr:addObject(CCRemoveSelf:create())
        labeltip:runAction(CCSequence:create(arr))
    end
end

function QHeroStatusView:onForceChanged(event)
    if event.forceAuto == true then
        self._ccbOwner.ccb_animationAutoSkill1:setVisible(true)
    else
        self._ccbOwner.ccb_animationAutoSkill1:setVisible(false)
    end
    if app.scene then
        app.scene:checkAutoSkillButtonHighlight()
    end
end

-- attention: skill distance is not considered in manual skill

function QHeroStatusView:_onClickSkillButton1()
    if app.battle:isPausedBetweenWave() == true then
        return
    end

    local allow, warning = app.battle:isAllowControl()
    if not allow then
        app.tip:floatTip(warning)
        return
    end

	if self._skill1 ~= nil and self._hero:isDead() == false and self._skill1:isReadyAndConditionMet() and self._hero:canAttack(self._skill1) then
        local range = app.grid:getRangeArea()
        local pos = self._hero:getPosition()
        if pos.x < range.left or pos.x > range.right then
            return
        end
        self._hero:onUseManualSkill(self._skill1)
    end
end

function QHeroStatusView:_onClickHeroHead()
    local battle = app.battle
    if app.battle:isPausedBetweenWave() == true or 
        ( battle:isPVPMode() and ((battle:isInArena() and not battle:isArenaAllowControl()) or (battle:isInSunwell() and not battle:isSunwellAllowControl())) ) then
        return
    end
    
    if app.scene:uiSelectHero(self._hero) == true then
       printInfo("on ui select hero") 
    end
end

function QHeroStatusView:_onUseSkill(event)
    if event == nil or event.skill == nil then
        return
    end

    local skillNode = nil
    if event.skill == self._skill1 then
        if self._skill1:isNeedRage() then
            return
        end
        skillNode = self._ccbOwner.ccb_animationSkill1
    end

    if skillNode ~= nil then
        local animationManager = tolua.cast(skillNode:getUserObject(), "CCBAnimationManager")
        if animationManager ~= nil then 
            animationManager:runAnimationsForSequenceNamed(global.ui_skill_icon_effect_release)
        end
    end
end

function QHeroStatusView:onSelectHero(hero)
    if self._hero == hero then
        if self._isChooseAnimationPlaying == false then
            self._ccbOwner.ccb_chooseAnimationNode:setVisible(true)
            local animationManager = tolua.cast(self._ccbOwner.ccb_chooseAnimationNode:getUserObject(), "CCBAnimationManager")
            animationManager:runAnimationsForSequenceNamed("choose")

            self._ccbOwner.ccb_animationSelectHero:setVisible(true)
            animationManager = tolua.cast(self._ccbOwner.ccb_animationSelectHero:getUserObject(), "CCBAnimationManager")
            animationManager:runAnimationsForSequenceNamed("choose_hero")

            self._isChooseAnimationPlaying = true
        end
    else
        self._ccbOwner.ccb_chooseAnimationNode:setVisible(false)
        self._ccbOwner.ccb_animationSelectHero:setVisible(false)
        self._isChooseAnimationPlaying = false
    end
end

function QHeroStatusView:playCoolDownAnimation()
    if self._skill1 == nil or self._skill1:isReady() == true then
        return
    end

    local animationManager = tolua.cast(self._ccbOwner.ccb_animationCoolDown:getUserObject(), "CCBAnimationManager")
    animationManager:disconnectScriptHandler()

    if self._nodeSkillCooling ~= nil then 
        self._nodeSkillCooling:setVisibleCCBNode(false)
    end

    self._ccbOwner.ccb_animationCoolDown:setVisible(true)
    
    animationManager:runAnimationsForSequenceNamed("cool_down")
    animationManager:connectScriptHandler(function()
        animationManager:disconnectScriptHandler()
        self._ccbOwner.ccb_animationCoolDown:setVisible(false)
    end)
end

function QHeroStatusView:playCoolDownAnimation_red(time)
    if self._label_cooldown_red == nil then
        self._label_cooldown_red = CCLabelBMFont:create("", "font/FontCooltime_red.fnt")
        self._label_cooldown_red:setString(string.format("冷却时间+%d秒", time))
        self._ccbOwner.ccb_animationCoolDown:getParent():addChild(self._label_cooldown_red)
        self._label_cooldown_red:setPosition(self._ccbOwner.ccb_animationCoolDown:getPositionX(), self._ccbOwner.ccb_animationCoolDown:getPositionY())
    end

    local arr = CCArray:create()
    arr:addObject(CCFadeIn:create(0.1667))
    arr:addObject(CCDelayTime:create(1.0))
    arr:addObject(CCFadeOut:create(0.3333))
    self._label_cooldown_red:runAction(CCSequence:create(arr))
end

function QHeroStatusView:updateSkillCD(percent)
    if percent < 0 then
        percent = 0 
    elseif percent > 1 then
        percent = 1
    end
    self._cd1:update(percent)
end

function QHeroStatusView:setHetiVisible(visible)
    if app.scene:isAutoTwoWavePVP() then
        visible = false
    end
    self._ccbOwner.sprite_heti:setVisible(not not visible)
    self._ccbOwner.sprite_heti_2:setVisible(not not visible)
end

function QHeroStatusView:hightlightSkillIconOn(highlightSheet)
    if self._nodeSkillOriginalPos ~= nil then
        return
    end

    local nodeSkill = self._ccbOwner.node_skill1
    nodeSkill:retain()
    self._nodeSkillOriginalPos = ccp(nodeSkill:getPosition())
    self._nodeSkillOriginalParent = nodeSkill:getParent()
    local worldPos = nodeSkill:getParent():convertToWorldSpace(self._nodeSkillOriginalPos)
    nodeSkill:removeFromParentAndCleanup(false)
    highlightSheet:addChild(nodeSkill)
    nodeSkill:setPosition(highlightSheet:convertToNodeSpace(worldPos))
    self._ccbOwner.button_skill1_1:setTouchEnabled(false)
end

function QHeroStatusView:dehighlightSkillIcon()
    if self._nodeSkillOriginalPos == nil then
        return
    end

    local nodeSkill = self._ccbOwner.node_skill1
    nodeSkill:removeFromParentAndCleanup(false)
    self._nodeSkillOriginalParent:addChild(nodeSkill)
    nodeSkill:setPosition(self._nodeSkillOriginalPos)
    nodeSkill:release()
    self._ccbOwner.button_skill1_1:setTouchEnabled(true)
    self._nodeSkillOriginalPos = nil
    self._nodeSkillOriginalParent = nil
end

function QHeroStatusView:registerEvent()
    self:setNodeEventEnabled(true)
    if self._skill1 ~= nil then
        local skill = self._skill1
        self._skillEventProxy1 = cc.EventProxy.new(self._skill1)
        self._skillEventProxy1:addEventListener(QDEF.EVENT_CD_CHANGED, handler(self, self.onCdChanged))
        self._skillEventProxy1:addEventListener(QDEF.EVENT_CD_STARTED, handler(self, self.onCdStarted))
        self._skillEventProxy1:addEventListener(QDEF.EVENT_CD_STOPPED, handler(self, self.onCdStopped))
        self._skillEventProxy1:addEventListener(skill.EVENT_SKILL_DISABLE, handler(self, self.onSkillDisable))
        self._skillEventProxy1:addEventListener(skill.EVENT_SKILL_ENABLE, handler(self, self.onSkillEnable))
    end

    if self._skillActive ~= nil then
        self._skillEventProxy3 = cc.EventProxy.new(self._skillActive)
        self._skillEventProxy3:addEventListener(QDEF.EVENT_CD_STOPPED, handler(self, self.onCdStopped))
    end

    if self._hero ~= nil then
        self._heroEventProxy = cc.EventProxy.new(self._hero)
        self._heroEventProxy:addEventListener(self._hero.HP_CHANGED_EVENT, handler(self, self.onHpChanged))
        self._heroEventProxy:addEventListener(self._hero.CP_CHANGED_EVENT, handler(self, self.onCpChanged))
        self._heroEventProxy:addEventListener(self._hero.RP_CHANGED_EVENT, handler(self, self.onRpChanged))
        self._heroEventProxy:addEventListener(self._hero.HP_LIMIT_CHANGE_EVENT, handler(self, self.onHpLimitHChanged))
        self._heroEventProxy:addEventListener(self._hero.FORCE_AUTO_CHANGED_EVENT, handler(self, self.onForceChanged))
        self._heroEventProxy:addEventListener(self._hero.USE_MANUAL_SKILL_EVENT, handler(self, self._onUseSkill))

        self._heroEventProxy:addEventListener(self._hero.ABSORB_CHANGE_EVENT, handler(self, self.onAbsorbChanged))
        self._heroEventProxy:addEventListener(self._hero.MAX_HP_CHANGED_EVENT, handler(self, self.onMaxHpChanged))
        self:onRpChanged()
    end

    local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(false)
    touchNode:setTouchEnabled(true)
    touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QHeroStatusView._onTouchEvent))
    self:addChild(touchNode)
    self._touchNode = touchNode
end

function QHeroStatusView:setCandidateHero(hero)
    self._candidateHero = hero
end

function QHeroStatusView:getCandidateHero()
    return self._candidateHero
end

return QHeroStatusView
