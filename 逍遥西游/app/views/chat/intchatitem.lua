CWorldChatItem_Other = class(".CWorldChatItem_Other", CPrivateChatItem_Other)
function CWorldChatItem_Other:ctor(pid, msg, yy, vip, iwidth, clickListener)
  CWorldChatItem_Other.super.ctor(self, pid, msg, yy, vip, iwidth, clickListener, true)
  self.m_Channel = CHANNEL_WOLRD
end
function CWorldChatItem_Other:GetPlayerInfo()
  local info = g_MessageMgr:getPlayerInfo(self.m_PlayerId)
  return info
end
