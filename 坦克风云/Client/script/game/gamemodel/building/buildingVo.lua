buildingVo={}
function buildingVo:new(id)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.id=id
    nc.status=-1  --建筑状态 -1:未解锁 0:未建造 1:正常 2:升级 
    nc.level=0
    nc.upgradePercent=0
    nc.type=-1
    nc.lastStatus=-1
    nc.sortId=-1
    return nc
end


function buildingVo:initWithData(type,level,status)
    self.type=type
    self.level=level
    self.status=status
    self.lastStatus=status
end
function buildingVo:setSortId(sortId)
    self.sortId = sortId
end