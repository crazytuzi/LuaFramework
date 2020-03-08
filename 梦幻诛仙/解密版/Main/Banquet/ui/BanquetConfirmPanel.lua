local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local BanquetConfirmPanel = Lplus.Extend(ECPanelBase, "BanquetConfirmPanel")
local BanquetInterface = require("Main.Banquet.BanquetInterface")
local banquetInterface = BanquetInterface.Instance()
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = BanquetConfirmPanel.define
local instance
def.field("string").contnet = ""
def.field("function").confirmCallback = nil
def.static("=>", BanquetConfirmPanel).Instance = function()
  if instance == nil then
    instance = BanquetConfirmPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("string", "function").ShowDlg = function(self, contnet, confirmCallback)
  if self:IsShow() == false then
    self.contnet = contnet
    self.confirmCallback = confirmCallback
    self:CreatePanel(RESPATH.PERFAB_JIAYAN_CONFIRM, 2)
    self:SetModal(true)
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setInfo()
  else
    self.confirmCallback = nil
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HideDlg()
  elseif id == "Btn_OpenConfirm" then
    if self.confirmCallback then
      self.confirmCallback()
      self.confirmCallback = nil
    end
    self:HideDlg()
  elseif id == "Btn_NotConfirm" then
    self:HideDlg()
  end
end
def.method().setInfo = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Label_Info = Img_Bg0:FindDirect("Label_Info")
  Label_Info:GetComponent("UILabel"):set_text(self.contnet)
end
BanquetConfirmPanel.Commit()
return BanquetConfirmPanel
