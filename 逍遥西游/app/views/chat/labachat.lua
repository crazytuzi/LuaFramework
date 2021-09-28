CLaBaChat = class(".CLaBaChat", CChatBoxBase)
function CLaBaChat:ctor(chatList, clickMsgListener)
  CLaBaChat.super.ctor(self, chatList, clickMsgListener)
end
function CLaBaChat:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Message_XiaoLaBa then
    local chatpid = arg[1]
    local pInfo = arg[2]
    local msg = arg[3]
    local msgTime = arg[4]
    local yy = arg[5]
    local vip = arg[6]
    self:AddXiaoLaBaTip(chatpid, pInfo, msg, yy, msgTime, vip)
  end
end
function CLaBaChat:GetInitChatContent()
  return {}
end
function CLaBaChat:CreateChatItem_Local(msg, yy, vip, width, clickMsgListener)
  local msgItem = CPrivateChatItem_Local.new(msg, yy, vip, width, clickMsgListener)
  return msgItem
end
function CLaBaChat:CreateChatItem_Other(pid, msg, yy, vip, width, clickMsgListener)
  local msgItem = CLaBaChatItem_Other.new(pid, msg, yy, vip, width, clickMsgListener)
  return msgItem
end
function CLaBaChat:AddXiaoLaBaTip(chatpid, pInfo, msg, yy, msgTime, vip)
  self:pushbackChatMsg(chatpid, msg, yy, msgTime, vip)
end
