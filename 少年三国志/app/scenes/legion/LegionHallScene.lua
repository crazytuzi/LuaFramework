--LegionHallScene.lua

local LegionHallScene = class("LegionHallScene", UFCCSBaseScene)


function LegionHallScene:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionHallScene:onSceneLoad( ... )
	self._mainBody = require("app.scenes.legion.LegionHallLayer").create(...)
	self:addUILayerComponent("LegionHallLayer", self._mainBody, false)
end

function LegionHallScene:onSceneEnter( ... )
	local headerInfo = G_commonLayerModel:getShopRoleInfoLayer()
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)
    self:addUILayerComponent("Header", headerInfo,true)
	self:adapterLayerHeight(self._mainBody, headerInfo, speedBar, -8, -15)
end

--移除通用模块
function LegionHallScene:onSceneExit( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "Header")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return LegionHallScene