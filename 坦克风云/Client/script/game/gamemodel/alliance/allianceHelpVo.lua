allianceHelpVo={}
function allianceHelpVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end
--tid：科技id
--bType：建筑类型
--level：等级
--pic：头像
--num：帮助次数
--maxNum：最大帮助次数
--hType：帮助类型
function allianceHelpVo:initWithData(id,uid,name,tid,bType,level,pic,num,maxNum,hType,time)
	self.id=id
	self.uid=uid
	self.name=name or ""
	self.tid=tid or 1
	self.bType=bType or 1
	self.level=tonumber(level) or 0
	self.pic=pic or 1
	self.num=tonumber(num) or 0
	self.maxNum=tonumber(maxNum) or 0
	self.hType=hType
	self.time=tonumber(time) or 0
end