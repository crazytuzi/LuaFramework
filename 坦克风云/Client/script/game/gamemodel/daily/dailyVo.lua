dailyVo={}
function dailyVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function dailyVo:initWithData(id,freeNum,num,award,cost,time)
	self.id=id
	self.freeNum=freeNum
	self.num=num
	self.award=award
	self.cost=cost
	self.time=time
	--self.awardPool=awardPool
end