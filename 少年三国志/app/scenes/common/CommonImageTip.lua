--CommonImageTip.lua

local EffectMovingNode = require "app.common.effects.EffectMovingNode"

local CommonImageTip = class ("CommonImageTip", EffectMovingNode)


function CommonImageTip:ctor( tipPath )
    self._img = ImageView:create()
    self._img:loadTexture(tipPath, UI_TEX_TYPE_LOCAL)
	self._img:retain()
    self.super.ctor(self, "moving_texttip2", 
        
        function(key) 
            if key == "txt" then
                return self._img
            end
        end,
        function(event)
            if event == "finish" then
                self:stop()
                self:removeFromParentAndCleanup(true)
                if self._img then
				    self._img:release()
                end
            end
        end 
    )

end


function CommonImageTip.showImageTip( tipPath )
	local imgTip = require("app.scenes.common.CommonImageTip").new(tipPath)
	imgTip:play()
	return imgTip
end

return CommonImageTip
