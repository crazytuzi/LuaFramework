local ExpansionDungeonMainScene = class("ExpansionDungeonMainScene", UFCCSBaseScene)

function ExpansionDungeonMainScene:ctor(scenePack, ...)
	self.super.ctor(self, ...)

	self._tMainLayer = require("app.scenes.expansiondungeon.ExpansionDungeonMainLayer").create(scenePack)
	self:addUILayerComponent("ThemeDropMainLayer", self._tMainLayer, true)

end

function ExpansionDungeonMainScene:onSceneEnter()
	self:_addCommonUIComponent()

	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)
end

function ExpansionDungeonMainScene:onSceneExit()
	self:_removeCommonUIComponent()
end

function ExpansionDungeonMainScene:_addCommonUIComponent()
	local tRoleInfo = G_commonLayerModel:getExDungeonRoleInfoLayer()
	local tSpeedBar = G_commonLayerModel:getSpeedbarLayer()
	self:addUILayerComponent("RoleInfoUI", tRoleInfo, true)
	self:addUILayerComponent("SpeedBar", tSpeedBar, true)
	self:adapterLayerHeight(self._tMainLayer, nil, tSpeedBar, 0, 0)
	GlobalFunc.flyIntoScreenLR({tRoleInfo}, true, 0.4, 2, 100)
end

function ExpansionDungeonMainScene:_removeCommonUIComponent()
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end


return ExpansionDungeonMainScene
