local none = 0
local btn1down = 1
local btn2down = 2
local longpressadd = 3
local longpressdel = 4

local function pbtnMouseBtnDown1(self, e)
	self.mode = btn1down
	self.number = CEGUI.PropertyHelper:stringToUint(self.numwnd:getText()) or 0
end

local function pbtnMouseBtnDown2(self, e)
	self.mode = btn2down
	self.number = CEGUI.PropertyHelper:stringToUint(self.numwnd:getText()) or 0
end

local function pbtnMouseBtnUp1(self, e)
	self.mode = none
	self.number = nil
	self.eslaped = 0
end

local function pbtnMouseBtnUp2(self, e)
	self.mode = none
	self.number = nil
	self.eslaped = 0
end

local function incrNum(self, delta)
	local num = self.number + delta
	if num < 0 then num = 0 end
	if self.max and num > self.max then
		num = self.max
	end
	self.numwnd:setText(num)
end

local function onUpdate(self, e)
	if not self.mode or self.mode == none then
		return true
	end
	local updateArgs = CEGUI.toUpdateEventArgs(e)
	self.eslaped = self.eslaped and self.eslaped + updateArgs.d_timeSinceLastFrame 
		or updateArgs.d_timeSinceLastFrame
	LogInsane("self.eslaped="..self.eslaped)
	if self.mode == longpressadd or self.mode == longpressdel then
		local interval = self.interval or 1
		local delta = math.floor(self.eslaped * 10) * interval
		if self.mode == longpressadd then
			incrNum(self, delta)
		elseif self.mode == longpressdel then
			incrNum(self, -delta)
		end
		
	elseif self.eslaped > 2 then
		if self.mode == btn1down then
			self.mode = longpressadd
		elseif self.mode == btn2down then
			self.mode = longpressdel
		end
	end
end

local function onLMouseBtnClicked1(self, e)
	local interval = self.interval or 1
	self.number = CEGUI.PropertyHelper:stringToUint(self.numwnd:getText()) or 0
	incrNum(self, interval)
end

local function onLMouseBtnClicked2(self, e)
	local interval = self.interval or 1
	self.number = CEGUI.PropertyHelper:stringToUint(self.numwnd:getText()) or 0
	incrNum(self, -interval)
end

local function createComponent(pushbutton1, pushbutton2, numwnd)
	local component = {numwnd=numwnd}
	function component:setInterval(interval)
		self.interval = interval
	end
	pushbutton1:subscribeEvent("MouseButtonDown", pbtnMouseBtnDown2, component)
	pushbutton2:subscribeEvent("MouseButtonDown", pbtnMouseBtnDown1, component)
	pushbutton1:subscribeEvent("Clicked", onLMouseBtnClicked2, component)
	pushbutton2:subscribeEvent("Clicked", onLMouseBtnClicked1, component)
	pushbutton1:subscribeEvent("MouseButtonUp", pbtnMouseBtnUp2, component)
	pushbutton2:subscribeEvent("MouseButtonUp", pbtnMouseBtnUp1, component)
	--MouseLeave
	pushbutton1:subscribeEvent("MouseLeave", pbtnMouseBtnUp2, component)
	pushbutton2:subscribeEvent("MouseLeave", pbtnMouseBtnUp1, component)
	numwnd:subscribeEvent("WindowUpdate", onUpdate, component)
	return component
end

return createComponent