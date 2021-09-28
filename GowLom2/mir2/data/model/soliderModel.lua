local soliderModel = class("soliderModel")
soliderModel.ctor = function (self, params)
	self.params = params
	self.base = params.base or g_data.solider
	self.id = params.id or -1
	self.have = false
	self.name = ""
	self.img = ""
	self.level = 0
	self.haveStuff = 0

	self.fillData(self)

	return 
end
soliderModel.fillData = function (self)
	if not def.solider.nameCfg[self.id] then
		return 
	end

	local data = self.base:getSoliderData(self.id)

	if data then
		self.have = true
		self.level = data.FLevel
		self.haveStuff = data.FHaveStuff
	else
		self.have = false
	end

	self.name = def.solider.nameCfg[self.id]
	self.img = def.solider.imgCfg[self.id]

	return 
end
soliderModel.getCurCfg = function (self)
	return def.solider:getCfg(self.id, self.level)
end
soliderModel.getNextCfg = function (self)
	return def.solider:getCfg(self.id, self.level + 1)
end

return soliderModel
