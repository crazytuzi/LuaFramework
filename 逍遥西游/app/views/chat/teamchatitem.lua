CTeamChatItem_Tip = class(".CTeamChatItem_Tip", function()
  return Widget:create()
end)
function CTeamChatItem_Tip:ctor(tip, iwidth)
  local offx = 10
  local offy = 7
  local tipBg = display.newScale9Sprite("views/common/bg/bg1041.png", 10, 3, CCSize(1, 1))
  tipBg:setAnchorPoint(ccp(0, 0))
  self:addNode(tipBg, 0)
  local tipTxt = CRichText.new({
    width = iwidth - 2 * offx,
    fontSize = 20
  })
  self:addChild(tipTxt, 1)
  tipTxt:addRichText(tip)
  local size = tipTxt:getRichTextSize()
  tipTxt:setAnchorPoint(ccp(0, 1))
  tipTxt:setPosition(ccp(offx, size.height + offy))
  tipBg:setContentSize(CCSize(iwidth, size.height + (offy - 1) * 2))
  tipBg:setPosition(ccp(0, 1))
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iwidth, size.height + offy * 2))
  self:setAnchorPoint(ccp(0, 0))
end
CTeamChatItem_Other = class(".CTeamChatItem_Other", CPrivateChatItem_Other)
function CTeamChatItem_Other:ctor(pid, msg, yy, vip, iwidth, clickListener)
  CTeamChatItem_Other.super.ctor(self, pid, msg, yy, vip, iwidth, clickListener, true)
  self.m_Channel = CHANNEL_TEAM
end
function CTeamChatItem_Other:GetPlayerInfo()
  local info = g_TeamMgr:getPlayerInfo(self.m_PlayerId)
  return info
end
