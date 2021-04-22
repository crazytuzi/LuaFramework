--[[
    QNpcActorView 
--]]

local QTouchActorView = import(".QTouchActorView")
local QNpcActorView = class("QNpcActorView", QTouchActorView)

local QBaseEffectView = import(".QBaseEffectView")
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QNpcActorView:ctor(actor, skeletonView)
    QNpcActorView.super.ctor(self, actor, skeletonView)

    local properties = QStaticDatabase.sharedDatabase():getCharacterByID(actor:getActorID())
    if properties.npc_skill_list then
	    self._selectSourceCircle = QBaseEffectView.new(QTouchActorView.HERO_ENEMY_EFFECT_SOURCE_FILE, nil, nil, {scale = actorScale, sizeRenderTexture = CCSize(96, 32)})
	    self._selectSourceCircle:setScale(1.2)
	    self:addChild(self._selectSourceCircle, -1)
	    self._selectSourceCircle:setVisible(false)
	    self._selectSourceCircle:setVisible(true)
	    self._selectSourceCircle:playAnimation(self._selectSourceCircle:getPlayAnimationName(), true)
	end
end

function QNpcActorView:onEnter()
    QNpcActorView.super.onEnter(self)
    self:setEnableTouchEvent(true)
end

function QNpcActorView:_displaySkillName()
    if not self._labelSkillLockTime or (q.time() - self._labelSkillLockTime) > 1.0 then
        local actor = self._actor
        local skill = actor:getCurrentSkill()
        local name = skill and skill:getDisplayName() or ""
        if skill and (skill:getSkillType() == skill.MANUAL and ENABLE_MANUAL_SKILL_DISPLAY)
            and actor:getType() == ACTOR_TYPES.NPC and (actor:isBoss() or actor:isEliteBoss())
            and name ~= "" then
            self._labelSkill:setString(name)
            self._labelSkill:setVisible(true)
            -- self._hpViewNode:setVisible(false)
        else
            self._labelSkill:setString("")
            self._labelSkill:setVisible(false)
            -- self._hpViewNode:setVisible(true)
        end
    end
end

function QNpcActorView:onExit()
    QNpcActorView.super.onExit(self)
    self:setEnableTouchEvent(false)
end

return QNpcActorView
