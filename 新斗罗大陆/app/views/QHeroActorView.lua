--[[
    Class name QHeroActorView 
    Create by julian 
    This class is a hero actor.
--]]

local QTouchActorView = import(".QTouchActorView")
local QHeroActorView = class("QHeroActorView", QTouchActorView)

local QBaseEffectView = import(".QBaseEffectView")
local QBaseActorView = import(".QBaseActorView")

function QHeroActorView:ctor(hero, skeletonView)
    QHeroActorView.super.ctor(self, hero, skeletonView)
    self._canTouchBegin = true

    if app.battle:isPVPMode() and not ((app.battle:isInSunwell() and app.battle:isSunwellAllowControl()) or app.battle:isInArena()) then
        if hero:getType() == ACTOR_TYPES.HERO or hero:getType() == ACTOR_TYPES.HERO_NPC then
            self._selectSourceCircle = QBaseEffectView.new(QBaseActorView.SELECT_EFFECT_SOURCE_FILE, nil, nil, {scale = actorScale, sizeRenderTexture = CCSize(96, 32)})
            self._selectSourceCircle:setScale(1.2)
            self:addChild(self._selectSourceCircle, -1)
            self._selectSourceCircle:setVisible(false)
            self._selectSourceCircle:setVisible(true)
            self._selectSourceCircle:playAnimation(self._selectSourceCircle:getPlayAnimationName())
        else
            self._selectSourceCircle = QBaseEffectView.new(QBaseActorView.ENEMY_SELECT_EFFECT_SOURCE_FILE, nil, nil, {scale = actorScale, sizeRenderTexture = CCSize(96, 32)})
            self._selectSourceCircle:setScale(1.2)
            self:addChild(self._selectSourceCircle, -1)
            self._selectSourceCircle:setVisible(false)
            self._selectSourceCircle:setVisible(true)
            self._selectSourceCircle:playAnimation(self._selectSourceCircle:getPlayAnimationName())
        end
    end

    if app.battle:isInSunwell() and app.battle:isSunwellAllowControl() or (app.battle:isInArena() and app.battle:isArenaAllowControl()) then
        if hero:getType() == ACTOR_TYPES.HERO or hero:getType() == ACTOR_TYPES.HERO_NPC then
        else
            self._selectSourceCircle = CCSprite:create(global.ui_npc_circle)
            -- 这里是为了修复线上可能由于资源损坏导致的报错bug
            if self._selectSourceCircle == nil then
                self._selectSourceCircle = QBaseEffectView.new(QBaseActorView.ENEMY_SELECT_EFFECT_SOURCE_FILE, nil, nil, {scale = actorScale, sizeRenderTexture = CCSize(96, 32)})
                self._selectSourceCircle:playAnimation(EFFECT_ANIMATION)
            end
            self._selectSourceCircle:setScale(0.5)
            self:addChild(self._selectSourceCircle, -1)
            self._selectSourceCircle:setVisible(false)
            self._selectSourceCircle:setVisible(true)
        end
    end

    if ENABLE_SKILL_DISPLAY then
        self._labelSkill:setString("") -- ccb preload
    end
end

function QHeroActorView:_displaySkillName()
    if not self._labelSkillLockTime or (q.time() - self._labelSkillLockTime) > 1.0 then
        local actor = self._actor
        local skill = actor:getCurrentSkill()
        if skill and (skill:getSkillType() == skill.ACTIVE and not skill:isTalentSkill()) then
            self._labelSkill:setString(skill:getName())
            self._labelSkill:setVisible(true)
            -- self._hpViewNode:setVisible(false)
        else
            self._labelSkill:setString("")
            self._labelSkill:setVisible(false)
            -- self._hpViewNode:setVisible(true)
        end
    end
end

function QHeroActorView:onEnter()
    QHeroActorView.super.onEnter(self)
    self:setEnableTouchEvent(true)
end

function QHeroActorView:onExit()
    self:setEnableTouchEvent(false)
    QHeroActorView.super.onExit(self)
end

return QHeroActorView
