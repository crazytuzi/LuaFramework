local bag = import(".bag")
local heroBag = clone(bag)
heroBag.isHero = true
heroBag.getFreeCount = function (self)
	local cnt = 0

	for i = 1, g_data.hero.bagSize, 1 do
		if not self.items[i] then
			cnt = cnt + 1
		end
	end

	return cnt
end

return heroBag
