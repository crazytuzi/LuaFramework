local TimePrivilegeMainScene = class("TimePrivilegeMainScene", UFCCSBaseScene)

function TimePrivilegeMainScene:ctor(...)
	self.super.ctor(self, ...)

	self._tMainLayer = require("app.scenes.timeprivilege.TimePrivilegeMainLayer").create()
	self:addUILayerComponent("TimePrivilegeMainLayer", self._tMainLayer, true)
	self:_addCommonUIComponent()
end

function TimePrivilegeMainScene:onSceneEnter()

end

function TimePrivilegeMainScene:onSceneExit()
	self:_removeCommonUIComponent()
end

function TimePrivilegeMainScene:_addCommonUIComponent()
	local tRoleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
	local tSpeedBar = G_commonLayerModel:getSpeedbarLayer()
	self:addUILayerComponent("RoleInfoUI", tRoleInfo, true)
--	self:addUILayerComponent("SpeedBar", tSpeedBar, true)
	self:adapterLayerHeight(self._tMainLayer, tRoleInfo, nil, -12, 0)
end

function TimePrivilegeMainScene:_removeCommonUIComponent()
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
--    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end


return TimePrivilegeMainScene