local FriendMainScene = class("FriendMainScene",UFCCSBaseScene)

function FriendMainScene:ctor(...)
    self.super.ctor(self)
    self._first = false
end

--移除通用模块
function FriendMainScene:onSceneLoad( ... )

    self._friendLayer = require("app.scenes.friend.FriendListLayer").create() 

    self:addUILayerComponent("FriendLayer", self._friendLayer, true)
    
end

function FriendMainScene:onSceneEnter()
    -- print("onlay onSceneEnter")

    self:_addCommonComponents()

    self:adapterLayerHeight(self._friendLayer,self._topbar,self._speedbar,-10,-50)
    if not self._first then
        self._friendLayer:adapterLayer()
        self._first = true
    end

end


--添加通用模块
function FriendMainScene:_addCommonComponents( ... )


   --顶部信息栏
    self._topbar = G_commonLayerModel:getFriendRoleInfoLayer() 
    self:addUILayerComponent("friendTopbar",self._topbar,true)

   --底部按钮栏    
   self._speedbar = G_commonLayerModel:getSpeedbarLayer()
   self._speedbar:setSelectBtn()
   self:addUILayerComponent("SpeedBar", self._speedbar,true)
end

--移除通用模块
function FriendMainScene:onSceneExit( ... )

    self:removeComponent(SCENE_COMPONENT_GUI, "friendTopbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function FriendMainScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end




return FriendMainScene




