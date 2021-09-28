local FuMainScene = class("FuMainScene",UFCCSBaseScene)

function FuMainScene:ctor(index)
    self.super.ctor(self, index)
end

function FuMainScene:onSceneLoad( index )   
    self._mainBody = require("app.scenes.dafuweng.FuMainLayer").create(index)
    self:addUILayerComponent("FuLayer", self._mainBody, true)
    
end

function FuMainScene:setDisplayEffect(displayEffect)
    self._mainBody:setDisplayEffect(displayEffect)
end

function FuMainScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end

function FuMainScene:onSceneEnter(  )
    
    self._roleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)
    
    self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedBar, -10, -45)

    self._mainBody:adapterLayer()
end
 
--移除通用模块
function FuMainScene:onSceneExit( ... )
	-- self:removeComponent(SCENE_COMPONENT_GUI, "Notice")
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return FuMainScene

