local horseModel = class("horseModel")
horseModel.ctor = function (self, params)
	self.params = params
	self.hasCfg = false
	self.have = false
	self.base = params.base
	self.id = 0
	self.name = ""
	self.clientname = ""
	self.shape = 0
	self.propstr = ""
	self.desc = ""
	self.time = 0
	self.lasttime = 0

	self.fillData(self)

	return 
end
horseModel.fillData = function (self)
	if self.params.id then
		self.id = self.params.id
		local cfg = def.horse:getBaseCfgByID(self.id)

		if cfg then
			self.hasCfg = true
			self.name = cfg.ClientName
			self.clientname = cfg.ClientName
			self.shape = cfg.Shape
			self.propstr = cfg.PropertyStr
			self.desc = cfg.Desc
			self.istime = cfg.BoLimitTime ~= 0
			self.time = cfg.Time
		else
			self.hasCfg = false
		end

		local data = self.base:get(self.id)
		self.have = data ~= nil

		if data then
			self.lasttime = data.FInvalidTime
		end
	end

	return 
end

return horseModel
