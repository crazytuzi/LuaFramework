local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FriendUtils = require("Main.friend.FriendUtils")
local FriendData = Lplus.ForwardDeclare("FriendData")
local SocialPanel = Lplus.ForwardDeclare("SocialPanel")
local MailShow = Lplus.Class("MailShow")
local ItemModule = require("Main.Item.ItemModule")
local GangModule = require("Main.Gang.GangModule")
local GangData = require("Main.Gang.data.GangData")
local mailConsts = require("netio.protocol.mzm.gsp.mail.MailConsts")
local MailContent = require("netio.protocol.mzm.gsp.mail.MailContent")
local UpdateNoticeModule = require("Main.UpdateNotice.UpdateNoticeModule")
local def = MailShow.define
local instance
def.field("userdata")._panel = nil
def.field(SocialPanel)._base = nil
def.field(FriendData)._friendData = nil
def.field("table").uiTbl = nil
def.field("number").selectMailOnlyIndex = 0
def.static("=>", MailShow).Instance = function(self)
  if nil == instance then
    instance = MailShow()
    instance._friendData = FriendData.Instance()
    instance.uiTbl = {}
  end
  return instance
end
def.method("userdata", SocialPanel).SetPanelAndBase = function(self, panel, base)
  self._panel = panel
  self._base = base
  self:FillMailUI()
end
def.method().FillMailUI = function(self)
  local Group_Mail = self._panel:FindDirect("Img_BgFriend/Widget_Friend/Group_Mail")
  local Group_MailTitle = Group_Mail:FindDirect("Group_MailTitle")
  local Img_MailList = Group_Mail:FindDirect("Img_MailList")
  local ScrollView_Mail = Img_MailList:FindDirect("Scroll View_Mail")
  local Img_BgNotice = ScrollView_Mail:FindDirect("Img_BgNotice")
  local Img_GangNotice = ScrollView_Mail:FindDirect("Img_GangNotice")
  local Grid_MailWithoutGang = ScrollView_Mail:FindDirect("Grid_MailWithoutGang")
  local Grid_MailWithGang = ScrollView_Mail:FindDirect("Grid_MailWithGang")
  self.uiTbl.Group_Mail = Group_Mail
  self.uiTbl.Group_MailTitle = Group_MailTitle
  self.uiTbl.ScrollView_Mail = ScrollView_Mail
  self.uiTbl.Img_BgNotice = Img_BgNotice
  self.uiTbl.Img_GangNotice = Img_GangNotice
  self.uiTbl.Grid_MailWithoutGang = Grid_MailWithoutGang
  self.uiTbl.Grid_MailWithGang = Grid_MailWithGang
end
def.method().FillSyncAnno = function(self)
  local hasRead = UpdateNoticeModule.Instance():HasRead()
  if hasRead == false then
    self.uiTbl.Img_BgNotice:FindDirect("Img_NewRedPiont01"):SetActive(true)
  else
    self.uiTbl.Img_BgNotice:FindDirect("Img_NewRedPiont01"):SetActive(false)
  end
  local notice = UpdateNoticeModule.Instance():GetNotice(UpdateNoticeModule.NoticeSceneType.EnterWorldAlert)
  local noticeTitle = textRes.Mail[1]
  self.uiTbl.Img_BgNotice:FindDirect("Label_Notice"):SetActive(true)
  self.uiTbl.Img_BgNotice:FindDirect("Label_Notice"):GetComponent("UILabel"):set_text(noticeTitle)
end
def.method().UpdateUnRead = function(self)
  local mails = self._friendData:GetMailCatalog()
  local str = #mails .. "/" .. FriendUtils.GetStoreMax()
  local unReadMailsNum = self._friendData:GetUnReadMailsNum()
  if unReadMailsNum > 0 then
    str = unReadMailsNum .. textRes.Friend[28] .. #mails .. "/" .. FriendUtils.GetStoreMax()
  end
  local Label_MailNum = self.uiTbl.Group_MailTitle:FindDirect("Label_MailNum")
  Label_MailNum:GetComponent("UILabel"):set_text(str)
end
def.method("=>", "userdata").GetGridTemplate = function(self)
  local gridTemplate = self.uiTbl.Grid_MailWithoutGang
  self.uiTbl.Img_GangNotice:SetActive(false)
  self.uiTbl.Grid_MailWithGang:SetActive(false)
  if GangModule.Instance():HasGang() then
    gridTemplate = self.uiTbl.Grid_MailWithGang
    self.uiTbl.Img_GangNotice:SetActive(true)
    local data = GangData.Instance()
    local unRead = data:GetUnReadAnnoNum()
    self:OnAnnouncementsChanged(unRead)
    self.uiTbl.Grid_MailWithoutGang:SetActive(false)
  end
  gridTemplate:SetActive(true)
  return gridTemplate
end
def.method("number").OnAnnouncementsChanged = function(self, unRead)
  if unRead > 0 then
    self.uiTbl.Img_GangNotice:FindDirect("Img_NewRedPion02"):SetActive(true)
  else
    self.uiTbl.Img_GangNotice:FindDirect("Img_NewRedPion02"):SetActive(false)
  end
end
def.method().ClearMails = function(self)
  local gridTemplate = self:GetGridTemplate()
  local allNum = gridTemplate:get_childCount()
  FriendUtils.ClearList(gridTemplate, allNum)
end
def.method().UpdateMailReadPointAttach = function(self)
  local mails = self._friendData:GetMailCatalog()
  local gridTemplate = self:GetGridTemplate()
  self:FillList(mails, gridTemplate)
end
def.method().ShowMailsList = function(self)
  self:FillSyncAnno()
  self:UpdateAutoButtonLabel()
  local gridTemplate = self:GetGridTemplate()
  local mails = self._friendData:GetMailCatalog()
  local Label_MailNum = self.uiTbl.Group_MailTitle:FindDirect("Label_MailNum")
  local str = #mails .. "/" .. FriendUtils.GetStoreMax()
  if 0 == #mails then
    Label_MailNum:GetComponent("UILabel"):set_text(str)
    GameUtil.AddGlobalTimer(0.1, true, function()
      if self._base.m_panel and false == self._base.m_panel.isnil then
        self.uiTbl.ScrollView_Mail:GetComponent("UIScrollView"):ResetPosition()
      end
    end)
  end
  local unReadMailsNum = self._friendData:GetUnReadMailsNum()
  if unReadMailsNum > 0 then
    str = unReadMailsNum .. textRes.Friend[28] .. #mails .. "/" .. FriendUtils.GetStoreMax()
  end
  Label_MailNum:GetComponent("UILabel"):set_text(str)
  self:FillList(mails, gridTemplate)
  self._base:TouchGameObject(self._base.m_panel, self._base.m_parent)
  GameUtil.AddGlobalTimer(0.3, true, function()
    if self._base.m_panel and false == self._base.m_panel.isnil then
      self.uiTbl.ScrollView_Mail:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method("table", "userdata").FillList = function(self, list, gridTemplate)
  local listNum = #list
  local uiList = gridTemplate:GetComponent("UIList")
  uiList:set_itemCount(listNum)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local mailsUI = uiList:get_children()
  for i = 1, #mailsUI do
    local mailUI = mailsUI[i]
    local mailInfo = list[i]
    self:FillMailInfo(mailUI, i, mailInfo)
  end
  self._base:TouchGameObject(self._base.m_panel, self._base.m_parent)
end
def.method("userdata", "number", "table").FillMailInfo = function(self, mailUI, index, mailInfo)
  local Img_MailGang = mailUI:FindDirect(string.format("Img_MailGang_%d", index))
  local iconSprite = Img_MailGang:FindDirect(string.format("Img_IconMail_%d", index)):GetComponent("UISprite")
  local bRead = mailInfo.readState == mailConsts.MAIL_DATA_STATE_READED
  if bRead then
    FriendUtils.FillIcon("Img_Read", iconSprite, 3)
    Img_MailGang:FindDirect(string.format("Img_NewRedPiont_%d", index)):SetActive(false)
  else
    FriendUtils.FillIcon("Img_unRead", iconSprite, 3)
    Img_MailGang:FindDirect(string.format("Img_NewRedPiont_%d", index)):SetActive(true)
  end
  local bHaveThing = mailInfo.hasThing == mailConsts.MAIL_DATA_HAS_THING
  if bHaveThing then
    Img_MailGang:FindDirect(string.format("Img_Attachement_%d", index)):SetActive(true)
  else
    Img_MailGang:FindDirect(string.format("Img_Attachement_%d", index)):SetActive(false)
  end
  Img_MailGang:FindDirect(string.format("Label_MailName_%d", index)):GetComponent("UILabel"):set_text(mailInfo.title)
  local remainTime, unit = FriendUtils.ComputeMailRemainTime(mailInfo)
  Img_MailGang:FindDirect(string.format("Label_MailDate_%d", index)):GetComponent("UILabel"):set_text(remainTime .. unit)
  if mailInfo.mailIndex == self.selectMailOnlyIndex then
    Img_MailGang:GetComponent("UIToggle"):set_isChecked(true)
  else
    Img_MailGang:GetComponent("UIToggle"):set_isChecked(false)
  end
end
def.method().SucceedAttach = function(self)
  local gridTemplate = self:GetGridTemplate()
  local index = self._friendData:GetMailIndexByOnly(self.selectMailOnlyIndex)
  if index == 0 then
    return
  end
  local haveCount = gridTemplate:get_childCount()
  if index <= haveCount then
    local Img_MailGang = gridTemplate:GetChild(index):FindDirect(string.format("Img_MailGang_%d", index))
    Img_MailGang:FindDirect(string.format("Img_Attachement_%d", index)):SetActive(false)
  end
  self:UpdateAutoButtonLabel()
end
def.method().SucceedRead = function(self)
  local gridTemplate = self:GetGridTemplate()
  local index = self._friendData:GetMailIndexByOnly(self.selectMailOnlyIndex)
  if index == 0 then
    return
  end
  local haveCount = gridTemplate:get_childCount()
  if index <= haveCount then
    local Img_MailGang = gridTemplate:GetChild(index):FindDirect(string.format("Img_MailGang_%d", index))
    local iconSprite = Img_MailGang:FindDirect(string.format("Img_IconMail_%d", index)):GetComponent("UISprite")
    FriendUtils.FillIcon("Img_Read", iconSprite, 3)
    Img_MailGang:FindDirect(string.format("Img_NewRedPiont_%d", index)):SetActive(false)
  end
end
def.method().UpdateMailRemainTime = function(self)
  local mails = self._friendData:GetMailCatalog()
  if nil == self._panel or self._panel.isnil or false == self.uiTbl.Group_Mail:get_activeInHierarchy() or 0 == #mails then
    return
  end
  local gridTemplate = self:GetGridTemplate()
  local haveCount = gridTemplate:get_childCount()
  for i = 1, #mails do
    if i <= haveCount then
      local mail = gridTemplate:GetChild(i)
      local remainTime, unit = FriendUtils.ComputeMailRemainTime(mails[i])
      local Img_MailGang = mail:FindDirect(string.format("Img_MailGang_%d", i))
      Img_MailGang:FindDirect(string.format("Label_MailDate_%d", i)):GetComponent("UILabel"):set_text(remainTime .. unit)
    end
  end
end
def.method("table", "=>", "boolean").IsSpecialCfgMail = function(self, mail)
  local id = tonumber(mail.mailContent.contentMap[MailContent.CONTENT_MAIL_CFG_ID])
  local swornMgr = require("Main.Sworn.SwornMgr")
  if id and swornMgr.GetSwornVoteMail(id, mail.mailIndex) then
    return true
  end
  return false
end
def.method("number").ShowSelectMailDetail = function(self, index)
  local gridTemplate = self:GetGridTemplate()
  local haveCount = gridTemplate:get_childCount()
  local mails = self._friendData:GetMailCatalog()
  local mail = mails[index]
  if index <= haveCount and mail ~= nil then
    local groupCount = gridTemplate:get_childCount()
    if index < groupCount then
      local Img_MailGang = gridTemplate:GetChild(index):FindDirect(string.format("Img_MailGang_%d", index))
      Img_MailGang:GetComponent("UIToggle"):set_isChecked(true)
      self.selectMailOnlyIndex = mail.mailIndex
      if mail.contentType == MailContent.TYPE_MAIL_FULL_CFG then
        require("Main.friend.FriendModule").ReadMail(mail.mailIndex)
      end
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.mail.CReadMailReq").new(mail.mailIndex))
    end
  end
end
def.method("number").SelectMailByMailIndex = function(self, mailIndex)
  local mails = self._friendData:GetMailCatalog()
  for k, v in pairs(mails) do
    if v.mailIndex == mailIndex then
      self:ShowSelectMailDetail(k)
      break
    end
  end
end
def.method().UpdateAutoButtonLabel = function(self)
  local Btn_Shortcut = self.uiTbl.Group_MailTitle:FindDirect("Btn_Shortcut")
  local mails = self._friendData:GetMailCatalog()
  if #mails == 0 then
    Btn_Shortcut:SetActive(false)
    return
  end
  local str = textRes.Friend[29]
  for k, v in pairs(mails) do
    if mailConsts.MAIL_DATA_HAS_THING == v.hasThing then
      str = textRes.Friend[30]
      break
    end
  end
  Btn_Shortcut:SetActive(true)
  local Label_Shortcut = Btn_Shortcut:FindDirect("Label_Shortcut")
  Label_Shortcut:GetComponent("UILabel"):set_text(str)
end
def.method().GetNewGangMsg = function(self)
  self.uiTbl.Img_GangNotice:SetActive(true)
  self:ShowMailsList()
end
def.method().Clear = function(self)
  self.selectMailOnlyIndex = 0
  self:ClearMails()
end
def.method().OnAutoButtonClick = function(self)
  local bHavethings = false
  local mails = self._friendData:GetMailCatalog()
  local swornMgr = require("Main.Sworn.SwornMgr")
  for k, v in pairs(mails) do
    local id = v.mailContent.contentMap[MailContent.CONTENT_MAIL_CFG_ID]
    if id then
      swornMgr.DelSwornVoteMail(tonumber(id))
    end
    if mailConsts.MAIL_DATA_HAS_THING == v.hasThing then
      bHavethings = true
    end
  end
  if bHavethings then
    local bagId = require("netio.protocol.mzm.gsp.item.BagInfo").BAG
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
MailShow.Commit()
return MailShow
