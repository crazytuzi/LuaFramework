local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local OperationFixEquip = Lplus.Extend(OperationBase, "OperationFixEquip")
local def = OperationFixEquip.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if (source == ItemTipsMgr.Source.Bag or source == ItemTipsMgr.Source.Equip) and itemBase.itemType == ItemType.EQUIP then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8118]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  local itemBase = ItemUtils.GetItemBase(item.id)
  local equipBase = ItemUtils.GetEquipBase(item.id)
  local equipFullDurable = equipBase.usePoint
  local durable = item.extraMap[ItemXStoreType.USE_POINT_VALUE]
  local fixCost = 0
  local equipLevl = itemBase.useLevel
  if equipFullDurable <= durable then
    Toast(textRes.Item[8370])
    return true
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local equipmentLevel = DynamicRecord.GetIntValue(entry, "equipmentLevel")
    if equipmentLevel == equipLevl then
      fixCost = DynamicRecord.GetIntValue(entry, "fixOnePointNeedSilver")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  local useSilver = (equipFullDurable - durable) * fixCost
  CommonConfirmDlg.ShowConfirm(textRes.Item[8318], string.format(textRes.Item[23], useSilver, itemBase.name), OperationFixEquip.FixCallback, {bagId = bagId, itemKey = itemKey})
  return true
end
def.static("number", "table").FixCallback = function(select, tag)
  if select == 1 then
    local fixEquip = require("netio.protocol.mzm.gsp.item.CFixEquipment").new(tag.bagId, tag.itemKey)
    gmodule.network.sendProtocol(fixEquip)
  end
end
OperationFixEquip.Commit()
return OperationFixEquip
