local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local FoolsDayMgr = require("Main.Festival.FoolsDay.FoolsDayMgr")
local OperationUseFoolsDayChest = Lplus.Extend(OperationBase, "OperationUseFoolsDayChest")
local def = OperationUseFoolsDayChest.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.FOOLS_DAY_ACTIVITY_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local bFeatureOpen = FoolsDayMgr.Instance():GetFeatureOpen()
  if not bFeatureOpen then
    local moduleName = textRes.IDIP.PlayTypeName[FoolsDayMgr.GetFeatureType()]
    if moduleName then
      local tip = string.format(textRes.IDIP[7], moduleName)
      Toast(tip)
    end
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local ItemUtils = require("Main.Item.ItemUtils")
  local roleId = ItemUtils.GetRoleIdByItem(item, ItemXStoreType.MAKER_ID_LOW, ItemXStoreType.MAKER_ID_HIGH)
  local actId = item.extraMap[ItemXStoreType.ACTIVITY_CFG_ID]
  warn(">>>>roleId = " .. Int64.ToNumber(roleId) .. "<<<<")
  local iOpenTimes = FoolsDayMgr.GetOpenedTimes(actId)
  local iMaxOpenTimes = FoolsDayMgr.GetTotalOpenChestTimes()
  if iOpenTimes >= iMaxOpenTimes then
    Toast(textRes.Festival.FoolsDay[21])
    return true
  end
  local bOpened = FoolsDayMgr.ExistInOpenedRoleList(roleId, actId)
  if bOpened then
    local bOepnSelfTwice = FoolsDayMgr.IsMySelf(roleId)
    local iMaxSameRole = FoolsDayMgr.GetOpenSameRoleChestMaxTimes()
    if bOepnSelfTwice then
      Toast(string.format(textRes.Festival.FoolsDay[15], iMaxSameRole, iOpenTimes, iMaxOpenTimes))
    else
      Toast(string.format(textRes.Festival.FoolsDay[22], iMaxSameRole, iOpenTimes, iMaxOpenTimes))
    end
    return true
  end
  FoolsDayMgr.SendOpenChestReq(itemKey, roleId)
  return true
end
OperationUseFoolsDayChest.Commit()
return OperationUseFoolsDayChest
