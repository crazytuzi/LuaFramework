CSysChat = class(".CSysChat", CChatBoxBase)
function CSysChat:ctor(chatList, clickMsgListener)
  CSysChat.super.ctor(self, chatList, clickMsgListener)
  local loginTip = g_MessageMgr:getLoginTip()
  if loginTip ~= nil then
    self:AddCommonTip(loginTip)
  end
  local tempMsgList = g_MessageMgr:getCacheForIntchatAndClean()
  for _, data in ipairs(tempMsgList) do
    local msgSID = data[1]
    local arg = data[2]
    if msgSID == MsgID_Message_XinXiTip then
      self:AddXinxiTip(arg[1])
    end
  end
end
function CSysChat:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Message_SysMsg then
    self:AddSysMsgTip(arg[1])
  elseif msgSID == MsgID_Message_HelpTip then
    self:AddSysHelpTip(arg[1])
  elseif msgSID == MsgID_Message_KuaiXunTip then
    self:AddKuaixunTip(arg[1])
  elseif msgSID == MsgID_Message_XinXiTip then
    self:AddXinxiTip(arg[1])
  elseif msgSID == MsgID_Message_CommonTip then
    self:AddCommonTip(arg[1])
  end
end
function CSysChat:GetInitChatContent()
  return {}
end
function CSysChat:AddSysMsgTip(tip)
  self:checkLimitShowNumOfChat()
  local size = self.list_chat:getContentSize()
  local msgItem = CSysMsgItem_Tip.new(tip, size.width, self.m_ClickMsgListener)
  self.list_chat:pushBackCustomItem(msgItem)
  self:checkJumpToBottom()
end
function CSysChat:AddSysHelpTip(tip)
  self:checkLimitShowNumOfChat()
  local size = self.list_chat:getContentSize()
  local msgItem = CSysHelpItem_Tip.new(tip, size.width, self.m_ClickMsgListener)
  self.list_chat:pushBackCustomItem(msgItem)
  self:checkJumpToBottom()
end
function CSysChat:AddKuaixunTip(tip)
  self:checkLimitShowNumOfChat()
  local size = self.list_chat:getContentSize()
  local msgItem = CSysHelpItem_Kuaixun.new(tip, size.width, self.m_ClickMsgListener)
  self.list_chat:pushBackCustomItem(msgItem)
  self:checkJumpToBottom()
end
function CSysChat:AddXinxiTip(tip)
  self:checkLimitShowNumOfChat()
  local size = self.list_chat:getContentSize()
  local msgItem = CSysHelpItem_Xinxi.new(tip, size.width, nil)
  self.list_chat:pushBackCustomItem(msgItem)
  self:checkJumpToBottom()
end
function CSysChat:AddCommonTip(tip)
  self:checkLimitShowNumOfChat()
  local size = self.list_chat:getContentSize()
  local msgItem = CSysHelpItem_Common.new(tip, size.width, self.m_ClickMsgListener)
  self.list_chat:pushBackCustomItem(msgItem)
  self:checkJumpToBottom()
end
