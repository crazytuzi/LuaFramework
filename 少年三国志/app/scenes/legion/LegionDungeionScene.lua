--LegionDungeionScene.lua

local LegionDungeionScene = class("LegionDungeionScene", UFCCSBaseScene)


function LegionDungeionScene:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionDungeionScene:onSceneLoad( ... )
	self._mainBody = require("app.scenes.legion.LegionDungeonListLayer").create()
	self:addUILayerComponent("LegionDungeonListLayer", self._mainBody, false)

	local headerInfo = G_commonLayerModel:getShopRoleInfoLayer()
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)
    self:addUILayerComponent("Header", headerInfo,true)
	self:adapterLayerHeight(self._mainBody, headerInfo, speedBar, -4, -50)
	GlobalFunc.flyIntoScreenLR( { headerInfo }, true, 0.4, 2, 100)
end

function LegionDungeionScene:onSceneEnter( ... )
end


return LegionDungeionScene
