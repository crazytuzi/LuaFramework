--LegionListScene.lua

local LegionListScene = class("LegionListScene", UFCCSBaseScene)


function LegionListScene:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionListScene:onSceneLoad( _, _, _, _, scenePack )
	self._mainBody = require("app.scenes.legion.LegionListLayer").create(scenePack)
	self:addUILayerComponent("LegionListLayer", self._mainBody, false)
end

function LegionListScene:onSceneEnter( ... )
	local headerInfo = G_commonLayerModel:getShopRoleInfoLayer()
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)
    self:addUILayerComponent("Header", headerInfo,true)
	self:adapterLayerHeight(self._mainBody, headerInfo, speedBar, -8, -15)
end


return LegionListScene

