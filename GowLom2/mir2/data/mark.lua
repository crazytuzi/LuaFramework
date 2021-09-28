local mark = {
	playerName = "",
	maxCount = 30,
	chat = 4,
	near = 1,
	group = 2,
	friend = 3,
	guild = 5,
	memList = {},
	check = function (self, name, priority, reset)
		if name == self.playerName then
			return true
		end

		for key, value in pairs(self.memList) do
			if value.tar == name then
				if reset then
					if priority <= value.pri then
						return true
					else
						table.remove(self.memList, key)

						return false
					end
				else
					return true
				end
			end
		end

		return false
	end,
	removeWithType = function (self, type)
		for i = #self.memList, 1, -1 do
			if self.memList[i].src == type then
				table.remove(self.memList, i)
			end
		end

		return 
	end,
	reorder = function (self)
		local function _sort(a, b)
			local aName = ycFunction:u2a(a.tar, string.len(a.tar))
			local bName = ycFunction:u2a(b.tar, string.len(b.tar))

			return aName < bName
		end

		table.sort(self.memList, slot1)

		if self.maxCount < #self.memList then
			for i = #self.memList, self.maxCount, -1 do
				table.remove(self.memList, i)
			end
		end

		return 
	end,
	getNames = function (self)
		local data = {}

		for key, value in pairs(self.memList) do
			data[#data + 1] = value.tar
		end

		return data
	end,
	addMem = function (self, name, priority, source, reset)
		local exist = nil

		if type(name) == "table" then
			for i, v in ipairs(name) do
				if type(v) == "string" then
					exist = self.check(self, v, priority, reset)

					if not exist then
						self.memList[#self.memList + 1] = {
							tar = v,
							pri = priority,
							src = source
						}
					end
				end
			end
		elseif type(name) == "string" then
			exist = self.check(self, name, priority, reset)

			if not exist then
				self.memList[#self.memList + 1] = {
					tar = name,
					pri = priority,
					src = source
				}
			end
		end

		self.reorder(self)

		return 
	end,
	removeMem = function (self, name)
		for i, v in ipairs(self.memList) do
			if v.tar == name then
				table.remove(self.memList, i)
			end
		end

		return 
	end,
	addNear = function (self, name)
		self.removeWithType(self, "near")
		self.addMem(self, name, self.near, "near", true)

		return 
	end,
	addGroup = function (self, name)
		self.addMem(self, name, self.group, "group", true)

		return 
	end,
	addFriend = function (self, name)
		self.addMem(self, name, self.friend, "friend", true)

		return 
	end,
	addChat = function (self, name)
		self.addMem(self, name, self.chat, "chat", true)

		return 
	end,
	addGuild = function (self, name)
		self.addMem(self, name, self.guild, "guild", true)

		return 
	end
}

return mark
