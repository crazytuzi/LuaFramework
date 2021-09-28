local PetBuffEntry = class("PetBuffEntry", require("app.scenes.battle.entry.TweenEntry"))

function PetBuffEntry:ctor(buffType, buffValue, data, objects, battleField)
	self._buffType = buffType
	self._buffValue = buffValue
	PetBuffEntry.super.ctor(self, "battle/tween/tween_pet_add.json", data, objects, battleField)

	battleField:addToNormalSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(self._objects:convertToWorldSpaceAR(ccp(0, 130))))
end

function PetBuffEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
	local displayNode = node

	if not displayNode then
		if tweenNode == "item" then
			local buffTxt = G_lang.getPassiveSkillTypeName(self._buffType, true)
			local valueTxt = G_lang.getPassiveSkillValue(self._buffType, self._buffValue)

			displayNode = ui.newTTFLabel(
											{text = buffTxt .. "+" .. valueTxt,
											 font = "ui/font/FZYiHei-M20S.ttf",
											 size = 28,
											 align = ui.TEXT_ALIGN_CENTER
											}
										)
			displayNode:setColor(Colors.lightColors.TITLE_01)
			displayNode:createStroke(Colors.strokeBrown, 1)
		end
	end

	if displayNode then
		self._node:addChild(displayNode, tween.order or 0)
	end

	return displayNode
end

return PetBuffEntry