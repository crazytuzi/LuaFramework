CPrivateChat = class(".CPrivateChat", CChatBoxBase)
function CPrivateChat:ctor(pid, chatList, clickMsgListener)
  self.m_PlayerId = pid
  CPrivateChat.super.ctor(self, chatList, clickMsgListener)
end
function CPrivateChat:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Message_PrivateMsg then
    local pid = arg[1]
    if pid == self.m_PlayerId then
      local chatpid = arg[2]
      local msg = arg[3]
      local msgTime = arg[4]
      local yy = arg[5]
      local vip = arg[6]
      self:onReceivePrivateMessage(chatpid, msg, yy, msgTime, vip)
    end
  end
end
function CPrivateChat:GetInitChatContent()
  local content = g_MessageMgr:getPrivateMessage(self.m_PlayerId)
  return DeepCopyTable(content)
end
function CPrivateChat:InsertChatMsgCache(msgData, forceShowTime)
  self:InsertChatMsg(msgData[3], msgData[1], msgData[5], msgData[2], msgData[6], true, forceShowTime)
end
function CPrivateChat:CreateChatItem_Local(msg, yy, vip, width, clickMsgListener)
  local msgItem = CPrivateChatItem_Local.new(msg, yy, vip, width, clickMsgListener)
  return msgItem
end
function CPrivateChat:CreateChatItem_Other(pid, msg, yy, vip, width, clickMsgListener)
  local msgItem = CPrivateChatItem_Other.new(pid, msg, yy, vip, width, clickMsgListener, false)
  return msgItem
end
function CPrivateChat:onReceivePrivateMessage(chatpid, msg, yy, msgTime, vip)
  self:pushbackChatMsg(chatpid, msg, yy, msgTime, vip)
end
function CPrivateChat:reloadChatContent(pid)
  self.m_PlayerId = pid
  CPrivateChat.super.reloadChatContent(self)
end
