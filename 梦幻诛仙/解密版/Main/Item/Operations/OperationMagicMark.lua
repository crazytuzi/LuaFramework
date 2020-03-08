local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local OperationMagicMark = Lplus.Extend(OperationBase, "OperationMagicMark")
local def = OperationMagicMark.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.MAGIC_MARK then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if _G.PlayerIsInFight() then
    Toast(textRes.Item[100])
    return false
  end
  if not gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK).enabled then
    Toast(textRes.MagicMark[18])
    return false
  end
  local itemData = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if itemData == nil then
    return
  end
  local itemCfg = gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK):GetMagicMarkItemCfg(itemData.id)
  require("Main.MagicMark.ui.DlgMagicMarkUnlock").Instance():ShowDlg(itemCfg.magicType)
  return true
end
OperationMagicMark.Commit()
return OperationMagicMark
