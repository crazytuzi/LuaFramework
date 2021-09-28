local TreasureSaoDangScene = class("TreasureSaoDangScene",UFCCSBaseScene)


function TreasureSaoDangScene:ctor(...) 
  self.super.ctor(self,...)
end

function TreasureSaoDangScene:onSceneLoad(index,fragment_id,userList)
    if self._saodangLayer == nil then
        --第一次进入场景
        self._saodangLayer= require("app.scenes.treasure.TreasureSaoDangLayer").create(index,fragment_id,userList)
        self:addUILayerComponent("TreasureSaoDang", self._saodangLayer, true)
    end
end

function TreasureSaoDangScene:onSceneEnter()
    

end


function TreasureSaoDangScene:onSceneUnload()
    uf_eventManager:removeListenerWithTarget(self)
end

return TreasureSaoDangScene
