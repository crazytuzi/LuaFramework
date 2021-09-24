acGangtierongluVo=activityVo:new()
function acGangtierongluVo:new()
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  return nc
end

function acGangtierongluVo:updateSpecialData(data)
  if data~=nil then
    if data.cost then
      self.cost=data.cost  -- 合成消耗的钛矿
    end
    if data.exchange then
      self.exchange=data.exchange -- 熔炼坦克得到的钛矿
    end
    if data.tasklist then
      self.tasklist=data.tasklist -- 任务列表
    end
    if data.flag then
      self.flagTb=data.flag -- 领取过奖励标记列表
    end
    if data.a then
      self.a=data.a -- a 通过熔解累计得到钛矿
    end
    if data.r then
      self.r=data.r -- r 熔解掉num辆name坦克
    end
    if data.h then
      self.h=data.h -- 抽奖消耗掉num钛矿
    end
    if data.g then
      self.g=data.g -- g 通过抽奖得到num辆name坦克
    end
    if data.version then
      self.version=data.version
    end
  end
end
