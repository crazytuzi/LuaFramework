--LegionHigEggScene.lua


local LegionHigEggScene = class("LegionHigEggScene", UFCCSBaseScene)


function LegionHigEggScene:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionHigEggScene:onSceneLoad( chapterIndex )
	self._mainBody = require("app.scenes.legion.LegionHitEggLayer").create( chapterIndex )
	self:addUILayerComponent("LegionHitEggLayer", self._mainBody, false)
end

function LegionHigEggScene:onSceneEnter( ... )
	local headerInfo = G_commonLayerModel:getShopRoleInfoLayer()
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)
    self:addUILayerComponent("Header", headerInfo,true)
	self:adapterLayerHeight(self._mainBody, headerInfo, speedBar, -4, -20)
end


return LegionHigEggScene
