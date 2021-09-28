local LegionTechScene = class("LegionTechScene",UFCCSBaseScene)

function LegionTechScene:ctor(...)
    self.super.ctor(self,...)
end

--移除通用模块
function LegionTechScene:onSceneLoad( ... )

    self._techLayer = require("app.scenes.legion.LegionTechLayer").create() 

    self:addUILayerComponent("TechLayer", self._techLayer, true)
    
end

function LegionTechScene:onSceneEnter()
    -- print("onlay onSceneEnter")

    self:_addCommonComponents()

    self:adapterLayerHeight(self._techLayer,self._topbar,self._speedbar,-8,-50)
    self._techLayer:adapterLayer()
end


--添加通用模块
function LegionTechScene:_addCommonComponents( ... )


   --顶部信息栏
    self._topbar = G_commonLayerModel:getLegionRoleInfoLayer() 
    self:addUILayerComponent("shopTopbar",self._topbar,true)

   --底部按钮栏    
   self._speedbar = G_commonLayerModel:getSpeedbarLayer()
   self._speedbar:setSelectBtn()
   self:addUILayerComponent("SpeedBar", self._speedbar,true)
end

--移除通用模块
function LegionTechScene:onSceneExit( ... )

    self:removeComponent(SCENE_COMPONENT_GUI, "shopTopbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

-- function LegionTechScene:onSceneUnload()
-- 	uf_eventManager:removeListenerWithTarget(self)
-- end




return LegionTechScene
