local WheelScene = class("WheelScene",UFCCSBaseScene)

function WheelScene:ctor(...)
    self.super.ctor(self, ...)
end

function WheelScene:onSceneLoad( _, _, _, _, scenePack, ... )   
    self._mainBody = require("app.scenes.wheel.WheelMainLayer").new("ui_layout/wheel_MainLayer.json",nil, scenePack)
    self:addUILayerComponent("WheelLayer", self._mainBody, true)
    
end

function WheelScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end

function WheelScene:onSceneEnter(  )

    self._roleInfo = G_commonLayerModel:getTreasureRobRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)
    
    self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedBar, -5, -45)
    self._mainBody:adaptView()
end
 
--移除通用模块
function WheelScene:onSceneExit( ... )
	-- self:removeComponent(SCENE_COMPONENT_GUI, "Notice")
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return WheelScene

