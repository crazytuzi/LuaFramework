taskVo={}
function taskVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end


function taskVo:initWithData(sid,type,num,cNum,isReward,ts,level)
	self.sid=sid
	self.type=type
	self.num=num
	self.cNum=cNum
	self.isReward=isReward
	self.ts=ts
	self.level=level
end

