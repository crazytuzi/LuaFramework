local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local OperationDoublePoint = Lplus.Extend(OperationBase, "OperationDoublePoint")
local def = OperationDoublePoint.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.DOUBLE_POINT_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.static("number", "table").UseDoublePointCallback = function(i, tag)
  if i == 1 then
    local uuid = tag.uuid
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.item.CUseDoublePointReq").new(uuid))
  end
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local OnHookModule = require("Main.OnHook.OnHookModule")
  local OnHookUtils = require("Main.OnHook.OnHookUtils")
  local frozenPoolPointNum = OnHookModule.GetFrozenPoolPointNum()
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return false
  end
  local num = OnHookUtils.GetDoublePoint(item.id)
  local itemBase = ItemUtils.GetItemBase(item.id)
  local carryMax = OnHookUtils.GetCarryMaxNum()
  if carryMax < frozenPoolPointNum + num then
    local tag = {
      uuid = item.uuid[1]
    }
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.OnHook[18], itemBase.name, num), OperationDoublePoint.UseDoublePointCallback, tag)
  else
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.item.CUseDoublePointReq").new(item.uuid[1]))
  end
  return true
end
OperationDoublePoint.Commit()
return OperationDoublePoint
