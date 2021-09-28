CIntchat = class(".CIntchat", CChatBoxBase)
function CIntchat:ctor(chatList, clickMsgListener)
  CIntchat.super.ctor(self, chatList, clickMsgListener)
end
function CIntchat:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Message_WorldMsg then
    local chatpid = arg[1]
    local pInfo = arg[2]
    local msg = arg[3]
    local msgTime = arg[4]
    local yy = arg[5]
    local vip = arg[6]
    self:onReceiveIntMessage(chatpid, pInfo, msg, yy, msgTime, vip)
  end
end
function CIntchat:GetInitChatContent()
  return {}
end
function CIntchat:CreateChatItem_Local(msg, yy, vip, width, clickMsgListener)
  local msgItem = CPrivateChatItem_Local.new(msg, yy, vip, width, clickMsgListener)
  return msgItem
end
function CIntchat:CreateChatItem_Other(pid, msg, yy, vip, width, clickMsgListener)
  local msgItem = CWorldChatItem_Other.new(pid, msg, yy, vip, width, clickMsgListener)
  return msgItem
end
function CIntchat:onReceiveIntMessage(chatpid, pInfo, msg, yy, msgTime, vip)
  self:pushbackChatMsg(chatpid, msg, yy, msgTime, vip)
end
