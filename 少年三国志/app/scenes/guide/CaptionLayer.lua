--CaptionLayer.lua

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local CaptionLayer = class("CaptionLayer", UFCCSNormalLayer)


function CaptionLayer:ctor( ... )
	self._callback = nil
	self._captionLabel = nil
	self._strList = {}
	self._playFinish = false
	self._playSpeed = 4
	self._curNum = 1

	self.super.ctor(self, ...)

	self._captionLabel = self:getLabelByName("Label_caption")

	self:showWidgetByName("Image_click_continue", false)
	--self:enableLabelStroke("Label_caption", Colors.strokeBrown, 1 )

	self:adapterWithScreen()
	self:registerTouchEvent(false, true, 0)
end

function CaptionLayer:initCallback( textId, func )
	self._callback = func

	if type(textId) ~= "string" then
		return self:_doCallback()
	end

	local str = G_lang:get(textId)
	for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do 
        self._strList[#self._strList+1] = uchar 
    end
	if self._captionLabel then 
		self._captionLabel:setText("")
	end
end

function CaptionLayer:onLayerEnter( ... )
	local num = 1
	local desc = ""
	self._timer = G_GlobalFunc.addTimer(0.15,function()
		self._curNum = (self._curNum or 1) + (self._playSpeed or 1)
		while num <= self._curNum do
			if self._strList[num] then
				desc = desc..self._strList[num]
			end
			num = num + 1
		end

		if self._captionLabel then 
			self._captionLabel:setText(desc)
		end

   --      if self._strList[num] then
   --          desc = desc  .. self._strList[num]
   --          num = num + self._playSpeed
   --          if self._captionLabel then 
			-- 	self._captionLabel:setText(desc)
			-- end
   --      end
        
        if num-1 >= #self._strList then
            G_GlobalFunc.removeTimer(self._timer)
            self._timer = nil
            self._strList = {}
            self._playFinish = true
            self:showWidgetByName("Image_click_continue", true)
            EffectSingleMoving.run(self:getWidgetByName("Image_click_continue"), "smoving_wait", nil , {position = true} )
            
        end
    end
        )
end

function CaptionLayer:_doCallback( ... )
	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
	
	if self._callback then 
    	self._callback()
    end
end

function CaptionLayer:onTouchEnd( xpos, ypos )
	if not self._playFinish then 
		self._playSpeed = self._playSpeed + 2

		-- if self._playSpeed > 2 then 
		-- 	self:_doCallback()
  --   		self:close()
		-- end
		return 
	end

    self:_doCallback()
    self:close()
end


return CaptionLayer

