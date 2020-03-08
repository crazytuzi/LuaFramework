local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationFivePrecious = Lplus.Extend(OperationBase, "OperationFivePrecious")
local def = OperationFivePrecious.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.FIVE_PRECIOUS then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8122]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self:CannotUseInFight() then
    return false
  end
  local itemModule = gmodule.moduleMgr:GetModule(ModuleId.ITEM)
  local item = itemModule:GetItemByBagIdAndItemKey(bagId, itemKey)
  local ItemUtils = require("Main.Item.ItemUtils")
  local fivePreciousItemCfg = ItemUtils.GetFivePreciousItemCfg(item.id)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local canExchange = ActivityInterface.Instance():isNpcExchangeWithinTime(fivePreciousItemCfg.exchangeid)
  if not canExchange then
    Toast(textRes.activity[408])
    return false
  end
  gmodule.moduleMgr:GetModule(ModuleId.ITEM):CloseInventoryDlg()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    fivePreciousItemCfg.npcid
  })
  return true
end
OperationFivePrecious.Commit()
return OperationFivePrecious
