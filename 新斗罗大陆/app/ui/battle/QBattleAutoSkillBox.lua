local QBattleAutoSkillBox = class("QBattleAutoSkillBox", function()
    return display.newNode()
end)

local QUserData = import("...utils.QUserData")
local QUIWidgetSwitchBtn = import("...widgets.QUIWidgetSwitchBtn")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QBattleAutoSkillBox.TYPE_SUPPORT = "TYPE_SUPPORT"
QBattleAutoSkillBox.TYPE_HERO = "TYPE_HERO"
QBattleAutoSkillBox.TYPE_SOULSPIRIT = "TYPE_SOULSPIRIT"

function QBattleAutoSkillBox:ctor(type, addtionIndex, callback)
    self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouchEnable))
    self:setTouchEnabled( true )

    local ccbFile
    if type == QBattleAutoSkillBox.TYPE_HERO then
        ccbFile = "Battle_AutoSkill_box.ccbi"
    elseif type == QBattleAutoSkillBox.TYPE_SUPPORT then
        ccbFile = "Battle_AutoSkill_box1.ccbi"
    elseif type == QBattleAutoSkillBox.TYPE_SOULSPIRIT then
        ccbFile = "Battle_AutoSkill_box2.ccbi"
    end
    self._type = type
    self._index = addtionIndex
    self._callback = callback

    local owner = {}

    local proxy = CCBProxy:create()
    self._ccbOwner = owner or {};

    owner.clickSkill = handler(self, QBattleAutoSkillBox.onClickSkill)
    owner.clickSkillButton = handler(self, QBattleAutoSkillBox.onClickSkill)

    self._ccbNode = CCBuilderReaderLoad(ccbFile, proxy, owner)
    self._ccbProxy = proxy;
    self:addChild(self._ccbNode)

    self:setNodeEventEnabled(true)

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

    self._button_skill = QUIWidgetSwitchBtn.new()
    self._button_skill:addEventListener(QUIWidgetSwitchBtn.EVENT_CLICK, handler(self, self.onClickSkill))
    self._button_skill:setScale(0.7)
    self._ccbOwner.btn_node:addChild(self._button_skill)
end

function QBattleAutoSkillBox:setHeroInfo(hero, skill)
    self._hero = hero
    self._skill = skill
    return self:_setupSkill()
end

function QBattleAutoSkillBox:_setupSkill()
    local skill = self._skill
    local hero = self._hero
    local castSwitchOn = true

    if skill == nil then
        local skillTexture = CCTextureCache:sharedTextureCache():addImage(global.ui_skill_icon_placeholder)
        self._ccbOwner.sprite_skillIcon:setTexture(skillTexture)
        local size = skillTexture:getContentSize()
        local rect = CCRectMake(0, 0, size.width, size.height)
        self._ccbOwner.sprite_skillIcon:setDisplayFrame(CCSpriteFrame:createWithTexture(skillTexture, rect))
        self._ccbOwner.sprite_highlight:setVisible(false)
        self._ccbOwner.node_gray:setVisible(true)
        self._ccbOwner.node_ok:setVisible(false)
        if self._ccbOwner.ccb_animationSkill then
            self._ccbOwner.ccb_animationSkill:setVisible(false)
        end
        self._ccbOwner.node_skillName:setVisible(false)
    else
        local icon = skill:getIcon()
        if self._type == QBattleAutoSkillBox.TYPE_SOULSPIRIT then
            icon = hero:getIcon()
        end
        local skillTexture = CCTextureCache:sharedTextureCache():addImage(icon)
        self._ccbOwner.sprite_skillIcon:setTexture(skillTexture)
        local size = skillTexture:getContentSize()
        local rect = CCRectMake(0, 0, size.width, size.height)
        self._ccbOwner.sprite_skillIcon:setDisplayFrame(CCSpriteFrame:createWithTexture(skillTexture, rect))

        if self._type == QBattleAutoSkillBox.TYPE_SOULSPIRIT then
            self._ccbOwner.sprite_skillIcon:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
            self._ccbOwner.sprite_skillIcon:setScale(0.8)
            local spriteFrame = QSpriteFrameByKey("fight_hero_ling")
            if spriteFrame then
                self._ccbOwner.sprite_type:setDisplayFrame(spriteFrame)
            end
        end
        if self._type == QBattleAutoSkillBox.TYPE_SUPPORT then
            local spriteFrame = QSpriteFrameByKey("fight_hero_yuan" .. self._index)
            if spriteFrame then
                self._ccbOwner.sprite_type:setDisplayFrame(spriteFrame)
            end
        end

        self._ccbOwner.sprite_highlight:setVisible(true)
        self._ccbOwner.node_gray:setVisible(false)
        self._ccbOwner.node_ok:setVisible(true)
        local autoUseSkill = app:getUserData():getUserValueForKey(hero:getActorID(true) .. self._suffix)
        if autoUseSkill == nil or autoUseSkill ~= QUserData.STRING_TRUE then
            if self._ccbOwner.ccb_animationSkill then
                self._ccbOwner.ccb_animationSkill:setVisible(false)
            end
            castSwitchOn = false -- If there is at least one cast not auto spell, show "一键开启" text.
        else
            if self._ccbOwner.ccb_animationSkill then
                self._ccbOwner.ccb_animationSkill:setVisible(true)
            end
        end
        self._button_skill:setState(castSwitchOn)
        self._ccbOwner.node_skillName:setVisible(true)
        self._ccbOwner.node_skillName:setString(skill:getLocalName() or "")
    end

    self._ccbOwner.sprite_heti:setVisible(hero ~= nil and hero:getDeputyActorIDs() ~= nil)

    return castSwitchOn
end

function QBattleAutoSkillBox:onClickSkill()
    if self._skill == nil then return end
    self:_onTriggerAutoUseSkill()
    if self._callback then
        self._callback()
    end
end

function QBattleAutoSkillBox:_onTriggerAutoUseSkill()
    local skill = self._skill
    local hero = self._hero

    if skill == nil then
        return
    end

    local autoUseSkill = app:getUserData():getUserValueForKey(hero:getActorID(true) .. self._suffix)
    if autoUseSkill == nil or autoUseSkill ~= QUserData.STRING_TRUE then
        self:changeAutoSkillState("on")
    else
        self:changeAutoSkillState("off")
    end
end

-- state should be "on" or "off"
function QBattleAutoSkillBox:changeAutoSkillState(state)
    local skill = self._skill
    local hero = self._hero

    if skill == nil then
        return
    end

    if state == "on" then
        self._ccbOwner.ccb_animationSkill:setVisible(true)
        self._button_skill:setState(true)
        hero:setForceAuto(true)
        app:getUserData():setUserValueForKey(hero:getActorID(true) .. self._suffix, QUserData.STRING_TRUE)
    else
        self._ccbOwner.ccb_animationSkill:setVisible(false)
        self._button_skill:setState(false)
        hero:setForceAuto(false)
        app:getUserData():setUserValueForKey(hero:getActorID(true) .. self._suffix, QUserData.STRING_FALSE)
    end
end

function QBattleAutoSkillBox:getAutoSkillState()
    local hero = self._hero

    if hero == nil then
        return nil
    end

    local autoUseSkill = app:getUserData():getUserValueForKey(hero:getActorID(true) .. self._suffix)
    if autoUseSkill == nil or autoUseSkill ~= QUserData.STRING_TRUE then
        return false
    else
        return true
    end
end

function QBattleAutoSkillBox:_onTouchEnable(event)
    if event.name == "began" then
        return true
    elseif event.name == "moved" then
        
    elseif event.name == "ended" then

    elseif event.name == "cancelled" then
        
    end
end

function QBattleAutoSkillBox:onExit()
    if self._skill == nil then return end
end

return QBattleAutoSkillBox
