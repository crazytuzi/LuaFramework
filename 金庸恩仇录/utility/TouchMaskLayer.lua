local TouchMaskLayer = class("TouchMaskLayer", function ()
	return display.newColorLayer(cc.c4b(0, 0, 0, 0))
end)

function TouchMaskLayer:ctor(param)
	local _btns      = param.btns
	local _contents = {}
	
	local showColorRect = false
	
	--    self:setContentSize(cc.size(display.width, display.height))
	
	for k, v in ipairs(param.contents) do
		table.insert(_contents, v)
		
		if showColorRect then
			local l = display.newColorLayer(cc.c4b(255, 0, 0, 170))
			l:setContentSize(v.size)
			l:setPosition(v.origin)
			self:addChild(l)
		end
	end
	
	for _, v in ipairs(_btns) do
		local p = self:convertToNodeSpace(v:convertToWorldSpace(cc.p(0, 0)))
		local btnSize = v:getContentSize()
		table.insert(_contents, cc.rect(p.x, p.y, btnSize.width, btnSize.height))
		if showColorRect then
			local l = display.newColorLayer(cc.c4b(255, 0, 0, 170))
			l:setContentSize(s)
			l:setPosition(p)
			self:addChild(l)
		end
	end
	self:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT,
	function (event)
		if "began" == event.name then
			for k, v in ipairs(_contents) do
				--dump(event)
				--dump(v)
				if cc.rectContainsPoint(v, cc.p(event.x, event.y)) then
					return false
				end
			end
			return true
		end
	end,
	1)
	self:setTouchEnabled(true)
	self:setTouchCaptureEnabled(true)
	self:setTag(1234)
end

return TouchMaskLayer