checkPointVo={}
function checkPointVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--chapterTab格式：{{isUnlock=true,index=1,starNum=3},{isUnlock=true,index=2,starNum=1}...}
function checkPointVo:initWithData(sid,starNum,isUnlock,chapterTab)
	self.sid=sid
	self.starNum=starNum
	self.isUnlock=isUnlock
	self.chapterTab=chapterTab
end