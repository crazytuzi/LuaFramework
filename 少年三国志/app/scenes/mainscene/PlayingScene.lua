local PlayingScene = class("PlayingScene", UFCCSBaseScene)

function PlayingScene:ctor(...)
    self.super.ctor(self, ...)

    self._layer = require("app.scenes.mainscene.ZhengZhanLayer").create()
    self:addUILayerComponent("PlayingLayer",self._layer, false) 
    
    self._roleInfo = G_commonLayerModel:getBarRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
     self:adapterLayerHeight(self._layer, self._roleInfo, self._speedBar,0,0)
end




function PlayingScene:onSceneEnter(...)
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.UI_SLIDER)
    self._speedBar:backPlay()
    
end

function PlayingScene:onSceneExit(...)
    uf_eventManager:removeListenerWithTarget(self)
end


return PlayingScene

