local star = class("star", function ()
	return display.newNode()
end)
star.ctor = function (self, params)
	self.params = params or {}
	self.total = params.total or 10
	self.light = params.light or 0
	self.selectEnable = params.selectEnable or false
	self.__stars = {}

	self.setupUI(self)

	return 
end
star.setupUI = function (self)
	local node = self
	local margin = 0
	local w = 0
	local y = 0

	for i = 1, self.total, 1 do
		local star = an.newBtn(res.gettex2("pic/panels/wingUpgrade/starBg.png"), function ()
			sound.playSound("103")

			return 
		end, {
			select = {
				res.gettex2("pic/panels/wingUpgrade/star.png")
			}
		}).add2(slot9, node):anchor(0.5, 0.5)
		w = star.getw(star)
		h = star.geth(star)

		star.pos(star, i*(w + margin), h/2)
		star.setTouchEnabled(star, self.selectEnable)

		self.__stars[i] = star
	end

	w = w*self.total + margin*(self.total - 1)

	self.size(self, w, h)

	if self.light <= self.total then
		self.select(self, self.light)
	end

	return 
end
star.select = function (self, idx)
	for i, v in ipairs(self.__stars) do
		if i <= idx then
			v.select(v)
		else
			v.unselect(v)
		end
	end

	return 
end
star.selectOne = function (self, idx)
	for i, v in ipairs(self.__stars) do
		if i == idx then
			v.select(v)
		else
			v.unselect(v)
		end
	end

	return 
end

return star
