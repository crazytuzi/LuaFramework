local ArenaScene = class("ArenaScene",UFCCSBaseScene)


function ArenaScene:ctor(jsonFile, fun, functionValue, chapterId, scenePack, ...)
    self.super.ctor(self, ...)

    GlobalFunc.savePack(self, scenePack)
end

function ArenaScene:onSceneEnter( )
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVP)
    if self._arenaLayer == nil then
        self._arenaLayer = require("app.scenes.arena.ArenaLayer02").create(GlobalFunc.getPack(self))
        self:addUILayerComponent("ArenaLayer", self._arenaLayer, true)
        self._roleInfo  = G_commonLayerModel:getBarRoleInfoLayer()
        self:addUILayerComponent("roleInfo", self._roleInfo,true)

        self._speedbar = G_commonLayerModel:getSpeedbarLayer()
        self:addUILayerComponent("SpeedBar", self._speedbar,true)

        self:adapterLayerHeight(self._arenaLayer, nil, self._speedbar, 0, -60)
        self._arenaLayer:adapterLayer()
    else
        self._roleInfo  = G_commonLayerModel:getBarRoleInfoLayer()
        self:addUILayerComponent("roleInfo", self._roleInfo,true)

        self._speedbar = G_commonLayerModel:getSpeedbarLayer()
        self:addUILayerComponent("SpeedBar", self._speedbar,true)
    end
    
end

function ArenaScene:onSceneExit()
    self:removeComponent(SCENE_COMPONENT_GUI, "roleInfo")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return ArenaScene
