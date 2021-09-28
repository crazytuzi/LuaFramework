local horseModel = import(".model.horseModel")
local horse = {
	FCurrIdent = 0,
	state = 0,
	FList = {},
	setInfo = function (self, result)
		self.FCurrIdent = result.FCurrHorseID
		self.FList = result.FHorseList

		g_data.eventDispatcher:dispatch("M_HORSE_LIST_CHG")
		g_data.eventDispatcher:dispatch("M_HORSE_DATA_CHG")

		return 
	end,
	get = function (self, id)
		for i, v in ipairs(self.FList) do
			if v.FID == id then
				return v
			end
		end

		return nil
	end,
	add = function (self, data)
		self.FList[#self.FList + 1] = data

		g_data.eventDispatcher:dispatch("M_HORSE_LIST_CHG")
		g_data.eventDispatcher:dispatch("M_HORSE_DATA_CHG")

		return 
	end,
	del = function (self, id)
		local isdel = false

		for i, v in ipairs(self.FList) do
			if v.FID == id then
				isdel = true

				table.remove(self.FList, i)

				break
			end
		end

		if self.FCurrIdent == id then
			self.FCurrIdent = 0
		end

		if isdel then
			g_data.eventDispatcher:dispatch("M_HORSE_LIST_CHG")
			g_data.eventDispatcher:dispatch("M_HORSE_DATA_CHG")
		end

		return 
	end,
	update = function (self, id, info)
		local data = self.get(self, id)

		if data then
			for i, v in pairs(info) do
				if data[i] ~= nil then
					data[i] = v
				end
			end
		end

		return data
	end,
	setCurrentIdent = function (self, ident)
		self.FCurrIdent = ident

		g_data.eventDispatcher:dispatch("M_HORSE_DATA_CHG")

		return 
	end,
	getHorseById = function (self, id)
		local info = horseModel.new({
			id = id,
			base = self
		})

		return info
	end,
	isHaveHorse = function (self, id)
		for i, v in ipairs(self.FList) do
			if v.FID == id then
				return true
			end
		end

		return false
	end,
	getDataById = function (self, id)
		for i, v in ipairs(self.FList) do
			if v.FID == horseid then
				return v
			end
		end

		return nil
	end,
	getDataByIdent = function (self, horseIdent)
		for i, v in ipairs(self.FList) do
			if v.FCliHorseIdent == horseid then
				return v
			end
		end

		return nil
	end,
	getCurrentIdent = function (self)
		return self.FCurrIdent
	end,
	getCurrentData = function (self)
		return self.getDataByIdent(self, self.getCurrentIdent(self))
	end,
	setRideState = function (self, state)
		self.state = state

		return 
	end
}

return horse
