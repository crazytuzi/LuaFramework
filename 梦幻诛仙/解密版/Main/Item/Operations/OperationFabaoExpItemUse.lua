local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local FabaoExp = require("Main.Fabao.ui.FabaoExpPanel")
local OperationFabaoExpItemUse = Lplus.Extend(OperationBase, "OperationFabaoExpItemUse")
local def = OperationFabaoExpItemUse.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.FabaoExp and (itemBase.itemType == ItemType.FABAO_FRAG_ITEM or itemBase.itemType == ItemType.FABAO_EXP_ITEM) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  return false
end
def.override("number", "number", "userdata", "table", "=>", "boolean").OperateAll = function(self, bagId, itemKey, m_panel, context)
  if not FabaoExp.Instance():CanAddExp(false) then
    return false
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  local itemBase = ItemUtils.GetItemBase(item.id)
  local askStr = string.format(textRes.Item[8323], HtmlHelper.NameColor[itemBase.namecolor], itemBase.name)
  local dlg = CommonConfirmDlg.ShowConfirm(textRes.Item[8324], askStr, function(selection, tag)
    if selection == 1 then
      FabaoExp.Instance():AddAllExp()
    end
  end, nil)
  dlg:rename(m_panel.name)
  return true
end
OperationFabaoExpItemUse.Commit()
return OperationFabaoExpItemUse
