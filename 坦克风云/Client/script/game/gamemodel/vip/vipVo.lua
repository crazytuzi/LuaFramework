vipVo=
{
	monthlyCardLastGet=0,			--上次领取月卡金币的时间
	monthlyCardExpireTime=0,		--月卡到期的时间
}

function vipVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function vipVo:update(data)
	if(data[1])then
		self.monthlyCardExpireTime=tonumber(data[1])
	end
	if(data[2])then
		self.monthlyCardLastGet=tonumber(data[2])
	end
end

