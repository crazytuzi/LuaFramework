local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SkillPanel = Lplus.Extend(ECPanelBase, "SkillPanel")
local def = SkillPanel.define
local OccupationSkillNode = require("Main.Skill.ui.OccupationSkillNode")
local LivingSkillNode = require("Main.Skill.ui.LivingSkillNode")
local GangSkillNode = require("Main.Skill.ui.GangSkillNode")
local ExerciseSkillNode = require("Main.Skill.ui.ExerciseSkillNode")
local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
local GUIUtils = require("GUI.GUIUtils")
local SkillModule = Lplus.ForwardDeclare("SkillModule")
local Vector = require("Types.Vector")
def.const("table").NodeId = {
  OccupationSkillNode = 1,
  ExerciseSkillNode = 2,
  LivingSkillNode = 3,
  GangSkillNode = 4
}
def.const("table").NodeTabName = {
  [1] = "Tab_School",
  [2] = "Tab_Exercise",
  [3] = "Tab_Life",
  [4] = "Tab_Gang"
}
SkillPanel.TabPosY = 0
SkillPanel.TabPosX = 0
SkillPanel.TabPosOffsetY = 0
def.field("table").nodes = nil
def.field("number").curNode = 1
def.field("table").uiObjs = nil
def.field("number").selectSkillBagId = 0
local instance
def.static("=>", SkillPanel).Instance = function()
  if instance == nil then
    instance = SkillPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
  self.m_TryIncLoadSpeed = true
end
def.method("number").ShowPanel = function(self, curNode)
  if not self:CheckNode(curNode) then
    return
  end
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.curNode = curNode
  self:CreatePanel(RESPATH.PREFAB_SKILL_PANEL, 1)
  self:SetModal(true)
end
def.method("number").SetSelectSkillBagId = function(self, id)
  self.selectSkillBagId = id
end
def.method("=>", "number").GetSelectSkillBagId = function(self)
  return self.selectSkillBagId
end
def.override().OnCreate = function(self)
  self.nodes = {}
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local occupationSkillNode = self.uiObjs.Img_Bg0:FindDirect("Group_School")
  self.nodes[SkillPanel.NodeId.OccupationSkillNode] = OccupationSkillNode.Instance()
  self.nodes[SkillPanel.NodeId.OccupationSkillNode]:Init(self, occupationSkillNode)
  self.nodes[SkillPanel.NodeId.OccupationSkillNode]:SetFuncType(SkillModule.SkillFuncType.Occupation)
  local livingSkillNode = self.uiObjs.Img_Bg0:FindDirect("Group_Life")
  self.nodes[SkillPanel.NodeId.LivingSkillNode] = LivingSkillNode.Instance()
  self.nodes[SkillPanel.NodeId.LivingSkillNode]:Init(self, livingSkillNode)
  self.nodes[SkillPanel.NodeId.LivingSkillNode]:SetFuncType(SkillModule.SkillFuncType.Living)
  local exerciseSkillNode = self.uiObjs.Img_Bg0:FindDirect("Group_Exercise")
  self.nodes[SkillPanel.NodeId.ExerciseSkillNode] = ExerciseSkillNode.Instance()
  self.nodes[SkillPanel.NodeId.ExerciseSkillNode]:Init(self, exerciseSkillNode)
  self.nodes[SkillPanel.NodeId.ExerciseSkillNode]:SetFuncType(SkillModule.SkillFuncType.Exercise)
  local gangSkillNode = self.uiObjs.Img_Bg0:FindDirect("Group_Gang")
  self.nodes[SkillPanel.NodeId.GangSkillNode] = GangSkillNode.Instance()
  self.nodes[SkillPanel.NodeId.GangSkillNode]:Init(self, gangSkillNode)
  self.nodes[SkillPanel.NodeId.GangSkillNode]:SetFuncType(SkillModule.SkillFuncType.Gang)
  for i = 1, 4 do
    local tab = self.uiObjs.Img_Bg0:FindDirect(SkillPanel.NodeTabName[i])
    tab:GetComponent("UIToggle"):set_startsActive(false)
  end
  local tab1 = self.uiObjs.Img_Bg0:FindDirect(SkillPanel.NodeTabName[1])
  local tab2 = self.uiObjs.Img_Bg0:FindDirect(SkillPanel.NodeTabName[2])
  SkillPanel.TabPosX = tab1.transform.localPosition.x
  SkillPanel.TabPosY = tab1.transform.localPosition.y
  SkillPanel.TabPosOffsetY = tab2.transform.localPosition.y - SkillPanel.TabPosY
  local count = 0
  for i, node in ipairs(self.nodes) do
    local tab = self.uiObjs.Img_Bg0:FindDirect(SkillPanel.NodeTabName[i])
    if node:IsUnlock() then
      count = count + 1
      tab:SetActive(true)
      local x = SkillPanel.TabPosX
      local y = SkillPanel.TabPosY + (count - 1) * SkillPanel.TabPosOffsetY
      tab.transform.localPosition = Vector.Vector3.new(x, y, 0)
    else
      tab:SetActive(false)
      node:Hide()
    end
  end
  self:UpdateTabBadges()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, SkillPanel.OnSilverMoneyChanged)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.SKILL_NOTIFY_UPDATE, SkillPanel.OnSkillNotifyUpdate)
  Event.RegisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ORACLE_DLG_CLOSED, SkillPanel.OnOracleChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, SkillPanel.OnOracleChange)
  Event.RegisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_GET_ORACLE_ALLOCATION, SkillPanel.OnOracleChange)
  Event.RegisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ORACLE_TOTAL_POINTS_CHANGE, SkillPanel.OnOracleChange)
  Event.RegisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_SWITCH_ORACLE_CHANGE, SkillPanel.OnOracleChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, SkillPanel.OnFunctionInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, SkillPanel.OnFunctionOpenChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, SkillPanel.OnSilverMoneyChanged)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.SKILL_NOTIFY_UPDATE, SkillPanel.OnSkillNotifyUpdate)
  Event.UnregisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ORACLE_DLG_CLOSED, SkillPanel.OnOracleChange)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, SkillPanel.OnOracleChange)
  Event.UnregisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_GET_ORACLE_ALLOCATION, SkillPanel.OnOracleChange)
  Event.UnregisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ORACLE_TOTAL_POINTS_CHANGE, SkillPanel.OnOracleChange)
  Event.UnregisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_SWITCH_ORACLE_CHANGE, SkillPanel.OnOracleChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, SkillPanel.OnFunctionInit)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, SkillPanel.OnFunctionOpenChange)
  self:Clear()
  self.nodes[self.curNode]:Hide()
end
def.override("boolean").OnShow = function(self, isShow)
  if not isShow then
    return
  end
  self:SwitchToNode(self.curNode)
end
def.method("number").SetCurNode = function(self, node)
  self.curNode = node
end
def.static("table", "table").OnSilverMoneyChanged = function(params, context)
  local self = instance
  self.nodes[self.curNode]:OnSilverMoneyChanged(params, context)
end
def.static("table", "table").OnSkillNotifyUpdate = function(params, context)
  local self = instance
  self:UpdateTabBadges()
  self.nodes[self.curNode]:OnSkillNotifyUpdate()
end
def.static("table", "table").OnOracleChange = function(params, context)
  local self = instance
  self:UpdateTabBadges()
end
def.static("table", "table").OnFunctionInit = function(params, context)
  SkillPanel.OnOracleChange(params, context)
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if param.feature == ModuleFunSwitchInfo.TYPE_GENIUS then
    SkillPanel.OnOracleChange(param, context)
  end
end
def.method().Clear = function(self)
  self.selectSkillBagId = 0
  self.nodes[SkillPanel.NodeId.LivingSkillNode]:ClearNode()
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  self:onClick(id)
  self.nodes[self.curNode]:onClickObj(clickobj)
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Tab_School" then
    self:SwitchToNode(SkillPanel.NodeId.OccupationSkillNode)
  elseif id == "Tab_Exercise" then
    self:SwitchToNode(SkillPanel.NodeId.ExerciseSkillNode)
  elseif id == "Tab_Life" then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    if heroProp.level < LivingSkillUtility.GetLivingSkillConst("OPEN_LEVEL") then
      self:ShowLivingSkillLockedTip()
    else
      self:SwitchToNode(SkillPanel.NodeId.LivingSkillNode)
    end
  elseif id == "Tab_Gang" then
    self:SwitchToNode(SkillPanel.NodeId.GangSkillNode)
  elseif id == "Btn_Talent" then
    Event.DispatchEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.OPEN_ORACLE_DLG, nil)
  else
    self.nodes[self.curNode]:onClick(id)
  end
end
def.method("string").onLongPress = function(self, id)
  self.nodes[self.curNode]:onLongPress(id)
end
def.method("string", "boolean").onToggle = function(self, id, isActive)
  if isActive == false then
    return
  end
end
def.method("number").SwitchToNode = function(self, node)
  if self.curNode ~= node then
    self.nodes[self.curNode]:Hide()
  end
  self.curNode = node
  self.nodes[self.curNode]:Show()
  local tab = self.uiObjs.Img_Bg0:FindDirect(SkillPanel.NodeTabName[node])
  tab:GetComponent("UIToggle"):set_value(true)
end
def.method().ShowLockedTip = function(self)
  Toast(textRes.Common[9])
  self.m_panel:FindDirect("Img_Bg0/Tab_School"):GetComponent("UIToggle"):set_value(true)
end
def.method().ShowLivingSkillLockedTip = function(self)
  Toast(string.format(textRes.Skill[7], LivingSkillUtility.GetLivingSkillConst("OPEN_LEVEL")))
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self.m_panel:FindDirect("Img_Bg0/Tab_School"):GetComponent("UIToggle"):set_value(true)
end
def.method("number", "=>", "boolean").CheckNode = function(self, node)
  local heroProp = _G.GetHeroProp()
  if node == SkillPanel.NodeId.ExerciseSkillNode then
    if heroProp.level < require("Main.Skill.ExerciseSkillMgr").Instance():GetUnlockLevel() then
      Toast(textRes.Skill[20])
      return false
    else
      return true
    end
  elseif node == SkillPanel.NodeId.LivingSkillNode then
    if heroProp.level < LivingSkillUtility.GetLivingSkillConst("OPEN_LEVEL") then
      self:ShowLivingSkillLockedTip()
      return false
    else
      return true
    end
  end
  return true
end
def.method().UpdateTabBadges = function(self)
  for i, node in ipairs(self.nodes) do
    local tabObj = self.uiObjs.Img_Bg0:FindDirect(SkillPanel.NodeTabName[i])
    if tabObj then
      local Img_Red = tabObj:FindDirect("Img_Red")
      GUIUtils.SetActive(Img_Red, node:HasNotify())
    end
  end
end
return SkillPanel.Commit()
