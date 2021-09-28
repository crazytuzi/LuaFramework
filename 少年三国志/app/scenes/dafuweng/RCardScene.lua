local RCardScene = class("RCardScene",UFCCSBaseScene)

function RCardScene:ctor(...)
    self.super.ctor(self, ...)
end

function RCardScene:onSceneLoad( ... )   
    self._mainBody = require("app.scenes.dafuweng.RCardMainLayer").new("ui_layout/dafuweng_RechargeCard.json",...)
    self:addUILayerComponent("RCardLayer", self._mainBody, true)
    
end

function RCardScene:onSceneEnter(  )

    self._roleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)
    
    self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedBar, 0, -30)
    
    -- self._mainBody:adapterLayer()

end
 
--移除通用模块
function RCardScene:onSceneExit( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return RCardScene

