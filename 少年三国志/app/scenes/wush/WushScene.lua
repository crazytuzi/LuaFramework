local WushScene = class("WushScene",UFCCSBaseScene)

function WushScene:ctor(win, ...)
    self.super.ctor(self, win, ...)
    if win == nil then 
        self._win = nil 
    else
        self._win = win or false
    end
end

function WushScene:onSceneLoad( jsonFile, fun, functionValue, chapterId, scenePack, ... )   
    self._mainBody = require("app.scenes.wush.WushMainLayer").new("ui_layout/wush_MainLayer.json",nil, scenePack)
    self:addUILayerComponent("WushLayer", self._mainBody, true)
    
end

function WushScene:setDisplayEffect(displayEffect)
    self._mainBody:setDisplayEffect(displayEffect)
end

function WushScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end

function WushScene:onSceneEnter(  )
    if G_moduleUnlock:checkModuleUnlockStatus(require("app.const.FunctionLevelConst").TOWER_SCENE) == false then
        uf_sceneManager:replaceScene(require("app.scenes.mainscene.PlayingScene").new())
        return
    end

    -- 精英挑战boss战斗返回之后不需要做上下边栏的移除与添加，否则层级会高于精英挑战弹窗的层级
    if not G_Me.wushData:getIsInWushBossLayer() then
        self._roleInfo = G_commonLayerModel:getBarRoleInfoLayer()
        self._speedBar = G_commonLayerModel:getSpeedbarLayer()

        self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
        self:addUILayerComponent("SpeedBar", self._speedBar,true)

        GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)
    end
    
    
    -- self:adapterLayerHeight(self._roleInfo,self._notice,nil,0,0)
    -- self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedBar, 0, -30)
    -- self:adapterLayerHeight(self._mainBody, self._roleInfo, nil, 0, 0)
    self:adapterLayerHeight(self._mainBody, nil, self._speedBar, 0, -45)

    self._mainBody:updateView(self._win)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)

 
    self._sceneIsEnter = true
end
 
--移除通用模块
function WushScene:onSceneExit( ... )
	-- self:removeComponent(SCENE_COMPONENT_GUI, "Notice")
    if not G_Me.wushData:getIsInWushBossLayer() then
	   self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
	   self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
    end
end

return WushScene

