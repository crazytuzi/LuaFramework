local tjbx = class("tjbxMgr")
function tjbx:ctor()
  self.m_Status = 2
  self.m_ExchangeSilverBoxTimes = 0
end
function tjbx:setStatus(status)
  self.m_Status = status
end
function tjbx:getStatus()
  return self.m_Status
end
function tjbx:setExchangeSilverBoxTimes(times)
  times = times or 0
  self.m_ExchangeSilverBoxTimes = times
end
function tjbx:getExchangeSilverBoxTimes()
  return self.m_ExchangeSilverBoxTimes
end
function tjbx:getExchangeSilverBoxMaxTimes()
  return data_BaoXiangVar.SilverBaoXiang_ExchangeLimit or 5
end
function tjbx:exchangeSilverBox()
  if self.m_ExchangeSilverBoxTimes >= self:getExchangeSilverBoxMaxTimes() then
    ShowNotifyTips(string.format("本周已经兑换了%d个银宝箱，不能再兑换了", self.m_ExchangeSilverBoxTimes))
    return
  end
  netsend.netactivity.exchangeSilverBox()
end
return tjbx
