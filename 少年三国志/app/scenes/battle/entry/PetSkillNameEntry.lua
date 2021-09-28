require("app.cfg.skill_info")

local PetSkillNameEntry = class("PetSkillNameEntry", require("app.scenes.battle.entry.TweenEntry"))

function PetSkillNameEntry:ctor(...)
	PetSkillNameEntry.super.ctor(self, ...)
	self._battleField:addToPetAttackNode(self._node, 1)
	self._node:setPosition(self._node:getParent():convertToNodeSpace(ccp(display.cx, display.cy)))
end

function PetSkillNameEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
	local attack = self._data

	local displayNode = node
	if not displayNode then
		if tweenNode == "skillname" then
			local skillID = attack.skill_id
			local skillText = skill_info.get(skillID).txt
			local textSprite = display.newSprite(G_Path.getBattleSkillTextImage(skillText..'.png'))

			displayNode = display.newNode()
			displayNode:addChild(textSprite)
			displayNode:setCascadeOpacityEnabled(true)
            displayNode:setCascadeColorEnabled(true)
		end
	end

	assert(displayNode, "Unknown tweenNode: "..tweenNode)

	if displayNode then
		self._node:addChild(displayNode, tween.order or 0)
	end

	return displayNode
end

return PetSkillNameEntry	