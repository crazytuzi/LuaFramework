local levelup = class("CGiftOfLevelup")
function levelup:ctor()
  self.m_CurDoId = -1
  self.m_LoginId = -1
  self.m_ShowFlag = false
  self.m_ShowLogin = false
end
function levelup:getRewardId()
  return self.m_CurDoId
end
function levelup:getLoginRewardId()
  return self.m_LoginId
end
function levelup:dataUpdate(id)
  if id ~= nil then
    self.m_CurDoId = id
    SendMessage(MsgID_Gift_LevelupRewardUpdate)
  end
end
function levelup:dataLogindate(id)
  if id ~= nil then
    self.m_LoginId = id
    SendMessage(MsgID_Gift_LevelupRewardUpdate)
  end
end
function levelup:dataShowUpdate(showFlag)
  self.m_ShowFlag = showFlag
  SendMessage(MsgID_Gift_LevelupRewardUpdate)
end
function levelup:dataShowLogindate(showFlag)
  self.m_ShowLogin = showFlag
  SendMessage(MsgID_Gift_LevelupRewardUpdate)
end
function levelup:getDataShowUpdate()
  return self.m_ShowFlag
end
function levelup:getDataShowLogindate()
  return self.m_ShowLogin
end
function levelup:getData(id)
  local d = data_GiftOfLevelUp[id or self.m_CurDoId]
  if d then
    return d.zs, d.lv, d.reward
  end
  return nil
end
function levelup:getLoginData(id)
  local d = data_GiftOfLevelUp[id or self.m_LoginId]
  if d then
    return d.zs, d.lv, d.reward, d.pet or {}
  end
  return nil
end
function levelup:getLoginReward(id)
  local d = data_GiftOfLevelUp[id or self.m_LoginId]
  if d then
    return d.reward
  end
  return nil
end
function levelup:getReward(id)
  local d = data_GiftOfLevelUp[id or self.m_CurDoId]
  if d then
    return d.reward
  end
  return nil
end
function levelup:CanGetLoginReward()
  if self.m_ShowLogin == false then
    return false
  end
  local zs, lv, rewardList = self:getLoginData()
  local mainHero = g_LocalPlayer:getMainHero()
  local zhuan = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local level = mainHero:getProperty(PROPERTY_ROLELEVEL)
  if self:getLoginReward() ~= nil and (zs < zhuan or zhuan == zs and lv <= level) then
    return true
  else
    return false
  end
end
function levelup:CanGetLevelupReward()
  if self.m_ShowFlag == false then
    return false
  end
  local zs, lv, rewardList = self:getData()
  local mainHero = g_LocalPlayer:getMainHero()
  local zhuan = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local level = mainHero:getProperty(PROPERTY_ROLELEVEL)
  if self:getReward() ~= nil and (zs < zhuan or zhuan == zs and lv <= level) then
    return true
  else
    return false
  end
end
function levelup:OnMessage(msgSID, ...)
end
return levelup
