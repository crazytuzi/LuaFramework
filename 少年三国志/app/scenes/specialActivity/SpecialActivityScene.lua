--SpecialActivityScene.lua

local SpecialActivityScene = class("SpecialActivityScene", UFCCSBaseScene)



function SpecialActivityScene:ctor(...)
    self.super.ctor(self,...)
end

function SpecialActivityScene:onSceneLoad()
    self._layer = require("app.scenes.specialActivity.SpecialActivityMainLayer").create() 

    self:addUILayerComponent("activityLayer", self._layer, true)

    --顶部信息栏
    local topbar = G_commonLayerModel:getShopRoleInfoLayer() 
    self:addUILayerComponent("Topbar", topbar, true)

    --底部按钮栏    
    local speedbar = G_commonLayerModel:getSpeedbarLayer()
    speedbar:setSelectBtn()
    self:addUILayerComponent("SpeedBar", speedbar,true)

    self:adapterLayerHeight(self._layer, topbar, speedbar, 0, -80)
    self._layer:adapterLayer()
end

--移除通用模块
function SpecialActivityScene:onSceneExit( ... )

    self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end


return SpecialActivityScene

