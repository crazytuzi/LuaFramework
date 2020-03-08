local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationAxes = Lplus.Extend(OperationBase, "OperationAxes")
local def = OperationAxes.define
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local ExchangeYuanBaoMgr = require("Main.Award.mgr.ExchangeYuanBaoMgr")
def.field("number")._iHasUsedCount = 0
def.field("number")._iLastItemKey = 0
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local bFeatureOpen = ExchangeYuanBaoMgr.IsUseAxesFeatureOpen()
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.AXE_ITEM and bFeatureOpen then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local bFeatureOpen = ExchangeYuanBaoMgr.IsUseAxesFeatureOpen()
  if not bFeatureOpen then
    Toast(textRes.Award.ExchangeYuanBao[5])
    return true
  end
  self:UseAxeItem(itemKey, 1)
  return false
end
def.override("number", "number", "userdata", "table", "=>", "boolean").OperateAll = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  local itemNum = ItemModule.Instance():GetItemCountById(item.id)
  if itemNum <= 0 then
    return true
  end
  local itemBase = ItemUtils.GetItemBase(item.id)
  local askStr = string.format(textRes.Item[8323], HtmlHelper.NameColor[itemBase.namecolor], itemBase.name)
  local dlg = CommonConfirmDlg.ShowConfirm(textRes.Item[8324], askStr, function(selection, tag)
    if selection == 1 then
      self:UseAxeItem(itemKey, item.number)
    end
  end, nil)
  dlg:rename(m_panel.name)
  return true
end
def.method("number", "number").UseAxeItem = function(self, itemKey, num)
  warn(">>>>itemKey=" .. itemKey, " _iLastItemKey=" .. self._iLastItemKey)
  if self._iLastItemKey == itemKey then
    self._iHasUsedCount = self._iHasUsedCount + 1
  else
    self._iHasUsedCount = 0
  end
  self._iLastItemKey = itemKey
  ExchangeYuanBaoMgr.SendUseAxesReq(itemKey, num)
end
return OperationAxes.Commit()
