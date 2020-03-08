local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FriendUtils = require("Main.friend.FriendUtils")
local Vector = require("Types.Vector")
local FriendData = Lplus.ForwardDeclare("FriendData")
local SocialPanel = Lplus.ForwardDeclare("SocialPanel")
local FriendListShow = Lplus.Class("FriendListShow")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local mailConsts = require("netio.protocol.mzm.gsp.mail.MailConsts")
local UpdateNoticeModule = require("Main.UpdateNotice.UpdateNoticeModule")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local def = FriendListShow.define
local instance
def.field("userdata")._panel = nil
def.field(SocialPanel)._base = nil
def.field(FriendData)._friendData = nil
def.field("number")._applyLastNum = 0
def.static("=>", FriendListShow).Instance = function(self)
  if nil == instance then
    instance = FriendListShow()
    instance._friendData = FriendData.Instance()
  end
  return instance
end
def.method("userdata", SocialPanel).SetPanelAndBase = function(self, panel, base)
  self._panel = panel
  self._base = base
end
def.method().UpdateNewApplicantName = function(self)
  local applyList = self._friendData:GetApplicantList()
  local applyEntrance = self._panel:FindDirect("Img_BgFriend/Widget_Friend/Img_FriendList/Scroll View_Friend/Img_BgApplyEntrance")
  applyEntrance:FindDirect("Label_PlayerNameEntrance"):GetComponent("UILabel"):set_text(applyList[#applyList].roleName .. textRes.Friend[13])
end
def.method("userdata").ClearFriendList = function(self, gridTemplate)
  local haveCount = gridTemplate:get_childCount()
  FriendUtils.ClearList(gridTemplate, haveCount)
end
def.method().Clear = function(self)
  local gridTemplate = self:GetFriendListTemplate()
  self:ClearFriendList(gridTemplate)
  self._applyLastNum = 0
end
def.method().UpdateFriendGrid = function(self)
  local scrollView = self._panel:FindDirect("Img_BgFriend/Widget_Friend/Img_FriendList/Scroll View_Friend")
  scrollView:FindDirect("Grid_FriendWithApply"):SetActive(false)
  scrollView:FindDirect("Grid_FriendWithoutApply"):SetActive(false)
  if 0 == #self._friendData:GetApplicantList() then
    if 0 < #self._friendData:GetFriendList() or 0 < #ChatModule.Instance():GetStrangerChat() then
      scrollView:FindDirect("Grid_FriendWithoutApply"):SetActive(true)
    end
  elseif 0 < #self._friendData:GetFriendList() or 0 < #ChatModule.Instance():GetStrangerChat() then
    scrollView:FindDirect("Grid_FriendWithApply"):SetActive(true)
  end
end
def.method().ShowMainFriendList = function(self)
  local WidgetFriend = self._panel:FindDirect("Img_BgFriend/Widget_Friend")
  local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
  WidgetFriend:FindDirect("Img_BgApply"):SetActive(false)
  WidgetFriend:FindDirect("Img_BgBlock"):SetActive(false)
  self:HideSearchInfo()
  self:UpdateUnRead()
  local applyEntrance = FriendListImg:FindDirect("Scroll View_Friend/Img_BgApplyEntrance")
  if 0 == #self._friendData:GetApplicantList() then
    applyEntrance:SetActive(false)
  else
    applyEntrance:SetActive(true)
    applyEntrance:FindDirect("Img_NewRedPiont002"):SetActive(true)
    applyEntrance:FindDirect("Img_NewRedPiont002/Label_NewRedPiont002"):GetComponent("UILabel"):set_text(string.format("%d", #self._friendData:GetApplicantList()))
    self:UpdateNewApplicantName()
  end
  self:UpdateFriendGrid()
  self:UpdateFriendList()
end
def.method().UpdateUnRead = function(self)
  local scrollView = self._panel:FindDirect("Img_BgFriend/Widget_Friend/Img_FriendList/Scroll View_Friend")
  local Img_BgMail = scrollView:FindDirect("Img_BgMail")
  local Label_TitleMail = Img_BgMail:FindDirect("Label_TitleMail")
  local Img_NewRedPiont001 = Img_BgMail:FindDirect("Img_NewRedPiont001")
  local Label_NewRedPiont001 = Img_NewRedPiont001:FindDirect("Label_NewRedPiont001")
  local mails = self._friendData:GetMailCatalog()
  if #mails > 0 then
    Label_TitleMail:GetComponent("UILabel"):set_text(mails[1].title)
  else
    Label_TitleMail:GetComponent("UILabel"):set_text("")
  end
  local hasRead = UpdateNoticeModule.Instance():HasRead()
  local unReadMailsNum = self._friendData:GetUnReadMailsNum()
  local gangUnRead = require("Main.Gang.data.GangData").Instance():GetUnReadAnnoNum() or 0
  unReadMailsNum = unReadMailsNum + gangUnRead
  if hasRead == false then
    unReadMailsNum = unReadMailsNum + 1
  end
  if unReadMailsNum > 0 then
    Img_NewRedPiont001:SetActive(true)
    local str = unReadMailsNum
    if unReadMailsNum > 99 then
      str = 99 .. "+"
    end
    Label_NewRedPiont001:GetComponent("UILabel"):set_text(str)
  else
    Img_NewRedPiont001:SetActive(false)
  end
end
def.method("=>", "userdata").GetFriendListTemplate = function(self)
  local gridTemplate
  local WidgetFriend = self._panel:FindDirect("Img_BgFriend/Widget_Friend")
  local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
  local scrollView = FriendListImg:FindDirect("Scroll View_Friend")
  if 0 == #self._friendData:GetApplicantList() then
    gridTemplate = scrollView:FindDirect("Grid_FriendWithoutApply")
  else
    gridTemplate = scrollView:FindDirect("Grid_FriendWithApply")
  end
  if FriendListImg:get_activeInHierarchy() then
    gridTemplate:GetChild(0):SetActive(true)
  else
    gridTemplate:GetChild(0):SetActive(false)
  end
  return gridTemplate
end
def.method().UpdateFriendList = function(self)
  local gridTemplate = self:GetFriendListTemplate()
  self:CreateFriendList(gridTemplate)
end
def.method("userdata").CreateFriendList = function(self, gridTemplate)
  local allFriends = self._friendData:GetAllFriends()
  self:FillList(allFriends, gridTemplate)
  local WidgetFriend = self._panel:FindDirect("Img_BgFriend/Widget_Friend")
  local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
  local scrollView = FriendListImg:FindDirect("Scroll View_Friend")
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self._base.m_panel and false == self._base.m_panel.isnil then
      scrollView:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method("table", "userdata").FillList = function(self, showList, gridTemplate)
  local listNum = #showList
  local uiList = gridTemplate:GetComponent("UIList")
  uiList:set_itemCount(listNum)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local friendsUI = uiList:get_children()
  for i = 1, #friendsUI do
    local friendUI = friendsUI[i]
    local friendInfo = showList[i]
    self:FillFriendInfo(friendUI, i, friendInfo)
  end
  self._base.m_msgHandler:Touch(gridTemplate)
end
def.method("userdata", "userdata", "number").UpdateFriendMsg = function(self, roleId, friendUI, index)
  local chatInfo = ChatModule.Instance():GetFriendNewOne(roleId)
  local timeStr = ""
  if nil ~= chatInfo and nil ~= chatInfo.time then
    local cur = os.date("*t", GetServerTime())
    local last = os.date("*t", chatInfo.time)
    if cur.day ~= last.day or cur.month ~= last.month or cur.year ~= last.year then
      timeStr = string.format("%d-%d-%d", last.year, last.month, last.day)
    else
      timeStr = os.date("%X", chatInfo.time)
    end
  end
  friendUI:FindDirect(string.format("Label_Time_%d", index)):GetComponent("UILabel"):set_text(timeStr)
  local chatContent = ""
  if nil == chatInfo then
    chatContent = ""
  else
    chatContent = chatInfo.plainHtml
    if chatContent ~= nil then
      chatContent = require("Main.Chat.HtmlHelper").ConvertFriendChat(chatContent)
    end
  end
  local newPoint = friendUI:FindDirect(string.format("Img_NewRedPiont_%d", index))
  local msgCount = ChatModule.Instance():GetChatNewCount(roleId)
  local name = friendUI:FindDirect(string.format("Label_FriendName_%d", index)):GetComponent("UILabel"):get_text()
  if nil ~= chatInfo and nil ~= chatContent and msgCount > 0 then
    newPoint:SetActive(true)
    newPoint:FindDirect(string.format("Label_NewRedPiont_%d", index)):GetComponent("UILabel"):set_text(msgCount)
  else
    newPoint:SetActive(false)
  end
  if nil ~= chatContent then
    local quickCnt = friendUI:FindDirect(string.format("Label_WordPreview_%d", index))
    quickCnt:SetActive(true)
    quickCnt:GetComponent("NGUIHTML"):ForceHtmlText(chatContent)
  else
    friendUI:FindDirect(string.format("Label_WordPreview_%d", index)):SetActive(false)
  end
end
def.method("userdata", "number", "table").FillFriendInfo = function(self, friendUI, index, friendInfo)
  local tbl = {
    level = string.format("Label_Num_%d", index),
    name = string.format("Label_FriendName_%d", index),
    icon = string.format("Img_IconHead_%d", index),
    occupation = string.format("Img_School_%d", index),
    cover = string.format("Img_Cover_%d", index),
    offlineIcon = string.format("Img_OffLine_%d", index)
  }
  local friendBasicUI = friendUI:FindDirect(string.format("Scroll View_%d", index)):FindDirect(string.format("Img_BgFriend_%d", index))
  local bOnline = require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_ONLINE == friendInfo.onlineStatus
  FriendUtils.FillBasicInfo(friendBasicUI, tbl, friendInfo, bOnline)
  self:UpdateFriendMsg(friendInfo.roleId, friendBasicUI, index)
end
def.method().HideSearchInfo = function(self)
  local WidgetFriend = self._panel:FindDirect("Img_BgFriend/Widget_Friend")
  local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
  FriendListImg:FindDirect("Img_BgSearch"):SetActive(true)
  FriendListImg:FindDirect("Img_BgSearch"):FindDirect("Img_BgInput"):SetActive(true)
  FriendListImg:FindDirect("Img_BgSearch"):FindDirect("Img_BgSearchShort/Img_BgSearchInput"):GetComponent("UIInput"):set_value("")
  FriendListImg:FindDirect("Img_BgSearch"):FindDirect("Img_BgSearchShort"):SetActive(false)
  FriendListImg:FindDirect("Img_BgSearchFriend"):SetActive(false)
end
def.method("=>", "number").GetApplyLastNum = function(self)
  return self._applyLastNum
end
def.method("number").SetApplyLastNum = function(self, num)
  self._applyLastNum = num
end
def.method().CheckNewApply = function(self)
  local WidgetFriend = self._panel:FindDirect("Img_BgFriend/Widget_Friend")
  local FriendListImg = WidgetFriend:FindDirect("Img_FriendList")
  local scrollView = FriendListImg:FindDirect("Scroll View_Friend")
  local gridTemplate2 = scrollView:FindDirect("Grid_FriendWithoutApply")
  local gridTemplate1 = scrollView:FindDirect("Grid_FriendWithApply")
  local applyEntrance = scrollView:FindDirect("Img_BgApplyEntrance")
  local curNum = #self._friendData:GetApplicantList()
  if 1 == self._applyLastNum and 0 == curNum then
    applyEntrance:SetActive(false)
    gridTemplate1:SetActive(false)
    gridTemplate2:SetActive(true)
    self:ClearFriendList(gridTemplate1)
    self:CreateFriendList(gridTemplate2)
  elseif 1 == curNum and 0 == self._applyLastNum then
    gridTemplate2:SetActive(false)
    applyEntrance:SetActive(true)
    gridTemplate1:SetActive(true)
    self:UpdateNewApplicantName()
    self:ClearFriendList(gridTemplate2)
    self:CreateFriendList(gridTemplate1)
  end
  local strApply = textRes.Friend[12] .. curNum
  local ApplyImg = WidgetFriend:FindDirect("Img_BgApply")
  local ApplyTitle = ApplyImg:FindDirect("Img_BgFriendApplyTitle")
  ApplyTitle:FindDirect("Btn_BackToFriend01/Label_BackToFriend01"):GetComponent("UILabel"):set_text(strApply)
  local applyEntrance = FriendListImg:FindDirect("Scroll View_Friend/Img_BgApplyEntrance")
  if curNum > 0 then
    applyEntrance:FindDirect("Img_NewRedPiont002"):SetActive(true)
    applyEntrance:FindDirect("Img_NewRedPiont002/Label_NewRedPiont002"):GetComponent("UILabel"):set_text(curNum)
  else
    applyEntrance:FindDirect("Img_NewRedPiont002"):SetActive(false)
  end
end
FriendListShow.Commit()
return FriendListShow
