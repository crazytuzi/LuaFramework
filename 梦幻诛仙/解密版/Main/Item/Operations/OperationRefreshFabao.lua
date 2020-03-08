local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationRefreshFabao = Lplus.Extend(OperationBase, "OperationRefreshFabao")
local def = OperationRefreshFabao.define
def.field("boolean").bind = false
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.FABAO_XILIAN_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local key, item = ItemModule.Instance():SelectOneItemByItemType(ItemModule.EQUIPBAG, ItemType.FABAO_ITEM)
  if key <= 0 then
    Toast(textRes.Item[8334])
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  CommonConfirmDlg.ShowConfirm(textRes.Item[8329], textRes.Item[8328], function(selection, tag)
    if selection == 1 then
      local fabaoXilian = require("netio.protocol.mzm.gsp.item.CUseFabaoResetItem").new(item.uuid[1])
      gmodule.network.sendProtocol(fabaoXilian)
    end
  end, nil)
  return true
end
OperationRefreshFabao.Commit()
return OperationRefreshFabao
