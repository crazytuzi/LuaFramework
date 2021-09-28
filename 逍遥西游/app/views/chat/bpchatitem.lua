CBpChatItem_Other = class(".CBpChatItem_Other", CPrivateChatItem_Other)
function CBpChatItem_Other:ctor(pid, msg, yy, vip, iwidth, clickListener)
  CBpChatItem_Other.super.ctor(self, pid, msg, yy, vip, iwidth, clickListener, true)
  self.m_Channel = CHANNEL_BP_MSG
end
function CBpChatItem_Other:SetPlayerInfo(isUpdate)
  CBpChatItem_Other.super.SetPlayerInfo(self, isUpdate)
  local info = self:GetPlayerInfo()
  if info then
    if self.m_BpPlaceTxt ~= nil then
      self.m_BpPlaceTxt:removeFromParentAndCleanup(true)
      self.m_BpPlaceTxt = nil
    end
    local placeName = data_getBangpaiPlaceName(info.place)
    self.m_BpPlaceTxt = ui.newTTFLabel({
      text = placeName,
      size = 16,
      font = KANG_TTF_FONT,
      color = ccc3(142, 117, 81)
    })
    self:addNode(self.m_BpPlaceTxt)
    self.m_BpPlaceTxt:setAnchorPoint(ccp(0.5, 1))
    local size = self.m_Content:getRealRichTextSize()
    local bgsize = self.m_MsgBg:getContentSize()
    local hsize = self.m_Head:getContentSize()
    local x, y = self.m_Head:getPosition()
    local s = self.m_Head:getScale()
    local hx, hy = hsize.width * s / 2 + x, bgsize.height - hsize.height * s + 10
    self.m_BpPlaceTxt:setPosition(ccp(hx, hy))
  end
end
function CBpChatItem_Other:GetPlayerInfo()
  local info = g_MessageMgr:getBpPlayerInfo(self.m_PlayerId)
  return info
end
CBpMsgItem_Tip = class(".CBpMsgItem_Tip", function()
  return Widget:create()
end)
function CBpMsgItem_Tip:ctor(tip, iwidth, clickListener)
  local offx = 10
  local offy = 7
  local tipBg = display.newScale9Sprite("views/common/bg/bg1041.png", 10, 3, CCSize(1, 1))
  tipBg:setAnchorPoint(ccp(0, 0))
  self:addNode(tipBg, 0)
  local tipTxt = CRichText.new({
    width = iwidth - offx * 2,
    color = MsgColor_BpChannel_s,
    fontSize = 20,
    clickTextHandler = clickListener
  })
  tipTxt:addRichText(string.format("#<Channel:%d># %s", CHANNEL_BP_TIP, tip))
  self:addChild(tipTxt, 2)
  local size = tipTxt:getRichTextSize()
  tipTxt:setPosition(ccp(offx, offy))
  tipBg:setContentSize(CCSize(iwidth, size.height + (offy - 1) * 2))
  tipBg:setPosition(ccp(0, 1))
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iwidth, size.height + offy * 2))
  self:setAnchorPoint(ccp(0, 0))
end
