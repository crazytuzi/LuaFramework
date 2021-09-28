local petSkinModel = class("petSkinModel")
petSkinModel.ctor = function (self, params)
	self.params = params
	self.hasCfg = false
	self.have = false
	self.base = params.base
	self.id = 0
	self.name = ""
	self.clientname = ""
	self.img = 0
	self.propstr = ""
	self.time = 0
	self.lasttime = 0
	self.desc = ""
	self.kind = 0
	self.istime = false

	self.fillData(self)

	return 
end
petSkinModel.fillData = function (self)
	if self.params.id then
		self.id = self.params.id
		local cfg = def.pet:getBaseSkinCfgByID(self.id)

		if cfg then
			self.hasCfg = true
			self.name = cfg.ClientName
			self.clientname = cfg.ClientName
			self.img = cfg.Img
			self.propstr = cfg.PropertyStr
			self.istime = cfg.BoLimitTime ~= 0
			self.time = cfg.Time
			self.desc = cfg.Desc
			self.kind = cfg.Kind
		else
			self.hasCfg = false
		end

		local data = self.base:getPetSkinByID(self.id)
		self.have = data ~= nil

		if data then
			self.lasttime = data.FInvalidTime
		end
	end

	return 
end

return petSkinModel
