--LegionCrossMainScene.lua


local LegionCrossMainScene = class("LegionCrossMainScene", UFCCSBaseScene)


function LegionCrossMainScene:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionCrossMainScene:onSceneLoad( ... )
	self._mainBody = require("app.scenes.legion.battle.LegionCrossMainLayer").create()
	self:addUILayerComponent("LegionListLayer", self._mainBody, false)
	self:registerKeypadEvent(true)
end

function LegionCrossMainScene:onSceneEnter( ... )
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar,true)

    self:adapterLayerHeight(self._mainBody, nil, speedBar, 0, -20)
end

function LegionCrossMainScene:onSceneExit( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function LegionCrossMainScene:onBackKeyEvent( ... )
	if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
	end

	return true
end

return LegionCrossMainScene
