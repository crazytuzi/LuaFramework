local petModel = class("petModel")
petModel.ctor = function (self, params)
	self.params = params
	self.have = false
	self.base = params.base
	self.ident = params.ident
	self.index = params.index
	self.level = 0
	self.quality = 0
	self.qualityExp = 0
	self.aptitude = 0
	self.lvHaveExp = 0
	self.totalLvExp = 0
	self.name = ""
	self.img = ""
	self.job = 0
	self.rarity = 0
	self.rarityCoeff = 0
	self.maxLv = 0
	self.maxAptLv = 0
	self.inneritJb = 0
	self.inneritPYD = 0
	self.aptJb = 0
	self.aptZZD = 0
	self.qualityCoeff = 0
	self.growthCoeff = 0
	self.upEatGetExp = 0
	self.quaEatGetExp = 0
	self.upPropStr = nil
	self.zizhiPropStr = nil
	self.desc = nil

	self.fillData(self)

	return 
end
petModel.fillData = function (self)
	if self.params.ident then
		local data = self.base:getDataByIdent(self.params.ident)
		self.have = data ~= nil

		if self.have then
			self.ident = self.params.ident
			self.index = data.FPetIndex
			self.quality = data.FQualityID
			self.qualityExp = data.FQualityExp
			self.aptitude = data.FAptitude
			self.lvHaveExp = data.FLvHaveExp
			self.level = data.FLevel
			self.totalLvExp = data.FTotalLvExp
			local cfg = def.pet:getBaseCfgByID(self.index)

			if cfg then
				self.name = cfg.Name
				self.img = cfg.Img
				self.job = cfg.Job - 1
				self.rarity = cfg.RarityID
				self.rarityCoeff = cfg.RariryCoeff
				self.maxLv = cfg.MaxUpLv
				self.maxAptLv = cfg.MaxAptLv
				self.inneritJb = cfg.InheritNeedJB
				self.inneritPYD = cfg.InheritNeedPYD
				self.aptJb = cfg.AptInhNeedJB
				self.aptZZD = cfg.AptInhNeedZZD
				self.desc = cfg.Desc
				local upcfg = def.pet:getUpgradeCfgByLevel(self.level)

				if upcfg then
					self.upPropStr = upcfg.PropertyStr
				end
			end

			local cfg = def.pet:getRareCfgByID(self.rarity, self.quality)

			if cfg then
				self.qualityCoeff = cfg.QualityCoeff
				self.growthCoeff = cfg.GrowthCoeff
				self.upEatGetExp = cfg.UpEatGetExp
				self.quaEatGetExp = cfg.QuaEatGetExp
			end

			local zizhi = def.pet:getZizhiProperty(self.aptitude)

			if zizhi then
				self.zizhiPropStr = zizhi.PropertyStr
			end
		end
	elseif self.params.index then
		self.have = false
		local cfg = def.pet:getBaseCfgByID(self.index)

		if cfg then
			self.name = cfg.Name
			self.img = cfg.Img
			self.job = cfg.Job - 1
			self.rarity = cfg.RarityID
			self.rarityCoeff = cfg.RariryCoeff
			self.maxLv = cfg.MaxUpLv
			self.maxAptLv = cfg.MaxAptLv
			self.inneritJb = cfg.InheritNeedJB
			self.inneritPYD = cfg.InheritNeedPYD
			self.aptJb = cfg.AptInhNeedJB
			self.aptZZD = cfg.AptInhNeedZZD
			self.desc = cfg.Desc
			local upcfg = def.pet:getUpgradeCfgByLevel(self.level)

			if upcfg then
				self.upPropStr = upcfg.PropertyStr
			end
		end

		local cfg = def.pet:getRareCfgByID(self.rarity, self.quality)

		if cfg then
			self.qualityCoeff = cfg.QualityCoeff
			self.growthCoeff = cfg.GrowthCoeff
			self.upEatGetExp = cfg.UpEatGetExp
			self.quaEatGetExp = cfg.QuaEatGetExp
		end
	else
		self.have = false
	end

	return 
end

return petModel
