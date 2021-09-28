local map = {
	mapTitle = "",
	mapState = 0,
	mapReplace = {},
	safezones = {},
	setSafeZone = function (self, result)
		self.safezones = {}

		for k, v in pairs(result.FList) do
			local points = self.safezones[v.FStartMap]

			if not points then
				points = {}
				self.safezones[v.FStartMap] = points
			end

			points[#points + 1] = {
				x = v.FX,
				y = v.FY,
				rang = (v.FRang == 0 and 9) or v.FRang
			}
		end

		return 
	end,
	isInSafeZone = function (self, mapid, x, y)
		if ycFunction:band(cAreaStateSafe, self.mapState) ~= 0 then
			return true
		end

		local points = self.safezones[mapid]

		if not points then
			return 
		end

		for i, v in ipairs(points) do
			if math.abs(v.x - x) <= v.rang and math.abs(v.y - y) <= v.rang then
				return true
			end
		end

		return 
	end,
	isSeeSafeZoneEdge = function (self, mapid, x, y, w, h)
		local points = self.safezones[mapid]

		if not points then
			return 
		end

		local ret = nil

		for i, v in ipairs(points) do
			if math.abs(v.x - x) <= v.rang + w and math.abs(v.y - y) <= v.rang + h then
				ret = ret or {}
				ret[#ret + 1] = v
			end
		end

		return ret
	end,
	setMapState = function (self, state)
		self.mapState = state

		return 
	end,
	setMapTitle = function (self, title)
		self.mapTitle = title

		return 
	end
}

return map
