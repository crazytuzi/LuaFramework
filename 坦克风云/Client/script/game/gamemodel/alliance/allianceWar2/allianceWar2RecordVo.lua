allianceWar2RecordVo={}
function allianceWar2RecordVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceWar2RecordVo:initWithData(battleId,warid,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attBuff,defBuff,attPoint,defPoint,isWin,report,attRaising,defRaising,time,placeIndex,destroyNum,lostNum,isAttacker,isBattle)
	self.battleId=battleId
    self.warid=warid
    self.attId=attId --  攻击者id
    self.defId=defId -- 防守者id
    self.attName=attName -- 
    self.defName=defName
    self.attAid=attAid -- 军团id
    self.defAid=defAid
    self.attAName=attAName or "" --军团名字
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
    self.placeIndex=placeIndex or "h1"
    self.destroyNum=destroyNum or 0
    self.lostNum=lostNum or 0
    self.isAttacker=isAttacker
    self.isBattle=isBattle

end