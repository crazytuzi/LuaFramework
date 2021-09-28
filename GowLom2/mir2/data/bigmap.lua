local bigmap = {
	maps = {},
	group = {},
	scriptPath = {},
	likeNames = {},
	loadLike = function (self, map)
		self.maps[map] = self.maps[map] or {}
		local mapCache = cache.getBigmap(map)
		local likes = {}

		if mapCache and mapCache.likes then
			likes = mapCache.likes
		end

		if not self.maps[map].likes then
			self.maps[map].likes = likes
		end

		return 
	end,
	isExistLike = function (self, map, x, y)
		if not map or map == "" then
			return false
		end

		self.loadLike(self, map)

		for i, v in ipairs(self.maps[map].likes) do
			if v.x == x and v.y == y then
				return true
			end
		end

		return false
	end,
	isExistLikeName = function (self, map, name)
		for i, v in ipairs(self.maps[map].likes) do
			if v.name == name then
				return true
			end
		end

		return false
	end,
	addLike = function (self, map, name, x, y)
		if not map or map == "" then
			return 
		end

		self.loadLike(self, map)

		for i, v in ipairs(self.maps[map].likes) do
			if v.x == x and v.y == y then
				return 
			end
		end

		local like = {
			dataType = "pos",
			name = name,
			x = x,
			y = y
		}
		self.maps[map].likes[#self.maps[map].likes + 1] = like

		cache.saveBigmap(map)
		table.insert(self.likeNames, name)

		return 
	end,
	removeLike = function (self, map, x, y)
		if not map or map == "" then
			return 
		end

		self.loadLike(self, map)

		for i, v in ipairs(self.maps[map].likes) do
			if v.x == x and v.y == y then
				table.remove(self.maps[map].likes, i)
				self.removeLike(self, map, x, y)
				cache.saveBigmap(map)
			end
		end

		table.removebyvalue(self.likeNames, name)

		return 
	end,
	getLikesNum = function (self, map)
		self.loadLike(self, map)

		return #self.maps[map].likes
	end,
	getLikes = function (self, map)
		self.loadLike(self, map)

		return self.maps[map].likes
	end,
	loadNpcs = function (self, map)
		self.maps[map] = self.maps[map] or cache.getBigmap(map) or {}
		self.maps[map].npcs = self.maps[map].npcs or {}

		return 
	end,
	addNpcs = function (self, npcList)
		local title = g_data.client.npcMap.title
		self.maps[title] = self.maps[title] or {}
		self.maps[title].npcs = {}
		self.maps[title].npcs = npcList

		return 
	end,
	getNpcs = function (self, map)
		if not self.maps[map] then
			return nil
		else
			return self.maps[map].npcs
		end

		return 
	end,
	getGroupInfo = function (self, result)
		self.group = {}

		for k, v in pairs(result.FPositionList) do
			local temp = {
				name = v.FName,
				x = v.FPosX,
				y = v.FPosY
			}
			self.group[#self.group + 1] = temp
		end

		return 
	end,
	getScriptPath = function (self, mapid)
		if 0 < #self.scriptPath then
			local tmp = nil

			for i, v in ipairs(self.scriptPath) do
				if v.name == mapid then
					return v
				end
			end
		end

		return 
	end
}

return bigmap
