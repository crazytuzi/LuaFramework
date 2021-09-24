heroEquipChallengeVo={}
function heroEquipChallengeVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.s=0
    self.a=0
    self.r=0
    return nc
end

function heroEquipChallengeVo:initWithData(data)
	-- 该关卡获得的星数
	if data.s then
		self.s=data.s
	end
	-- 今日攻打次数
	if data.a then
		self.a=data.a
	end
	-- 今天重置次数
	if data.r then
		self.r=data.r
	end
end
