local DailyPvpTeamScene = class("DailyPvpTeamScene",UFCCSBaseScene)
-- BattleBriefUser
function DailyPvpTeamScene:ctor(...)
    self.super.ctor(self, ...)
end

function DailyPvpTeamScene:onSceneLoad( ... )   
    self._mainBody = require("app.scenes.dailypvp.DailyPvpTeamLayer").create()
    self:addUILayerComponent("DailyPvpLayer", self._mainBody, true)
    
end

function DailyPvpTeamScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end

function DailyPvpTeamScene:onSceneEnter(  )
    -- if G_moduleUnlock:checkModuleUnlockStatus(require("app.const.FunctionLevelConst").TOWER_SCENE) == false then
    --     uf_sceneManager:replaceScene(require("app.scenes.mainscene.PlayingScene").new())
    --     return
    -- end
    self._roleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer() 
    -- self._speedBar = G_commonLayerModel:getSpeedbarLayer()

    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    -- self:addUILayerComponent("SpeedBar", self._speedBar,true)

    -- GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)
    
    -- self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedBar, 0, 0)
    self:adapterLayerHeight(self._mainBody, self._roleInfo, nil, -8, 0)
    if G_topLayer then 
        G_topLayer:showTemplate()
        G_topLayer:resetChatDefaultChannel(4)
    end
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)

end
 
--移除通用模块
function DailyPvpTeamScene:onSceneExit( ... )
    if G_topLayer then 
        G_topLayer:resumeStatus()
        G_topLayer:resetChatDefaultChannel()
    end
    self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return DailyPvpTeamScene

