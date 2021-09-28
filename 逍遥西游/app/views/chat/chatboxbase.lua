local g_MinRecordTimeSpace = 120
local g_MinShowTimeSpace = 120
local g_LimitShowNumOfChat = 40
CChatBoxBase = class(".CChatBoxBase", nil)
function CChatBoxBase:ctor(chatList, clickMsgListener)
  self.list_chat = chatList
  self.m_ClickMsgListener = clickMsgListener
  self:InitChatContent()
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Message)
end
function CChatBoxBase:InitChatContent()
  self.list_chat:addLoadMoreListenerScrollView_DragDown(function()
    self:LoadMoreChatContent()
  end)
  self.m_ContentList = self:GetInitChatContent()
  self:LoadMoreMsgCache()
  local x, y = self.list_chat:getPosition()
  self.list_chat:setPosition(ccp(-10000, -10000))
  local act1 = CCDelayTime:create(0.1)
  local act2 = CCCallFunc:create(function()
    self.list_chat:setPosition(ccp(x, y))
    self.list_chat:jumpToBottom()
  end)
  self.list_chat:stopAllActions()
  self.list_chat:runAction(transition.sequence({act1, act2}))
end
function CChatBoxBase:getLimitShowNumOfChat()
  return g_LimitShowNumOfChat
end
function CChatBoxBase:GetInitChatContent()
  return {}
end
function CChatBoxBase:LoadMoreMsgCache()
  local loadCnt = 15
  for i = 1, loadCnt do
    local n = #self.m_ContentList
    if n <= 0 then
      break
    end
    local d = table.remove(self.m_ContentList, n)
    self:InsertChatMsgCache(d, n <= 1)
  end
  self.list_chat:refreshView()
end
function CChatBoxBase:InsertChatMsgCache(msgData, forceShowTime)
end
function CChatBoxBase:InsertChatMsg(pid, msg, yy, msgTime, vip, isInit, forceShowTime)
  if self.list_chat:getCount() >= self:getLimitShowNumOfChat() then
    return
  end
  local size = self.list_chat:getContentSize()
  if pid == g_LocalPlayer:getPlayerId() then
    local msgItem = self:CreateChatItem_Local(msg, yy, vip, size.width, self.m_ClickMsgListener)
    self.list_chat:insertCustomItem(msgItem, 0)
  else
    local msgItem = self:CreateChatItem_Other(pid, msg, yy, vip, size.width, self.m_ClickMsgListener)
    self.list_chat:insertCustomItem(msgItem, 0)
  end
  local timeTable = os.date("*t", checkint(msgTime))
  local month = timeTable.month
  local day = timeTable.day
  local hour = timeTable.hour
  local min = timeTable.min
  if self.m_MostPreChatTime == nil then
    self.m_MostPreChatTime = msgTime
  end
  if forceShowTime then
    local timeItem = CPrivateChatItem_Time.new(month, day, hour, min, size.width)
    self.list_chat:insertCustomItem(timeItem, 0)
  elseif self.m_MostPreChatTime - msgTime > g_MinRecordTimeSpace then
    local timeTable_2 = os.date("*t", checkint(self.m_MostPreChatTime))
    local lmonth = timeTable_2.month
    local lday = timeTable_2.day
    local lhour = timeTable_2.hour
    local lmin = timeTable_2.min
    local timeItem = CPrivateChatItem_Time.new(lmonth, lday, lhour, lmin, size.width)
    self.list_chat:insertCustomItem(timeItem, 1)
  end
  self.m_MostPreChatTime = msgTime
  if self.m_LastChatTime == nil then
    self.m_LastChatTime = msgTime
  end
  if isInit == true then
    self.list_chat:refreshView()
    self.list_chat:jumpToBottom()
  else
    self:checkJumpToBottom()
  end
end
function CChatBoxBase:pushbackChatMsg(pid, msg, yy, msgTime, vip, isInit)
  self:checkLimitShowNumOfChat()
  local size = self.list_chat:getContentSize()
  local timeTable = os.date("*t", checkint(msgTime))
  local month = timeTable.month
  local day = timeTable.day
  local hour = timeTable.hour
  local min = timeTable.min
  if self.m_LastChatTime == nil or msgTime - self.m_LastChatTime > g_MinShowTimeSpace then
    local timeItem = CPrivateChatItem_Time.new(month, day, hour, min, size.width)
    self.list_chat:pushBackCustomItem(timeItem)
  end
  self.m_LastChatTime = msgTime
  if self.m_MostPreChatTime == nil then
    self.m_MostPreChatTime = msgTime
  end
  if pid == g_LocalPlayer:getPlayerId() then
    local msgItem = self:CreateChatItem_Local(msg, yy, vip, size.width, self.m_ClickMsgListener)
    self.list_chat:pushBackCustomItem(msgItem)
  else
    local msgItem = self:CreateChatItem_Other(pid, msg, yy, vip, size.width, self.m_ClickMsgListener)
    self.list_chat:pushBackCustomItem(msgItem)
  end
  if isInit == true then
    self.list_chat:refreshView()
    self.list_chat:jumpToBottom()
  else
    self:checkJumpToBottom()
  end
end
function CChatBoxBase:checkLimitShowNumOfChat()
  if self.list_chat:getCount() >= self:getLimitShowNumOfChat() then
    for i = 0, self.list_chat:getCount() - self:getLimitShowNumOfChat() do
      self.list_chat:removeItem(0)
    end
  end
end
function CChatBoxBase:LoadMoreChatContent()
  local lastTime = self.m_LastLoadingTime or 0
  local curTime = os.time()
  if curTime - lastTime < 0.1 then
    print("--->>>太快了！load无效")
    return
  end
  if 0 >= #self.m_ContentList then
    return
  end
  local size_1 = self.list_chat:getInnerContainerSize()
  local h_1 = size_1.height
  self:LoadMoreMsgCache()
  local size_2 = self.list_chat:getInnerContainerSize()
  local h_2 = size_2.height
  local percent = h_1 / h_2
  self.m_LastLoadingTime = curTime
  self.list_chat:jumpToPercentVertical((1 - percent) * 100)
end
function CChatBoxBase:reloadChatContent()
  self.list_chat:removeAllItems()
  self:InitChatContent()
end
function CChatBoxBase:checkJumpToBottom()
  local needJump = false
  local innerContainer = self.list_chat:getInnerContainer()
  if innerContainer then
    local _, y = innerContainer:getPosition()
    if y >= -10 then
      needJump = true
    end
  end
  self.list_chat:refreshView()
  if needJump then
    self.list_chat:jumpToBottom()
  end
end
function CChatBoxBase:Clear()
  self.list_chat = nil
  self.m_ClickMsgListener = nil
  self:RemoveAllMessageListener()
end
