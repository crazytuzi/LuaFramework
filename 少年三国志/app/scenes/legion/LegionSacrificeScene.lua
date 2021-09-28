--LegionSacrificeScene.lua


local LegionSacrificeScene = class("LegionSacrificeScene", UFCCSBaseScene)


function LegionSacrificeScene:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionSacrificeScene:onSceneLoad( ... )
	self._mainBody = require("app.scenes.legion.LegionSacrificeLayer").create()
	self:addUILayerComponent("LegionSacrificeLayer", self._mainBody, false)
end

function LegionSacrificeScene:onSceneEnter( ... )
	local headerInfo = G_commonLayerModel:getShopRoleInfoLayer()
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)
    self:addUILayerComponent("Header", headerInfo,true)
	self:adapterLayerHeight(self._mainBody, headerInfo, speedBar, -30, 0)
	GlobalFunc.flyIntoScreenLR( { headerInfo }, true, 0.4, 2, 100)
end


return LegionSacrificeScene

