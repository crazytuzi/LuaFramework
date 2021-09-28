
local TreasureComposeScene = class("TreasureComposeScene",UFCCSBaseScene)

function TreasureComposeScene:ctor(...)
    self.super.ctor(self,...)
end

function TreasureComposeScene:onSceneLoad(jsonFile, fun, functionValue, chapterId, scenePack, ...)
    self._mainBody = require("app.scenes.treasure.TreasureComposeLayer").create(functionValue, chapterId, scenePack)
    self:addUILayerComponent("TreasureListLayer", self._mainBody, true)
end
function TreasureComposeScene:onSceneEnter()
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVP)
    self._roleInfo  = G_commonLayerModel:getTreasureRobRoleInfoLayer()
    self:addUILayerComponent("roleInfo", self._roleInfo,true)

    self._speedbar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedbar,true)
    
    self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedbar, 0, 0)
    self._mainBody:adapterLayer()
end


function TreasureComposeScene:onSceneExit()
    __LogTag(TAG,"TreasureComposeScene:onSceneExit()")
    self:removeComponent(SCENE_COMPONENT_GUI, "roleInfo")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end



return TreasureComposeScene






