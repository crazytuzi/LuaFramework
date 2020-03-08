local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CurrencyBase = import(".CurrencyBase")
local GangContribute = Lplus.Extend(CurrencyBase, CUR_CLASS_NAME)
local ItemModule = require("Main.Item.ItemModule")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local def = GangContribute.define
local instance
def.static("=>", GangContribute).Instance = function()
  if instance == nil then
    instance = GangContribute.New()
  end
  return instance
end
def.static("=>", GangContribute).New = function()
  local instance = GangContribute()
  instance:Init()
  return instance
end
def.method().Init = function(self)
end
def.override("=>", "string").GetName = function(self)
  return textRes.Item.MoneyName[MoneyType.GANGCONTRIBUTE] or ""
end
def.override("=>", "string").GetSpriteName = function(self)
  return "Icon_Bang"
end
def.override("=>", "userdata").GetHaveNum = function(self)
  local GangModule = require("Main.Gang.GangModule")
  local bHasGang = GangModule.Instance():HasGang()
  if bHasGang == false then
    return Int64.new(0)
  else
    local bangGong = GangModule.Instance():GetHeroCurBanggong()
    return Int64.new(bangGong)
  end
end
def.override().AcquireWithQuery = function(self)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local title = textRes.Common[8]
  local moneyTypeMame = self:GetName()
  local desc = string.format(textRes.Common[41], moneyTypeMame)
  CommonConfirmDlg.ShowConfirm(title, desc, function(s)
    if s == 1 then
      self:Acquire()
    end
  end, nil)
end
def.override().OnAcquire = function(self)
  local GangModule = require("Main.Gang.GangModule")
  local bHasGang = GangModule.Instance():HasGang()
  if bHasGang == false then
    Toast(textRes.Item[136])
    return
  end
  local HaveGangPanel = require("Main.Gang.ui.HaveGangPanel")
  HaveGangPanel.Instance():ShowPanelToTab(HaveGangPanel.NodeId.WELFARE)
end
return GangContribute.Commit()
