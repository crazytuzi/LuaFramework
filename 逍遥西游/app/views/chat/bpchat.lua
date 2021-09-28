CBangPaiChat = class(".CBangPaiChat", CChatBoxBase)
function CBangPaiChat:ctor(chatList, clickMsgListener)
  CBangPaiChat.super.ctor(self, chatList, clickMsgListener)
end
function CBangPaiChat:OnMessage(msgSID, ...)
  if msgSID == MsgID_Message_BangPaiMsg then
    local arg = {
      ...
    }
    local chatpid = arg[1]
    local pInfo = arg[2]
    local msg = arg[3]
    local msgTime = arg[4]
    local yy = arg[5]
    local vip = arg[6]
    self:onReceiveBpMessage(chatpid, pInfo, msg, yy, msgTime, vip)
  elseif msgSID == MsgID_Message_BangPaiTip then
    local arg = {
      ...
    }
    self:AddBangPaiTip(arg[1])
  end
end
function CBangPaiChat:GetInitChatContent()
  return {}
end
function CBangPaiChat:CreateChatItem_Local(msg, yy, vip, width, clickMsgListener)
  local msgItem = CPrivateChatItem_Local.new(msg, yy, vip, width, clickMsgListener)
  return msgItem
end
function CBangPaiChat:CreateChatItem_Other(pid, msg, yy, vip, width, clickMsgListener)
  local msgItem = CBpChatItem_Other.new(pid, msg, yy, vip, width, clickMsgListener)
  return msgItem
end
function CBangPaiChat:onReceiveBpMessage(chatpid, pInfo, msg, yy, msgTime, vip)
  self:pushbackChatMsg(chatpid, msg, yy, msgTime, vip)
end
function CBangPaiChat:AddBangPaiTip(tip)
  local size = self.list_chat:getContentSize()
  local msgItem = CBpMsgItem_Tip.new(tip, size.width, self.m_ClickMsgListener)
  self.list_chat:pushBackCustomItem(msgItem)
  self:checkJumpToBottom()
end
function CBangPaiChat:AddBangPaiTeam(teamItem)
  self.list_chat:pushBackCustomItem(teamItem)
  self:checkJumpToBottom()
end
