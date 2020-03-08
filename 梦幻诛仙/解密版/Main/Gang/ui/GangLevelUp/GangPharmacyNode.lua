local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GangPharmacyNode = Lplus.Extend(TabNode, "GangPharmacyNode")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GangBuildingEnum = require("netio.protocol.mzm.gsp.gang.GangBuildingEnum")
local def = GangPharmacyNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:FillAllInfo()
end
def.method().FillAllInfo = function(self)
  self:FillDefault()
  self:FillLevelUpInfo()
end
def.method().FillDefault = function(self)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local gangTbl = GangUtility.GetGangCfg(gangInfo.level)
  local Label_Lv = self.m_node:FindDirect("Label1/Label2"):GetComponent("UILabel")
  Label_Lv:set_text(gangInfo.pharmacyLevel)
  local Group_Cost = self.m_node:FindDirect("Group_Cost")
  local Group_NextLevel = self.m_node:FindDirect("Group_NextLevel")
  local Goup_Manji = self.m_node:FindDirect("Goup_Manji")
  if gangInfo.pharmacyLevel >= gangTbl.yaoDianMaxLevel then
    Group_NextLevel:SetActive(false)
    Group_Cost:SetActive(false)
    Goup_Manji:SetActive(true)
    local manjiLabel = Goup_Manji:FindDirect("Sprite/Label"):GetComponent("UILabel")
    manjiLabel:set_text(string.format(textRes.Gang[117], textRes.Gang.BuildType[3]))
  else
    Group_NextLevel:SetActive(true)
    Group_Cost:SetActive(true)
    Goup_Manji:SetActive(false)
    local pharmacyTbl = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
    local gangTblNext = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel + 1)
    local Label_CostNum1 = Group_Cost:FindDirect("Img_Num1/Label_CostNum"):GetComponent("UILabel")
    local Label_CostNum2 = Group_Cost:FindDirect("Img_Num2/Label_CostNum"):GetComponent("UILabel")
    Label_CostNum1:set_text(pharmacyTbl.levelUpNeedMoney)
    Label_CostNum2:set_text(gangInfo.money)
    local Label1 = Group_NextLevel:FindDirect("Label_Content/Label1"):GetComponent("UILabel")
    local Label2 = Group_NextLevel:FindDirect("Label_Content/Label2"):GetComponent("UILabel")
    Label1:set_text(gangTblNext.itemNum)
    Label2:set_text(gangTblNext.itemKindNum)
    local Label3 = Group_NextLevel:FindDirect("Label_Content/Label_1"):GetComponent("UILabel")
    local Label4 = Group_NextLevel:FindDirect("Label_Content/Label_2"):GetComponent("UILabel")
    Label3:set_text(string.format(textRes.Gang[253], pharmacyTbl.itemNum))
    Label4:set_text(string.format(textRes.Gang[253], pharmacyTbl.itemKindNum))
  end
end
def.method().FillLevelUpInfo = function(self)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local gangTbl = GangUtility.GetGangCfg(gangInfo.level)
  local Btn_StartConsruct = self.m_node:FindDirect("Btn_StartConsruct")
  local Group_Progress = self.m_node:FindDirect("Group_Progress")
  if gangInfo.pharmacyLevel >= gangTbl.yaoDianMaxLevel then
    Btn_StartConsruct:SetActive(false)
    Group_Progress:SetActive(false)
    return
  end
  if gangInfo.pharmacyEndTime <= 0 then
    Btn_StartConsruct:SetActive(true)
    Group_Progress:SetActive(false)
  else
    Btn_StartConsruct:SetActive(false)
    Group_Progress:SetActive(true)
    local pharmacyTbl = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
    self:FillOpen(gangInfo.pharmacyEndTime, pharmacyTbl.levelUpNeedTimeM * 60)
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  if nil ~= memberInfo then
    local tbl = GangUtility.GetAuthority(memberInfo.duty)
    if false == tbl.isCanLevelUpGang then
      Btn_StartConsruct:SetActive(false)
      Group_Progress:FindDirect("Btn_SendMessage"):SetActive(false)
    end
  end
end
def.method("number", "number").FillOpen = function(self, buildEndTime, time)
  local Group_Progress = self.m_node:FindDirect("Group_Progress")
  local remain = buildEndTime - GetServerTime()
  local rate1 = remain / time
  local timeStr = GangUtility.GetTimeStr(remain)
  local Img_Slide1 = Group_Progress:FindDirect("Img_Slide1")
  Img_Slide1:GetComponent("UISlider"):set_sliderValue(rate1)
  Img_Slide1:FindDirect("Label"):GetComponent("UILabel"):set_text(timeStr)
end
def.override().OnHide = function(self)
end
def.method().UpdateInfo = function(self)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  if gangInfo.pharmacyEndTime > 0 then
    local pharmacyTbl = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
    self:FillOpen(gangInfo.pharmacyEndTime, pharmacyTbl.levelUpNeedTimeM * 60)
  end
end
def.method().OnOpenConsructClick = function(self)
  GangUtility.TryGangConstruct(GangBuildingEnum.YAODIAN)
end
def.method().OnSendMessageClick = function(self)
  Toast(textRes.Gang[238])
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CCallBuildingLevelUpDonateReq").new(GangBuildingEnum.YAODIAN))
end
def.method().OnDonateClick = function(self)
  local GangBuildingEnum = require("netio.protocol.mzm.gsp.gang.GangBuildingEnum")
  local GangBuildDonatePanel = require("Main.Gang.ui.GangBuildDonatePanel")
  GangBuildDonatePanel.ShowDonateBuildPanel(GangBuildingEnum.YAODIAN)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_StartConsruct" == id then
    self:OnOpenConsructClick()
  elseif "Btn_SendMessage" == id then
    self:OnSendMessageClick()
  elseif "Btn_Donate" == id then
    self:OnDonateClick()
  end
end
GangPharmacyNode.Commit()
return GangPharmacyNode
