local RichScene = class("RichScene",UFCCSBaseScene)

function RichScene:ctor(...)
    self.super.ctor(self, ...)
end

function RichScene:onSceneLoad( _, _, _, _, scenePack, ... )   
    self._mainBody = require("app.scenes.dafuweng.RichLayer").new("ui_layout/dafuweng_TravelMainLayer.json",nil, scenePack)
    self:addUILayerComponent("RichLayer", self._mainBody, true)
    
end

function RichScene:setDisplayEffect(displayEffect)
    self._mainBody:setDisplayEffect(displayEffect)
end

function RichScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end

function RichScene:onSceneEnter(  )

    self._roleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)
    
    self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedBar, -10, -10)
    
    self._mainBody:adapterLayer()
    self._mainBody:setContainer(self)

end

function RichScene:removeSpeedBar()
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function RichScene:addSpeedBar()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
end
 
--移除通用模块
function RichScene:onSceneExit( ... )
	-- self:removeComponent(SCENE_COMPONENT_GUI, "Notice")
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return RichScene

