ltzdzTransReportVo={}

function ltzdzTransReportVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzTransReportVo:initWithData(data)
    self.rid=data.id or 0 --战报id
    self.rtype=data.type or 1 --战报的类型（1：战斗报告，2：运输报告）
    self.auid=data.auid --玩家id
    self.time=data.ts --运输到达的时间
    self.isVictory=data.isvictory --运输结果（1：运输成功，2：运输失败）
    self.reserve=data.reserve or 0 --运输的预备役数量
    self.city=data.city --城市数据 city[1]起始城，city[2]目标城 格式：{城id,等级}
    -- self.cost={10000,60} --运输消耗（{石油，时间}）
end