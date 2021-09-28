local progress = class("an.progress", function ()
	return display.newNode()
end)

table.merge(slot0, {
	bg,
	bar,
	isV
})

progress.ctor = function (self, barfile, bgfile, offset, isV)
	assert(barfile, "[an.progress] barfile must not nil.")

	offset = offset or {
		x = 0,
		y = 0
	}
	self.isV = isV
	self.bar = display.newSprite(barfile):anchor(0, 0):pos(offset.x, offset.y):add2(self, 1)

	if bgfile then
		self.bg = display.newSprite(bgfile):anchor(0, 0):add2(self)

		self.size(self, self.bg:getw(), self.bg:geth())
	else
		self.bg = nil

		self.size(self, self.bar:getw(), self.bar:geth())
	end

	self.setp(self, 0)

	return 
end
progress.setp = function (self, p)
	if 1 < p then
		p = 1
	end

	if p < 0 then
		p = 0
	end

	local size = self.bar:getTexture():getContentSize()

	if self.isV then
		self.bar:setTextureRect(cc.rect(0, (p - 1)*size.height, size.width, size.height*p))
	else
		self.bar:setTextureRect(cc.rect(0, 0, size.width*p, size.height))
	end

	return 
end

return progress
