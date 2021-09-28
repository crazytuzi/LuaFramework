CLaBaChatItem_Other = class(".CLaBaChatItem_Other", CPrivateChatItem_Other)
function CLaBaChatItem_Other:ctor(pid, msg, yy, vip, iwidth, clickListener)
  CLaBaChatItem_Other.super.ctor(self, pid, msg, yy, vip, iwidth, clickListener, true)
  self.m_Channel = CHANNEL_LaBa
end
function CLaBaChatItem_Other:GetPlayerInfo()
  local info = g_MessageMgr:getLaBaPlayerInfo(self.m_PlayerId)
  return info
end
