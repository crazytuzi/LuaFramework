local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenBuyGoldSilverPanel = import(".OpenBuyGoldSilverPanel")
local OpenBuySilverPanel = Lplus.Extend(OpenBuyGoldSilverPanel, CUR_CLASS_NAME)
local BuyGoldSilverPanel = require("Main.Item.ui.BuyGoldSilverPanel")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local def = OpenBuySilverPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.moneyType = MoneyType.SILVER
  return OpenBuyGoldSilverPanel.Operate(self, params)
end
return OpenBuySilverPanel.Commit()
