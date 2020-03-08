local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIActionList = Lplus.Extend(ECPanelBase, "UIActionList")
local Cls = UIActionList
local def = UIActionList.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local InteractionUtils = require("Main.DoubleInteraction.DoubleInteractionUtils")
local InteractionModule = require("Main.DoubleInteraction.DoubleInteractionModule")
def.field("table")._actList = nil
def.field("table")._roleInfo = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = UIActionList()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._actList = InteractionUtils.FastLoadAllCfg()
  self:_initActionList()
end
def.override().OnDestroy = function(self)
  self._actList = nil
  self._roleInfo = nil
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
def.method("table").ShowPanel = function(self, roleInfo)
  self._roleInfo = roleInfo
  self:CreatePanel(RESPATH.PREFAB_ACTION_LIST, 2)
  self:SetOutTouchDisappear()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if string.find(id, "Btn_Action_Multi_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[4])
    self:onClickAction(idx)
  end
end
def.method("number").onClickAction = function(self, idx)
  local actionCfg = self._actList[idx]
  if actionCfg ~= nil then
    InteractionModule.CSendInviteReq(self._roleInfo.roleId, actionCfg.id)
  end
  self:DestroyPanel()
end
return Cls.Commit()
