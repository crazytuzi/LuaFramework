local BagSellScene = class("BagSellScene",UFCCSBaseScene)

function BagSellScene:ctor(...)
    self.super.ctor(self,...)
end


function BagSellScene:onSceneLoad(...)
	-- body
	self._sellLayer = require("app.scenes.bag.BagSellLayer").create(...)
	self:addUILayerComponent("sellLayer", self._sellLayer, true)
    
end

function BagSellScene:onSceneEnter( ... )
	
	self:adapterLayerHeight(self._sellLayer,self._roleInfo,nil,0,0)
	self._sellLayer:adapterLayer()
end

return BagSellScene
