--WaitingLayer.lua

local WaitingLayer = class ("WaitingLayer", UFCCSModelLayer)
local EffectNode = require("app.common.effects.EffectNode")


function WaitingLayer:ctor( ... )
	self.super.ctor(self, ...)
	uf_notifyLayer:getLockNode():addChild(self, 1000, 0)
	self:enableLabelStroke("Label_loading", Colors.strokeBrown, 1 )
	self:setVisible(false)
end

function WaitingLayer:onLayerLoad( ... )
	local panel = self:getWidgetByName("Panel")
	if not panel then 
		return 
	end

	local size = panel:getSize()
	self._effect = EffectNode.new("effect_loading", 
    			function(event)
    			end)
	panel:addNode(self._effect )
	self._effect:play()
	self._effect:setPosition(ccp(size.width/2, size.height/2))
	self._effect:pause()
	self:showTextWithLabel("Label_loading", G_lang:get("LANG_SYSTEM_LOADING"))
end


function WaitingLayer:show( b )
	self:setVisible(b)
	if self._effect  then
		if b then
			self._effect:resume()
		else
			self._effect:pause()

		end
	end
end

function WaitingLayer:onLayerEnter( ... )	
end

function WaitingLayer:onLayerExit( ... )
end


return WaitingLayer