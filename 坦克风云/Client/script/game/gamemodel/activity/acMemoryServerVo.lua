acMemoryServerVo = activityVo:new()

function acMemoryServerVo:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	return nc
end

function acMemoryServerVo:updateSpecialData(data)
	if data == nil then
		return
	end
	if data._activeCfg then
		self.activityCfg = data._activeCfg
	end
	if data.bind then
		self.bind = data.bind --[uid,zid,ozid]
	end
	if data.bindudata then
		self.bindData = data.bindudata
	end
	if data.rd then
		self.rd = data.rd
	end
	if data.tk then
		self.tk = data.tk
	end
end