goldMineVo={}

--id：金矿的id，level：金矿当前等级，endTime：该金矿消失时间
function goldMineVo:new(mid,level,endTime)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.mid=mid
    nc.level=level
    nc.endTime=endTime
      
    return nc
end