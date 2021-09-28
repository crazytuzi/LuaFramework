MailView = class("MailView", CcsSubView)
function MailView:ctor()
  MailView.super.ctor(self, "views/mail.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_List = self:getNode("list_main")
  self.m_List:addTouchItemListenerListView(handler(self, self.ChooseItem), handler(self, self.ListEventListener))
  self.txt_loading = self:getNode("txt_loading")
  self.txt_loading:setText("加载中")
  local txt = {
    "加载中.",
    "加载中..",
    "加载中..."
  }
  local idx = -1
  self:runAction(CCRepeatForever:create(transition.sequence({
    CCDelayTime:create(0.8),
    CCCallFunc:create(function()
      idx = (idx + 1) % 3
      self.txt_loading:setText(txt[idx + 1])
    end)
  })))
  self:ListenMessage(MsgID_Mail)
  g_MailMgr:reqGetAllMails()
end
function MailView:OnMessage(msgSID, ...)
  if msgSID == MsgID_Mail_AllMailLoaded then
    self:LoadAllMail()
  elseif msgSID == MsgID_Mail_MailUpdated then
    local arg = {
      ...
    }
    local mailId = arg[1]
    if mailId then
      for idx, mailItem in pairs(self.m_Items) do
        if mailItem:getMailId() == mailId then
          mailItem:reflush()
          break
        end
      end
    end
  elseif msgSID == MsgID_Mail_MailDeleteed then
    local arg = {
      ...
    }
    local mailId = arg[1]
    if mailId then
      local delIdx = -1
      for idx, mailItem in pairs(self.m_Items) do
        if mailItem:getMailId() == mailId then
          delIdx = idx
          break
        end
      end
      if delIdx >= 0 then
        self.m_List:removeItem(self.m_List:getIndex(self.m_Items[delIdx]:getUINode()))
        table.remove(self.m_Items, delIdx)
        self.m_List:sizeChangedForShowMoreTips()
      end
    end
    self:UpdateEmptyTxt()
  end
end
function MailView:LoadAllMail()
  self.txt_loading:setEnabled(false)
  local mails = g_MailMgr:getMails()
  local sortMails = {}
  for k, v in pairs(mails) do
    local d = {}
    for k1, v1 in pairs(v) do
      d[k1] = v1
    end
    d.mailid = k
    sortMails[#sortMails + 1] = d
  end
  if #sortMails > 0 then
    table.sort(sortMails, function(d1, d2)
      if d1 == nil or d2 == nil then
        return false
      end
      if d1.mailid == 0 and d2.mailid ~= 0 then
        return true
      elseif d1.mailid ~= 0 and d2.mailid == 0 then
        return false
      end
      if d1.time and d2.time and d1.time > d2.time then
        return true
      end
      return false
    end)
    self.m_Items = {}
    local idx = 0
    for i, mailInfo in ipairs(sortMails) do
      local item = MainViewItem.new(mailInfo.mailid)
      if item:Init() == true then
        self.m_List:pushBackCustomItem(item:getUINode())
        self.m_Items[idx + 1] = item
        idx = idx + 1
      end
    end
  end
  self:UpdateEmptyTxt()
  self.m_List:sizeChangedForShowMoreTips()
end
function MailView:UpdateEmptyTxt()
  local flag = true
  local mails = g_MailMgr:getMails()
  for k, v in pairs(mails) do
    flag = false
    break
  end
  if flag then
    if self.m_EmptyTxt == nil then
      self.m_EmptyTxt = ui.newTTFLabel({
        text = "(你的邮箱空空如也哟)",
        font = KANG_TTF_FONT,
        size = 24,
        color = ccc3(77, 48, 14)
      })
      self.txt_loading:getParent():addNode(self.m_EmptyTxt, self.txt_loading:getZOrder())
      local x, y = self.txt_loading:getPosition()
      self.m_EmptyTxt:setPosition(ccp(x, y))
    else
      self.m_EmptyTxt:setVisible(true)
    end
  elseif self.m_EmptyTxt ~= nil then
    self.m_EmptyTxt:setVisible(false)
  end
end
function MailView:ChooseItem(item, index, listObj)
  item = self.m_Items[index + 1]
  if item == nil then
    return
  end
  print("==>MailView:ChooseItem:", item:getMailId())
  local mailId = item:getMailId()
  local mailInfo = item:getMailInfo()
  getCurSceneView():addSubView({
    subView = MailDetailView.new(mailId, mailInfo),
    zOrder = MainUISceneZOrder.menuView
  })
end
function MailView:ListEventListener(item, index, listObj, status)
  item = self.m_Items[index + 1]
  if item == nil then
    return
  end
  if status == LISTVIEW_ONSELECTEDITEM_START then
    if item then
      item:setTouchStatus(true)
      self.m_TouchStartItem = item
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
    if self.m_TouchStartItem then
      self.m_TouchStartItem:setTouchStatus(false)
      self.m_TouchStartItem = nil
    end
    if item then
      item:setTouchStatus(false)
    end
  end
end
function MailView:Clear()
  self.m_TouchStartItem = nil
end
function MailView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
