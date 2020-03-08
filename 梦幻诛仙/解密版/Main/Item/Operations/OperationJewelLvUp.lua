local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationJewelLvUp = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationJewelLvUp.define
local JewelMgr = require("Main.GodWeapon.JewelMgr")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
local txtConst = textRes.GodWeapon.Jewel
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local bFeatureOpen = JewelMgr.IsFeatureOpen()
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.SUPER_EQUIPMENT_JEWEL_ITEM and bFeatureOpen then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return txtConst[5]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local bFeatureOpen = JewelMgr.IsFeatureOpen()
  if not bFeatureOpen then
    Toast(txtConst[11])
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    warn("Jewel item not exist")
    return true
  end
  local jewelItemCfg = JewelUtils.GetJewelItemByItemId(item.id, false)
  if jewelItemCfg.nxtLvItemId == 0 then
    Toast(txtConst[8])
    return true
  end
  local params = {
    itemId = item.id
  }
  require("Main.GodWeapon.ui.UIJewelBag").Instance():ShowWithParams(params)
  return true
end
return OperationJewelLvUp.Commit()
