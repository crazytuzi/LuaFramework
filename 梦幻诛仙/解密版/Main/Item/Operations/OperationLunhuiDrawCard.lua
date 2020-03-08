local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local OperationLunhuiDrawCard = Lplus.Extend(OperationBase, "OperationLunhuiDrawCard")
local def = OperationLunhuiDrawCard.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  warn("")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.FLOP_LOTTERY_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local uuid = item.uuid[1]
  local lunhuiTreasureCfg = require("Main.Item.ItemUtils").GetDrawCardItemCfg(item.id)
  if lunhuiTreasureCfg then
    require("Main.Award.mgr.LunhuiTreasureMgr").Instance():OpenLunhuiItem(lunhuiTreasureCfg.flopLotteryMainCfgId, uuid)
  end
  return true
end
OperationLunhuiDrawCard.Commit()
return OperationLunhuiDrawCard
