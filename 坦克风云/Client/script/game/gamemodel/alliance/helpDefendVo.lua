helpDefendVo={}
function helpDefendVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function helpDefendVo:initWithData(id,uid,aid,name,time,status,lastTime,tankInfoTab)
	self.id=tostring(id)
	self.uid=tonumber(uid) or 0
	self.aid=tonumber(aid) or 0
    self.name=tostring(name) or ""
	self.time=tonumber(time) or 0
	self.status=tonumber(status) or 1
	self.lastTime=tonumber(lastTime) or 0
	self.tankInfoTab=tankInfoTab
end