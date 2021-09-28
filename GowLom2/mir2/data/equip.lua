local equip = {
	lockState = 0,
	isHero = false,
	attrDetailPageIndex = 1,
	gemstoneRequestFromEquip = true,
	lockTime = 180000,
	stateDetailPageIndex = 1,
	serverUnlockTime = 0,
	items = {},
	takeOffing = {},
	set = function (self, result)
		self.items = {}
		self.takeOffing = {}

		for k, v in ipairs(result.FList) do
			setmetatable(v.FCliEquip, {
				__index = gItemOp
			})

			self.items[v.FnPos] = v.FCliEquip

			v.FCliEquip:decodedCallback()
		end

		return 
	end,
	upt = function (self, result)
		local data = result.FItem

		setmetatable(data, {
			__index = gItemOp
		})
		data.decodedCallback(data)

		for k, v in pairs(self.items) do
			if v.FItemIdent == data.FItemIdent and v.getVar(v, "name") == data.getVar(data, "name") then
				print("equip:upt ", v.getVar(v, "name"))

				self.items[k] = data

				return data.FItemIdent
			end
		end

		return 
	end,
	isEquipped = function (self, equipName)
		for k, v in pairs(self.items) do
			if v.getVar(v, "name") == equipName then
				return true
			end
		end

		return 
	end,
	checkEquips = function (self, equipTbl)
		for _, equipName in ipairs(equipTbl) do
			for k, v in pairs(self.items) do
				if v.getVar(v, "name") == equipName then
					return true, v
				end
			end
		end

		return 
	end,
	getEquipByPos = function (self, fnpos)
		return self.items[fnpos]
	end,
	checkAmulet = function (self)
		amuletNames = {
			"护身符",
			"护身符(大)",
			"超级护身符"
		}

		return self.checkEquips(self, amuletNames)
	end,
	isBlurryEquipped = function (self, itemsName)
		local names = {}

		if type(itemsName) == "string" then
			names[1] = itemsName
		elseif type(itemsName) == "table" then
			names = itemsName
		end

		for i, name in ipairs(names) do
			if type(name) == "string" then
				for k, v in pairs(self.items) do
					if string.find(v.getVar(v, "name"), name) then
						return true
					end
				end
			end
		end

		return 
	end,
	duraChange = function (self, idx, dura, duraMax)
		local item = self.items[tonumber(idx)]

		if item then
			item.FDura = dura
			item.FDuraMax = duraMax
		end

		return 
	end,
	getItem = function (self, makeIndex)
		for k, v in pairs(self.items) do
			if makeIndex == v.FItemIdent then
				return k, v
			end
		end

		return 
	end,
	delItem = function (self, makeIndex)
		for k, v in pairs(self.items) do
			if tonumber(makeIndex) == v.FItemIdent then
				self.items[k] = nil

				return true
			end
		end

		return 
	end,
	setItem = function (self, where, item)
		self.items[tonumber(where)] = item

		return 
	end,
	takeOff = function (self, makeIndex, params)
		if self.takeOffing.item and socket.gettime() - self.takeOffing.time < 5 then
			return 
		end

		for k, v in pairs(self.items) do
			if makeIndex == v.FItemIdent then
				self.takeOffing.item = v
				self.takeOffing.time = socket.gettime()
				self.takeOffing.params = params
				self.items[k] = nil

				return true
			end
		end

		return 
	end,
	takeOffEnd = function (self, isSuccess)
		local ret = nil

		if not isSuccess and self.takeOffing.item then
			self.setItem(self, self.takeOffing.params.where, self.takeOffing.item)

			ret = self.takeOffing.item.FItemIdent
		end

		self.takeOffing = {}

		return ret
	end,
	setLock = function (self, key)
		self.lockState = key

		return 
	end,
	setServerUnlockTime = function (self, time)
		self.serverUnlockTime = time

		return 
	end
}

return equip
