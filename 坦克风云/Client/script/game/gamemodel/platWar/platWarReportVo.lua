platWarReportVo={}
function platWarReportVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function platWarReportVo:initWithData(id,attacker,attName,attPlat,attServer,defender,defName,defPlat,defServer,isVictory,isAttacker,time,roadIndex)
	self.id=id
	self.attacker=attacker
	self.attName=attName
	self.attPlat=attPlat
	self.attServer=attServer
	self.defender=defender
	self.defName=defName
	self.defPlat=defPlat
	self.defServer=defServer
	self.isVictory=isVictory
	self.isAttacker=isAttacker
	self.time=time
	self.roadIndex=roadIndex
end