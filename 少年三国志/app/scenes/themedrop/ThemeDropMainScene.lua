local ThemeDropMainScene = class("ThemeDropMainScene", UFCCSBaseScene)

function ThemeDropMainScene:ctor(scenePack, ...)
	self.super.ctor(self, ...)

	self._tMainLayer = require("app.scenes.themedrop.ThemeDropMainLayer").create(scenePack)
	self:addUILayerComponent("ThemeDropMainLayer", self._tMainLayer, true)

end

function ThemeDropMainScene:onSceneEnter()
	self:_addCommonUIComponent()
end

function ThemeDropMainScene:onSceneExit()
	self:_removeCommonUIComponent()
end

function ThemeDropMainScene:_addCommonUIComponent()
	local tRoleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
	local tSpeedBar = G_commonLayerModel:getSpeedbarLayer()
	self:addUILayerComponent("RoleInfoUI", tRoleInfo, true)
	self:addUILayerComponent("SpeedBar", tSpeedBar, true)
	self:adapterLayerHeight(self._tMainLayer, tRoleInfo, tSpeedBar, -4, 0)
end

function ThemeDropMainScene:_removeCommonUIComponent()
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end


return ThemeDropMainScene
