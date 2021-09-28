local RebelBossMainScene = class("RebelBossMainScene", UFCCSBaseScene)

function RebelBossMainScene:ctor(enterFromAwardShortcut, ...)
	self.super.ctor(self, ...)

	G_Me.moshenData:setEnterFromAwardShortcut(enterFromAwardShortcut or false)

	self._tMainLayer = require("app.scenes.moshen.rebelboss.RebelBossMainLayer").create()
	self:addUILayerComponent("WorldBossMainLayer", self._tMainLayer, true)
	self:_addCommonUIComponent()
end

function RebelBossMainScene:onSceneEnter()

end

function RebelBossMainScene:onSceneExit()
	self:_removeCommonUIComponent()
end

function RebelBossMainScene:_addCommonUIComponent()
	local tRoleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
	local tSpeedBar = G_commonLayerModel:getSpeedbarLayer()
	self:addUILayerComponent("RoleInfoUI", tRoleInfo, true)
	self:addUILayerComponent("SpeedBar", tSpeedBar, true)
	self:adapterLayerHeight(self._tMainLayer, tRoleInfo, tSpeedBar, -10, 0)
end

function RebelBossMainScene:_removeCommonUIComponent()
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end


return RebelBossMainScene