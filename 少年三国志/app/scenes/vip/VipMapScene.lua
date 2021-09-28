local VipMapScene = class("VipMapScene",UFCCSBaseScene)

function VipMapScene:ctor(index, ...)
    if index then
        __Log("================index: %d", index)
    else
        __Log("================index is nil")
    end

    self._index = index or 1
    self._hasEnter = index or -1
    self.super.ctor(self, index, ...)
end

function VipMapScene:onSceneLoad( jsonFile, fun, functionValue, chapterId, scenePack, ... )    
    __Log("mapId:%d, functionValue:%d", self._index, functionValue and functionValue or 0)
    if functionValue and functionValue > 0 then 
        self._index = functionValue
    end

    self._mainBody = require("app.scenes.vip.VipMapLayer").create(scenePack)
    self:addUILayerComponent("VipMapLayer", self._mainBody, true)
end

-- function VipMapScene:setDisplayEffect(displayEffect)
--     self._mainBody:setDisplayEffect(displayEffect)
-- end

function VipMapScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end

function VipMapScene:onSceneEnter(  )
    if G_moduleUnlock:checkModuleUnlockStatus(require("app.const.FunctionLevelConst").VIP_SCENE) == false then
        uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
        return
    end

    self._roleInfo = G_commonLayerModel:getDungeonRoleKongInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)
    
    -- self:adapterLayerHeight(self._roleInfo,self._notice,nil,0,0)
    self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedBar, 0, 0)
    -- self:adapterLayerHeight(self._mainBody, self._roleInfo, nil, 0, 0)
    -- self:adapterLayerHeight(self._mainBody, nil, self._speedBar, 0, -45)

    self._mainBody:updateView(self._index, self._hasEnter)
    -- G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)

 
    self._sceneIsEnter = true
end
 
--移除通用模块
function VipMapScene:onSceneExit( ... )
	-- self:removeComponent(SCENE_COMPONENT_GUI, "Notice")
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return VipMapScene

