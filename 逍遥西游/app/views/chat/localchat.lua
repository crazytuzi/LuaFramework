CLocalchat = class(".CLocalchat", CChatBoxBase)
function CLocalchat:ctor(chatList, clickMsgListener)
  CLocalchat.super.ctor(self, chatList, clickMsgListener)
end
function CLocalchat:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Message_LocalMsg then
    local chatpid = arg[1]
    local pInfo = arg[2]
    local msg = arg[3]
    local msgTime = arg[4]
    local yy = arg[5]
    local vip = arg[6]
    self:onReceiveLocalMessage(chatpid, pInfo, msg, yy, msgTime, vip)
  elseif msgSID == MsgID_Message_LocalChannelSysMsg then
    local msg = arg[1]
    self:AddLocalChannelSysMsg(msg)
  end
end
function CLocalchat:GetInitChatContent()
  return {}
end
function CLocalchat:CreateChatItem_Local(msg, yy, vip, width, clickMsgListener)
  local msgItem = CPrivateChatItem_Local.new(msg, yy, vip, width, clickMsgListener)
  return msgItem
end
function CLocalchat:CreateChatItem_Other(pid, msg, yy, vip, width, clickMsgListener)
  local msgItem = CLocalChatItem_Other.new(pid, msg, yy, vip, width, clickMsgListener)
  return msgItem
end
function CLocalchat:onReceiveLocalMessage(chatpid, pInfo, msg, yy, msgTime, vip)
  self:pushbackChatMsg(chatpid, msg, yy, msgTime, vip)
end
function CLocalchat:AddLocalChannelSysMsg(tip)
  self:checkLimitShowNumOfChat()
  local size = self.list_chat:getContentSize()
  local msgItem = CLocalChannelSysMsgItem_Msg.new(tip, size.width, self.m_ClickMsgListener)
  self.list_chat:pushBackCustomItem(msgItem)
  self:checkJumpToBottom()
end
