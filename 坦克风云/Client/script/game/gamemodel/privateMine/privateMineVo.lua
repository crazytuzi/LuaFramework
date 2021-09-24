privateMineVo={}
--保护矿
--id：矿的id，level：当前等级，endTime：该矿消失时间
function privateMineVo:new(mid,endTime)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.mid=mid
    nc.endTime=endTime
    return nc
end