local Lplus = require("Lplus")
local NPCModule = Lplus.ForwardDeclare("NPCModule")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local HuanhunGet = Lplus.Extend(ECPanelBase, "HuanhunGet")
local def = HuanhunGet.define
local inst
local Vector = require("Types.Vector")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemTips = require("Main.Item.ui.ItemTips")
def.field("boolean").isshowing = false
def.static("=>", HuanhunGet).Instance = function()
  if inst == nil then
    inst = HuanhunGet()
    inst:Init()
  end
  return inst
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self.isshowing = true
    self:CreatePanel(RESPATH.PREFAB_UI_HUANHUN_GET, 1)
    self:SetOutTouchDisappear()
  end
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HideDlg()
  elseif id == "Btn_Get" then
    local p = require("netio.protocol.mzm.gsp.huanhun.CGetHuanHunReq").new()
    gmodule.network.sendProtocol(p)
    self:HideDlg()
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
  self.isshowing = false
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
  else
    self.isshowing = false
  end
end
def.method().Fill = function(self)
end
HuanhunGet.Commit()
return HuanhunGet
