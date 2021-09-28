-- if the player want to forge an orange-quality treasure into a red-quality treasure, 
-- and meanwhile the orange-quality treasure is currently equipped, then show this layer
-- to tell the player that the treasure will be unloaded if he confirm to forge it.
local TreasureForgeConfirm = class("TreasureForgeConfirm", UFCCSModelLayer)

function TreasureForgeConfirm.create(teamId, teamPos, treasureSlot, ...)
	return TreasureForgeConfirm.new("ui_layout/treasure_TreasureForgeConfirm.json",
		Colors.modelColor, teamId, teamPos, treasureSlot, ...)
end

function TreasureForgeConfirm:ctor(json, color, teamId, teamPos, treasureSlot, ...)
	self._teamId = teamId
	self._teamPos = teamPos
	self._treasureSlot = treasureSlot
	self.super.ctor(self, ...)
end

function TreasureForgeConfirm:onLayerLoad(...)
	-- create stroke
	self:enableLabelStroke("Label_Desc", Colors.strokeBrown, 1)

	-- register button-click events
	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onClickConfirm))
	self:registerBtnClickEvent("Button_Cancel", handler(self, self._onClickCancel))
end

function TreasureForgeConfirm:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)
end

function TreasureForgeConfirm:_onClickConfirm()
	G_HandlersManager.fightResourcesHandler:sendClearFightTreasure(self._teamId , self._teamPos, self._treasureSlot)
	self:animationToClose()
end

function TreasureForgeConfirm:_onClickCancel()
	self:animationToClose()
end

return TreasureForgeConfirm