--LegionHigEggScene.lua


local LegionNewHigEggScene = class("LegionNewHigEggScene", UFCCSBaseScene)


function LegionNewHigEggScene:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionNewHigEggScene:onSceneLoad( chapterIndex )
	self._mainBody = require("app.scenes.legion.LegionNewHitEggLayer").create( chapterIndex )
	self:addUILayerComponent("LegionHitEggLayer", self._mainBody, false)
end

function LegionNewHigEggScene:onSceneEnter( ... )
	local headerInfo = G_commonLayerModel:getShopRoleInfoLayer()
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)
    self:addUILayerComponent("Header", headerInfo,true)
	self:adapterLayerHeight(self._mainBody, headerInfo, speedBar, -4, -20)
end
-- require("app.scenes.legion.LegionTreasurePreviewLayer").show()

return LegionNewHigEggScene
