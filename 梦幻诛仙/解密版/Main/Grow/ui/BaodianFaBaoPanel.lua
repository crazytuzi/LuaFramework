local Lplus = require("Lplus")
local BaodianBasePanel = require("Main.Grow.ui.BaodianBasePanel")
local BaodianUtils = require("Main.Grow.BaodianUtils")
local GUIUtils = require("GUI.GUIUtils")
local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local BaodianFaBaoPanel = Lplus.Extend(BaodianBasePanel, "BaodianFaBaoPanel")
local def = BaodianFaBaoPanel.define
def.field("number").mNeedLevel = 0
def.field("userdata").mParent = nil
local instance
def.static("=>", BaodianFaBaoPanel).Instance = function()
  if instance == nil then
    instance = BaodianFaBaoPanel()
  end
  return instance
end
def.override("userdata").ShowPanel = function(self, parentPanel)
  if self:IsShow() then
    return
  end
  self.mParent = parentPanel
  GameUtil.AddGlobalLateTimer(0, true, function()
    self:CreatePanel(RESPATH.PREFAB_BAODIAN_FABAO, 2)
  end)
end
def.override().OnCreate = function(self)
  if self.mParent == nil or self.mParent.isnil == true then
    self:DestroyPanel()
    return
  end
  self:InitData()
  self:InitUI()
end
def.method().InitData = function(self)
  self.mNeedLevel = FabaoUtils.GetFabaoConstValue("FABAO_OPEN_LEVEL")
end
def.method().InitUI = function(self)
  local sxLabel = self.m_panel:FindDirect("Lead_BD_FaBao/Group_FB_SX/Group_Tips/Label_Tips")
  local xlLabel = self.m_panel:FindDirect("Lead_BD_FaBao/Group_FB_XL/Group_Tips/Label_Tips")
  local ccLabel = self.m_panel:FindDirect("Lead_BD_FaBao/Group_FB_CC/Group_Tips/Label_Tips")
  local lgLabel = self.m_panel:FindDirect("Lead_BD_FaBao/Group_FB_LG/Group_Tips/Label_Tips")
  local sxDesc = BaodianUtils.GetBaodianDescByName("GROW_FABAO_ATT_DESC")
  local xlDesc = BaodianUtils.GetBaodianDescByName("GROW_FABAO_XILIAN_DESC")
  local ccDesc = BaodianUtils.GetBaodianDescByName("GROW_FABAO_GROWUP_DESC")
  local lgDesc = BaodianUtils.GetBaodianDescByName("GROW_FABAO_LONGJING_DESC")
  sxLabel:GetComponent("UILabel").text = sxDesc
  xlLabel:GetComponent("UILabel").text = xlDesc
  ccLabel:GetComponent("UILabel").text = ccDesc
  lgLabel:GetComponent("UILabel").text = lgDesc
end
def.method("=>", "boolean").HasFabaoTask = function(self)
  local FabaoModule = require("Main.Fabao.FabaoModule")
  local hasFabaoTask, taskId = FabaoModule.HasFabaoTask()
  if hasFabaoTask and 0 ~= taskId then
    Toast(textRes.Fabao[131] or textRes.Fabao[59])
    return true
  else
    return false
  end
end
def.method("string").onClick = function(self, id)
  local heroLevel = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  local ItemModule = require("Main.Item.ItemModule")
  if id == "Btn_HC" then
    if heroLevel < self.mNeedLevel then
      Toast(string.format(textRes.Grow[12], self.mNeedLevel))
      return
    end
    if self:HasFabaoTask() then
      return
    end
    FabaoSocialPanel.Instance():ShowPanelWithParams(FabaoSocialPanel.NodeId.FabaoCZ, {
      czSubNode = FabaoSocialPanel.CZSubNode.StarUp
    })
  elseif id == "Btn_YL" then
    if heroLevel < self.mNeedLevel then
      Toast(string.format(textRes.Grow[12], self.mNeedLevel))
      return
    end
    if self:HasFabaoTask() then
      return
    end
    FabaoSocialPanel.Instance():ShowPanelWithParams(FabaoSocialPanel.NodeId.FabaoBasic, {
      basicSubNode = FabaoSocialPanel.BasicSubNode.FabaoTuJian
    })
  elseif id == "Btn_XL" then
    if heroLevel < self.mNeedLevel then
      Toast(string.format(textRes.Grow[13], self.mNeedLevel))
      return
    end
    if self:HasFabaoTask() then
      return
    end
    FabaoSocialPanel.Instance():ShowPanelWithParams(FabaoSocialPanel.NodeId.FabaoCZ, {
      czSubNode = FabaoSocialPanel.CZSubNode.LevelUp
    })
  elseif id == "Btn_CC" then
    if heroLevel < self.mNeedLevel then
      Toast(string.format(textRes.Grow[14], self.mNeedLevel))
      return
    end
    if self:HasFabaoTask() then
      return
    end
    FabaoSocialPanel.Instance():ShowPanelWithParams(FabaoSocialPanel.NodeId.FabaoCZ, {
      czSubNode = FabaoSocialPanel.CZSubNode.SkillWash
    })
  elseif id == "Btn_XQ" then
    if heroLevel < self.mNeedLevel then
      Toast(string.format(textRes.Grow[15], self.mNeedLevel))
      return
    end
    if self:HasFabaoTask() then
      return
    end
    FabaoSocialPanel.Instance():ShowPanel(FabaoSocialPanel.NodeId.FabaoXQ)
  end
end
def.override().ReleaseUI = function(self)
end
def.override().OnDestroy = function(self)
  self:ReleaseUI()
  self.mParent = nil
end
BaodianFaBaoPanel.Commit()
return BaodianFaBaoPanel
