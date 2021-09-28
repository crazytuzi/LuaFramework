--CartoonScene.lua


local CartoonScene = class("CartoonScene", UFCCSBaseScene)


function CartoonScene:ctor( ... )
	self._mainLayer = nil
	self.super.ctor(self, ...)
end

function CartoonScene:onLayerLoad( step_id, asyncFunc, callbackFunc  )
	self._mainLayer = require("app.scenes.guide.CartoonLayer").new()
	self:addChild(self._mainLayer)
	self._mainLayer:initCallback(callbackFunc)
end


return CartoonScene
