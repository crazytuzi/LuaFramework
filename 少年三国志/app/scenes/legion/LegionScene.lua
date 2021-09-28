--LegionScene.lua


local LegionScene = class("LegionScene", UFCCSBaseScene)


function LegionScene:ctor( ... )
	self._sceneIsEnter = false
	self.super.ctor(self, ...)
end

function LegionScene:onSceneLoad( _, _, _, _, scenePack )
	self._mainBody = require("app.scenes.legion.LegionMainLayer").create(scenePack)
	self:addUILayerComponent("LegionMainLayer", self._mainBody, false)
end

function LegionScene:onSceneEnter( ... )
	local headerInfo = G_commonLayerModel:getShopRoleInfoLayer()
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)
    self:addUILayerComponent("Header", headerInfo,true)
	self:adapterLayerHeight(self._mainBody, headerInfo, speedBar, -15, -15)

	if not self._sceneIsEnter then
		GlobalFunc.flyIntoScreenLR( { headerInfo }, true, 0.4, 2, 100)
		--self._mainBody:adapterLayer()
	end

	self._sceneIsEnter = true
end

function LegionScene:onSceneExit( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "Header")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return LegionScene

