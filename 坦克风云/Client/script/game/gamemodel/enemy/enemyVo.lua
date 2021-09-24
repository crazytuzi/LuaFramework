enemyVo={}
function enemyVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--place 地点 {x,y}
function enemyVo:initWithData(slotId,islandType,level,place,time,attackerName,totalTime,enemyPlace)
	self.slotId=slotId
	self.islandType=islandType
    self.level=level
	self.place=place
	self.time=time
	self.attackerName=attackerName
	self.totalTime=totalTime
	self.enemyPlace=enemyPlace
end