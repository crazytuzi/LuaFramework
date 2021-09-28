MainViewItem = class("MainViewItem", CcsSubView)
function MainViewItem:ctor(mailId)
  MainViewItem.super.ctor(self, "views/mail_item.json")
  self.m_MainId = mailId
  self.m_MailState_NotRead = self:getNode("pic_item")
  self:ListenMessage(MsgID_Mail)
end
function MainViewItem:getMailInfo()
  return self.m_mailInfo
end
function MainViewItem:getMailId()
  return self.m_MainId
end
function MainViewItem:getIsRead()
  return self.m_IsRead
end
function MainViewItem:Init()
  local mailInfo = g_MailMgr:getMailInfo(self.m_MainId)
  if mailInfo == nil then
    return false
  end
  self.m_mailInfo = mailInfo
  local title = mailInfo.title or "新邮件"
  local sender = mailInfo.sender or "系统"
  local sendTime = mailInfo.time
  self.m_BgPic = self:getNode("bg")
  self:getNode("txt_title"):setVisible(false)
  local bgSize = self.m_BgPic:getContentSize()
  local p = self:getNode("txt_title"):getParent()
  local txt_title = CRichText.new({
    width = bgSize.width - 130,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 20,
    color = ccc3(255, 255, 255),
    align = CRichText_AlignType_Left,
    maxLineNum = 1
  })
  txt_title:addRichText(title or "")
  local x, y = self:getNode("txt_title"):getPosition()
  local titleTxtSize = txt_title:getRichTextSize()
  txt_title:setPosition(ccp(x, y - titleTxtSize.height / 2))
  p:addChild(txt_title)
  self:getNode("txt_sender"):setText(string.format("发件人:%s", sender))
  self:getNode("txt_delTime"):setEnabled(false)
  if sendTime then
    local month = checkint(os.date("%m", sendTime))
    local year = checkint(os.date("%Y", sendTime))
    local day = checkint(os.date("%d", sendTime))
    self:getNode("txt_time"):setText(string.format("%d年%02d月%02d日", year, month, day))
    local restSeconds = sendTime + 864000 - os.time()
    if restSeconds > 0 and self.m_MainId ~= 0 then
      local restDay = math.ceil(restSeconds / 3600 / 24)
      if restDay > 10 then
        restDay = 10
      elseif restDay < 1 then
        restDay = 1
      end
      self:getNode("txt_delTime"):setText(string.format("邮件保留:%d天", restDay))
      self:getNode("txt_delTime"):setEnabled(true)
    end
  else
    self:getNode("txt_time"):setEnabled(false)
  end
  self:reflush()
  return true
end
function MainViewItem:reflush()
  local mailInfo = g_MailMgr:getMailInfo(self.m_MainId)
  if mailInfo == nil then
    return
  end
  self.m_mailInfo = mailInfo
  self.m_IsRead = self.m_mailInfo.isread
  local isShowReadImg = false
  if self.m_IsRead then
    self.m_MailState_NotRead:setEnabled(false)
    isShowReadImg = true
  else
    self.m_MailState_NotRead:setEnabled(true)
    isShowReadImg = false
  end
  if isShowReadImg == false then
    if self.m_MailState_Read then
      self.m_MailState_Read:setVisible(false)
    end
  elseif self.m_MailState_Read then
    self.m_MailState_Read:setVisible(true)
  else
    self.m_MailState_Read = display.newSprite("views/pic/pic_mail_read.png")
    self.m_MailState_NotRead:getParent():addNode(self.m_MailState_Read, self.m_MailState_NotRead:getZOrder())
    local x, y = self.m_MailState_NotRead:getPosition()
    self.m_MailState_Read:setPosition(ccp(x, y))
  end
end
function MainViewItem:setTouchStatus(isTouch)
  print("setTouchStatus:", isTouch)
  self.m_BgPic:stopAllActions()
  if isTouch then
    self.m_BgPic:setScaleX(0.95)
    self.m_BgPic:setScaleY(0.95)
  else
    self.m_BgPic:setScaleX(1)
    self.m_BgPic:setScaleY(1)
    self.m_BgPic:runAction(transition.sequence({
      CCScaleTo:create(0.1, 1, 1)
    }))
  end
end
function MainViewItem:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Mail_MailUpdated then
    local mailID = arg[1]
    if mailID == self.m_MainId then
      self:reflush()
    end
  end
end
