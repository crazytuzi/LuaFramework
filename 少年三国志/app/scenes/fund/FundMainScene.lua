local FundMainScene = class("FundMainScene",UFCCSBaseScene)

function FundMainScene:ctor(...)
    self.super.ctor(self,...)

end



function FundMainScene:onSceneEnter(...)

    if self._layer == nil then
        --第一次进入场景
        self._layer = require("app.scenes.fund.FundMainLayer").create() 

        self:addUILayerComponent("fundLayer", self._layer, true)

        self:_addCommonComponents()

        self:adapterLayerHeight(self._layer,self._topbar,self._speedbar,-8,-50)
        self._layer:adapterLayer()


    else
        --pop场景
        self:_addCommonComponents()


        self:adapterLayerHeight(self._layer,self._topbar,self._speedbar,-8,-50)
        self._layer:adapterLayer()

    end



end


--添加通用模块
function FundMainScene:_addCommonComponents( ... )


   --顶部信息栏
    self._topbar = G_commonLayerModel:getStrengthenRoleInfoLayer() 
    self:addUILayerComponent("Topbar",self._topbar,true)

   --底部按钮栏    
   self._speedbar = G_commonLayerModel:getSpeedbarLayer()
   self._speedbar:setSelectBtn()
   self:addUILayerComponent("SpeedBar", self._speedbar,true)
end

--移除通用模块
function FundMainScene:onSceneExit( ... )

    self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function FundMainScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end




return FundMainScene




