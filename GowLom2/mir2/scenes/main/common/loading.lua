local loading = class("loading", function ()
	return display.newNode()
end)
local default_params = {
	keep_visible = false,
	style = "horse",
	hide_lbl = false,
	lbl_format = "%.02f/%.02f"
}
loading.ctor = function (self)
	self.bg = nil
	self.bar = nil
	self.lbl = nil
	self.showing = false

	return 
end
loading.precent = function (self, v)
	self.bar:setScaleX(v)

	return 
end
loading.show = function (self, ttime, params)
	local params = params or {}
	self.params = params

	self.selectStyle(self, params.style or default_params.style)
	self.reset(self)

	self.total = ttime

	self.bg:setVisible(true)

	self.showing = true

	self.lbl:setVisible(not self.params.hide_lbl)

	return 
end
loading.selectStyle = function (self, style)
	self.removeUI(self)

	local processBg = display.newScale9Sprite(res.getframe2("pic/panels/horseUpgrade/process_bg.png"), 0, 0, cc.size(111, 16)):anchor(0.5, 0.5):add2(self):pos(display.width/2, 288)
	local processBar = display.newScale9Sprite(res.getframe2("pic/panels/horseUpgrade/process.png"), 0, 0, cc.size(111, 16)):anchor(0, 0.5):add2(processBg):pos(0, processBg.geth(processBg)/2)
	local lbl = an.newLabel("", 18, 1, {
		color = cc.c3b(220, 210, 190)
	}):anchor(0.5, 0.5):pos(processBg.getw(processBg)/2, processBg.geth(processBg)/2):add2(processBg)
	self.bg = processBg
	self.bar = processBar
	self.lbl = lbl

	self.bg:setVisible(false)

	return 
end
loading.removeUI = function (self)
	if self.bg then
		self.bg:removeSelf()

		self.bg = nil
	end

	self.bar = nil
	self.lbl = nil

	return 
end
loading.hide = function (self)
	if self.bg then
		self.reset(self)
		self.bg:setVisible(false)
	end

	return 
end
loading.reset = function (self)
	self.total = 0
	self.current = 0

	self.lbl:setString("")
	self.bar:setScaleX(0)

	return 
end
loading.update = function (self, dt)
	if not self.showing then
		return 
	end

	self.current = self.current + dt
	local scale = self.current/self.total
	local timeout = false

	if 1 < scale then
		scale = 1
		timeout = true
	end

	if not self.params.hide_lbl then
		self.lbl:setString(string.format(self.params.lbl_format or default_params.lbl_format, self.current, self.total))
	end

	self.precent(self, scale)

	if timeout then
		self.timeout(self)
	end

	return 
end
loading.timeout = function (self)
	self.showing = false

	if not self.params.keep_visible then
		self.hide(self)
	end

	if self.params.timeout_cb then
		self.params.timeout_cb()
	end

	return 
end

return loading
