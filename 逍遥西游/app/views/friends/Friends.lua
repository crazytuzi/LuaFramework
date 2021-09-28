local g_MaxWordNumOfFindFriend = 11
local g_MaxWordNumOfPrivateChat = 50
local FriendLabel_Recently = 1
local FriendLabel_All = 2
local FriendLabel_Request = 3
local FriendLabel_Mail = 4
local _friendSortFunc = function(a, b)
  if a == nil or b == nil then
    return false
  end
  local pid_a = a[1]
  local pid_b = b[1]
  local info_a = a[2]
  local info_b = b[2]
  local banlvId = g_FriendsMgr:getBanLvId()
  if banlvId ~= nil and banlvId ~= 0 then
    if banlvId == pid_a then
      return true
    elseif banlvId == pid_b then
      return false
    end
  end
  local status_a = info_a.status or GAMESTATUS_OUTLINE
  local status_b = info_b.status or GAMESTATUS_OUTLINE
  if status_a == GAMESTATUS_ONLINE and status_b ~= GAMESTATUS_ONLINE then
    return true
  elseif status_a ~= GAMESTATUS_ONLINE and status_b == GAMESTATUS_ONLINE then
    return false
  else
    local t_a = info_a.time or 0
    local t_b = info_b.time or 0
    if t_a ~= t_b then
      return t_a > t_b
    else
      return pid_a < pid_b
    end
  end
end
local _recentlySortFunc = function(a, b)
  if a == nil or b == nil then
    return false
  end
  local pid_a = a[1]
  local pid_b = b[1]
  local info_a = a[2]
  local info_b = b[2]
  local lastTime_a = g_LocalPlayer:getPrivateChatTime(pid_a)
  local lastTime_b = g_LocalPlayer:getPrivateChatTime(pid_b)
  if lastTime_a ~= nil and lastTime_b ~= nil then
    return lastTime_a > lastTime_b
  elseif lastTime_a == nil and lastTime_b ~= nil then
    return false
  elseif lastTime_a ~= nil and lastTime_b == nil then
    return true
  else
    local t_a = info_a.time or 0
    local t_b = info_b.time or 0
    if t_a ~= t_b then
      return t_a > t_b
    else
      return pid_a < pid_b
    end
  end
end
FriendsDlg = class("FriendsDlg", CcsSubView)
function FriendsDlg:ctor()
  FriendsDlg.super.ctor(self, "views/friends.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_group_recently = {
      listener = handler(self, self.Btn_Group_Recently),
      variName = "btn_group_recently"
    },
    btn_group_all = {
      listener = handler(self, self.Btn_Group_All),
      variName = "btn_group_all"
    },
    btn_group_request = {
      listener = handler(self, self.Btn_Group_Request),
      variName = "btn_group_request"
    },
    btn_find = {
      listener = handler(self, self.Btn_FindFriend),
      variName = "btn_find"
    },
    btn_findicon = {
      listener = handler(self, self.Btn_FindFriendIcon),
      variName = "btn_findicon"
    },
    btn_friendchat_insert = {
      listener = handler(self, self.Btn_ChatInsert),
      variName = "btn_friendchat_insert"
    },
    btn_send_friendchat = {
      listener = handler(self, self.Btn_SendChat),
      variName = "btn_send_friendchat"
    },
    btn_voice_friend = {
      listener = handler(self, self.Btn_VoiceFriend),
      variName = "btn_voice_friend"
    },
    btn_keyboard_friend = {
      listener = handler(self, self.Btn_KeyBoardFriend),
      variName = "btn_keyboard_friend"
    },
    btn_clearrequest = {
      listener = handler(self, self.Btn_Request),
      variName = "btn_clearrequest"
    },
    btn_group_mail = {
      listener = handler(self, self.Btn_Group_Mail),
      variName = "btn_group_mail"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.btn_group_recently:setTitleText("最\n近")
  self.btn_group_all:setTitleText("好\n友")
  self.btn_group_request:setTitleText("请\n求")
  self.btn_group_mail:setTitleText("邮\n件")
  self:addBtnSigleSelectGroup({
    {
      self.btn_group_recently,
      "views/common/btn/btn_2words_shu_gray.png",
      ccc3(250, 246, 143)
    },
    {
      self.btn_group_all,
      "views/common/btn/btn_2words_shu_gray.png",
      ccc3(250, 246, 143)
    },
    {
      self.btn_group_request,
      "views/common/btn/btn_2words_shu_gray.png",
      ccc3(250, 246, 143)
    },
    {
      self.btn_group_mail,
      "views/common/btn/btn_2words_shu_gray.png",
      ccc3(250, 246, 143)
    }
  })
  self.m_NewTip_NewFriend = {}
  self.m_NewTip_Request = {}
  self.m_CurrLabel = -1
  self.m_ShowMoMo = false
  if channel.showMoMoFriendList == true then
    local userInfo = g_ChannelMgr:getUserInfo()
    if userInfo.userType == 3 then
      self.m_ShowMoMo = true
    end
  end
  self.sublayer_all = self:getNode("sublayer_all")
  self.sublayer_recently = self:getNode("sublayer_recently")
  self.sublayer_request = self:getNode("sublayer_request")
  self.layermail = self:getNode("layermail")
  self.list_all = self:getNode("list_all")
  self.list_recently = self:getNode("list_recently")
  self.list_request = self:getNode("list_request")
  self.txt_onlinenum = self:getNode("txt_onlinenum")
  self.txt_friendnum = self:getNode("txt_friendnum")
  self.txt_unreadrequest = self:getNode("txt_unreadrequest")
  self:resizeList(self.list_all)
  self:resizeList(self.list_recently)
  self:resizeList(self.list_request)
  local x2, y2 = self.list_all:getPosition()
  self.list_all._initPos = ccp(x2, y2)
  self.list_all:addTouchItemListenerListView(handler(self, self.OnFriendListItemClick), handler(self, self.FriendListEventListener))
  self.sublayer_find = self:getNode("sublayer_find")
  self.input_find = self:getNode("input_find")
  TextFieldEmoteExtend.extend(self.input_find, self:getUINode())
  self.input_find:setMaxLengthEnabled(false)
  self.input_find:SetMaxInputLength(g_MaxWordNumOfFindFriend)
  self.input_find:SetKeyBoardListener(handler(self, self.onFindKeyBoardListener))
  self.sublayer_friendchat = self:getNode("sublayer_friendchat")
  self.list_friendchat = self:getNode("list_friendchat")
  self.input_friendchat = self:getNode("input_friendchat")
  self.inputbg_friendchat = self:getNode("inputbg_friendchat")
  self.friendname = self:getNode("friendname")
  self:resizeList(self.list_friendchat)
  self.btn_voicepress_friend = self:getNode("btn_voicepress_friend")
  VoiceRecordBtnExtend.extend(self.btn_voicepress_friend, CHANNEL_FRIEND, handler(self, self.getCurrChatFriend), true)
  local pressBtnTxt = ui.newTTFLabel({
    text = "按住说话",
    size = 20,
    font = KANG_TTF_FONT,
    color = ccc3(236, 209, 76)
  })
  self.btn_voicepress_friend:addNode(pressBtnTxt)
  TextFieldEmoteExtend.extend(self.input_friendchat, self:getUINode())
  self.input_friendchat:setMaxLengthEnabled(false)
  self.input_friendchat:SetMaxInputLength(g_MaxWordNumOfPrivateChat)
  self.input_friendchat:SetKeyBoardListener(handler(self, self.onFriendChatKeyBoardListener))
  self.input_friendchat:SetDailyWordType(DailyWordType_Private)
  self.sublayer_momo = self:getNode("sublayer_momo")
  self.list_momofriend = self:getNode("list_momofriend")
  self:resizeList(self.list_momofriend)
  self.list_momofriend:addTouchItemListenerListView(handler(self, self.OnMoMoListItemClick), handler(self, self.MoMoListEventListener))
  for _, viewIns in pairs({
    self.sublayer_all,
    self.sublayer_recently,
    self.sublayer_request,
    self.sublayer_find,
    self.sublayer_friendchat,
    self.sublayer_momo,
    self.layermail
  }) do
    viewIns:setVisible(true)
    local x, y = viewIns:getPosition()
    viewIns._initPos = ccp(x, y)
  end
  local p = self.list_all:getParent()
  local pos = self.list_all._initPos
  local size = self.list_all:getContentSize()
  local wpos = p:convertToWorldSpace(ccp(pos.x, pos.y + size.height))
  self.m_FindItemPos = self.sublayer_find:convertToNodeSpace(ccp(wpos.x, wpos.y))
  self.pic_tipnew_recently = self:getNode("pic_tipnew_recently")
  self.unread_recently = self:getNode("unread_recently")
  self.pic_tipnew_friend = self:getNode("pic_tipnew_friend")
  self.unread_friend = self:getNode("unread_friend")
  self.pic_tipnew_request = self:getNode("pic_tipnew_request")
  self.unread_request = self:getNode("unread_request")
  self:ShowRecentlyTip(0)
  self:ShowNewFriendTip(0)
  self:ShowRequestTip(0)
  self:setTouchEnabled(true)
  self:setVisible(false)
  local size = self:getContentSize()
  self.m_InitPos = ccp(-size.width - 20, display.height - size.height)
  self.m_ShowPos = ccp(0, display.height - size.height)
  self:setPosition(ccp(self.m_InitPos.x, self.m_InitPos.y))
  self.m_IsDlgShow = false
  local bgSize = self:getNode("bg"):getContentSize()
  local addH = bgSize.height - display.height
  local newSzie = CCSize(bgSize.width, display.height)
  self:getNode("bg"):setSize(newSzie)
  self:getNode("bg"):setPosition(ccp(0, addH))
  self:showRecentlyFriendList()
  self:showAllFriendList()
  self:InitFriendsList()
  self:InitFriendChat()
  self:InitMomo()
  self:Btn_Group_All()
  self:Btn_KeyBoardFriend()
  self:ListenMessage(MsgID_Friends)
  self:ListenMessage(MsgID_Message)
  socialityDlgExtend_Mail.extend(self)
end
function FriendsDlg:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Friends_InitAllFirendsList then
    self:onInitAllFriendsList()
  elseif msgSID == MsgID_Friends_AddNewFirend then
    self:onAddNewFriend(arg[1], arg[2])
  elseif msgSID == MsgID_Friends_DeleteFirend then
    self:onDeleteFriend(arg[1])
  elseif msgSID == MsgID_Friends_UpdateFirend then
    self:onUpdateFriend(arg[1], arg[2])
  elseif msgSID == MsgID_Friends_FindPlayerInfo then
    self:onFindPlayerInfo(arg[1], arg[2])
  elseif msgSID == MsgID_Friends_NewFriendRequest then
    self:onNewFriendRequest(arg[1], arg[2])
  elseif msgSID == MsgID_Friends_DelFriendRequest then
    self:onDeleteFriendRequest(arg[1])
  elseif msgSID == MsgID_Message_PrivateMsg then
    self:onReceivePrivateMsg(arg[1])
  elseif msgSID == MsgID_Friends_ClearRequest then
    self:onReceiveClearRequest()
  elseif msgSID == MsgID_Friends_FlushBanLv then
    self:onReceiveBanLv()
  elseif msgSID == MsgID_Mail_AllMailLoaded then
    self:onReceiveMail_AllMailLoaded()
  elseif msgSID == MsgID_Mail_MailUpdated then
    self:onReceiveMail_MailUpdated(arg[1])
  elseif msgSID == MsgID_Mail_MailDeleteed then
    self:onReceiveMail_MailDeleteed(arg[1])
  elseif msgSID == MsgID_Mail_MailHasNewMail then
    self:onReceiveMail_MailHasNewMail()
  end
end
function FriendsDlg:resizeList(listObj)
  local offy = display.height - 640
  if offy ~= 0 then
    local size = listObj:getContentSize()
    listObj:setSize(CCSize(size.width, size.height + offy))
    local x, y = listObj:getPosition()
    listObj:setPosition(ccp(x, y - offy))
  end
end
function FriendsDlg:ShowDlg()
  if self.m_IsDlgShow then
    return
  end
  self.m_IsDlgShow = true
  self:stopAllActions()
  local act1 = CCCallFunc:create(function()
    self:setVisible(true)
  end)
  local act2 = CCMoveTo:create(0.3, ccp(self.m_ShowPos.x, self.m_ShowPos.y))
  self:runAction(transition.sequence({act1, act2}))
  self:CheckNewTip_WhenShow()
  g_FriendsMgr:send_onFriendListOpen()
  self:ShowMailPage(true)
  if g_SocialityDlg then
    g_SocialityDlg:HideDlg()
  end
end
function FriendsDlg:HideDlg()
  if not self.m_IsDlgShow then
    return
  end
  self.m_IsDlgShow = false
  self:stopAllActions()
  local act1 = CCMoveTo:create(0.2, ccp(self.m_InitPos.x, self.m_InitPos.y))
  local act2 = CCCallFunc:create(function()
    self:setVisible(false)
    self:CheckNewTip_WhenHide()
    self:SavePrivateChatToLocal()
    self:ShowMailPage(false)
  end)
  self:runAction(transition.sequence({act1, act2}))
  ClearShowChatDetail()
  self:CheckUpdateMoMoCache()
  self:CloseAllKeyBoard()
end
function FriendsDlg:ShowOrHideDlg()
  if self.m_IsDlgShow then
    self:HideDlg()
  else
    self:ShowDlg()
  end
end
function FriendsDlg:getIsDlgShow()
  return self.m_IsDlgShow
end
function FriendsDlg:SavePrivateChatToLocal()
  if self.m_CurrChatFriend ~= nil and self.sublayer_friendchat:isEnabled() then
    g_MessageMgr:SavePrivateMsgToLocal(self.m_CurrChatFriend)
  end
end
function FriendsDlg:OpenPrivateChat(pid)
  if not self.m_IsDlgShow then
    self:ShowDlg()
  end
  self:ShowSubLayerFriendChat(pid)
end
function FriendsDlg:checkNewTip()
  local cnt_1 = self:getNewTipNum_NewFriend()
  local cnt_2 = self:getNewTipNum_Request()
  local cnt_3 = self:getNewTipNum_PrivateMsg()
  self:ShowNewFriendTip(cnt_1)
  self:ShowRequestTip(cnt_2)
  self:ShowRecentlyTip(cnt_3)
  local cnt = cnt_1 + cnt_2 + cnt_3
  SendMessage(MsgID_Scene_NewFriendTip, cnt)
end
function FriendsDlg:CheckNewTip_WhenShow()
  self:checkNewTip_NewFriend(false)
  self:checkNewTip_Request(false)
  self:checkNewTip_PrivateMsg(false)
  self:checkNewTip()
end
function FriendsDlg:CheckNewTip_WhenHide()
  local cnt = self.list_all:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_all:getItem(j)
    local item = tempItem.m_UIViewParent
    if iskindof(item, "CFriendItem") then
      local pid = item:getPlayerId()
      if self.m_NewTip_NewFriend[pid] == nil then
        item:SetIsNewFriend(false)
      end
    end
  end
  self:checkNewTip()
end
function FriendsDlg:ShowRecentlyTip(num)
  if num > 99 then
    num = 99
  end
  self.pic_tipnew_recently:setVisible(num > 0)
  self.unread_recently:setText(tostring(num))
end
function FriendsDlg:ShowNewFriendTip(num)
  if num > 99 then
    num = 99
  end
  self.pic_tipnew_friend:setVisible(num > 0)
  self.unread_friend:setText(tostring(num))
end
function FriendsDlg:ShowRequestTip(num)
  if num > 99 then
    num = 99
  end
  self.pic_tipnew_request:setVisible(num > 0)
  self.unread_request:setText(tostring(num))
end
function FriendsDlg:getSocialityTipNum()
  local temp_1 = self.unread_recently:getStringValue()
  local temp_2 = self.unread_friend:getStringValue()
  local temp_3 = self.unread_request:getStringValue()
  return tonumber(temp_1) + tonumber(temp_2) + tonumber(temp_3)
end
function FriendsDlg:setFriendNum()
  self.txt_friendnum:setText(string.format("我的好友(%d/%d)", g_FriendsMgr:getFriendNum(), g_FriendsMgr:getFriendLimitNum()))
end
function FriendsDlg:setOnLineNum()
  self.txt_onlinenum:setText(string.format("在线:%d", g_FriendsMgr:getOnLineNum()))
end
function FriendsDlg:setRequestNum()
  local cnt = self.list_request:getCount()
  self.txt_unreadrequest:setText(string.format("未处理请求(%d)", cnt))
  self.txt_unreadrequest:setVisible(cnt > 0)
end
function FriendsDlg:CloseAllKeyBoard()
  if self.input_find then
    self.input_find:CloseTheKeyBoard()
  end
  if self.input_friendchat then
    self.input_friendchat:CloseTheKeyBoard()
  end
end
function FriendsDlg:ShowFriendList(showLayer)
  for _, sublayer in pairs({
    self.sublayer_all,
    self.sublayer_recently,
    self.sublayer_request,
    self.layermail
  }) do
    if sublayer == showLayer then
      sublayer:setVisible(true)
      sublayer:setPosition(ccp(sublayer._initPos.x, sublayer._initPos.y))
    else
      sublayer:setVisible(false)
      sublayer:setPosition(ccp(-10000, -10000))
    end
  end
  self:checkNewTip_NewFriend(false)
  self:checkNewTip_Request(false)
  self:checkNewTip_PrivateMsg(false)
  self:checkNewTip()
end
function FriendsDlg:checkNewTip_NewFriend(_checkNewTip)
  if getTableLength(self.m_NewTip_NewFriend) > 0 then
    if self.m_IsDlgShow and self.sublayer_all:isVisible() then
      self.m_NewTip_NewFriend = {}
    end
    if _checkNewTip ~= false then
      self:checkNewTip()
    end
  end
end
function FriendsDlg:getNewTipNum_NewFriend()
  return getTableLength(self.m_NewTip_NewFriend)
end
function FriendsDlg:checkNewTip_Request(_checkNewTip)
  if getTableLength(self.m_NewTip_Request) > 0 then
    if self.m_IsDlgShow and self.sublayer_request:isVisible() then
      self.m_NewTip_Request = {}
    end
    if _checkNewTip ~= false then
      self:checkNewTip()
    end
  end
end
function FriendsDlg:getNewTipNum_Request()
  return getTableLength(self.m_NewTip_Request)
end
function FriendsDlg:checkNewTip_PrivateMsg(_checkNewTip)
  if self.m_IsDlgShow and self.sublayer_recently:isVisible() and self.sublayer_friendchat:isEnabled() then
    if self.m_CurrChatFriend ~= nil then
      g_MessageMgr:setReadPrivateMessage(self.m_CurrChatFriend)
      self:setNewTip_PrivateChat_None(self.m_CurrChatFriend)
    end
    if _checkNewTip ~= false then
      self:checkNewTip()
    end
  end
end
function FriendsDlg:getNewTipNum_PrivateMsg()
  local unreadCnt = 0
  local cnt = self.list_recently:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_recently:getItem(j)
    local item = tempItem.m_UIViewParent
    unreadCnt = unreadCnt + item:getUnreadMsgCnt()
  end
  return unreadCnt
end
function FriendsDlg:InitFriendsList()
  self.list_recently:removeAllItems()
  self.list_all:removeAllItems()
  self.list_request:removeAllItems()
  local localPlayerId = g_LocalPlayer:getPlayerId()
  local needNewFriendTip = {}
  if self.m_ShowMoMo then
    local momoItem = CFriendMoMoItem.new()
    self.list_all:pushBackCustomItem(momoItem:getUINode())
  end
  local friendsList = g_FriendsMgr:getFriendsList()
  table.sort(friendsList, _friendSortFunc)
  for _, d in pairs(friendsList) do
    local pid, info = d[1], d[2]
    if pid ~= localPlayerId then
      local isNew = info.new == 1
      local item = CFriendItem.new(pid, info, handler(self, self.OnClickHead_All), handler(self, self.OnClickMore), isNew)
      self.list_all:pushBackCustomItem(item:getUINode())
      if isNew then
        needNewFriendTip[pid] = true
      end
    end
  end
  self:setNewTip_NewFriend(needNewFriendTip)
  self:setFriendNum()
  self:setOnLineNum()
  local BanLvId = g_FriendsMgr:getBanLvId() or 0
  self.m_CurrSortBanLvId = BanLvId
  local chatFriendsList = g_FriendsMgr:getChatFriendsList()
  table.sort(chatFriendsList, _recentlySortFunc)
  for _, d in pairs(chatFriendsList) do
    local pid, info = d[1], d[2]
    if pid ~= localPlayerId then
      local item = CFriendItemRecently.new(pid, info, handler(self, self.OnClickHead_Recently), handler(self, self.OnClickMore))
      self.list_recently:pushBackCustomItem(item:getUINode())
    end
  end
  local needNewRequestTip = {}
  local friendRequestList = g_FriendsMgr:getSortedRequestList()
  for _, d in pairs(friendRequestList) do
    local pid, info = d[1], d[2]
    if pid ~= localPlayerId then
      local item = CFriendRequestItem.new(pid, info)
      self.list_request:pushBackCustomItem(item:getUINode())
      local isNew = info.new == 1
      if isNew then
        needNewRequestTip[pid] = true
      end
    end
  end
  self:setNewTip_Request(needNewRequestTip)
  self:setRequestNum()
end
function FriendsDlg:OnFriendListItemClick(item, index, listObj)
  item = item.m_UIViewParent
  if iskindof(item, "CFriendMoMoItem") then
    self:showAllMoMoList()
  end
end
function FriendsDlg:FriendListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    item = item.m_UIViewParent
    if iskindof(item, "CFriendMoMoItem") then
      item:setTouchStatus(true)
      self.m_TouchStartFriendItem = item
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END and self.m_TouchStartFriendItem and iskindof(self.m_TouchStartFriendItem, "CFriendMoMoItem") then
    self.m_TouchStartFriendItem:setTouchStatus(false)
    self.m_TouchStartFriendItem = nil
  end
end
function FriendsDlg:setNewTip_NewFriend(data)
  if type(data) == "table" then
    for pid, _ in pairs(data) do
      self.m_NewTip_NewFriend[pid] = true
    end
    self:checkNewTip_NewFriend()
  elseif type(data) == "number" then
    self.m_NewTip_NewFriend[data] = true
    self:checkNewTip_NewFriend()
  end
end
function FriendsDlg:setNewTip_Request(data)
  if type(data) == "table" then
    for pid, _ in pairs(data) do
      self.m_NewTip_Request[pid] = true
    end
    self:checkNewTip_Request()
  elseif type(data) == "number" then
    self.m_NewTip_Request[data] = true
    self:checkNewTip_Request()
  end
end
function FriendsDlg:OnClickHead_All(pid)
  self:ShowSubLayerFriendChat(pid)
end
function FriendsDlg:OnClickHead_Recently(pid)
  self:ShowSubLayerFriendChat(pid)
end
function FriendsDlg:OnClickMore(pid, info, wPos)
  local moreDlg = CPlayerInfoOfFriendDlg.new(pid, info)
  self:addChild(moreDlg:getUINode(), 10)
  local pos = self:getUINode():convertToNodeSpace(wPos)
  local mysize = self:getContentSize()
  local sizeDlg = moreDlg:getContentSize()
  moreDlg:setPosition(ccp(mysize.width, pos.y - sizeDlg.height / 2))
  moreDlg:adjustPos()
end
function FriendsDlg:onInitAllFriendsList()
  self:InitFriendsList()
  self:checkNewTip()
end
function FriendsDlg:onAddNewFriend(pid, info)
  local i = -1
  local cnt = self.list_all:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_all:getItem(j)
    local item = tempItem.m_UIViewParent
    if iskindof(item, "CFriendItem") then
      i = j
      break
    end
  end
  local item = CFriendItem.new(pid, info, handler(self, self.OnClickHead_All), handler(self, self.OnClickMore), true)
  if i >= 0 then
    self.list_all:insertCustomItem(item:getUINode(), i)
  else
    self.list_all:pushBackCustomItem(item:getUINode())
  end
  self:onDeleteFriendRequest(pid)
  self:setNewTip_NewFriend(pid)
  self:setFriendNum()
  self:setOnLineNum()
end
function FriendsDlg:onDeleteFriend(pid)
  local cnt = self.list_all:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_all:getItem(j)
    local item = tempItem.m_UIViewParent
    if iskindof(item, "CFriendItem") and item:getPlayerId() == pid then
      self.list_all:removeItem(j)
      break
    end
  end
  local cnt = self.list_recently:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_recently:getItem(j)
    local item = tempItem.m_UIViewParent
    if item:getPlayerId() == pid then
      self.list_recently:removeItem(j)
      break
    end
  end
  if self.m_CurrChatFriend == pid then
    self.m_CurrChatFriend = nil
  end
  self:setFriendNum()
  self:setOnLineNum()
end
function FriendsDlg:onUpdateFriend(pid, info)
  local cnt = self.list_all:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_all:getItem(j)
    local item = tempItem.m_UIViewParent
    if iskindof(item, "CFriendItem") and item:getPlayerId() == pid then
      item:setContent(info)
      if info.status ~= nil then
        self:SetFriendToProperPos(pid)
      end
      break
    end
  end
  local cnt = self.list_recently:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_recently:getItem(j)
    local item = tempItem.m_UIViewParent
    if item:getPlayerId() == pid then
      item:setContent(info)
      break
    end
  end
  if info.status ~= nil then
    self:setOnLineNum()
  end
end
function FriendsDlg:onFindPlayerInfo(pid, info)
  self:removeFindPlayerItem()
  self.m_FindPlayerItem = CFindFriendItem.new(pid, info, handler(self, self.BackAfterFind), handler(self, self.OnClickMore))
  self.sublayer_find:addChild(self.m_FindPlayerItem:getUINode())
  local isize = self.m_FindPlayerItem:getContentSize()
  self.m_FindPlayerItem:setPosition(ccp(self.m_FindItemPos.x, self.m_FindItemPos.y - isize.height))
  self:ShowFriendList(nil)
  self.input_find:SetFieldText("")
end
function FriendsDlg:onNewFriendRequest(pid, info)
  local item = CFriendRequestItem.new(pid, info)
  self.list_request:insertCustomItem(item:getUINode(), 0)
  if info.new == 1 then
    self:setNewTip_Request(pid)
  end
  self:setRequestNum()
end
function FriendsDlg:onDeleteFriendRequest(pid)
  local cnt = self.list_request:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_request:getItem(j)
    local item = tempItem.m_UIViewParent
    if item:getPlayerId() == pid then
      self.list_request:removeItem(j)
      self:checkNewTip()
      break
    end
  end
  self:setRequestNum()
end
function FriendsDlg:onReceiveClearRequest()
  self.list_request:removeAllItems()
  self:setRequestNum()
end
function FriendsDlg:removeFindPlayerItem()
  if self.m_FindPlayerItem ~= nil then
    self.m_FindPlayerItem:removeFromParent()
    self.m_FindPlayerItem = nil
  end
end
function FriendsDlg:onReceiveBanLv()
  local BanLvId = g_FriendsMgr:getBanLvId() or 0
  if self.m_CurrSortBanLvId ~= nil and self.m_CurrSortBanLvId == BanLvId then
    if BanLvId ~= 0 then
      local cnt = self.list_all:getCount()
      for i = 0, cnt - 1 do
        local item = self.list_all:getItem(i)
        item = item.m_UIViewParent
        if item then
          item:checkFriendRelation()
        end
      end
      local cnt = self.list_recently:getCount()
      for i = 0, cnt - 1 do
        local item = self.list_recently:getItem(i)
        item = item.m_UIViewParent
        if item then
          item:checkFriendRelation()
        end
      end
    end
    return
  end
  self:onInitAllFriendsList()
end
function FriendsDlg:showRecentlyFriendList()
  self:removeFindPlayerItem()
  self.input_find:SetFieldText("")
  self.btn_group_recently:setTitleText("最\n近")
  self.sublayer_friendchat:setEnabled(false)
  self.list_recently:setEnabled(true)
  self.sublayer_find:setEnabled(true)
end
function FriendsDlg:showRecentlyChatList()
  self:removeFindPlayerItem()
  self.input_find:SetFieldText("")
  self.btn_group_recently:setTitleText("返\n回")
  self.sublayer_friendchat:setEnabled(true)
  self.list_recently:setEnabled(false)
  self.sublayer_find:setEnabled(false)
  self:checkNewTip_PrivateMsg()
end
function FriendsDlg:showAllFriendList()
  self:removeFindPlayerItem()
  self.input_find:SetFieldText("")
  self.btn_group_all:setTitleText("好\n友")
  self.sublayer_momo:setEnabled(false)
  self.list_all:setEnabled(true)
  self.txt_onlinenum:setEnabled(true)
  self.txt_friendnum:setEnabled(true)
  self.sublayer_find:setEnabled(true)
  self:checkNewTip_NewFriend()
end
function FriendsDlg:showAllMoMoList()
  self:removeFindPlayerItem()
  self.input_find:SetFieldText("")
  self.btn_group_all:setTitleText("返\n回")
  self.sublayer_momo:setEnabled(true)
  self.list_all:setEnabled(false)
  self.txt_onlinenum:setEnabled(false)
  self.txt_friendnum:setEnabled(false)
  self.sublayer_find:setEnabled(false)
end
function FriendsDlg:onFindKeyBoardListener(event)
  if event == TEXTFIELDEXTEND_EVENT_ATTACH_WITH_IME or event == TEXTFIELDEXTEND_EVENT_DETACH_WITH_IME or event == TEXTFIELDEXTEND_EVENT_TEXT_CHANGE then
  end
end
function FriendsDlg:SetFriendToTop(pid)
  print("【FriendsDlg】-->>好友置顶:", pid)
  local topIdx
  local cnt = self.list_recently:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_recently:getItem(j)
    local item = tempItem.m_UIViewParent
    if topIdx == nil then
      topIdx = j
    end
    if item:getPlayerId() == pid then
      if j ~= topIdx then
        self:SetFriendToIndex(self.list_recently, item, j, topIdx)
      end
      return
    end
  end
  local info = g_FriendsMgr:getPlayerInfo(pid)
  if info ~= nil then
    local item = CFriendItemRecently.new(pid, info, handler(self, self.OnClickHead_Recently), handler(self, self.OnClickMore))
    if self.list_recently:getCount() > 0 then
      self.list_recently:insertCustomItem(item:getUINode(), 0)
    else
      self.list_recently:pushBackCustomItem(item:getUINode())
    end
  end
end
function FriendsDlg:SetFriendToProperPos(pid)
  print("【FriendsDlg】-->>好友放在合适的位置上:", pid)
  local oldIdx, newIdx, fItem
  local cnt = self.list_all:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_all:getItem(j)
    local item = tempItem.m_UIViewParent
    if iskindof(item, "CFriendItem") and item:getPlayerId() == pid then
      fItem = item
      oldIdx = j
      break
    end
  end
  local fInfo = g_FriendsMgr:getPlayerInfo(pid)
  if fInfo == nil then
    return
  end
  local cnt = self.list_all:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_all:getItem(j)
    local item = tempItem.m_UIViewParent
    if iskindof(item, "CFriendItem") then
      local itemId = item:getPlayerId()
      if itemId ~= pid then
        local itemInfo = g_FriendsMgr:getPlayerInfo(itemId)
        if itemInfo and _friendSortFunc({pid, fInfo}, {itemId, itemInfo}) then
          newIdx = j
          break
        end
      end
    end
  end
  if newIdx == nil then
    newIdx = self.list_all:getCount() + 1
  end
  print("SetFriendToProperPos:", oldIdx, newIdx)
  if fItem ~= nil and oldIdx ~= nil and newIdx ~= nil and oldIdx ~= newIdx then
    if oldIdx > newIdx then
      self:SetFriendToIndex(self.list_all, fItem, oldIdx, newIdx)
    else
      self:SetFriendToIndex(self.list_all, fItem, oldIdx, newIdx - 1)
    end
  end
end
function FriendsDlg:SetFriendToIndex(listObj, item, oldIdx, newIdx)
  print("【FriendsDlg】-->>SetFriendToIndex:", oldIdx, newIdx)
  if oldIdx == newIdx or item == nil then
    return
  end
  local itemUINode = item:getUINode()
  item._execNodeEvent = false
  itemUINode:retain()
  listObj:removeItem(oldIdx)
  if newIdx >= listObj:getCount() then
    listObj:pushBackCustomItem(itemUINode)
  else
    listObj:insertCustomItem(itemUINode, newIdx)
  end
  itemUINode:release()
  item._execNodeEvent = true
end
function FriendsDlg:InitFriendChat()
  self.m_CurrChatFriend = nil
end
function FriendsDlg:ShowSubLayerFriendChat(pid)
  self:SetChatFriend(pid)
  self.m_CurrLabel = -1
  self:Btn_Group_Recently()
  self:showRecentlyChatList()
  local pInfo = g_FriendsMgr:getPlayerInfo(pid)
  if pInfo then
    local zs = pInfo.zs
    local color = NameColor_MainHero[zs] or ccc3(255, 0, 0)
    self.friendname:setText(pInfo.name or "")
    self.friendname:setColor(color)
  else
    self.friendname:setText("")
  end
  self:setNewTip_PrivateChat_None(pid)
end
function FriendsDlg:SetChatFriend(pid)
  if self.m_CurrChatFriend == pid then
    return
  end
  if self.m_CurrChatFriend ~= nil then
    g_MessageMgr:SavePrivateMsgToLocal(self.m_CurrChatFriend)
  end
  self.m_CurrChatFriend = pid
  if self.m_FriendChatBox == nil then
    self.m_FriendChatBox = CPrivateChat.new(pid, self.list_friendchat, handler(self, self.OnClickMessage))
  else
    self.m_FriendChatBox:reloadChatContent(pid)
  end
end
function FriendsDlg:getCurrChatFriend()
  return self.m_CurrChatFriend
end
function FriendsDlg:onFriendChatKeyBoardListener(event, param)
  if event == TEXTFIELDEXTEND_EVENT_SEND_TEXT then
    local chatText = param
    if string.len(chatText) > 0 then
      if g_FriendsMgr:isLocalPlayerFriend(self.m_CurrChatFriend) then
        g_MessageMgr:sendPrivateMessage(self.m_CurrChatFriend, chatText)
      else
        ShowNotifyTips("只能跟好友进行聊天")
      end
    end
  end
end
function FriendsDlg:onReceivePrivateMsg(pid)
  if self:IsChattingWithFriendNow(pid) then
    g_MessageMgr:setReadPrivateMessage(pid)
  end
  self:SetFriendToTop(pid)
  local cnt = self.list_recently:getCount()
  for j = 0, cnt - 1 do
    local tempItem = self.list_recently:getItem(j)
    local item = tempItem.m_UIViewParent
    if pid == item:getPlayerId() then
      item:CheckUnreadMsg()
    end
  end
  self:checkNewTip()
end
function FriendsDlg:IsChattingWithFriendNow(pid)
  if self.m_IsDlgShow and self.sublayer_recently:isVisible() and self.sublayer_friendchat:isEnabled() and self.m_CurrChatFriend == pid then
    return true
  else
    return false
  end
end
function FriendsDlg:setNewTip_PrivateChat_None(pid)
  local cnt = self.list_recently:getCount()
  for i = 0, cnt - 1 do
    local tempItem = self.list_recently:getItem(i)
    local item = tempItem.m_UIViewParent
    if pid == item:getPlayerId() then
      item:CheckUnreadMsg()
      break
    end
  end
end
function FriendsDlg:InitMomo()
  if not self.m_ShowMoMo then
    return
  end
  self.m_MoMoPageNum = 20
  self.m_MoMoFriendInfoList = {}
  self.m_MoMoFriendRole = {}
  self:queryMoMoFriendList()
end
function FriendsDlg:queryMoMoFriendList()
  self.m_LastGetMoMoFriendListTime = os.time()
  g_ChannelMgr:getFriendList(handler(self, self.getMoMoFriendList))
end
function FriendsDlg:getMoMoFriendList(isSucceed, infoList)
  if not isSucceed then
    return
  end
  self.m_MoMoFriendInfoList = {}
  self.m_MoMoFriendRole = {}
  self.list_momofriend:removeAllItems()
  for userId, userInfo in pairs(infoList) do
    userInfo.userId = userId
    self.m_MoMoFriendInfoList[#self.m_MoMoFriendInfoList + 1] = userInfo
  end
  self.m_MoMoLoadIndex = 0
  self:LoadNextMoMoPart()
end
function FriendsDlg:LoadNextMoMoPart()
  if #self.m_MoMoFriendInfoList <= 0 then
    return
  end
  self.list_momofriend:removeAllItems()
  local initIndex = self.m_MoMoLoadIndex
  local n = 0
  local loadNum = self.m_MoMoPageNum
  for index = self.m_MoMoLoadIndex + 1, self.m_MoMoLoadIndex + loadNum do
    local info = self.m_MoMoFriendInfoList[index]
    if info == nil then
      break
    end
    if info.name ~= "陌陌" then
      local item = CFriendItem_MoMo.new(info)
      self.list_momofriend:pushBackCustomItem(item:getUINode())
      local userId = info.userId
      if self.m_MoMoFriendRole[userId] == nil then
        netsend.login.queryMoMoPlayerRoleInfo(GameType, userId)
      end
    end
    n = n + 1
  end
  self.m_MoMoLoadIndex = self.m_MoMoLoadIndex + n
  local preBtn = true
  local nextBtn = true
  if initIndex <= 1 then
    preBtn = false
  end
  if self.m_MoMoLoadIndex >= #self.m_MoMoFriendInfoList then
    nextBtn = false
  end
  local item = CFriendItem_MoMo_Split.new(handler(self, self.pageSplitListener), preBtn, nextBtn)
  self.list_momofriend:pushBackCustomItem(item:getUINode())
  self.list_momofriend:refreshView()
  self.list_momofriend:jumpToTop()
end
function FriendsDlg:pageSplitListener(showNext)
  if showNext then
    self:LoadNextMoMoPart()
  else
    self.m_MoMoLoadIndex = self.m_MoMoLoadIndex - self.m_MoMoPageNum * 2
    if self.m_MoMoLoadIndex < 0 then
      self.m_MoMoLoadIndex = 0
    end
    self:LoadNextMoMoPart()
  end
end
function FriendsDlg:setMoMoPlayerRoleInfo(userId, data)
  if data == nil then
    data = {}
  end
  self.m_MoMoFriendRole[userId] = data
  local cnt = self.list_momofriend:getCount()
  for i = 0, cnt - 1 do
    local tempItem = self.list_momofriend:getItem(i)
    tempItem = tempItem.m_UIViewParent
    if iskindof(tempItem, "CFriendItem_MoMo") and tempItem:getUserId() == userId then
      if #data > 0 then
        if tempItem:getIsShowDetail() then
          self:ShowMoMoRoleDetail(userId, data)
        end
        tempItem:setHasGameRole(true)
      else
        tempItem:setHasGameRole(false)
        tempItem:setIsShowDetail(false)
      end
    end
  end
end
function FriendsDlg:OnMoMoListItemClick(item, index, listObj)
  item = item.m_UIViewParent
  if iskindof(item, "CFriendItem_MoMo") then
    if item:getIsShowDetail() then
      local userId = item:getUserId()
      if self.m_MoMoFriendRole[userId] ~= nil then
        self:HideMoMoRoleDetail(userId)
        item:setIsShowDetail(false)
      end
    else
      local userId = item:getUserId()
      if self.m_MoMoFriendRole[userId] ~= nil then
        self:ShowMoMoRoleDetail(userId, self.m_MoMoFriendRole[userId])
      end
      item:setIsShowDetail(true)
    end
  end
end
function FriendsDlg:ShowMoMoRoleDetail(userId, data)
  local cnt = self.list_momofriend:getCount()
  local insertIndex = -1
  for index = 0, cnt - 1 do
    local item = self.list_momofriend:getItem(index)
    item = item.m_UIViewParent
    if iskindof(item, "CFriendItem_MoMo") and item:getUserId() == userId then
      insertIndex = index + 1
      break
    end
  end
  if insertIndex == -1 then
    return
  end
  for i, info in pairs(data) do
    local item = CFriendItem_MoMo_Role.new(userId, info, handler(self, self.OnClickMore))
    local n = self.list_momofriend:getCount()
    if insertIndex >= n then
      self.list_momofriend:pushBackCustomItem(item:getUINode())
    else
      self.list_momofriend:insertCustomItem(item:getUINode(), insertIndex)
      insertIndex = insertIndex + 1
    end
    if i == 1 then
      item:showArrowIcon()
    end
  end
end
function FriendsDlg:HideMoMoRoleDetail(userId)
  local cnt = self.list_momofriend:getCount()
  for index = cnt - 1, 0, -1 do
    local item = self.list_momofriend:getItem(index)
    item = item.m_UIViewParent
    if iskindof(item, "CFriendItem_MoMo_Role") and item:getUserId() == userId then
      self.list_momofriend:removeItem(index)
    end
  end
end
function FriendsDlg:MoMoListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    item = item.m_UIViewParent
    if iskindof(item, "CFriendItem_MoMo") and item:getHasGameRole() then
      item:setTouchStatus(true)
      self.m_TouchStartMoMoItem = item
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END and self.m_TouchStartMoMoItem and iskindof(self.m_TouchStartMoMoItem, "CFriendItem_MoMo") then
    self.m_TouchStartMoMoItem:setTouchStatus(false)
    self.m_TouchStartMoMoItem = nil
  end
end
function FriendsDlg:CheckUpdateMoMoCache()
  if not self.m_ShowMoMo then
    return
  end
  if self.m_LastGetMoMoFriendListTime == nil then
    return
  end
  local curTime = os.time()
  if curTime - self.m_LastGetMoMoFriendListTime > 1800 then
    self:queryMoMoFriendList()
  end
end
function FriendsDlg:Btn_Group_Recently()
  if self.m_CurrLabel == FriendLabel_Recently then
    self:showRecentlyFriendList()
    if self.m_CurrChatFriend ~= nil then
      g_MessageMgr:SavePrivateMsgToLocal(self.m_CurrChatFriend)
    end
  else
    self:setGroupBtnSelected(self.btn_group_recently)
    self.m_CurrLabel = FriendLabel_Recently
  end
  self:ShowFriendList(self.sublayer_recently)
  if self.list_recently:isEnabled() then
    self.sublayer_find:setEnabled(true)
  else
    self.sublayer_find:setEnabled(false)
  end
  self:removeFindPlayerItem()
end
function FriendsDlg:Btn_Group_All()
  if self.m_CurrLabel == FriendLabel_All then
    self:showAllFriendList()
  else
    self:setGroupBtnSelected(self.btn_group_all)
    self.m_CurrLabel = FriendLabel_All
  end
  self:ShowFriendList(self.sublayer_all)
  if self.list_all:isEnabled() then
    self.sublayer_find:setEnabled(true)
  else
    self.sublayer_find:setEnabled(false)
  end
  self:removeFindPlayerItem()
end
function FriendsDlg:Btn_Group_Request()
  self:setGroupBtnSelected(self.btn_group_request)
  self:ShowFriendList(self.sublayer_request)
  self.m_CurrLabel = FriendLabel_Request
  self.sublayer_find:setEnabled(false)
  self:removeFindPlayerItem()
end
function FriendsDlg:Btn_Group_Mail()
  self:setGroupBtnSelected(self.btn_group_mail)
  self:ShowFriendList(self.layermail)
  self.m_CurrLabel = FriendLabel_Mail
  self.sublayer_find:setEnabled(false)
  self:removeFindPlayerItem()
  self:ShowMailPage(true)
end
function FriendsDlg:Btn_FindFriend(obj, t)
  local inputText = self.input_find:GetFieldText()
  if string.len(inputText) > 0 then
    g_FriendsMgr:send_findPlayerByName(inputText)
  else
    ShowNotifyTips("请输入需要查找的玩家ID或者玩家昵称")
  end
end
function FriendsDlg:Btn_FindFriendIcon(obj, t)
  self.input_find:attachWithIME()
end
function FriendsDlg:BackAfterFind(obj, t)
  if self.m_CurrLabel == FriendLabel_Recently then
    self.m_CurrLabel = -1
    self:Btn_Group_Recently()
  else
    self.m_CurrLabel = -1
    self:Btn_Group_All()
  end
end
function FriendsDlg:Btn_ChatInsert(obj, t)
  if self.btn_voicepress_friend:isVisible() then
    self:Btn_KeyBoardFriend()
  end
  self.input_friendchat:openInsertBoard()
end
function FriendsDlg:Btn_SendChat(obj, t)
  if self.btn_voicepress_friend:isVisible() then
    self:Btn_KeyBoardFriend()
  end
  if g_FriendsMgr:isLocalPlayerFriend(self.m_CurrChatFriend) then
    local chatText = self.input_friendchat:GetFieldText()
    if string.len(chatText) > 0 then
      if g_MessageMgr:sendPrivateMessage(self.m_CurrChatFriend, chatText) then
        self.input_friendchat:SetFieldText("")
      end
    else
      ShowNotifyTips("请先输入聊天内容")
    end
  else
    ShowNotifyTips("只能跟好友进行聊天")
    self:showRecentlyFriendList()
  end
end
function FriendsDlg:Btn_VoiceFriend(obj, t)
  self.btn_voice_friend:setVisible(false)
  self.btn_voice_friend:setTouchEnabled(false)
  self.btn_keyboard_friend:setVisible(true)
  self.btn_keyboard_friend:setTouchEnabled(true)
  self.input_friendchat:setVisible(false)
  self.input_friendchat:setTouchEnabled(false)
  self.inputbg_friendchat:setVisible(false)
  self.btn_voicepress_friend:setVisible(true)
  self.btn_voicepress_friend:setTouchEnabled(true)
  self.input_friendchat:CloseTheKeyBoard()
end
function FriendsDlg:Btn_KeyBoardFriend(obj, t)
  self.btn_voice_friend:setVisible(true)
  self.btn_voice_friend:setTouchEnabled(true)
  self.btn_keyboard_friend:setVisible(false)
  self.btn_keyboard_friend:setTouchEnabled(false)
  self.input_friendchat:setVisible(true)
  self.input_friendchat:setTouchEnabled(true)
  self.inputbg_friendchat:setVisible(true)
  self.btn_voicepress_friend:setVisible(false)
  self.btn_voicepress_friend:setTouchEnabled(false)
end
function FriendsDlg:Btn_Request()
  if self.list_request:getCount() <= 0 then
    return
  end
  local curTime = cc.net.SocketTCP.getTime()
  if self.btn_clearrequest.__lastClickTime ~= nil and curTime - self.btn_clearrequest.__lastClickTime < 1 then
    return
  end
  self.btn_clearrequest.__lastClickTime = curTime
  netsend.netfriends.clearFriendRequest()
end
function FriendsDlg:Btn_Close(obj, t)
  self:HideDlg()
end
function FriendsDlg:OnClickMessage(obj, msgType, msgPram)
  if msgType == CRichText_MessageType_Item then
    if msgPram then
      local playerId = msgPram.playerId
      local itemId = msgPram.itemId
      local itemTypeId = msgPram.itemTypeId
      self:onCheckItemInMsg(playerId, itemId, itemTypeId)
    end
  elseif msgType == CRichText_MessageType_Pet and msgPram then
    local playerId = msgPram.playerId
    local petId = msgPram.petId
    local petTypeId = msgPram.petTypeId
    self:onCheckPetInMsg(playerId, petId)
  end
end
function FriendsDlg:onCheckItemInMsg(playerId, itemId, itemTypeId)
  print("-->>onCheckItemInMsg:", playerId, itemId, itemTypeId)
  ShowChatDetail_Item(playerId, itemId, itemTypeId)
end
function FriendsDlg:onCheckPetInMsg(playerId, petId)
  print("-->>onCheckPetInMsg:", playerId, petId)
  ShowChatDetail_Pet(playerId, petId)
end
function FriendsDlg:setCheckDetailDlg(dlg)
  if dlg == nil then
    return
  end
  local size = self.m_UINode:getContentSize()
  local x, y = self.m_UINode:getPosition()
  local s = self.m_UINode:getScale()
  dlg:setPosition(ccp(size.width * s, y))
end
function FriendsDlg:Clear()
  self.input_find:ClearTextFieldExtend()
  self.input_friendchat:ClearTextFieldExtend()
  if self.m_FriendChatBox then
    self.m_FriendChatBox:Clear()
  end
  if self.btn_voicepress_friend._VR_ParamFetchFunc then
    self.btn_voicepress_friend._VR_ParamFetchFunc = nil
  end
  if g_FriendsDlg == self then
    g_FriendsDlg = nil
  end
  self:Clear_MailExtend()
end
