local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local SLAXML = require("Utility.SLAXML.slaxdom")
local ReportDlg = Lplus.Extend(ECPanelBase, "ReportDlg")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local def = ReportDlg.define
local instance
def.field("table").roleInfo = nil
def.field("table").uiTbl = nil
def.field("number").chatCount = 0
def.field("table").chatMsg = nil
def.const("number").MAXCHATCOUNT = 10
def.const("number").REASONCOUNT = 7
def.const("number").BASE_REASONCOUNT = 5
def.const("number").EXTAND_REPORT_ID = 100
def.static("=>", ReportDlg).Instance = function()
  if instance == nil then
    instance = ReportDlg()
  end
  return instance
end
def.method("table").ShowPanel = function(self, roleInfo)
  if self:IsShow() then
    self:DestroyPanel()
  end
  if roleInfo then
    self.roleInfo = roleInfo
    self:CreatePanel(RESPATH.PREFAB_REPORT_PANEL, 0)
    self:SetDepth(GUIDEPTH.TOP)
    self:SetModal(true)
  end
end
def.method().ClosePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method().Init = function(self)
  local roleInfo = self.roleInfo
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Label_Name = Img_Bg:FindDirect("Group_Name/Label_NameContent")
  local Label_RoleId = Img_Bg:FindDirect("Group_ID/Label_NameContent")
  local Label_Desc = Img_Bg:FindDirect("Group_Info/Group_NameContent/Label_NameContent")
  local Group_Reason = Img_Bg:FindDirect("Group_Reason")
  local Scroll_View = Img_Bg:FindDirect()
  local uiListGO = Img_Bg:FindDirect("Group_Basis/Scroll View/List")
  local Label_Reasons = {}
  for i = 1, ReportDlg.REASONCOUNT do
    Label_Reasons[i] = Group_Reason:FindDirect(string.format("Label_Reason%d/Img_Toggle4", i))
  end
  self.uiTbl = {}
  self.uiTbl.Label_Desc = Label_Desc
  self.uiTbl.Label_Reasons = Label_Reasons
  self.uiTbl.uiListGO = uiListGO
  local HeroUtils = require("Main.Hero.HeroUtility").Instance()
  local roleId = tostring(HeroUtils:RoleIDToDisplayID(roleInfo.roleId))
  Label_Name:GetComponent("UILabel"):set_text(roleInfo.name)
  Label_RoleId:GetComponent("UILabel"):set_text(roleId)
  GUIUtils.Toggle(Label_Reasons[1], true)
  self:SetChatInfo()
end
def.method().SetNewFriendInfo = function(self)
  local roleInfo = self.roleInfo
  local newIdx = self.chatCount + 1
  self.chatMsg[newIdx] = {}
  self.chatMsg[newIdx].content = roleInfo.name
  self.chatMsg[newIdx].mainHtml = string.format(textRes.Friend[68], roleInfo.name)
  self.chatMsg[newIdx].id = ReportDlg.EXTAND_REPORT_ID
  newIdx = newIdx + 1
  local friendData = require("Main.friend.FriendData").Instance()
  local applicantList = friendData:GetApplicantList()
  local countApplicantList = #applicantList
  local radioApplyContent = self.uiTbl.Label_Reasons[7].parent
  radioApplyContent:SetActive(false)
  for i = 1, countApplicantList do
    if applicantList[i].roleId == roleInfo.roleId then
      self.chatMsg[newIdx] = {}
      self.chatMsg[newIdx].content = applicantList[i].content or " "
      self.chatMsg[newIdx].mainHtml = string.format(textRes.Friend[68], applicantList[i].content)
      self.chatMsg[newIdx].id = ReportDlg.EXTAND_REPORT_ID + 1
      radioApplyContent:SetActive(true)
      break
    end
  end
end
def.override().OnCreate = function(self)
  self:Init()
end
def.override().OnDestroy = function(self)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Report" then
    self:OnBtnReportClick()
  else
    local parentName = obj.parent.name
    local s, e = string.find(parentName, "Label_Reason")
    local uiGroupItm = self.uiTbl.uiListGO:FindDirect("Group_Item")
    if s == nil then
      return
    end
    local reasonIdx = tonumber(string.sub(parentName, e + 1, -1))
    if reasonIdx <= ReportDlg.BASE_REASONCOUNT then
      self:SetChatInfo()
      return
    end
    self:setIllgelNewFriendBasis(reasonIdx)
  end
end
def.method().SetChatInfo = function(self)
  local itemCount = 0
  local uiListGO = self.uiTbl.uiListGO
  local roleChatMsg = ChatMsgData.Instance():GetRoleChatRecord(self.roleInfo.roleId)
  if roleChatMsg then
    itemCount = #roleChatMsg
    if itemCount > ReportDlg.MAXCHATCOUNT then
      itemCount = ReportDlg.MAXCHATCOUNT
    end
  end
  self.chatMsg = {}
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local chatMsg = roleChatMsg[i]
    local guiHtml = itemGO:FindDirect(("Label_Reason1_%d"):format(i)):GetComponent("NGUIHTML")
    local Img_Toggle = itemGO:FindDirect(("Img_Toggle4_%d"):format(i))
    self.chatMsg[i] = chatMsg
    guiHtml:ForceHtmlText(chatMsg.mainHtml)
    GUIUtils.Toggle(Img_Toggle, i == 1)
  end
  self.chatCount = itemCount
  self:SetNewFriendInfo()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
  end)
end
def.method("=>", "number").GetSelectReason = function(self)
  for i = 1, ReportDlg.REASONCOUNT do
    if GUIUtils.IsToggle(self.uiTbl.Label_Reasons[i]) then
      return i
    end
  end
  return 0
end
def.method("=>", "table").GetSelectChat = function(self)
  local uiListGO = self.uiTbl.uiListGO
  local listItems = uiListGO:GetComponent("UIList").children
  for i = 1, self.chatCount do
    local Img_Toggle = listItems[i]:FindDirect(("Img_Toggle4_%d"):format(i))
    if GUIUtils.IsToggle(Img_Toggle) then
      return self.chatMsg[i]
    end
  end
  return nil
end
def.method().OnBtnReportClick = function(self)
  local roleInfo = self.roleInfo
  local reasonIndex = self:GetSelectReason()
  local chatMsg
  if reasonIndex > ReportDlg.BASE_REASONCOUNT then
    chatMsg = self.chatMsg[self.chatCount + reasonIndex - ReportDlg.BASE_REASONCOUNT]
  else
    chatMsg = self:GetSelectChat()
  end
  local descInfo = GUIUtils.GetUILabelTxt(self.uiTbl.Label_Desc)
  local Basis
  if not chatMsg or chatMsg == "" then
    Toast(textRes.PubRole[9])
    return
  end
  Basis = tostring(chatMsg.id) .. "#" .. chatMsg.content
  local Octets = require("netio.Octets")
  local p = require("netio.protocol.mzm.gsp.chat.CReportRoleReq").new(roleInfo.roleId, Octets.rawFromString(descInfo or ""), reasonIndex, Octets.rawFromString(Basis or ""))
  gmodule.network.sendProtocol(p)
end
def.method("number").setIllgelNewFriendBasis = function(self, idx)
  local itemCount = 1
  local uiListGO = self.uiTbl.uiListGO
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local msg = self.chatMsg[self.chatCount + idx - ReportDlg.BASE_REASONCOUNT]
    local guiHtml = itemGO:FindDirect(("Label_Reason1_%d"):format(i)):GetComponent("NGUIHTML")
    local Img_Toggle = itemGO:FindDirect(("Img_Toggle4_%d"):format(i))
    guiHtml:ForceHtmlText(msg.mainHtml)
    GUIUtils.Toggle(Img_Toggle, i == 1)
  end
end
return ReportDlg.Commit()
