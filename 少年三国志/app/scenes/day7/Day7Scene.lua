--Day7Scene.lua

local Day7Scene = class("Day7Scene", UFCCSBaseScene)



function Day7Scene:ctor(...)
    self.super.ctor(self,...)
end

function Day7Scene:onSceneLoad(dayIndex, ...)
    self._layer = require("app.scenes.day7.Day7MainLayer").create(dayIndex, ...) 

    self:addUILayerComponent("everydayLayer", self._layer, true)

    --顶部信息栏
    local topbar = G_commonLayerModel:getShopRoleInfoLayer() 
    self:addUILayerComponent("Topbar", topbar, true)

    --底部按钮栏    
    local speedbar = G_commonLayerModel:getSpeedbarLayer()
    speedbar:setSelectBtn()
    self:addUILayerComponent("SpeedBar", speedbar,true)

    self:adapterLayerHeight(self._layer, topbar, speedbar, 0, -80)
end

--移除通用模块
function Day7Scene:onSceneExit( ... )

    self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end


return Day7Scene

