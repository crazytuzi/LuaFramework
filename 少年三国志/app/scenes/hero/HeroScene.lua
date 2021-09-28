--HeroScene2.lua


local HeroScene = class("HeroScene", UFCCSBaseScene)

function HeroScene:ctor( heroIndex, ... )
	self._sceneIsEnter = false

	self.super.ctor(self, heroIndex, ...)	
end
-- @param  isToFriendLayer 从主界面的更多按钮层点击“援军助威”时需要传的参数
function HeroScene:onSceneLoad( heroIndex, isToFriendLayer, ... )
    self._heroInfo = require("app.scenes.hero.HeroLayer").new("ui_layout/knight_cast.json", nil , heroIndex, isToFriendLayer, ...)
    self:addUILayerComponent("heroArray", self._heroInfo, false);

    -- self._speedbar = G_commonLayerModel:getSpeedbarLayer()
    -- self:addUILayerComponent("SpeedBar", self._speedbar,true)
    
    --if not self._sceneIsEnter then
      --  self:adapterLayerHeight(self._heroInfo, nil, self._speedbar, 0, -30)
      --  self._heroInfo:doAdapterWidget()
    --end
	--self._heroInfo = self:addUILayerComponent("heroArray", "ui_layout/knight_cast.json", false, false)
end

function HeroScene:onSceneEnter( )
    self._speedbar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedbar,true)
	
     if not self._sceneIsEnter then
     	self:adapterLayerHeight(self._heroInfo, nil, self._speedbar, -2, -30)
         self._heroInfo:doAdapterWidget()
	 end

	self._sceneIsEnter = true
end

function HeroScene:onSceneExit(  )
	self:removeComponent(SCENE_COMPONENT_GUI, "Notice")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function HeroScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end


return HeroScene
