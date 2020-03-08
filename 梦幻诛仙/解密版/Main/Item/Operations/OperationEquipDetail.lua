local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemModule = require("Main.Item.ItemModule")
local OperationEquipDetail = Lplus.Extend(OperationBase, "OperationEquipDetail")
local def = OperationEquipDetail.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.EQUIP and (source == ItemTipsMgr.Source.Bag or source == ItemTipsMgr.Source.Equip) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8108]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local source = m_panel:FindDirect("Table_Tips")
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = source:GetComponent("UISprite")
  local itemId = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey).id
  EquipUtils.ShowEquipDetailsDlg(itemId, screenPos.x, screenPos.y - sprite:get_height() * 0.5, sprite:get_width(), sprite:get_height())
  return false
end
OperationEquipDetail.Commit()
return OperationEquipDetail
