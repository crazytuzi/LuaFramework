require("app.cfg.pet_info")
local SpEntry = require("app.scenes.battle.entry.SpEntry")

local PetBuffShowEntry = class("PetBuffShowEntry", require("app.scenes.battle.entry.TweenEntry"))

-- @param data: PetSprite
-- @param objects: nil
-- @param battleField: battlelayer
function PetBuffShowEntry:ctor(data, objects, battleField)
	self._petID = data:getBaseID()
	PetBuffShowEntry.super.ctor(self, "battle/tween/tween_zc_jiacheng.json", data, objects, battleField)

	-- set position and scale
	self._node:setPositionXY(data:getPositionX(), data:getPositionY())
	self._node:setScale(data:getScale())

	battleField:addToPetAttackNode(self._node)
end

function PetBuffShowEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
	local displayNode = node
	local fx = string.gsub("f0", "%d", frameIndex)

	if not displayNode then
		if tweenNode == "text" then
			displayNode = CCSprite:create("ui/text/battle/zhanchongshenlianjiacheng.png")
		elseif tweenNode == "light" then
			local petName = pet_info.get(self._petID).ready_id
			local imgName = "sp_" .. petName .. "_light"

			local spJson = tween[fx].start
			spJson.spId = imgName
			displayNode = SpEntry.new(spJson, self._objects, self._battleField)
		end
	end

	if displayNode then
		if displayNode.isEntry then
			self:addEntryToNewQueue(displayNode, displayNode.updateEntry)
            self._node:addChild(displayNode:getObject(), tween.order or 0)
		else
			self._node:addChild(displayNode, tween.order or 0)
		end
	end

	return displayNode
end

return PetBuffShowEntry