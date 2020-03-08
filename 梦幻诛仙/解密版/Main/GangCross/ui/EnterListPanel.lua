local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local EnterListPanel = Lplus.Extend(ECPanelBase, "EnterListPanel")
local GangCrossData = require("Main.GangCross.data.GangCrossData")
local GangCrossUtility = require("Main.GangCross.GangCrossUtility")
local def = EnterListPanel.define
local instance
def.field("table").uiTbl = nil
def.field("table").gangList = nil
def.field("number").actTime = 0
def.field("boolean").findSelfGang = false
def.static("=>", EnterListPanel).Instance = function()
  if not instance then
    instance = EnterListPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, gangList)
  self.gangList = gangList
  if self:IsShow() then
    self:UpdateUI()
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_CROSS_GANG, 1)
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
  local Group_Time = Img_Bg:FindDirect("Group_Bottom/Group_Label")
  local Label_Time = Group_Time:FindDirect("Label_Time")
  uiTbl.Group_Time = Group_Time
  uiTbl.Label_Time = Label_Time
  local Label_Tips = Img_Bg:FindDirect("Group_Bottom/Label_Tips")
  uiTbl.Label_Tips = Label_Tips
  local Group_Empty = Img_Bg:FindDirect("Group_Center/Group_Empty")
  uiTbl.Group_Empty = Group_Empty
  local Btn_Join = Img_Bg:FindDirect("Group_Bottom/Btn_Join")
  uiTbl.Btn_Join = Btn_Join
end
def.method().Reset = function(self)
end
def.method().UpdateUI = function(self)
  do
    local ownGangIndex = 0
    local gangList = self.gangList
    local zoneId = require("netio.Network").m_zoneid or 0
    local gangId = require("Main.Gang.data.GangData").Instance():GetGangId()
    if gangId then
      for k, v in ipairs(gangList) do
        if Int64.eq(v.factionid, gangId) then
          ownGangIndex = k
          break
        end
      end
    end
    if ownGangIndex > 0 then
      local tmp = gangList[1]
      gangList[1] = gangList[ownGangIndex]
      gangList[ownGangIndex] = tmp
      self.findSelfGang = true
    else
      self.findSelfGang = false
    end
  end
  self.actTime = GangCrossUtility.Instance():getActivityWeekBeginTime()
  self:UpdateTime(0)
  self:FillGangList()
  self.uiTbl.Btn_Join:SetActive(not self.findSelfGang)
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
    self.uiTbl.Btn_Join:SetActive(false)
    self.uiTbl.Group_Time:SetActive(false)
    self.uiTbl.Label_Tips:SetActive(true)
    self.uiTbl.Label_Tips:GetComponent("UILabel"):set_text(textRes.GangCross[31] or "")
  else
    self.uiTbl.Btn_Join:SetActive(true)
    self.uiTbl.Group_Time:SetActive(true)
    self.uiTbl.Label_Tips:SetActive(false)
    timeStr = GangCrossUtility.Instance():getTimeString(time)
    self.uiTbl.Label_Time:GetComponent("UILabel"):set_text(timeStr or "")
  end
end
def.method().FillGangList = function(self)
  local gangList = self.gangList
  self.uiTbl.Group_Empty:SetActive(#gangList < 1)
  local scrollViewObj = self.uiTbl.Group_List:FindDirect("Scroll View")
  local scrollListObj = scrollViewObj:FindDirect("List_Member")
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    self:FillGangInfo(item, i, gangList[i])
  end)
  ScrollList_setCount(uiScrollList, #gangList)
  self.m_msgHandler:Touch(scrollListObj)
  if bResetScrollView then
    scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
  end
end
def.method("userdata", "number", "table").FillGangInfo = function(self, memberUI, index, gangInfo)
  local Label_GangName = memberUI:FindDirect("Label_GangName")
  local Label_GangKing = memberUI:FindDirect("Label_GangKing")
  Label_GangName:GetComponent("UILabel"):set_text(gangInfo.faction_name)
  Label_GangKing:GetComponent("UILabel"):set_text(gangInfo.leader_name)
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
def.method().onBtnJoinClick = function(self)
  if GangCrossData.Instance():getCrossGangBattleState() then
    Toast(textRes.GangCross[14])
  else
    local bCanSignUp = false
    local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
    local memberInfo = require("Main.Gang.data.GangData").Instance():GetMemberInfoByRoleId(heroProp.id)
    if memberInfo then
      local tbl = require("Main.Gang.GangUtility").GetAuthority(memberInfo.duty)
      bCanSignUp = tbl.canSignUpCrossCompete
    end
    if bCanSignUp then
      self:DestroyPanel()
      require("Main.GangCross.ui.JoinPanel").Instance():ShowPanel()
    else
      Toast(textRes.GangCross[13])
    end
  end
end
def.method().onBtnHelpClick = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701609956)
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
return EnterListPanel.Commit()
