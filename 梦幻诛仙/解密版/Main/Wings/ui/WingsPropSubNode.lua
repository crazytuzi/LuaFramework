local Lplus = require("Lplus")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local WingsSubNodeBase = require("Main.Wings.ui.WingsSubNodeBase")
local WingsUtility = require("Main.Wings.WingsUtility")
local WingsDataMgr = require("Main.Wings.data.WingsDataMgr")
local WingsModule = Lplus.ForwardDeclare("Main.Wings.WingsModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local HeroModule = require("Main.Hero.HeroModule")
local WingsPanel = Lplus.ForwardDeclare("WingsPanel")
local WingsPropSubNode = Lplus.Extend(WingsSubNodeBase, "WingsPropSubNode")
local def = WingsPropSubNode.define
def.field("table").levelUpCfg = nil
def.field("table").curLevelExp = nil
local instance
def.static("=>", WingsPropSubNode).Instance = function()
  if instance == nil then
    instance = WingsPropSubNode()
  end
  return instance
end
def.override(WingsPanel, "userdata").Init = function(self, base, node)
  WingsSubNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_CURRENT_PROP_CHANGED, WingsPropSubNode.OnPropChanged)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_EXP_ADDED, WingsPropSubNode.OnWingsExpAdded)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_CURRENT_PROP_CHANGED, WingsPropSubNode.OnPropChanged)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_EXP_ADDED, WingsPropSubNode.OnWingsExpAdded)
  self:ClearUp()
end
def.method().ClearUp = function(self)
  self.curLevelExp = nil
  self.levelUpCfg = nil
end
def.method().UpdateUI = function(self)
  self:UpdatePropInfo()
  self:UpdateLvlExpInfo()
end
def.method().UpdatePropInfo = function(self)
  local propMap = WingsDataMgr.Instance():GetPropertyMap(true)
  if not propMap then
    return
  end
  local imgBG = self.m_node:FindDirect("Img_Bg")
  for i = 1, WingsDataMgr.WING_PROPERTY_NUM do
    local propRoot = imgBG:FindDirect("Attribute_" .. i)
    local propitem = propMap[WingsUtility.PropSeq[i]]
    if not propitem then
      return
    end
    propRoot:FindDirect("Label2"):GetComponent("UILabel"):set_text(string.format("+ %d", propitem.value))
    local colorText = string.format("[%s]%s[-]", ItemTipsMgr.Color[propitem.phase], textRes.Wings.PropPhase[propitem.phase])
    propRoot:FindDirect("Label3"):GetComponent("UILabel"):set_text(colorText)
  end
end
def.method().UpdateLvlExpInfo = function(self)
  self.curLevelExp = WingsDataMgr.Instance():GetCurrentLevelExp()
  if not self.curLevelExp then
    return
  end
  local lblLevel = self.m_node:FindDirect("Label_Level")
  lblLevel:GetComponent("UILabel"):set_text(self.curLevelExp.level)
  self.levelUpCfg = WingsUtility.GetWingsLevelUpCfg(self.curLevelExp.level)
  local uiSliderExp = self.m_node:FindDirect("Slider_Exp"):GetComponent("UISlider")
  local uiLabelExp = self.m_node:FindDirect("Slider_Exp/Label_SX_SliderActive"):GetComponent("UILabel")
  if self.levelUpCfg then
    uiSliderExp:set_sliderValue(self.curLevelExp.exp / self.levelUpCfg.needWingExp)
    uiLabelExp:set_text(string.format("%d/%d", self.curLevelExp.exp, self.levelUpCfg.needWingExp))
  else
    uiSliderExp:set_sliderValue(1)
    local levelCfg = WingsUtility.GetWingsLevelUpCfg(self.curLevelExp.level - 1)
    uiLabelExp:set_text(string.format("%d/%d", levelCfg.needWingExp, levelCfg.needWingExp))
  end
  local propResetLvl = WingsDataMgr.MIN_LEVEL_FOR_RESET_PROPERTY
  self.m_node:FindDirect("Img_Bg/Btn_Reset"):SetActive(propResetLvl <= self.curLevelExp.level)
  if propResetLvl > self.curLevelExp.level then
    self.m_node:FindDirect("Img_Bg/Label"):GetComponent("UILabel"):set_text(string.format(textRes.Wings[34], propResetLvl))
  else
    self.m_node:FindDirect("Img_Bg/Label"):GetComponent("UILabel"):set_text(textRes.Wings[35])
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Add" then
    self:OnAddedExpClicked()
  elseif id == "Btn_Reset" then
    self:OnResetClicked()
  elseif id == "Btn_Tip" then
    self:OnBtnTipClicked()
  end
end
def.method().OnBtnTipClicked = function(self)
  local tmpPosition = {x = 0, y = 0}
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  local tipString = require("Main.Common.TipsHelper").GetHoverTip(701605006)
  if tipString == "" then
    return
  end
  CommonDescDlg.ShowCommonTip(tipString, tmpPosition)
end
def.method().OnAddedExpClicked = function(self)
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    Toast(textRes.Wings[2])
    return
  end
  if not self.levelUpCfg then
    Toast(textRes.Wings[12])
    return
  end
  local curPhase = WingsDataMgr.Instance():GetCurrentWingsPhase()
  local curRoleLevel = HeroModule.Instance():GetHeroProp().level
  if curRoleLevel < self.levelUpCfg.needRoleLevel then
    Toast(string.format(textRes.Wings[13], self.levelUpCfg.needRoleLevel))
    return
  end
  if curPhase < self.levelUpCfg.needWingPhase then
    Toast(string.format(textRes.Wings[14], self.levelUpCfg.needWingPhase))
    return
  end
  local CommonUsePanel = require("GUI.CommonUsePanel")
  local idList = WingsUtility.GetAllWingsExpItemIds()
  CommonUsePanel.Instance():SetItemIdList(idList)
  CommonUsePanel.Instance():ShowPanel(WingsUtility.WingsExpItemFilter, nil, CommonUsePanel.Source.WingsItemBag, nil)
end
def.method().OnResetClicked = function(self)
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    Toast(textRes.Wings[2])
    return
  end
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  if idx then
    local p = require("netio.protocol.mzm.gsp.wing.COpenPropertyReset").new(idx)
    gmodule.network.sendProtocol(p)
    require("Main.Wings.ui.WingsPropPanel").Instance():ShowPanel()
  end
end
def.override().OnWingsSchemaChanged = function(self)
  self:UpdateUI()
end
def.override("table", "table").OnSyncWingsInfo = function(params, context)
  self:UpdateUI()
end
def.static("table", "table").OnPropChanged = function(params, context)
  instance:UpdatePropInfo()
end
def.static("table", "table").OnWingsExpAdded = function(params, context)
  instance:UpdateLvlExpInfo()
end
return WingsPropSubNode.Commit()
