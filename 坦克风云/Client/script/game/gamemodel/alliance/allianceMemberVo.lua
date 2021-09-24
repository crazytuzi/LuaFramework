allianceMemberVo={}
function allianceMemberVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end
--[[
[{"role":"3","stats":"0","fight":"476","uid":"1000328","name":"Www","aid":"18","logined_at":"0","raising":"0","updated_at":"1389271141","level":"1","requests":"[]"}]
]]
--logined_at 最后登录时间
--joinTime 加入军团时间
function allianceMemberVo:initWithData(uid,name,level,role,fight,signature,logined_at,weekDonate,donate,donateTime,useDonate,joinTime,apoint,apoint_at,ar,ar_at)
	self.uid=uid
	self.name=name
	self.level=level
	self.role=role
    self.fight=fight
    self.signature=signature
    self.rank1=0
    self.rank2=0
    self.logined_at=logined_at
    self.weekDonate=tonumber(weekDonate) or 0
    self.donate=tonumber(donate) or 0
    self.donateTime=tonumber(donateTime) or 0
    self.useDonate=tonumber(useDonate) or 0
    self.rank3=1
    self.rank4=1
    self.joinTime=tonumber(joinTime) or 0
    self.apoint=tonumber(apoint) or 0
    self.apoint_at=tonumber(apoint_at) or 0
    
    self.ar=tonumber(ar) or {}
    self.ar_at=tonumber(ar_at) or 0
end