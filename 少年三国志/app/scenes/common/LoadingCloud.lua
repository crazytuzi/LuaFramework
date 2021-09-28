--LoadingCloud.lua

local EffectNode = require "app.common.effects.EffectNode"

local LoadingCloud = class("LoadingCloud", function ( ... )
	return CCSModelLayer:create()
end)

function LoadingCloud:ctor(...)

	self._showCallback = nil 
	self._finishCallback = nil 

	uf_notifyLayer:getLockNode():addChild(self)
	self:setVisible(false)

end

function LoadingCloud:_loadCloud( ... )
	if not self._effect then 
		self._effect = EffectNode.new("effect_transition", function(event)
    		if event == "out" then
    			self:_onShowCound()
    		elseif event == "finish" then
    			self:_onFinishCound()
    		end
 		end)

 		self:addChild(self._effect)
		local winSize = CCDirector:sharedDirector():getWinSize()
 		self._effect:setPosition(ccp(winSize.width/2, winSize.height/2))
	end 	
end

function LoadingCloud:showLoading( showFunc, finishFunc )
	self:_loadCloud()

	if self._effect then 
		self._showCallback = showFunc
		self._finishCallback = finishFunc
		self._effect:play()
		self:setVisible(true)
	else
		__LogError("effect is nil in LoadingCloud!")
	end
end

function LoadingCloud:_onShowCound( ... )
	if self._showCallback then 
		self._showCallback()
	end

	self._showCallback = nil
end

function LoadingCloud:_onFinishCound( ... )
	if self._finishCallback then 
		self._finishCallback()
	end
	self._finishCallback = nil
	self:setVisible(false)

end

return LoadingCloud



