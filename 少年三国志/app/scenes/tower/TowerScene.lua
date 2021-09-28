local TowerScene = class("TowerScene",UFCCSBaseScene)

function TowerScene:ctor(win)
    self.super.ctor(self)
    self._win = win or false
end

function TowerScene:onSceneLoad( jsonFile, fun, functionValue, chapterId, scenePack, ... )    
    self._mainBody = require("app.scenes.tower.TowerLayer").new("ui_layout/tower_TowerLayer.json",nil, scenePack)
    self:addUILayerComponent("TowerLayer", self._mainBody, true)
    
end

function TowerScene:setDisplayEffect(displayEffect)
    self._mainBody:setDisplayEffect(displayEffect)
end

function TowerScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end

function TowerScene:onSceneEnter(  )
    if G_moduleUnlock:checkModuleUnlockStatus(require("app.const.FunctionLevelConst").TOWER_SCENE) == false then
        uf_sceneManager:replaceScene(require("app.scenes.mainscene.PlayingScene").new())
        return
    end

    self._roleInfo = G_commonLayerModel:getBarRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)
    
    -- self:adapterLayerHeight(self._roleInfo,self._notice,nil,0,0)
    -- self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedBar, 0, -30)
    -- self:adapterLayerHeight(self._mainBody, self._roleInfo, nil, 0, 0)
    self:adapterLayerHeight(self._mainBody, nil, self._speedBar, 0, -45)

    self._mainBody:updateView(self._win)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)

 
    self._sceneIsEnter = true
end
 
--移除通用模块
function TowerScene:onSceneExit( ... )
	-- self:removeComponent(SCENE_COMPONENT_GUI, "Notice")
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return TowerScene

