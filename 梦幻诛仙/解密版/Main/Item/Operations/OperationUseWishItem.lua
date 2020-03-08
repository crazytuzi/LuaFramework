local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local WishingWellData = require("Main.activity.WishingWell.data.WishingWellData")
local OperationUseWishItem = Lplus.Extend(OperationBase, "OperationUseWishItem")
local def = OperationUseWishItem.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local result = false
  local wishMap = WishingWellData.Instance():GetWishingMap()
  if wishMap then
    for activityId, wishCfg in pairs(wishMap) do
      if source == ItemTipsMgr.Source.Bag and itemBase.itemid == wishCfg.costItemId then
        warn(string.format("[OperationUseWishItem:CanDispaly] item [%d] for wish activity [%d].", itemBase.itemid, wishCfg.type))
        result = true
        break
      end
    end
  end
  return result
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Wish, {bagId = bagId, itemKey = itemKey})
  return true
end
OperationUseWishItem.Commit()
return OperationUseWishItem
