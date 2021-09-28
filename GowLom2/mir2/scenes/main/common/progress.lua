local progress = class("progress", function ()
	return display.newNode()
end)
progress.ctor = function (self, params)
	self.params = params or {}
	self.percent = 0
	self.percent_ext = 0
	self.totalValue = 0
	self.currentValue = 0
	self.extValue = 0
	params.bg_file = params.bg_file or "pic/panels/wingUpgrade/pg_bg.png"
	params.bg_body_file = params.bg_body_file or "pic/panels/wingUpgrade/pg.png"
	params.bg_ext_file = params.bg_ext_file or "pic/panels/wingUpgrade/pg_ext.png"
	params.bg_size = params.bg_size or cc.size(255, 25)
	params.body_size = params.body_size or cc.size(249, 17)
	params.body_margin_l = params.body_margin_l or 3
	params.show_lbl = params.show_lbl or true
	params.lbl_param = params.lbl_param or {}

	self.setupUI(self)

	return 
end
progress.setupUI = function (self)
	local node = self
	local params = self.params

	self.size(self, params.bg_size)

	local bg = display.newScale9Sprite(res.getframe2(params.bg_file), 0, 0, params.bg_size):anchor(0, 0):add2(node)
	local body = display.newScale9Sprite(res.getframe2(params.bg_body_file), 0, 0, params.body_size):anchor(0, 0.5):add2(bg):pos(params.body_margin_l, bg.geth(bg)/2)
	local body_ext = display.newScale9Sprite(res.getframe2(params.bg_ext_file), 0, 0, params.body_size):anchor(0, 0.5):add2(bg):pos(params.body_margin_l, bg.geth(bg)/2)
	local lbl = an.newLabelM(params.bg_size.width, 18, 1, {
		manual = false,
		center = true
	}):add2(bg):anchor(0.5, 0.5):pos(params.bg_size.width/2, params.bg_size.height/2)

	lbl.nextLine(lbl)

	self.bg = bg
	self.body = body
	self.body_ext = body_ext
	self.lbl = lbl

	self.layout(self)

	return 
end
progress.setPercent = function (self, percent)
	self.percent = percent

	self.layout(self)

	return 
end
progress.setExtPercent = function (self, percent)
	self.percent_ext = percent

	self.layout(self)

	return 
end
progress.setValue = function (self, valueMap)
	valueMap.totalValue = valueMap.totalValue or self.totalValue
	valueMap.currentValue = valueMap.currentValue or self.currentValue
	valueMap.extValue = valueMap.extValue or self.extValue
	self.totalValue = valueMap.totalValue
	self.currentValue = valueMap.currentValue
	self.extValue = valueMap.extValue
	local texts = {}

	if 0 < self.extValue then
		texts[#texts + 1] = {
			"" .. self.currentValue + self.extValue,
			def.colors.Ce66946
		}
	else
		texts[#texts + 1] = {
			"" .. self.currentValue
		}
	end

	texts[#texts + 1] = {
		"/"
	}
	texts[#texts + 1] = {
		"" .. self.totalValue
	}

	self.setLabelText(self, texts)
	self.setPercent(self, self.currentValue/self.totalValue)
	self.setExtPercent(self, self.extValue/self.totalValue)

	return 
end
progress.layout = function (self)
	local per = (1 < self.percent and 1) or self.percent
	local perExt = self.percent_ext

	if 1 < self.percent_ext + per then
		perExt = per - 1
	end

	self.body:setScaleX(per)
	self.body_ext:setScaleX(perExt)

	local x = self.body:getPositionX()
	local x2 = self.body:getw()*per

	self.body_ext:setPositionX(self.body:getPositionX() + self.body:getw()*per)

	return 
end
progress.setLabelText = function (self, texts)
	self.lbl:clear()

	if type(texts) == "string" then
		self.lbl:addLabel(texts)
	else
		for i, v in ipairs(texts) do
			if type(v) == "string" then
				self.lbl:addLabel(v)
			else
				self.lbl:addLabel(v[1], v[2])
			end
		end
	end

	return 
end

return progress
