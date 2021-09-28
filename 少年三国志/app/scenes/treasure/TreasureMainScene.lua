local TreasureMainScene = class("TreasureMainScene",UFCCSBaseScene)

function TreasureMainScene:ctor(scenePack, ...)
    self.super.ctor(self)
    self._scenePack = scenePack
end



function TreasureMainScene:onSceneEnter()

    if self._equipLayer == nil then 
        --第一次进入场景
        self._equipLayer = require("app.scenes.treasure.TreasureMainLayer").create(self._scenePack) 

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
function TreasureMainScene:_addCommonComponents( ... )


   --顶部信息栏
    self._topbar = G_commonLayerModel:getStrengthenRoleInfoLayer() 
    self:addUILayerComponent("Topbar",self._topbar,true)


   --底部按钮栏    
   self._speedbar = G_commonLayerModel:getSpeedbarLayer()
   self:addUILayerComponent("SpeedBar", self._speedbar,true)
end

--移除通用模块
function TreasureMainScene:onSceneExit( ... )

    self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function TreasureMainScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end




return TreasureMainScene




