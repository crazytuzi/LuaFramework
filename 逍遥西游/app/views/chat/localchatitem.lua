CLocalChatItem_Other = class(".CLocalChatItem_Other", CPrivateChatItem_Other)
function CLocalChatItem_Other:ctor(pid, msg, yy, vip, iwidth, clickListener)
  CLocalChatItem_Other.super.ctor(self, pid, msg, yy, vip, iwidth, clickListener, true)
  self.m_Channel = CHANNEL_LOCAL
end
function CLocalChatItem_Other:GetPlayerInfo()
  local info = g_MessageMgr:getPlayerInfoOfLocal(self.m_PlayerId)
  return info
end
CLocalChannelSysMsgItem_Msg = class(".CLocalChannelSysMsgItem_Msg", function()
  return Widget:create()
end)
function CLocalChannelSysMsgItem_Msg:ctor(tip, iwidth, clickListener)
  local offx = 10
  local offy = 7
  local tipBg = display.newScale9Sprite("views/common/bg/bg1041.png", 10, 3, CCSize(1, 1))
  tipBg:setAnchorPoint(ccp(0, 0))
  self:addNode(tipBg, 0)
  local tipTxt = CRichText.new({
    width = iwidth - offx * 2,
    color = MsgColor_LocalSysChannel_s,
    fontSize = 20,
    clickTextHandler = clickListener
  })
  tipTxt:addRichText(string.format("#<Channel:%d># %s", CHANNEL_LOCALSYS, tip))
  self:addChild(tipTxt, 2)
  local size = tipTxt:getRichTextSize()
  tipTxt:setPosition(ccp(offx, offy))
  tipBg:setContentSize(CCSize(iwidth, size.height + (offy - 1) * 2))
  tipBg:setPosition(ccp(0, 1))
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iwidth, size.height + offy * 2))
  self:setAnchorPoint(ccp(0, 0))
end
