local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local RechargeOBTAwardPanel = Lplus.Extend(ECPanelBase, "RechargeOBTAwardPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = RechargeOBTAwardPanel.define
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
def.field("table").uiObjs = nil
def.field("table").items = nil
local instance
def.static("=>", RechargeOBTAwardPanel).Instance = function()
  if instance == nil then
    instance = RechargeOBTAwardPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_RECHARGE_RETURN_AWARD_PANEL, 0)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Recharge" then
    self:GoToRecharge()
  end
end
def.method().GoToRecharge = function(self)
  self:DestroyPanel()
  local MallPanel = require("Main.Mall.ui.MallPanel")
  require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
  local PayModule = require("Main.Pay.PayModule")
  PayModule.Instance():SetPayTLogData(_G.TLOGTYPE.CHARGERETURN, {})
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Btn_Recharge = self.m_panel:FindDirect("Btn_Recharge")
end
return RechargeOBTAwardPanel.Commit()
