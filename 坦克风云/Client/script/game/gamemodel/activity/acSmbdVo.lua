acSmbdVo = activityVo:new()

function acSmbdVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acSmbdVo:updateSpecialData(data)

	if data == nil then
		return
	end
	if data._activeCfg then
		self.smbdCfg = data._activeCfg
	end
	if data.v then
		self.point = data.v
	end
	if data.p then
		self.taskPonit = data.p
	end
	if data.rd then --记录每个礼包兑换次数
		self.exchange=data.rd
	end
end