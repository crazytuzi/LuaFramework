local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local OperationFabaoDecompose = Lplus.Extend(OperationBase, "OperationFabaoDecompose")
local def = OperationFabaoDecompose.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  return false
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8360]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self:CannotUseInFight() then
    return false
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  CommonConfirmDlg.ShowConfirm(textRes.Item[8361], textRes.Item[8362], function(selection, tag)
    if selection == 1 then
      local FabaoMgr = require("Main.Fabao.FabaoMgr")
      local params = {}
      params.bagid = bagId
      params.fabaoid = item.itemKey
      FabaoMgr.FabaoDecompose(params)
    end
  end, nil)
  return true
end
OperationFabaoDecompose.Commit()
return OperationFabaoDecompose
