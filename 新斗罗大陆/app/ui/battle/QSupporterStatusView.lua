
local QSupporterStatusView = class("QSupporterStatusView", function()
    return display.newNode()
end)

local QCircleUiMask = import(".QCircleUiMask")
local QUserData = import("...utils.QUserData")

function QSupporterStatusView:ctor()
	local ccbFile = "ccb/Battle_But_fujiang.ccbi"
    local proxy = CCBProxy:create()
    self._ccbOwner = {}        
    self._ccbOwner.clickSkill1 = handler(self, QSupporterStatusView._onClickSkillButton1)

    local ccbView = CCBuilderReaderLoad(ccbFile, proxy, self._ccbOwner)
    if ccbView == nil then
        assert(false, "load ccb file:" .. ccbFile .. " faild!")
    end
    self:addChild(ccbView)

    -- self._mpBar = q.newPercentBarClippingNode(self._ccbOwner.sprite_mpFront)
    self.stencil = q.createHpBar(self._ccbOwner.sprite_mpFront)

    self._ccbOwner.sprite_skillIcon1 = self._ccbOwner.sprite_skillIcon1_1
    self._ccbOwner.sprite_highlight1 = self._ccbOwner.sprite_highlight1_1
    self._ccbOwner.node_gray1 = self._ccbOwner.node_gray1_1
    self._ccbOwner.node_ok1 = self._ccbOwner.node_ok1_1
    self._ccbOwner.ccb_animationSkill1 = self._ccbOwner.ccb_animationSkill1_1
    self._ccbOwner.button_skill1 = self._ccbOwner.button_skill1_1

    self:setNodeEventEnabled(true)
end

local function decorner(sprite)
    local parent = sprite:getParent()
    sprite:retain()
    sprite:removeFromParent()
    local node = display.newNode()
    parent:addChild(node)
    node:addChild(sprite)
    node:setPosition(ccp(sprite:getPosition()))
    sprite:setPosition(ccp(0, 0))
    sprite:release()

    local hwidth, hheight = sprite:getContentSize().width / 2 + 4, sprite:getContentSize().height / 2 + 4
    local length = 20
    local func = ccBlendFunc()
    func.src = GL_ZERO
    func.dst = GL_SRC_COLOR

    local layer = CCLayerColor:create(ccc4(255, 255, 255, 0), length, length)
    layer:setRotation(45)
    layer:setPosition(ccp(hwidth - length / 2, hheight - length / 2))
    node:addChild(layer, -1000)
    layer:setBlendFunc(func)
    
    local layer = CCLayerColor:create(ccc4(255, 255, 255, 0), length, length)
    layer:setRotation(45)
    layer:setPosition(ccp(-hwidth - length / 2, -hheight - length / 2))
    node:addChild(layer, -1000)
    layer:setBlendFunc(func)
    
    local layer = CCLayerColor:create(ccc4(255, 255, 255, 0), 25, 25)
    layer:setRotation(45)
    layer:setPosition(ccp(hwidth - 25 / 2, -hheight - 25 / 2))
    node:addChild(layer, -1000)
    layer:setBlendFunc(func)

    local func = ccBlendFunc()
    func.src = GL_DST_ALPHA
    func.dst = GL_ONE_MINUS_DST_ALPHA
    sprite:setBlendFunc(func)
    
    local layer = CCLayerColor:create(ccc4(0, 0, 0, 255), length, length)
    layer:setRotation(45)
    layer:setPosition(ccp(-hwidth - length / 2, -hheight - length / 2))
    node:addChild(layer)
    local func2 = ccBlendFunc()
    func2.src = GL_ONE
    func2.dst = GL_ONE
    layer:setBlendFunc(func2)
end

function QSupporterStatusView:setSupporter(hero)
	assert(hero, "QSupporterStatusView:supporter invaild supporter value")

	self._hero = hero

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

        decorner(self._ccbOwner.sprite_skillIcon1)
        decorner(self._ccbOwner.sprite_icon_bg)

        self._ccbOwner.sprite_highlight1:removeFromParent()
        self._ccbOwner.sprite_highlight1 = nil
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

        local sprite = CCSprite:create(icons[1])
        sprite:updateDisplayedColor(global.ui_skill_icon_disabled_overlay)

        local size = self._ccbOwner.sprite_skillIcon1:getContentSize()
        self._ccbOwner.sprite_skillIcon1:addChild(sprite)
        sprite:setPosition(size.width * 0.5, size.height * 0.5)
        self._cdSprite = sprite
        decorner(sprite)
    end

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

    if app.battle:isPVPMode() == true
        and ((app.battle:isInArena() == true
            and app.battle:isInGlory() == false
            and app.battle:isInTotemChallenge() == false)
        or app.battle:isInSilverMine()) then

        self._hero:setForceAuto(true)
        self._ccbOwner.ccb_animationAutoSkill1:setVisible(true)
    end

    -- 是否为合体技
    self._ccbOwner.sprite_heti:setVisible(hero:getDeputyActorIDs() ~= nil)

    if app.scene:isAutoTwoWavePVP() then
        self._ccbOwner.ccb_animationAutoSkill1:setVisible(false)
        self._ccbOwner.sprite_heti:setVisible(false)
        self._ccbOwner.sprite_yuan:setVisible(false)
        -- self._ccbOwner.node_bottomBar:setVisible(false)
    end

    self:onRpChanged()

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
    sprite:setColor(ccc3(63, 63, 63))

    self._cd1_node:setVisible(false)
    self._cd1:update(1.0)
end

function QSupporterStatusView:onEnter()
    if self._skill1 ~= nil then
        local skill = self._skill1
        self._skillEventProxy1 = cc.EventProxy.new(self._skill1)
        self._skillEventProxy1:addEventListener(QDEF.EVENT_CD_CHANGED, handler(self, self.onCdChanged))
        self._skillEventProxy1:addEventListener(QDEF.EVENT_CD_STARTED, handler(self, self.onCdStarted))
        self._skillEventProxy1:addEventListener(QDEF.EVENT_CD_STOPPED, handler(self, self.onCdStopped))
        self._skillEventProxy1:addEventListener(skill.EVENT_SKILL_DISABLE, handler(self, self.onSkillDisable))
        self._skillEventProxy1:addEventListener(skill.EVENT_SKILL_ENABLE, handler(self, self.onSkillEnable))
    end

    if self._hero ~= nil then
        self._heroEventProxy = cc.EventProxy.new(self._hero)
        self._heroEventProxy:addEventListener(self._hero.USE_MANUAL_SKILL_EVENT, handler(self, self._onUseSkill))
        self._heroEventProxy:addEventListener(self._hero.RP_CHANGED_EVENT, handler(self, self.onRpChanged))
        self._heroEventProxy:addEventListener(self._hero.FORCE_AUTO_CHANGED_EVENT, handler(self, self.onForceChanged))
        self:onRpChanged()
    end

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()
end

function QSupporterStatusView:onExit()
    if self._skillEventProxy1 ~= nil then
        self._skillEventProxy1:removeAllEventListeners()
        self._skillEventProxy1 = nil
    end

    if self._heroEventProxy ~= nil then
        self._heroEventProxy:removeAllEventListeners()
        self._heroEventProxy = nil
    end

    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
end

function QSupporterStatusView:getActor()
    return self._hero
end

function QSupporterStatusView:onSkillDisable(event)
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

function QSupporterStatusView:onSkillEnable(event)
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

function QSupporterStatusView:onCdStarted(event)
    
end

function QSupporterStatusView:onCdStopped(event)
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

function QSupporterStatusView:_onUseSkill(event)
    if event == nil or event.skill == nil then
        return
    end

    local skillNode = nil
    if event.skill == self._skill1 then
        skillNode = self._ccbOwner.ccb_animationSkill1
    end

    if skillNode ~= nil then
        local animationManager = tolua.cast(skillNode:getUserObject(), "CCBAnimationManager")
        if animationManager ~= nil then 
            animationManager:runAnimationsForSequenceNamed(global.ui_skill_icon_effect_release)
        end
    end
end

function QSupporterStatusView:_onFrame(dt)
    if self._skill1 then
        local ready = self._hero:isSupportSkillReady()
        self._ccbOwner.ccb_animationSkill1:setVisible(ready)
        self._cdSprite:setVisible(not ready)

        local last_ready = self._last_ready
        if ready and not self._last_ready then     
            local animationManager = tolua.cast(self._ccbOwner.ccb_animationSkill1:getUserObject(), "CCBAnimationManager")
            if animationManager ~= nil then 
                animationManager:runAnimationsForSequenceNamed(global.ui_skill_icon_effect_cdok)
            end
        end
        self._last_ready = ready

        self:setVisible(self._hero:isSupportSkillCountAvailable())

        local isCDOK = self._skill1:isCDOK()
        if not isCDOK then
            self._cd1_node:setVisible(true)
            makeNodeFromNormalToGray(self._ccbOwner.sprite_skillIcon1)
        else
            self._cd1_node:setVisible(false)
            makeNodeFromGrayToNormal(self._ccbOwner.sprite_skillIcon1)
        end
    end
end

function QSupporterStatusView:_onClickSkillButton1()
    if app.battle:isPausedBetweenWave() == true then
        return
    end

    local battle = app.battle
    if app.battle:isInReplay() and app.battle:isInQuick() then
        app.tip:floatTip(global.replay_warning) 
        return
    end

	if self._skill1 ~= nil and self._hero:isDead() == false and self._hero:isSupportSkillReady() then
		app.battle:useSupportHeroSkill(self._hero, true)
    end
end

function QSupporterStatusView:onRpChanged(event)
    local percent = self._hero:getRage() / self._hero:getRageTotal()

    -- self._ccbOwner.sprite_mpFront:setScaleX(percent * 0.523)

    -- local totalStencilWidth = self.stencil:getContentSize().width * self.stencil:getScaleX()
    -- self.stencil:setPositionX(-totalStencilWidth + percent*totalStencilWidth)
    self.stencil:update(percent)

    self._ccbOwner.node_mpFulls:setVisible(percent >= 1.0)
    self._ccbOwner.sprite_mpBack:setVisible(percent >= 1.0)

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

function QSupporterStatusView:onForceChanged(event)
    if app.scene:isAutoTwoWavePVP() then return end

    if event.forceAuto == true then
        self._ccbOwner.ccb_animationAutoSkill1:setVisible(true)
    else
        self._ccbOwner.ccb_animationAutoSkill1:setVisible(false)
    end
end

function QSupporterStatusView:getSpriteYuan()
    return self._ccbOwner.sprite_yuan
end

function QSupporterStatusView:onCdChanged(event)
    if self._hero:isDead() == true then
        return
    end
    
    if event.skill == self._skill1 then
        local percent = 1 - event.cd_progress
        if event.skill:isCDOK() then
            self._cd1:update(1)
        else
            self._cd1:update(percent)
        end
    end
end

return QSupporterStatusView