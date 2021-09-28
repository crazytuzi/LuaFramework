local SanguozhiMainScene = class("SanguozhiMainScene",UFCCSBaseScene)


function SanguozhiMainScene:ctor(...)
    self.super.ctor(self, ...)
end

function SanguozhiMainScene:onSceneEnter( )
    -- G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVP)
    if self._mainLayer == nil then
        self._mainLayer = require("app.scenes.sanguozhi.SanguozhiMainLayer").create()
        self:addUILayerComponent("Sanguozhi", self._mainLayer, true)
        self._roleInfo  = G_commonLayerModel:getBarRoleInfoLayer()
        self:addUILayerComponent("roleInfo", self._roleInfo,true)

        self._speedbar = G_commonLayerModel:getSpeedbarLayer()
        self:addUILayerComponent("SpeedBar", self._speedbar,true)

        self:adapterLayerHeight(self._mainLayer, self._roleInfo, self._speedbar, 0, 0)
        self._mainLayer:adapterLayer()
    else
        self._roleInfo  = G_commonLayerModel:getBarRoleInfoLayer()
        self:addUILayerComponent("roleInfo", self._roleInfo,true)

        self._speedbar = G_commonLayerModel:getSpeedbarLayer()
        self:addUILayerComponent("SpeedBar", self._speedbar,true)
    end
    
end

function SanguozhiMainScene:onSceneExit()
    self:removeComponent(SCENE_COMPONENT_GUI, "roleInfo")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return SanguozhiMainScene
