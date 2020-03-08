local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local XunluTip = Lplus.Extend(ECPanelBase, "XunluTip")
local def = XunluTip.define
local instance
def.const("table").PATHSTATE = {XUNLU = 1, XUNLUO = 2}
def.field("number").State = 0
def.field("number").refreshTimer = 0
def.static("=>", XunluTip).Instance = function()
  if instance == nil then
    instance = XunluTip()
    instance.m_HideOnDestroy = true
  end
  return instance
end
def.static().ShowXunlu = function()
  local tip = XunluTip.Instance()
  tip:SetDepth(1)
  tip.State = XunluTip.PATHSTATE.XUNLU
  if tip.m_panel then
    tip:ResetState()
  else
    tip:CreatePanel(RESPATH.PREFAB_XUNLU_EFFECT, 0)
  end
end
def.static().ShowXunluo = function()
  local tip = XunluTip.Instance()
  tip:SetDepth(1)
  tip.State = XunluTip.PATHSTATE.XUNLUO
  if tip.m_panel then
    tip:ResetState()
  else
    tip:CreatePanel(RESPATH.PREFAB_XUNLU_EFFECT, 0)
  end
end
def.static().HideXunlu = function()
  local tip = XunluTip.Instance()
  if tip.State == XunluTip.PATHSTATE.XUNLU then
    tip:DestroyPanel()
  end
end
def.static().HideXunluo = function()
  local tip = XunluTip.Instance()
  if tip.State == XunluTip.PATHSTATE.XUNLUO then
    tip:DestroyPanel()
  end
end
def.override("boolean").OnShow = function(self, show)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, XunluTip.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, XunluTip.OnLeaveFight)
  self:ResetState()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, XunluTip.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, XunluTip.OnLeaveFight)
end
def.method().ResetState = function(self)
  if self.State == XunluTip.PATHSTATE.XUNLU then
    self.m_panel:FindDirect("Group_XunLu"):SetActive(true)
    self.m_panel:FindDirect("Group_XunLuo"):SetActive(false)
  elseif self.State == XunluTip.PATHSTATE.XUNLUO then
    self.m_panel:FindDirect("Group_XunLu"):SetActive(false)
    self.m_panel:FindDirect("Group_XunLuo"):SetActive(true)
  else
    self.m_panel:FindDirect("Group_XunLu"):SetActive(false)
    self.m_panel:FindDirect("Group_XunLuo"):SetActive(false)
  end
  if PlayerIsInFight() then
    XunluTip.Instance():SetLayer(ClientDef_Layer.Invisible)
  else
    XunluTip.Instance():SetLayer(ClientDef_Layer.UI)
  end
end
def.method("string").onClick = function(self, id)
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if XunluTip.Instance().m_panel then
    XunluTip.Instance():SetLayer(ClientDef_Layer.Invisible)
  end
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  if XunluTip.Instance().m_panel then
    XunluTip.Instance():SetLayer(ClientDef_Layer.UI)
  end
end
return XunluTip.Commit()
