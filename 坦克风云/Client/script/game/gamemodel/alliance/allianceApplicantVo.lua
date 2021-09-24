allianceApplicantVo={}
function allianceApplicantVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceApplicantVo:initWithData(uid,name,level,fight)
	self.uid=uid
	self.name=name
	self.level=level
	self.fight=fight
end