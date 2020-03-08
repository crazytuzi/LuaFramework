local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GangScaleNode = Lplus.Extend(TabNode, "GangScaleNode")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GangBuildingEnum = require("netio.protocol.mzm.gsp.gang.GangBuildingEnum")
local def = GangScaleNode.define
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
  local Label_Lv = self.m_node:FindDirect("Label1/Label2"):GetComponent("UILabel")
  Label_Lv:set_text(gangInfo.level)
  local Group_NextLevel = self.m_node:FindDirect("Group_NextLevel")
  local Group_Cost = self.m_node:FindDirect("Group_Cost")
  local maxLevel = GangUtility.GetGangConsts("GANG_MAX_LEVEL")
  local Goup_Manji = self.m_node:FindDirect("Goup_Manji")
  if maxLevel <= gangInfo.level then
    Group_NextLevel:SetActive(false)
    Group_Cost:SetActive(false)
    Goup_Manji:SetActive(true)
    local manjiLabel = Goup_Manji:FindDirect("Sprite/Label"):GetComponent("UILabel")
    manjiLabel:set_text(textRes.Gang[116])
  else
    Group_NextLevel:SetActive(true)
    Group_Cost:SetActive(true)
    Goup_Manji:SetActive(false)
    local gangTblNext = GangUtility.GetGangCfg(gangInfo.level + 1)
    local gangTbl = GangUtility.GetGangCfg(gangInfo.level)
    local Label1 = Group_NextLevel:FindDirect("Label_Content/Label1"):GetComponent("UILabel")
    Label1:set_text(gangTblNext.xiangFangMaxLevel)
    local Label_CostNum1 = Group_Cost:FindDirect("Img_Num1/Label_CostNum"):GetComponent("UILabel")
    local Label_CostNum2 = Group_Cost:FindDirect("Img_Num2/Label_CostNum"):GetComponent("UILabel")
    Label_CostNum1:set_text(gangTbl.levelUpNeedMoney)
    Label_CostNum2:set_text(gangInfo.money)
  end
end
def.method().FillLevelUpInfo = function(self)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local Btn_StartConsruct = self.m_node:FindDirect("Btn_StartConsruct")
  local Group_Progress = self.m_node:FindDirect("Group_Progress")
  local maxLevel = GangUtility.GetGangConsts("GANG_MAX_LEVEL")
  if maxLevel <= gangInfo.level then
    Btn_StartConsruct:SetActive(false)
    Group_Progress:SetActive(false)
    return
  end
  if gangInfo.buildEndTime <= 0 then
    Btn_StartConsruct:SetActive(true)
    Group_Progress:SetActive(false)
  else
    Btn_StartConsruct:SetActive(false)
    Group_Progress:SetActive(true)
    local gangTbl = GangUtility.GetGangCfg(gangInfo.level)
    self:FillOpen(gangInfo.buildEndTime, gangTbl.levelUpNeedTimeM * 60)
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
  if gangInfo.buildEndTime > 0 then
    local gangTbl = GangUtility.GetGangCfg(gangInfo.level)
    self:FillOpen(gangInfo.buildEndTime, gangTbl.levelUpNeedTimeM * 60)
  end
end
def.method().OnOpenConsructClick = function(self)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local gangTbl = GangUtility.GetGangCfg(gangInfo.level)
  local num = 0
  if gangInfo.wingLevel >= gangTbl.needBuildingLevel then
    num = num + 1
  end
  if gangInfo.warehouseLevel >= gangTbl.needBuildingLevel then
    num = num + 1
  end
  if gangInfo.coffersLevel >= gangTbl.needBuildingLevel then
    num = num + 1
  end
  if gangInfo.pharmacyLevel >= gangTbl.needBuildingLevel then
    num = num + 1
  end
  if gangInfo.bookLevel >= gangTbl.needBuildingLevel then
    num = num + 1
  end
  if num < gangTbl.needBuildingNum then
    Toast(string.format(textRes.Gang[106], gangTbl.needBuildingNum, gangTbl.needBuildingLevel))
    return
  end
  GangUtility.TryGangConstruct(GangBuildingEnum.GANG)
end
def.method().OnSendMessageClick = function(self)
  Toast(textRes.Gang[238])
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CCallBuildingLevelUpDonateReq").new(GangBuildingEnum.GANG))
end
def.method().OnDonateClick = function(self)
  local GangBuildingEnum = require("netio.protocol.mzm.gsp.gang.GangBuildingEnum")
  local GangBuildDonatePanel = require("Main.Gang.ui.GangBuildDonatePanel")
  GangBuildDonatePanel.ShowDonateBuildPanel(GangBuildingEnum.GANG)
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
GangScaleNode.Commit()
return GangScaleNode
