local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Tab = require("GUI.TabNode")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local CurrencyChargeNode = Lplus.Extend(Tab, "CurrencyChargeNode")
local def = CurrencyChargeNode.define
local instance
def.static("=>", CurrencyChargeNode).Instance = function()
  if nil == instance then
    instance = CurrencyChargeNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  Tab.Init(self, base, node)
end
def.override().OnShow = function(self)
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Gold" then
    GoToBuyGold(false)
  elseif id == "Btn_Sliver" then
    GoToBuySilver(false)
  end
end
CurrencyChargeNode.Commit()
return CurrencyChargeNode
