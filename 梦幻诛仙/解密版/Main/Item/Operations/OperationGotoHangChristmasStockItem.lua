local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationGotoHangChristmasStockItem = Lplus.Extend(OperationBase, "OperationGotoHangChristmasStockItem")
local def = OperationGotoHangChristmasStockItem.define
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Bag and item.id == constant.CChristmasStockingConsts.CONSUME_ITEM_ID then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[13302]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if not require("Main.activity.ChristmasTree.ChristmasTreeMgr").Instance():CheckIsOpenAndToast() then
    return true
  end
  if gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):HaveHome() then
    gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):ReturnHome()
  else
    Toast(textRes.Homeland[60])
  end
  return true
end
return OperationGotoHangChristmasStockItem.Commit()
