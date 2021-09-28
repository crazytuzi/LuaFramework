local TreasureRobAllScene = class("TreasureRobAllScene", UFCCSBaseScene)

function TreasureRobAllScene:ctor(treasureID, autoUseEnergy)
	self.super.ctor(self, treasureID, autoUseEnergy)
end

function TreasureRobAllScene:onSceneLoad(treasureID, autoUseEnergy)
	if self._mainBody == nil then
		self._mainBody = require("app.scenes.treasure.TreasureRobAllLayer").create(treasureID, autoUseEnergy)
		self:addUILayerComponent("TreasureRobAll", self._mainBody, true)
	end
end

return TreasureRobAllScene