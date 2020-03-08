local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local OperationBase = require("Main.Item.Operations.OperationAccess")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationFurnitureAccess = Lplus.Extend(OperationBase, "OperationFurnitureAccess")
local FurnitureBag = require("Main.Homeland.FurnitureBag")
local def = OperationFurnitureAccess.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.FURNITURE_ITEM and source == ItemTipsMgr.Source.FurnitureBag then
    self.itemId = item.id
    local haveNum = FurnitureBag.Instance():GetFurnitureNumbersById(item.id)
    return haveNum == 0
  else
    return false
  end
end
OperationFurnitureAccess.Commit()
return OperationFurnitureAccess
