local ActivityMainScene = class("ActivityMainScene",UFCCSBaseScene)

function ActivityMainScene:ctor(index,...)
    self.super.ctor(self)
    self._index = index or 1
end



function ActivityMainScene:onSceneEnter()

    if self._layer == nil then 
        --第一次进入场景
        self._layer = require("app.scenes.activity.ActivityMainLayer").create() 

        self:addUILayerComponent("ActivityLayer", self._layer, true)

        self:_addCommonComponents()

        self:adapterLayerHeight(self._layer,self._topbar,self._speedbar,-9,-50)
        self._layer:adapterLayer(self._index)

    else
        --pop场景
        self:_addCommonComponents()


        self:adapterLayerHeight(self._layer,self._topbar,self._speedbar,-9,-50)
        self._layer:adapterLayer()

    end



end

--获取MainLayer
function ActivityMainScene:getMainLayer()
    return self._layer
end


--添加通用模块
function ActivityMainScene:_addCommonComponents( ... )

    --顶部信息栏
    self._topbar = G_commonLayerModel:getStrengthenRoleInfoLayer() 
    self:addUILayerComponent("Topbar",self._topbar,true)


    --底部按钮栏    
    self._speedbar = G_commonLayerModel:getSpeedbarLayer()
    self._speedbar:setSelectBtn()
    self:addUILayerComponent("SpeedBar", self._speedbar,true)
end

--移除通用模块
function ActivityMainScene:onSceneExit( ... )

    self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function ActivityMainScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end




return ActivityMainScene




