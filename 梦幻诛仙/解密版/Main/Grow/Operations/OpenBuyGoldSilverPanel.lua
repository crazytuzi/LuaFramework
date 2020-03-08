local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenBuyGoldSilverPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local BuyGoldSilverPanel = require("Main.Item.ui.BuyGoldSilverPanel")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local def = OpenBuyGoldSilverPanel.define
def.field("number").moneyType = MoneyType.GOLD
def.override("table", "=>", "boolean").Operate = function(self, params)
  BuyGoldSilverPanel.Instance():ShowPanel(self.moneyType)
  return false
end
return OpenBuyGoldSilverPanel.Commit()
