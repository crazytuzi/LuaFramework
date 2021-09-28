local KnightTransformMainScene = class("KnightTransformMainScene", UFCCSBaseScene)

function KnightTransformMainScene:ctor(...)
	self.super.ctor(self, ...)

	self._tMainLayer = require("app.scenes.knighttransform.KnightTransformMainLayer").create()
	self:addUILayerComponent("KnightTransformMainLayer", self._tMainLayer, true)
	self:_addCommonUIComponent()
end

function KnightTransformMainScene:onSceneEnter()

end

function KnightTransformMainScene:onSceneExit()
	self:_removeCommonUIComponent()
end

function KnightTransformMainScene:_addCommonUIComponent()
	local tRoleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
	local tSpeedBar = G_commonLayerModel:getSpeedbarLayer()
	self:addUILayerComponent("RoleInfoUI", tRoleInfo, true)
	self:addUILayerComponent("SpeedBar", tSpeedBar, true)
	self:adapterLayerHeight(self._tMainLayer, tRoleInfo, tSpeedBar, -4, 0)
end

function KnightTransformMainScene:_removeCommonUIComponent()
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end


return KnightTransformMainScene