local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationMooncakeIngredients = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationMooncakeIngredients.define
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.COOKIE_STUFF then
    local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    local isOpen = _G.IsFeatureOpen(Feature.TYPE_GUO_QING_MAKE_CAKES)
    return isOpen
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  require("Main.activity.NationalDay.ui.PanelXLSQ").ShowPanel()
  return true
end
return OperationMooncakeIngredients.Commit()
