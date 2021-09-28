local EquipmentMainScene = class("EquipmentMainScene",UFCCSBaseScene)

function EquipmentMainScene:ctor(checkType,curEquipId,...)
    self._checkType = checkType and checkType or 1
    self._curEquipId = curEquipId and curEquipId or 0
    self.super.ctor(self,...)

end



function EquipmentMainScene:onSceneEnter(...)
    --print("EquipmentMainScene onSceneEnter")
    if self._equipLayer == nil then
        --第一次进入场景
        self._equipLayer = require("app.scenes.equipment.EquipmentMainLayer").create(self._checkType,self._curEquipId,...) 

        self:addUILayerComponent("EquipLayer", self._equipLayer, true)

        self:_addCommonComponents()

        self:adapterLayerHeight(self._equipLayer,self._topbar,self._speedbar,-10,-50)
        self._equipLayer:adapterLayer()


    else
        --pop场景
        self:_addCommonComponents()


        self:adapterLayerHeight(self._equipLayer,self._topbar,self._speedbar,-10,-50)
        self._equipLayer:adapterLayer()

    end



end


--添加通用模块
function EquipmentMainScene:_addCommonComponents( ... )


   --顶部信息栏
    self._topbar = G_commonLayerModel:getStrengthenRoleInfoLayer() 
    self:addUILayerComponent("Topbar",self._topbar,true)

   --底部按钮栏    
   self._speedbar = G_commonLayerModel:getSpeedbarLayer()
   self._speedbar:setSelectBtn()
   self:addUILayerComponent("SpeedBar", self._speedbar,true)
end

--移除通用模块
function EquipmentMainScene:onSceneExit( ... )

    self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function EquipmentMainScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end




return EquipmentMainScene




