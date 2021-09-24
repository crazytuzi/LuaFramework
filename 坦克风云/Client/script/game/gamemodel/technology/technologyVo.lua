technologyVo={}
function technologyVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function technologyVo:initWithData(id,level)
  self.id=id
  self.level=level
  self.status=0 --0:正常  1：正在升级 2：等待
  self.startTime=0 --升级 或 等待开始时间
  self.unlockIndex=0 --解锁需要科技中心等级
  self.isFinishedUpgrade=false
end