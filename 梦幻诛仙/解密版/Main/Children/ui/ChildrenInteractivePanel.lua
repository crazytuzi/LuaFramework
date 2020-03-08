local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ChildrenInteractivePanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local def = ChildrenInteractivePanel.define
local ChildrenInterface = require("Main.Children.ChildrenInterface")
def.field("userdata").childId = nil
def.field("table").childEntity = nil
def.field("function").OnClickGround = nil
def.field("function").OnEnterFight = nil
def.static("userdata", "table", "=>", ChildrenInteractivePanel).new = function(childId, childEntity)
  local obj = ChildrenInteractivePanel()
  obj.childId = childId
  obj.childEntity = childEntity
  return obj
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:SetDepth(_G.GUIDEPTH.BOTTOM)
    self:CreatePanel(RESPATH.PREFAB_CHILDREN_INTERACTIVE, 2)
  end
end
def.override().OnCreate = function(self)
  function self:OnClickGround(params)
    self:DestroyPanel()
  end
  self.OnEnterFight = self.OnClickGround
  Event.RegisterEventWithContext(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, self.OnClickGround, self)
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, self.OnEnterFight, self)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.m_panel:SetActive(true)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, self.OnClickGround)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, self.OnEnterFight)
end
def.method("string").onClick = function(self, id)
  print("onClick", id, tostring(self.childId))
  if id == "Btn_YangYu" then
    ChildrenInterface.OpenChildGrow(self.childId)
    self:DestroyPanel()
  elseif id == "Btn_DaoZhe" then
    ChildrenInterface.ChildComeToMe(self.childId)
    self:DestroyPanel()
  elseif id == "Btn_DouLe" then
    self:OnDouLeBtnClick()
  elseif id == "Btn_XieDai" then
    ChildrenInterface.PickUpChild(self.childId)
    self:DestroyPanel()
  end
end
def.method("table").SetPos = function(self, pos)
  if self.m_panel == nil or pos == nil then
    return
  end
  self.m_panel.localPosition = pos
end
def.method().UpdateInfo = function(self)
end
def.method().OnDouLeBtnClick = function(self)
  if self.childEntity == nil then
    return
  end
  self.childEntity:PlayRandomAnimation()
end
return ChildrenInteractivePanel.Commit()
