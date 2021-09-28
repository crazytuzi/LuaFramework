local BagScene = class("BagScene",UFCCSBaseScene)


function BagScene:ctor(selectedIndex,packScene, functionValue, ...)
   self.super.ctor(self,...)
    self._selectedIndex = selectedIndex or 1
    self._selectedIndex = functionValue or self._selectedIndex
    self._packScene = packScene
end



function BagScene:onSceneEnter()

    if self._bagLayer == nil then
        --第一次进入场景
        self._bagLayer= require("app.scenes.bag.BagLayer").create(self._selectedIndex,self._packScene)
        self:addUILayerComponent("bagLayer", self._bagLayer, true)

        self:_addCommonComponents()

        self:adapterLayerHeight(self._bagLayer, self._roleInfo, self._speedbar, -15, 0)
        
        self._bagLayer:adapterLayer()


    else
        --pop场景
        self:_addCommonComponents()


        self:adapterLayerHeight(self._bagLayer, self._roleInfo, self._speedbar, -15, 0)
        
    end



end


--添加通用模块
function BagScene:_addCommonComponents( ... )
   --顶部
   self._roleInfo = G_commonLayerModel:getBagRoleInfoLayer()
   self:addUILayerComponent("Topbar",self._roleInfo,true)

   self._speedbar = G_commonLayerModel:getSpeedbarLayer()
   self:addUILayerComponent("SpeedBar", self._speedbar, true)
   
end

--移除通用模块
function BagScene:onSceneExit( ... )

    self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function BagScene:onSceneUnload()
    uf_eventManager:removeListenerWithTarget(self)
end

return BagScene
