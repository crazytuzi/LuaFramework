allianceSkillVo={}
function allianceSkillVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceSkillVo:initWithData(id,level,exp)
  self.id=id
  self.level=level
  self.exp=exp
end