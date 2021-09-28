local btn = import(".btn")
local label = import(".label")
local toggle = class("an.toggle", function ()
	return display.newNode()
end)

table.merge(slot2, {
	btn,
	label,
	isSelect,
	isDisable
})

toggle.ctor = function (self, imageName, imageName2, callback, params)
	params = params or {}

	local function click()
		if self.isDisable then
			return 
		end

		self.btn:setIsSelect(not self.btn.isSelect)

		if callback then
			callback(self.btn.isSelect)
		end

		return 
	end

	self.btn = an.btn.new(slot1, click, {
		select = {
			imageName2,
			manual = true
		},
		support = params.easy and "easy",
		scale9 = params.scale9
	}):anchor(0, 0):add2(self)

	if params.default then
		self.btn:select()
	end

	if params.label then
		self.label = an.newLabel(unpack(params.label)):anchor(0, 0.5):pos(self.btn:getw() + (params.space or 10), self.btn:geth()/2):add2(self)

		self.size(self, self.btn:getw() + 10 + self.label:getw(), self.btn:geth()):enableClick(click, {
			support = params.easy and "easy"
		})
	else
		self.size(self, self.btn:getContentSize())
	end

	self.isSelect = params.default
	self.isDisable = params.isDisable

	return 
end
toggle.isSelected = function (self)
	return self.btn.isSelect
end
toggle.setIsDisable = function (self, b)
	self.isDisable = b

	return self
end

return toggle
