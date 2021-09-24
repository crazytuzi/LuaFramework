serverWarTeamPRecordVo={}
function serverWarTeamPRecordVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--isBomb 是否是轰炸战报
function serverWarTeamPRecordVo:initWithData(type,warid,rid,selfIsAttPlayer,selfId,selfName,selfAName,targetId,targetName,targetAName,myLastPlace,targetLastPlace,time,placeIndex,isAttacker,isVictory,title,baseblood,isBase,lossBlood,isOccupy,isBomb)
    self.type=type
    self.warid=warid
	self.rid=rid

    self.selfIsAttPlayer=selfIsAttPlayer      --自己是否是attId这个玩家
    self.selfId=selfId
    self.selfName=selfName
    self.selfAName=selfAName
    self.targetId=targetId
    self.targetName=targetName
    self.targetAName=targetAName
    self.myLastPlace=myLastPlace
    self.targetLastPlace=targetLastPlace
    -- self.attId=attId
    -- self.defId=defId
    -- self.attName=attName
    -- self.defName=defName
    -- self.attAid=attAid
    -- self.defAid=defAid
    -- self.attAName=attAName or ""
    -- self.defAName=defAName or ""
    -- self.attZoneId=attZoneId
    -- self.defZoneId=defZoneId
    -- self.aLastPlace=aLastPlace or 0
    -- self.dLastPlace=dLastPlace or 0
    -- self.victor=victor
    -- self.placeOid=placeOid
    -- self.attKills=attKills or 0
    -- self.defKills=defKills or 0

    self.time=time or base.serverTime
    self.placeIndex=placeIndex or 1
    self.isAttacker=isAttacker
    self.isVictory=isVictory or false
    self.title=title or ""
    self.baseblood=baseblood or 0
    self.isBase=isBase or 0
    self.lossBlood=lossBlood or 0
    self.isOccupy=isOccupy or 0
    self.isBomb=isBomb or 0


    self.lostShip={}
    self.accessory={}
    self.hero={{{},0},{{},0}}
    self.report=nil
end