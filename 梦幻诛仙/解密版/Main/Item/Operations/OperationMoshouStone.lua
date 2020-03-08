local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationMoshouStone = Lplus.Extend(OperationBase, "OperationMoshouStone")
local def = OperationMoshouStone.define
def.field("number").itemType = -1
def.field("number").source = -1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  return false
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  gmodule.moduleMgr:GetModule(ModuleId.ITEM):CloseInventoryDlg()
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpen = feature:CheckFeatureOpen(Feature.TYPE_COMMON_EXCHANGE)
  if isOpen then
    require("Main.Exchange.ui.ExchangePanel").Instance():ShowPanel()
  end
  return true
end
OperationMoshouStone.Commit()
return OperationMoshouStone
