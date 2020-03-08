local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local OperationOpenAircraftUI = Lplus.Extend(OperationBase, "OperationOpenAircraftUI")
local def = OperationOpenAircraftUI.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.AIR_CRAFT_ITEM and source == ItemTipsMgr.Source.Equip then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8128]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local AircraftInterface = require("Main.Aircraft.AircraftInterface")
  AircraftInterface.OpenAircraftPanel(AircraftInterface.GetCurAircraftId())
  return true
end
OperationOpenAircraftUI.Commit()
return OperationOpenAircraftUI
