local Lplus = require("Lplus")
local PetPanelNodeBase = Lplus.Class("PetPanelNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local PetUtility = require("Main.Pet.PetUtility")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetMgrInstance = PetMgr.Instance()
local def = PetPanelNodeBase.define
def.field(ECPanelBase).m_base = nil
def.field("userdata").m_panel = nil
def.field("userdata").m_node = nil
def.field("boolean").isShow = false
def.field("number").nodeId = 0
def.field("boolean").isEmpty = false
def.field("userdata").ui_PetList = nil
def.field("userdata").ui_List_PetList = nil
def.virtual(ECPanelBase, "userdata").Init = function(self, base, node)
  self.m_base = base
  self.m_panel = self.m_base.m_panel
  self.m_node = node
end
def.method().Show = function(self)
  self.m_node:SetActive(true)
  self.isShow = true
  self:OnShow()
end
def.virtual().OnShow = function(self)
end
def.virtual().OnDestroy = function(self)
end
def.method().Hide = function(self)
  self.m_node:SetActive(false)
  self.isShow = false
  self:OnHide()
end
def.virtual().OnHide = function(self)
end
def.virtual("string").onClick = function(self, id)
end
def.virtual("string").onDoubleClick = function(self, id)
end
def.virtual("string", "boolean").onPress = function(self, id, state)
end
def.virtual("string", "boolean").onToggle = function(self, id, isActive)
end
def.virtual("string").onDragStart = function(self, id)
end
def.virtual("string").onDragEnd = function(self, id)
end
def.virtual("string", "number", "number").onDrag = function(self, id, dx, dy)
end
def.virtual().InitUI = function(self)
end
def.virtual().UpdateUI = function(self)
end
def.virtual("userdata").UpdatePetInfo = function(self, petId)
end
def.virtual().OnBagInfoSynchronized = function(self)
end
def.virtual("userdata").OnPetAdded = function(self, petId)
end
def.virtual("userdata").OnPetDeleted = function(self, petId)
end
def.virtual("=>", "boolean").HasNotify = function(self)
  return false
end
def.method().UpdateNotifyState = function(self)
  if self:HasNotify() then
    self.m_base:SetTabNotify(self.nodeId, true)
  else
    self.m_base:SetTabNotify(self.nodeId, false)
  end
end
def.method("userdata", "userdata", "dynamic", "dynamic").SetProgressBar = function(self, propgessBar, label, value, maxValue)
  local ui_propgessBar = propgessBar:GetComponent("UIProgressBar")
  local ui_label = label:GetComponent("UILabel")
  if maxValue == 0 or maxValue == nil then
    ui_propgessBar:get_foregroundWidget().gameObject:SetActive(false)
    ui_label.gameObject:SetActive(false)
    return
  else
    ui_propgessBar:get_foregroundWidget().gameObject:SetActive(true)
    ui_label.gameObject:SetActive(true)
  end
  local valueNumber, valueText
  if value and maxValue then
    valueNumber = value / maxValue
    valueText = string.format("%d/%d", value, maxValue)
  else
    valueNumber, valueText = 0, ""
  end
  ui_propgessBar:set_value(valueNumber)
  ui_label:set_text(valueText)
end
def.method("number", "userdata", "number").ShowPropHoverTip = function(self, propKey, sourceObj, prefer)
  local tipCfg = _G.GetCommonPropNameCfg(propKey)
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  CommonUISmallTip.Instance():ShowTip(tipCfg.propTips, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), prefer)
end
return PetPanelNodeBase.Commit()
