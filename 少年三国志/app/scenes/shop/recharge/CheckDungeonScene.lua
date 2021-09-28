local CheCkdungeonScene = class("CheCkdungeonScene",UFCCSBaseScene)


function CheCkdungeonScene:ctor(selectedIndex,packScene, functionValue, ...)
   self.super.ctor(self,...)
    self._selectedIndex = selectedIndex or 1
    self._selectedIndex = functionValue or self._selectedIndex
    self._packScene = packScene
end



function CheCkdungeonScene:onSceneEnter()

    if self._bagLayer == nil then
        --第一次进入场景
        self._bagLayer= require("app.scenes.shop.recharge.CheckDungeonInfo").create(true)
        self:addUILayerComponent("bagLayer", self._bagLayer, true)

        self:_addCommonComponents()

        self:adapterLayerHeight(self._bagLayer, self._roleInfo, self._speedbar, -15, 0)
        


    else
        --pop场景
        self:_addCommonComponents()


        self:adapterLayerHeight(self._bagLayer, self._roleInfo, self._speedbar, -15, 0)
        
    end



end


--添加通用模块
function CheCkdungeonScene:_addCommonComponents( ... )
   --顶部
   self._roleInfo = G_commonLayerModel:getBagRoleInfoLayer()
   self:addUILayerComponent("Topbar",self._roleInfo,true)

   self._speedbar = G_commonLayerModel:getSpeedbarLayer()
   self:addUILayerComponent("SpeedBar", self._speedbar, true)
   
end

--移除通用模块
function CheCkdungeonScene:onSceneExit( ... )

    self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function CheCkdungeonScene:onSceneUnload()
    uf_eventManager:removeListenerWithTarget(self)
end

return CheCkdungeonScene
