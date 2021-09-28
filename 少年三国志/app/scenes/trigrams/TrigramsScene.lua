local TrigramsScene = class("TrigramsScene",UFCCSBaseScene)

function TrigramsScene:ctor(...)
    self.super.ctor(self, ...)
end

function TrigramsScene:onSceneLoad( _, _, _, _, scenePack, ... )   
    self._mainBody = require("app.scenes.trigrams.TrigramsMainLayer").new("ui_layout/trigrams_MainLayer.json",nil, scenePack)
    self:addUILayerComponent("TrigramsMainLayer", self._mainBody, true)
    
end

function TrigramsScene:onSceneUnload()
end

function TrigramsScene:onSceneEnter(  )

    self._roleInfo = G_commonLayerModel:getTreasureRobRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)
    
    self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedBar, -10, -45)
    self._mainBody:adaptLayerView()
end
 
--移除通用模块
function TrigramsScene:onSceneExit( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return TrigramsScene

