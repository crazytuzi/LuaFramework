allianceBattleMemVo={}
function allianceBattleMemVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceBattleMemVo:initWithData(uid,name,level,role,fight,donate,useDonate,isBattle,index)
	self.uid=uid
	self.name=name
	self.level=level
	self.role=role
    self.fight=fight
    self.donate=tonumber(donate) or 0
    self.useDonate=tonumber(useDonate) or 0
    self.isBattle=isBattle
    self.index=index
end