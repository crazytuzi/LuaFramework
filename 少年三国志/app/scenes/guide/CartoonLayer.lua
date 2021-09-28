--CartoonLayer.lua


local CartoonLayer = class("CartoonLayer", UFCCSNormalLayer)


function CartoonLayer:ctor( ... )
	
	self.super.ctor(self, ...)
end

function CartoonLayer:initCallback( func )
	-- body
end

function CartoonLayer:onLayerEnter( ... )
	
end


return CartoonLayer

