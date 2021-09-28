local huoliHuodong = class("huoliHuodong")
function huoliHuodong:ctor()
  self.m_State = nil
end
function huoliHuodong:setStatus(state)
  self.m_State = state
end
function huoliHuodong:getIsStarting()
  return self.m_State == 1
end
return huoliHuodong
