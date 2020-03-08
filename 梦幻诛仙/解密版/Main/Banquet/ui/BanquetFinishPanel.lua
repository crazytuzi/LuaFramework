local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local BanquetFinishPanel = Lplus.Extend(ECPanelBase, "BanquetFinishPanel")
local BanquetInterface = require("Main.Banquet.BanquetInterface")
local banquetInterface = BanquetInterface.Instance()
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = BanquetFinishPanel.define
local instance
def.field("string").contnet = ""
def.field("number").timerId = 0
def.static("=>", BanquetFinishPanel).Instance = function()
  if instance == nil then
    instance = BanquetFinishPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("string").ShowDlg = function(self, contnet)
  if self:IsShow() == false then
    self.contnet = contnet
    self:CreatePanel(RESPATH.PERFAB_JIAYAN_FINISH, 2)
    self:SetModal(true)
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
    self.contnet = ""
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_END, BanquetFinishPanel.OnBanquetEnd)
  Event.RegisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_EXIT, BanquetFinishPanel.OnBanquetExit)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_END, BanquetFinishPanel.OnBanquetEnd)
  Event.UnregisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_EXIT, BanquetFinishPanel.OnBanquetExit)
end
def.static("table", "table").OnBanquetEnd = function(p1, p2)
  if instance and instance.m_panel then
    instance:HideDlg()
  end
end
def.static("table", "table").OnBanquetExit = function(p1, p2)
  if instance and instance.m_panel then
    instance:HideDlg()
  end
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setInfo()
    self.timerId = GameUtil.AddGlobalTimer(30, true, function()
      self:HideDlg()
      self.timerId = 0
    end)
  elseif self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HideDlg()
  end
end
def.method().setInfo = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Label_Info = Img_Bg0:FindDirect("Label_Info")
  local Label_Level = Img_Bg0:FindDirect("Label_Level")
  Label_Info:GetComponent("UILabel"):set_text(self.contnet)
end
BanquetFinishPanel.Commit()
return BanquetFinishPanel
