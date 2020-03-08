local Lplus = require("Lplus")
local DoubleInteractionNode = Lplus.Class("DoubleInteractionNode")
local Cls = DoubleInteractionNode
local def = Cls.define
local instance
local InteractionModule = require("Main.DoubleInteraction.DoubleInteractionModule")
local InteractionUtils = require("Main.DoubleInteraction.DoubleInteractionUtils")
local GUIUtils = require("GUI.GUIUtils")
def.field("userdata").m_panel = nil
def.field("table")._actList = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method("=>", "boolean").IsOpen = function(self)
  local bOpen = InteractionModule.IsFeatureOpen() and InteractionModule.IsLevelEnough()
  return bOpen
end
def.method("userdata").OnShow = function(self, panel)
  self.m_panel = panel
  self._actList = InteractionUtils.FastLoadAllCfg() or {}
  self:_initActionList()
end
def.method().OnHide = function(self)
  self.m_panel = nil
  self._actList = nil
end
def.method()._initActionList = function(self)
  local ctrlScrollView = self.m_panel:FindDirect("Img_Bg0/Group_Btn_Multi/Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("Grid")
  local numActs = #self._actList
  local ctrlActList = GUIUtils.InitUIList(ctrlUIList, numActs)
  for i = 1, numActs do
    self:_fillActInfo(ctrlActList[i], self._actList[i], i)
  end
end
def.method("userdata", "table", "number")._fillActInfo = function(self, ctrl, cfg, idx)
  local lblName = ctrl:FindDirect("Label_" .. idx)
  GUIUtils.SetText(lblName, cfg.name)
end
def.method("userdata", "=>", "boolean").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if string.find(id, "Btn_Action_Multi_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[4])
    self:onClickAct(idx)
    return true
  end
  return false
end
def.method("number").onClickAct = function(self, idx)
  if PlayerIsInFight() then
    Toast(textRes.Chat.Action[1])
    return
  end
  local selActionCfg = self._actList[idx]
  if selActionCfg ~= nil then
    InteractionModule.CSendPullRoleList(selActionCfg.id)
  end
end
return Cls.Commit()
