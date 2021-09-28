local DailyPvpMainScene = class("DailyPvpMainScene",UFCCSBaseScene)

function DailyPvpMainScene:ctor(...)
    self.super.ctor(self, ...)
end

function DailyPvpMainScene:onSceneLoad( ... )   
    self._mainBody = require("app.scenes.dailypvp.DailyPvpMainLayer").create(...)
    self:addUILayerComponent("DailyPvpLayer", self._mainBody, true)
    
end

function DailyPvpMainScene:onSceneUnload()
	
end

function DailyPvpMainScene:onSceneEnter(  )
    -- if G_moduleUnlock:checkModuleUnlockStatus(require("app.const.FunctionLevelConst").TOWER_SCENE) == false then
    --     uf_sceneManager:replaceScene(require("app.scenes.mainscene.PlayingScene").new())
    --     return
    -- end
    self._roleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer() 
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()

    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)

    -- GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)
    
    self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedBar, -8, 0)

    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)

end
 
--移除通用模块
function DailyPvpMainScene:onSceneExit( ... )
    self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end


-- function DailyPvpMainScene.show( ... )   
--     uf_sceneManager:replaceScene(DailyPvpMainScene.new(...))
-- end

return DailyPvpMainScene

