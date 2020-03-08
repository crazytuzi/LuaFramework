local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local OperationVigor = Lplus.Extend(OperationBase, "OperationVigor")
local def = OperationVigor.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.VIGOR_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local vigor = require("netio.protocol.mzm.gsp.role.CUseVigorItemReq").new(itemKey, 0)
  gmodule.network.sendProtocol(vigor)
  return false
end
def.override("number", "number", "userdata", "table", "=>", "boolean").OperateAll = function(self, bagId, itemKey, m_panel, context)
  local ItemModule = require("Main.Item.ItemModule")
  local ItemUtils = require("Main.Item.ItemUtils")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  local itemBase = ItemUtils.GetItemBase(item.id)
  local askStr = string.format(textRes.Item[8323], HtmlHelper.NameColor[itemBase.namecolor], itemBase.name)
  local dlg = CommonConfirmDlg.ShowConfirm(textRes.Item[8324], askStr, function(selection, tag)
    if selection == 1 then
      local vigor = require("netio.protocol.mzm.gsp.role.CUseVigorItemReq").new(itemKey, 1)
      gmodule.network.sendProtocol(vigor)
    end
  end, nil)
  dlg:rename(m_panel.name)
  return true
end
OperationVigor.Commit()
return OperationVigor
