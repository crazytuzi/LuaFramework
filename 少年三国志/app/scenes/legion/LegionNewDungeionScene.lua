--LegionNewDungeionScene.lua

local LegionNewDungeionScene = class("LegionNewDungeionScene", UFCCSBaseScene)


function LegionNewDungeionScene:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionNewDungeionScene:onSceneLoad( ... )
	self._mainBody = require("app.scenes.legion.LegionNewDungeonListLayer").create()
	self:addUILayerComponent("LegionNewDungeonListLayer", self._mainBody, false)

	local headerInfo = G_commonLayerModel:getShopRoleInfoLayer()
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)
    self:addUILayerComponent("Header", headerInfo,true)
	self:adapterLayerHeight(self._mainBody, headerInfo, speedBar, -4, -50)
	GlobalFunc.flyIntoScreenLR( { headerInfo }, true, 0.4, 2, 100)
end

function LegionNewDungeionScene:onSceneEnter( ... )
end


return LegionNewDungeionScene
