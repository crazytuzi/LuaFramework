local MyLayer = class("MyLayer", function ()
	return cc.Layer:create()
end)

function MyLayer:ctor(params)
	if params.name then
		self:setName(params.name)
	end
	self._initSize = false
	self._touchHandler = params.touchHandler
	local layer = tolua.cast(self,"cc.Layer")
	local swallow = true
	local touch = true
	if params.swallow  ~= nil then
		swallow = params.swallow
	end
	if params.touch  ~= nil then
		touch = params.touch
	end
	layer:setSwallowsTouches(swallow)
	layer:setTouchEnabled(touch)
	if (params.size ~= nil) then
		self._initSize = true
		self:setContentSize(params.size)
	end
	self:registerScriptTouchHandler(function (eventName, x, y)
		local event = {name = eventName, x = x, y = y}
		--dump(event)
		if eventName == "began" then
			self.startX = x
			self.startY = y
			self.prevX = x
			self.prevY = y
			if self._initSize == true then
				local pos = self:convertToNodeSpace(cc.p(x, y))
				--dump(event)
				--dump(pos)
				--dump(self:convertToWorldSpace(pos))
				--dump(self:getBoundingBox())
				--dump(self:getCascadeBoundingBox())
				--local size = self:getContentSize()
				--dump(size)
				if cc.rectContainsPoint(self:getBoundingBox(), pos) then
					self:touchHandler(event)
					return true
				else
					return false
				end
			end
			self:touchHandler(event)
			return true
		elseif eventName == "moved" then
			event.prevX = self.prevX
			event.prevY = self.prevY
			self.prevX = x
			self.prevY = y
		else
			event.prevX = self.prevX
			event.prevY = self.prevY
			event.startX = self.startX
			event.startY = self.startY
		end
		self:touchHandler(event)
	end)
	
	if params.parent ~= nil then
		params.parent:addChild(self)
	end
	
end

function MyLayer:touchHandler(event)
	if self._touchHandler ~= nil then
		self._touchHandler(event, self)
	end
end

function MyLayer:setTouchHandler(handler)
	self._touchHandler = handler
end

--[[
function MyLayer:onEnter()
	print("~~~~~~~~~~~~~~~~~~~~~~~MyLayer:onEnter")
end

function MyLayer:onExit()
	print("~~~~~~~~~~~~~~~~~~~~~~~MyLayer:onExit")
end
]]

return MyLayer