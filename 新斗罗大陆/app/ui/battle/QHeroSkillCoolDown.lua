
local QHeroSkillCoolDown = class("QHeroSkillCoolDown", function()
    return display.newNode()
end)

function QHeroSkillCoolDown:ctor()
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    self._ccbNode = CCBuilderReaderLoad("Widget_SkillCooling.ccbi", ccbProxy, ccbOwner)

    -- self._ccbNode:setPosition(37, 90)
    -- self._ccbNode:setScale(0.85)
    self._ccbNode:setPosition(25, 90)
    self._ccbNode:setScale(0.65)
    makeNodeOpacity(ccbOwner.label_skill_name:getParent(), 0)
    ccbOwner.label_skill_name:getParent():setOpacity(255)
    self:addChild(self._ccbNode)

    self._ccbOnwer = ccbOwner
end

function QHeroSkillCoolDown:setSkill(skill)
    self._skill = skill
    local str = skill:getName() .. "冷却"
    if app.scene:isAutoTwoWavePVP() then
        str = "冷却"
        local x, y = self._ccbOnwer.sprite_skill_icon:getPosition()
        local size = self._ccbOnwer.sprite_skill_icon:getContentSize()
        self._ccbNode:setPosition(45, 90)
        self._ccbOnwer.label_skill_name:setPosition(ccp(x - 32, y - size.height))
    end
    self._ccbOnwer.label_skill_name:setString(str)
    self._ccbOnwer.sprite_skill_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(skill:getIcon()))
end

function QHeroSkillCoolDown:playCCBAnimation()
    local animationManager = tolua.cast(self._ccbNode:getUserObject(), "CCBAnimationManager")
    if animationManager ~= nil then 
        self:setVisibleCCBNode(true)
        animationManager:runAnimationsForSequenceNamed("Default Timeline")
    end
end

function QHeroSkillCoolDown:setVisibleCCBNode(visible)
    self._ccbNode:setVisible(visible)
end

return QHeroSkillCoolDown