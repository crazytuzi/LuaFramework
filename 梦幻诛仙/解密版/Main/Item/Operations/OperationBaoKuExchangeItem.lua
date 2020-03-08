local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local OperationBaoKuExchangeItem = Lplus.Extend(OperationBase, "OperationBaoKuExchangeItem")
local def = OperationBaoKuExchangeItem.define
def.field("table").quickItem = nil
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.BAO_KU_EXCHANGE_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local LotteryAwardMgr = require("Main.Award.mgr.LotteryAwardMgr")
  LotteryAwardMgr.Instance():OpenBaoKuPanel()
  return true
end
OperationBaoKuExchangeItem.Commit()
return OperationBaoKuExchangeItem
