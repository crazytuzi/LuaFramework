CTeamChat = class(".CTeamChat", CChatBoxBase)
function CTeamChat:ctor(chatList, clickMsgListener)
  CTeamChat.super.ctor(self, chatList, clickMsgListener)
end
function CTeamChat:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Message_TeamMsg and g_TeamMgr:getLocalPlayerTeamId() ~= 0 then
    local chatpid = arg[1]
    local msg = arg[2]
    local msgTime = arg[3]
    local yy = arg[4]
    local vip = arg[5]
    self:onReceiveTeamMessage(chatpid, msg, yy, msgTime, vip)
  end
end
function CTeamChat:GetInitChatContent()
  return {}
end
function CTeamChat:InsertChatMsgCache(msgData, forceShowTime)
  local pid = msgData[3]
  local teamId = g_TeamMgr:getLocalPlayerTeamId()
  if g_TeamMgr:IsPlayerOfTeam(pid, teamId) then
    self:InsertChatMsg(pid, msgData[1], msgData[4], msgData[2], msgData[5], true, forceShowTime)
  end
end
function CTeamChat:CreateChatItem_Local(msg, yy, vip, width, clickMsgListener)
  local msgItem = CPrivateChatItem_Local.new(msg, yy, vip, width, clickMsgListener)
  return msgItem
end
function CTeamChat:CreateChatItem_Other(pid, msg, yy, vip, width, clickMsgListener)
  local msgItem = CTeamChatItem_Other.new(pid, msg, yy, vip, width, clickMsgListener)
  return msgItem
end
function CTeamChat:onReceiveTeamMessage(chatpid, msg, yy, msgTime, vip)
  local teamId = g_TeamMgr:getLocalPlayerTeamId()
  if g_TeamMgr:IsPlayerOfTeam(chatpid, teamId) then
    self:pushbackChatMsg(chatpid, msg, yy, msgTime, vip)
  end
end
function CTeamChat:AddTeamTip(tip)
  local size = self.list_chat:getContentSize()
  local msgItem = CTeamChatItem_Tip.new(tip, size.width)
  self.list_chat:pushBackCustomItem(msgItem)
  self:checkJumpToBottom()
end
