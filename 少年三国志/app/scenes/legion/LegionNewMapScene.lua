--LegionNewMapScene.lua

local LegionNewMapScene = class("LegionNewMapScene", UFCCSBaseScene)


function LegionNewMapScene:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionNewMapScene:onSceneLoad( chapterIndex )
	self._mainBody = require("app.scenes.legion.LegionNewMapLayer").create( chapterIndex )
	self:addUILayerComponent("LegionNewMapLayer", self._mainBody, false)
end

function LegionNewMapScene:onSceneEnter( ... )
	local headerInfo = G_commonLayerModel:getShopRoleInfoLayer()
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)
    self:addUILayerComponent("Header", headerInfo,true)
	self:adapterLayerHeight(self._mainBody, headerInfo, speedBar, -4, -50)
	GlobalFunc.flyIntoScreenLR( { headerInfo }, true, 0.4, 2, 100)
end

function LegionNewMapScene:onSceneExit( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "Header")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return LegionNewMapScene

