require("app.const.ShopType")
local funLevelConst = require("app.const.FunctionLevelConst")

local FunctionLevelConst = require("app.const.FunctionLevelConst")
local MainScene = class("MainScene", UFCCSBaseScene)

function MainScene:ctor( json, func, param1, param2, ...)
    self.super.ctor(self, json, func, param1, param2, ...)

    if patchMe and patchMe("main", self) then return end  

    self._hasWheelCall = false

    self._rootLayer = require("app.scenes.mainscene.MainRootLayer").create()
    self:addUILayerComponent("RootLayer",self._rootLayer,true)    

    self._layer = require("app.scenes.mainscene.MainButtonLayer").create()
    self:addUILayerComponent("MainLayer",self._layer,true)

end

function MainScene:onSceneEnter()
    --保证主场景肯定有网络连接
    G_NetworkManager:checkConnection()
    
    G_Notice:clear()  

    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.UI_SLIDER)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
    
    self._roleInfo = G_commonLayerModel:getMainRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()

    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    self:adapterLayerHeight(self._rootLayer,self._roleInfo,self._speedBar, -58,0)
    self:adapterLayerHeight(self._layer,self._roleInfo,self._speedBar, 0,0)

    GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTICE, handler(self, self._recvNotice), self)
    self._noticeLayer = require("app.scenes.notice.NoticeLayer").create()
    self:addChild(self._noticeLayer)

    self._speedBar:backMain()

    if not G_topLayer and G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CHAT) then 
        G_topLayer = require("app.scenes.mainscene.TopLayer").create()

        if G_GuideMgr and G_GuideMgr:isCurrentGuiding() then 
            G_topLayer:_onGuideStart()
        end
    end

end

-- 新的notice
function MainScene:_recvNotice()
    if self._noticeLayer == nil then
        return
    end

    if self._noticeLayer:isVisible() == false then
        self._noticeLayer:setVisible(true)
        self._noticeLayer:startMove()
    end
end

function MainScene:onSceneExit(...)
    uf_eventManager:removeListenerWithTarget(self)

    self:removeComponent(SCENE_COMPONENT_GUI, "Notice")
    self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function MainScene:onSceneUnload(...)
end

return MainScene
