--LegionMapScene.lua

local LegionMapScene = class("LegionMapScene", UFCCSBaseScene)


function LegionMapScene:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionMapScene:onSceneLoad( chapterIndex )
	self._mainBody = require("app.scenes.legion.LegionMapLayer").create( chapterIndex )
	self:addUILayerComponent("LegionMapLayer", self._mainBody, false)
end

function LegionMapScene:onSceneEnter( ... )
	local headerInfo = G_commonLayerModel:getShopRoleInfoLayer()
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)
    self:addUILayerComponent("Header", headerInfo,true)
	self:adapterLayerHeight(self._mainBody, headerInfo, speedBar, -4, -60)
	GlobalFunc.flyIntoScreenLR( { headerInfo }, true, 0.4, 2, 100)
end

function LegionMapScene:onSceneExit( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "Header")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return LegionMapScene

