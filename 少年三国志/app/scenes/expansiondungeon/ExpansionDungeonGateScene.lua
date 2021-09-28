local ExpansionDungeonGateScene = class("ExpansionDungeonGateScene", UFCCSBaseScene)

function ExpansionDungeonGateScene:ctor(nChapterId, isAutoOpenShop, ...)
	self.super.ctor(self, ...)

	self._tGateLayer = require("app.scenes.expansiondungeon.ExpansionDungeonGateLayer").create(self, nChapterId, isAutoOpenShop)
	self:addUILayerComponent("ExpansionDungeonGateLayer", self._tGateLayer, true)
end

function ExpansionDungeonGateScene:onSceneEnter()
	self:_addCommonUIComponent()

	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)
end

function ExpansionDungeonGateScene:onSceneExit()
	self:_removeCommonUIComponent()
end

function ExpansionDungeonGateScene:_addCommonUIComponent()
	local tRoleInfo = G_commonLayerModel:getExDungeonRoleInfoLayer()
	local tSpeedBar = G_commonLayerModel:getSpeedbarLayer()
	self:addUILayerComponent("RoleInfoUI", tRoleInfo, true)
	self:addUILayerComponent("SpeedBar", tSpeedBar, true)
	self:adapterLayerHeight(self._tGateLayer, nil, tSpeedBar, 0, -30)
	GlobalFunc.flyIntoScreenLR({tRoleInfo}, true, 0.4, 2, 100)
end

function ExpansionDungeonGateScene:_removeCommonUIComponent()
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return ExpansionDungeonGateScene


