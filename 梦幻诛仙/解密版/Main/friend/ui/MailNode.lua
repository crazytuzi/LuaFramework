local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local FriendUtils = require("Main.friend.FriendUtils")
local MailNode = Lplus.Extend(TabNode, "MailNode")
local MailConsts = require("netio.protocol.mzm.gsp.mail.MailConsts")
local MailContent = require("netio.protocol.mzm.gsp.mail.MailContent")
local def = MailNode.define
def.field("table").mailList = nil
def.field("number").curMailId = 0
def.field("number").listOffset = 1
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  local list = self.m_node:FindDirect("Scroll View_Mail/List_Mail")
  local GUIScrollList = list:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    list:AddComponent("GUIScrollList")
  end
  local scroll = self.m_node:FindDirect("Scroll View_Mail"):GetComponent("UIScrollView")
  local listCmp = list:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(listCmp, function(item, i)
    self:FillMailInfo(item, i)
    if scroll and not scroll.isnil then
      scroll:InvalidateBounds()
    end
  end)
  self.m_base.m_msgHandler:Touch(list)
end
def.method().ClearScrollList = function(self)
  local list = self.m_node:FindDirect("Scroll View_Mail/List_Mail")
  if list then
    local listCmp = list:GetComponent("UIScrollList")
    if listCmp then
      ScrollList_clear(listCmp)
    end
  end
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailCountChange, MailNode.OnMailNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailReadStateChange, MailNode.OnMailStateNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, MailNode.OnGangNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.UPDATE_NOTICE, gmodule.notifyId.UpdateNotice.UPDATE_NOTICE_UPDATE, MailNode.OnServerNoticeUpdate, self)
  self:ClearScrollList()
  self:UpdateTitle()
  self:UpdateAutoBtn()
  self:UpdateServerAnno()
  self:UpdateGangAnno()
  self:UpdateMaillList()
  self:ResetScroll()
  self.curMailId = 0
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, MailNode.OnGangNeedUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailCountChange, MailNode.OnMailNeedUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailReadStateChange, MailNode.OnMailStateNeedUpdate)
  Event.UnregisterEvent(ModuleId.UPDATE_NOTICE, gmodule.notifyId.UpdateNotice.UPDATE_NOTICE_UPDATE, MailNode.OnServerNoticeUpdate)
  require("Main.friend.ui.MailInfoPanel").CloseMailInfo()
  require("Main.friend.ui.GangAnnouncementInMailPanel").CloseGangAnnouncementInMailPanel()
end
def.method("table").OnMailNeedUpdate = function(self, params)
  self:UpdateTitle()
  self:UpdateAutoBtn()
  self:UpdateMaillList()
  self:ResetScroll()
end
def.method("table").OnMailStateNeedUpdate = function(self)
  self:UpdateTitle()
  self:UpdateAutoBtn()
  self:UpdateMaillList()
end
def.method("table").OnGangNeedUpdate = function(self, params)
  self:UpdateGangAnno()
  self:UpdateMaillList()
end
def.method("table").OnServerNoticeUpdate = function(self, params)
  self:UpdateServerAnno()
end
def.method().UpdateTitle = function(self)
  local friendData = require("Main.friend.FriendData").Instance()
  local mails = friendData:GetMailCatalog()
  local str = ""
  local unReadMailsNum = friendData:GetUnReadMailsNum()
  if unReadMailsNum > 0 then
    local unReadStr = textRes.Friend[28]:format(unReadMailsNum)
    str = #mails .. "/" .. FriendUtils.GetStoreMax() .. unReadStr
  else
    str = #mails .. "/" .. FriendUtils.GetStoreMax()
  end
  local Label_MailNum = self.m_node:FindDirect("Group_MailTitle/Label_MailNum")
  Label_MailNum:GetComponent("UILabel"):set_text(str)
end
def.method().UpdateAutoBtn = function(self)
  local friendData = require("Main.friend.FriendData").Instance()
  local Btn_Shortcut = self.m_node:FindDirect("Group_MailTitle/Btn_Shortcut")
  local mails = friendData:GetMailCatalog()
  if #mails == 0 then
    Btn_Shortcut:SetActive(false)
    return
  end
  local str = textRes.Friend[29]
  for k, v in pairs(mails) do
    if MailConsts.MAIL_DATA_HAS_THING == v.hasThing then
      str = textRes.Friend[30]
      break
    end
  end
  Btn_Shortcut:SetActive(true)
  local Label_Shortcut = Btn_Shortcut:FindDirect("Label_Shortcut")
  Label_Shortcut:GetComponent("UILabel"):set_text(str)
end
def.method().UpdateServerAnno = function(self)
  local updateNoticeMail = self.m_node:FindDirect("Scroll View_Mail/Img_BgNotice")
  local UpdateNoticeModule = require("Main.UpdateNotice.UpdateNoticeModule")
  local hasRead = UpdateNoticeModule.Instance():HasRead()
  if hasRead == false then
    updateNoticeMail:FindDirect("Img_NewRedPiont01"):SetActive(true)
  else
    updateNoticeMail:FindDirect("Img_NewRedPiont01"):SetActive(false)
  end
  local notice = UpdateNoticeModule.Instance():GetNotice(UpdateNoticeModule.NoticeSceneType.EnterWorldAlert)
  local noticeTitle = textRes.Mail[1]
  updateNoticeMail:FindDirect("Label_Notice"):SetActive(true)
  updateNoticeMail:FindDirect("Label_Notice"):GetComponent("UILabel"):set_text(noticeTitle)
end
def.method().UpdateGangAnno = function(self)
  local Vector = require("Types.Vector")
  local GangModule = require("Main.Gang.GangModule")
  local GangData = require("Main.Gang.data.GangData")
  local gangAnno = self.m_node:FindDirect("Scroll View_Mail/Img_GangNotice")
  local hasGang = GangModule.Instance():HasGang()
  local oldGang = gangAnno:get_activeInHierarchy()
  if hasGang then
    gangAnno:SetActive(true)
    local unRead = GangData.Instance():GetUnReadAnnoNum()
    if unRead > 0 then
      gangAnno:FindDirect("Img_NewRedPion02"):SetActive(true)
    else
      gangAnno:FindDirect("Img_NewRedPion02"):SetActive(false)
    end
    self.listOffset = 2
  else
    gangAnno:SetActive(false)
    self.listOffset = 1
  end
end
def.method().UpdateMaillList = function(self)
  local friendData = require("Main.friend.FriendData").Instance()
  self.mailList = friendData:GetMailCatalog()
  local num = #self.mailList + self.listOffset
  local list = self.m_node:FindDirect("Scroll View_Mail/List_Mail")
  local listCmp = list:GetComponent("UIScrollList")
  ScrollList_setCount(listCmp, num)
end
def.method().ResetScroll = function(self)
  local scroll = self.m_node:FindDirect("Scroll View_Mail")
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not scroll.isnil then
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method("userdata", "number").FillMailInfo = function(self, mailUI, index)
  local mailInfo = self.mailList[index - self.listOffset]
  if mailInfo == nil then
    mailUI:SetActive(false)
    return
  end
  mailUI:SetActive(true)
  local iconSprite = mailUI:FindDirect("Img_IconMail"):GetComponent("UISprite")
  local bRead = mailInfo.readState == MailConsts.MAIL_DATA_STATE_READED
  if bRead then
    FriendUtils.FillIcon("Img_Read", iconSprite, 3)
    mailUI:FindDirect("Img_NewRedPiont"):SetActive(false)
  else
    FriendUtils.FillIcon("Img_unRead", iconSprite, 3)
    mailUI:FindDirect("Img_NewRedPiont"):SetActive(true)
  end
  local bHaveThing = mailInfo.hasThing == MailConsts.MAIL_DATA_HAS_THING
  if bHaveThing then
    mailUI:FindDirect("Img_Attachement"):SetActive(true)
  else
    mailUI:FindDirect("Img_Attachement"):SetActive(false)
  end
  mailUI:FindDirect("Label_MailName"):GetComponent("UILabel"):set_text(mailInfo.title)
  local remainTime, unit = FriendUtils.ComputeMailRemainTime(mailInfo)
  mailUI:FindDirect("Label_MailDate"):GetComponent("UILabel"):set_text(remainTime .. unit)
  if mailInfo.mailIndex == self.curMailId then
    mailUI:GetComponent("UIToggle").value = true
  else
    mailUI:GetComponent("UIToggle").value = false
  end
  self.m_base.m_msgHandler:Touch(mailUI)
end
def.method().OneKeyAllDone = function(self)
  local friendData = require("Main.friend.FriendData").Instance()
  local bHavethings = false
  local swornMgr = require("Main.Sworn.SwornMgr")
  for k, v in pairs(self.mailList) do
    local id = v.mailContent.contentMap[MailContent.CONTENT_MAIL_CFG_ID]
    if id then
      swornMgr.DelSwornVoteMail(tonumber(id))
    end
    if MailConsts.MAIL_DATA_HAS_THING == v.hasThing then
      bHavethings = true
    end
  end
  if bHavethings then
    local ItemModule = require("Main.Item.ItemModule")
    local isBagFull = ItemModule.Instance():IsAnyBagFull()
    if isBagFull > 0 then
      ItemModule.Instance():ToastBagFull(isBagFull)
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.mail.CAutoGetMailReq").new())
  else
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.mail.CAutoDeleteMailReq").new())
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local name = clickobj.name
  if name == "Img_Mail" then
    local item, idx = ScrollList_getItem(clickobj)
    warn("item,idx", item, idx)
    if item then
      self:ReadMail(idx - self.listOffset)
    end
  end
end
def.override("string").onClick = function(self, id)
  if "Img_GangNotice" == id then
    local GangAnnouncementInMailPanel = require("Main.friend.ui.GangAnnouncementInMailPanel")
    GangAnnouncementInMailPanel.ShowGangAnnouncementInMailPanel()
    local gangAnno = self.m_node:FindDirect("Scroll View_Mail/Img_GangNotice")
    gangAnno:FindDirect("Img_NewRedPion02"):SetActive(false)
  elseif "Img_BgNotice" == id then
    local UpdateNoticeModule = require("Main.UpdateNotice.UpdateNoticeModule")
    UpdateNoticeModule.OpenNoticePanel(UpdateNoticeModule.NoticeSceneType.EnterWorldAlert, function(ret)
      if ret == false then
        Toast(textRes.UpdateNotice[1])
      end
    end)
  elseif id == "Btn_Shortcut" then
    self:OneKeyAllDone()
  end
end
def.method("number").ReadMail = function(self, index)
  local mail = self.mailList[index]
  if mail then
    self.curMailId = mail.mailIndex
    local FriendModule = require("Main.friend.FriendModule")
    if mail.contentType == MailContent.TYPE_MAIL_FULL_CFG then
      FriendModule.ReadMail(mail.mailIndex)
    end
    FriendModule.Instance():CReadMaill(mail)
  end
end
def.method("number").ReadMailByMailIndex = function(self, mailIndex)
  for k, v in pairs(self.mailList) do
    if v.mailIndex == mailIndex then
      self:ReadMail(k)
      break
    end
  end
end
MailNode.Commit()
return MailNode
