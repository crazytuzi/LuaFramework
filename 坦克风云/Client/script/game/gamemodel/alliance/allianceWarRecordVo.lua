allianceWarRecordVo={}
function allianceWarRecordVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceWarRecordVo:initWithData(battleId,warid,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attBuff,defBuff,attPoint,defPoint,isWin,report,attRaising,defRaising,time,placeIndex,destroyNum,lostNum,isAttacker,isBattle)
	self.battleId=battleId
    self.warid=warid
    self.attId=attId
    self.defId=defId
    self.attName=attName
    self.defName=defName
    self.attAid=attAid
    self.defAid=defAid
    self.attAName=attAName or ""
    self.defAName=defAName or ""
    self.attBuff=attBuff or {}
    self.defBuff=defBuff or {}
    self.attPoint=attPoint or 0
    self.defPoint=defPoint or 0
    self.isWin=isWin
    self.report=report
    self.attRaising=attRaising or 0
    self.defRaising=defRaising or 0
    self.time=time or base.serverTime
    self.placeIndex=placeIndex or 1
    self.destroyNum=destroyNum or 0
    self.lostNum=lostNum or 0
    self.isAttacker=isAttacker
    self.isBattle=isBattle

end