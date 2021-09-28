local special = class("CGiftOfSpecial")
function special:ctor()
  self.m_FreshGiftTime = 0
end
function special:setFreshGiftTime(timePoint)
  self.m_FreshGiftTime = timePoint
  SendMessage(MsgID_Gift_FreshGiftUpdate)
end
function special:getFreshGiftRestTime()
  if not g_DataMgr then
    return 0
  end
  if g_DataMgr:getServerTime() > self.m_FreshGiftTime then
    return 0
  end
  return self.m_FreshGiftTime - g_DataMgr:getServerTime()
end
function special:canGetFreshGift()
  if self:hasGetFreshGift() == true then
    return false
  end
  if not g_DataMgr then
    return false
  end
  if g_DataMgr:getServerTime() > self.m_FreshGiftTime then
    return true
  end
  return false
end
function special:hasGetFreshGift()
  if self.m_FreshGiftTime == 0 then
    return true
  end
  return false
end
return special
