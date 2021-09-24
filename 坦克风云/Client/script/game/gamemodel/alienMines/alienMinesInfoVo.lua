alienMinesInfoVo={}

--type 1-3:3种资源
function alienMinesInfoVo:new(dailyOccupyNum,updated_at,dailyRobNum,endTime,startTime,openTime,totoalRobNum,totoalOccupyNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.dailyOccupyNum=dailyOccupyNum -- 占领次数
    nc.updated_at=updated_at --最后一次更新时间戳
    nc.dailyRobNum=dailyRobNum -- 每日掠夺次数
    nc.endTime=endTime -- 结束时间
    nc.startTime=startTime -- 开始时间
    nc.openTime=openTime -- 开始日期
    nc.totoalRobNum=totoalRobNum
    nc.totoalOccupyNum=totoalOccupyNum
    return nc
end