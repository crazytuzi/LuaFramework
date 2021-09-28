local MoShenScene = class("MoShenScene",UFCCSBaseScene)


function MoShenScene:ctor(...)
   self.super.ctor(self,...)
    
end

function MoShenScene:onSceneLoad( _, _, _, _, scenePack, autoShowAward, ... )
    if self._moshenLayer == nil then
        self._moshenLayer= require("app.scenes.moshen.MoShenLayer").create(scenePack, autoShowAward)
        self:addUILayerComponent("MoShenLayer", self._moshenLayer, true)
    end
end

function MoShenScene:onSceneEnter(...)
        G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)
        self._speedbar = G_commonLayerModel:getSpeedbarLayer()
        self:addUILayerComponent("SpeedBar", self._speedbar, true)
        self:adapterLayerHeight(self._moshenLayer, nil, self._speedbar, 0, 0)
        self._moshenLayer:adapterLayer()
end

function MoShenScene:onSceneExit()
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return MoShenScene
