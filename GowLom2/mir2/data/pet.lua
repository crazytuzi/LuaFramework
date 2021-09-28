local petModel = import(".model.petModel")
local petSkinModel = import(".model.petSkinModel")
local pet = {
	FCurrSkinIdent = 0,
	FCurrIdent = 0,
	FList = {},
	FSkinList = {},
	setInfo = function (self, result)
		self.FCurrIdent = result.FCurrPetIdent
		self.FList = result.FPetList
		self.FCurrSkinIdent = result.FCurrPetSkinID
		self.FSkinList = result.FPetSkinList

		g_data.eventDispatcher:dispatch("M_PET_DATA_CHG")
		g_data.eventDispatcher:dispatch("M_PET_SKIN_CHG")
		g_data.eventDispatcher:dispatch("M_PET_SKIN_LIST_CHG")

		return 
	end,
	setCurrentIdent = function (self, ident)
		self.FCurrIdent = ident

		g_data.eventDispatcher:dispatch("M_PET_DATA_CHG")

		return 
	end,
	getPetSkinByID = function (self, id)
		for i, v in ipairs(self.FSkinList) do
			if v.FID == id then
				return v
			end
		end

		return nil
	end,
	setCurrentSkinId = function (self, id)
		self.FCurrSkinIdent = id

		g_data.eventDispatcher:dispatch("M_PET_SKIN_CHG")

		return 
	end,
	get = function (self, ident)
		for i, v in ipairs(self.FList) do
			if v.FCliPetIdent == ident then
				return v
			end
		end

		return nil
	end,
	add = function (self, data)
		self.FList[#self.FList + 1] = data

		g_data.eventDispatcher:dispatch("M_PET_LIST_CHG")

		return 
	end,
	del = function (self, ident)
		for i, v in ipairs(self.FList) do
			if v.FCliPetIdent == ident then
				table.remove(self.FList, i)
				g_data.eventDispatcher:dispatch("M_PET_LIST_CHG")

				break
			end
		end

		return 
	end,
	update = function (self, ident, info)
		local data = self.get(self, ident)

		if data then
			for i, v in pairs(info) do
				if data[i] ~= nil then
					data[i] = v
				end
			end
		end

		return data
	end,
	addSkin = function (self, skinId)
		self.FSkinList[#self.FSkinList + 1] = skinId

		g_data.eventDispatcher:dispatch("M_PET_SKIN_LIST_CHG")

		return 
	end,
	delSkin = function (self, skinId)
		local isdel = false

		for i, v in ipairs(self.FSkinList) do
			if v.FID == skinId then
				isdel = true

				table.remove(self.FSkinList, i)

				break
			end
		end

		if self.FCurrSkinIdent == skinId then
			self.FCurrSkinIdent = 0
		end

		if isdel then
			g_data.eventDispatcher:dispatch("M_PET_SKIN_LIST_CHG")
			g_data.eventDispatcher:dispatch("M_PET_SKIN_CHG")
		end

		return 
	end,
	getPetByIdent = function (self, ident)
		local info = petModel.new({
			ident = ident,
			base = self
		})

		return info
	end,
	getPetByIndex = function (self, index)
		local info = petModel.new({
			index = index,
			base = self
		})

		return info
	end,
	getPetSkinByIndex = function (self, id)
		local info = petSkinModel.new({
			id = id,
			base = self
		})

		return info
	end,
	getDataById = function (self, horseid)
		for i, v in ipairs(self.FList) do
			if v.FPetIndex == horseid then
				return v
			end
		end

		return nil
	end,
	getDataByIdent = function (self, horseIdent)
		for i, v in ipairs(self.FList) do
			if v.FCliPetIdent == horseIdent then
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
	end,
	computerProperty = function (self, petData)
		local baseCfg = def.pet:getBaseCfgByID(petData.FPetIndex)
		local levelCfg = def.pet:getUpgradeCfgByLevel(petData.FLevel)
		local rareCfg = def.pet:getRareCfgByID(baseCfg.RarityID, petData.FQualityID)
		local zizhiCfg = def.pet:getZizhiProperty(petData.FAptitude)
		local GrowthCoeff = rareCfg.GrowthCoeff/10000
		local RariryCoeff = baseCfg.RariryCoeff/10000
		local QualityCoeff = rareCfg.QualityCoeff/10000
		local levelProp = def.property.dumpPropertyStr(levelCfg.PropertyStr)
		local zizhiProp = def.property.dumpPropertyStr(zizhiCfg.PropertyStr)

		for i, v in ipairs(levelProp.props) do
			local value = v[2]
			value = value + value*GrowthCoeff
			local zizhiValue = zizhiProp.get(zizhiProp, v[1])
			value = value + zizhiValue
			local xishu = RariryCoeff + QualityCoeff
			value = value*xishu

			levelProp.set(levelProp, v[1], math.floor(value))
		end

		return levelProp
	end
}

return pet
