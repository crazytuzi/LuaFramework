local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local JoinPanel = Lplus.Extend(ECPanelBase, "JoinPanel")
local GangData = require("Main.Gang.data.GangData")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GangCrossUtility = require("Main.GangCross.GangCrossUtility")
local def = JoinPanel.define
local instance
local JOIN_TYPE = {
  GANG_LEVEL = 1,
  GANG_VITALITY = 2,
  GANG_MEMBER_SVRLV = 3,
  GANG_MERGE = 4,
  GANG_MEMBER_COUNT = 5
}
local MSG_LIST = {
  {
    type = JOIN_TYPE.GANG_LEVEL,
    name = string.format(textRes.GangCross[1], constant.GangCrossConsts.Scale)
  },
  {
    type = JOIN_TYPE.GANG_VITALITY,
    name = string.format(textRes.GangCross[2], constant.GangCrossConsts.Liveness)
  },
  {
    type = JOIN_TYPE.GANG_MEMBER_SVRLV,
    name = string.format(textRes.GangCross[3], constant.GangCrossConsts.MinusSeverLevel, constant.GangCrossConsts.PlayerNumberOfQualifiedLevel)
  },
  {
    type = JOIN_TYPE.GANG_MERGE,
    name = string.format(textRes.GangCross[4])
  }
}
def.field("table").uiTbl = nil
def.field("number").actTime = 0
def.static("=>", JoinPanel).Instance = function()
  if not instance then
    instance = JoinPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_CROSS_GANGTEAM, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateUI()
    Timer:RegisterListener(self.UpdateTime, self)
  else
    Timer:RemoveListener(self.UpdateTime)
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Center = Img_Bg:FindDirect("Group_Center")
  local Group_List = Group_Center:FindDirect("Group_List")
  uiTbl.Group_List = Group_List
  local Label_Time = Img_Bg:FindDirect("Group_Bottom/Group_Label/Label_Time")
  uiTbl.Label_Time = Label_Time
end
def.method().Reset = function(self)
end
def.method().UpdateUI = function(self)
  self.actTime = GangCrossUtility.Instance():getActivityWeekBeginTime()
  self:UpdateTime(0)
  self:FillGangList()
end
def.method("number").UpdateTime = function(self, dt)
  local time = 0
  local timeStr
  local actTime = self.actTime
  local nowTime = GetServerTime()
  if actTime > 0 and actTime < nowTime then
    time = nowTime - actTime
    time = constant.GangCrossConsts.SignUpDays * 86400 - time
  end
  if time <= 0 then
    time = 0
  end
  timeStr = GangCrossUtility.Instance():getTimeString(time)
  self.uiTbl.Label_Time:GetComponent("UILabel"):set_text(timeStr or "")
end
def.method().FillGangList = function(self)
  local scrollViewObj = self.uiTbl.Group_List:FindDirect("Scroll View")
  local scrollListObj = scrollViewObj:FindDirect("List_Member")
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    self:FillMsgInfo(item, i, MSG_LIST[i])
  end)
  ScrollList_setCount(uiScrollList, #MSG_LIST)
  self.m_msgHandler:Touch(scrollListObj)
  if bResetScrollView then
    scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
  end
end
def.method("=>", "boolean").IsGangMemberCountForServerLevel = function(self)
  local count = 0
  local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
  local svrLevel = serverLevelData.level - constant.GangCrossConsts.MinusSeverLevel
  local memberList = GangData.Instance():GetMemberList()
  for _, memberInfo in ipairs(memberList) do
    if svrLevel <= memberInfo.level then
      count = count + 1
    end
  end
  return count >= constant.GangCrossConsts.PlayerNumberOfQualifiedLevel
end
def.method("userdata", "number", "table").FillMsgInfo = function(self, memberUI, index, msgInfo)
  local Label_TermName = memberUI:FindDirect("Label_TermName")
  local Img_Right = memberUI:FindDirect("Group_Result/Img_Right")
  local Img_Wrong = memberUI:FindDirect("Group_Result/Img_Wrong")
  Label_TermName:GetComponent("UILabel"):set_text(msgInfo.name)
  local right = false
  if msgInfo.type == JOIN_TYPE.GANG_LEVEL then
    local gangInfo = GangData.Instance():GetGangBasicInfo()
    right = gangInfo.level >= constant.GangCrossConsts.Scale
  elseif msgInfo.type == JOIN_TYPE.GANG_VITALITY then
    local gangInfo = GangData.Instance():GetGangBasicInfo()
    right = gangInfo.vitality >= constant.GangCrossConsts.Liveness
  elseif msgInfo.type == JOIN_TYPE.GANG_MEMBER_SVRLV then
    right = self:IsGangMemberCountForServerLevel()
  elseif msgInfo.type == JOIN_TYPE.GANG_MERGE then
    right = not GangData.Instance():IsBeCombineGang()
  else
    right = false
  end
  Img_Right:SetActive(right)
  Img_Wrong:SetActive(not right)
  local Img_Bg1 = memberUI:FindDirect("Img_Bg1")
  local Img_Bg2 = memberUI:FindDirect("Img_Bg2")
  if index % 2 == 0 then
    Img_Bg1:SetActive(false)
    Img_Bg2:SetActive(true)
  else
    Img_Bg1:SetActive(true)
    Img_Bg2:SetActive(false)
  end
end
def.method().HidePanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Join" then
    self:onBtnJoinClick()
  elseif id == "Btn_Help" then
    self:onBtnHelpClick()
  else
    warn("-------------------- panel click btn:", id)
  end
end
def.static("number", "table").SendSignUpReq = function(i, tag)
  if i == 1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crosscompete.CSignUpReq").new())
  end
end
def.method().onBtnJoinClick = function(self)
  CommonConfirmDlg.ShowConfirm("", textRes.GangCross[17], JoinPanel.SendSignUpReq, {})
end
def.method().onBtnHelpClick = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701609957)
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
return JoinPanel.Commit()
