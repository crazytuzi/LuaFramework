serverWarTeamRecordVo={}
function serverWarTeamRecordVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function serverWarTeamRecordVo:initWithData(type,warid,rid,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attZoneId,defZoneId,time,placeIndex,report)
    self.type=type
	self.warid=warid
    self.rid=rid
    self.attId=attId
    self.defId=defId
    self.attName=attName
    self.defName=defName
    self.attAid=attAid
    self.defAid=defAid
    self.attAName=attAName or ""
    self.defAName=defAName or ""
    self.attZoneId=attZoneId
    self.defZoneId=defZoneId
    self.time=time or base.serverTime
    self.placeIndex=placeIndex or 1
    self.report=report
end