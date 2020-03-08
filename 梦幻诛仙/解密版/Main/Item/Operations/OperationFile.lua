local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GangModule = require("Main.Gang.GangModule")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local OperationFile = Lplus.Extend(OperationBase, "OperationFile")
local def = OperationFile.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.GANGFILE_ITEM then
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
    return false
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  if GangModule.Instance():HasGang() then
    local p = require("netio.protocol.mzm.gsp.item.CUseGangFileItem").new(item.uuid[1])
    gmodule.network.sendProtocol(p)
  else
    Toast(textRes.Item[8317])
    return false
  end
  return true
end
OperationFile.Commit()
return OperationFile
