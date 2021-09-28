--LegionCrossDateScene.lua


local LegionCrossDateScene = class("LegionCrossDateScene", UFCCSBaseScene)


function LegionCrossDateScene:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionCrossDateScene:onSceneLoad( ... )
	self._mainBody = require("app.scenes.legion.battle.LegionCrossDateLayer").create()
	self:addUILayerComponent("LegionListLayer", self._mainBody, false)
end

function LegionCrossDateScene:onSceneEnter( ... )
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)

    self:adapterLayerHeight(self._mainBody, nil, speedBar, 0, -100)
    self:registerKeypadEvent(true)
end

function LegionCrossDateScene:onSceneExit( ... )
	-- body
end

function LegionCrossDateScene:onBackKeyEvent( ... )
	if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
	end

	return true
end

return LegionCrossDateScene
