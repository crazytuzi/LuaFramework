local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CurrencyBase = import(".CurrencyBase")
local Yuanbao = Lplus.Extend(CurrencyBase, CUR_CLASS_NAME)
local ItemModule = require("Main.Item.ItemModule")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local def = Yuanbao.define
local instance
def.static("=>", Yuanbao).Instance = function()
  if instance == nil then
    instance = Yuanbao.New()
  end
  return instance
end
def.static("=>", Yuanbao).New = function()
  local instance = Yuanbao()
  instance:Init()
  return instance
end
def.method().Init = function(self)
end
def.override("=>", "string").GetName = function(self)
  return textRes.Item.MoneyName[MoneyType.YUANBAO] or ""
end
def.override("=>", "string").GetSpriteName = function(self)
  return "Img_Money"
end
def.override("=>", "userdata").GetHaveNum = function(self)
  return ItemModule.Instance():GetAllYuanBao()
end
def.override("function").RegisterCurrencyChangedEvent = function(self, func)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, func)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, func)
end
def.override("function").UnregisterCurrencyChangedEvent = function(self, func)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, func)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, func)
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
  local MallPanel = require("Main.Mall.ui.MallPanel")
  require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
end
return Yuanbao.Commit()
