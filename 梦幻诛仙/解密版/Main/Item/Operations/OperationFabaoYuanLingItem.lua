local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local OperationFabaoYuanLingItem = Lplus.Extend(OperationBase, "OperationFabaoYuanLingItem")
local def = OperationFabaoYuanLingItem.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.FABAO_YUANLING_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local FabaoUtils = require("Main.Fabao.FabaoUtils")
  local HeroProp = require("Main.Hero.Interface").GetHeroProp()
  local minLevel = FabaoUtils.GetFabaoConstValue("FABAO_OPEN_LEVEL") or 60
  if minLevel > HeroProp.level then
    Toast(textRes.Fabao[54]:format(minLevel))
    return false
  end
  local FabaoModule = require("Main.Fabao.FabaoModule")
  local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
  local hasFabaoTask, taskId = FabaoModule.HasFabaoTask()
  if false == hasFabaoTask and 0 == taskId then
    FabaoSocialPanel.Instance():ShowPanelWithParams(FabaoSocialPanel.NodeId.FabaoCZ, {
      czSubNode = FabaoSocialPanel.CZSubNode.StarUp
    })
    return true
  else
    Toast(textRes.Fabao[131] or textRes.Fabao[59])
    return false
  end
end
OperationFabaoYuanLingItem.Commit()
return OperationFabaoYuanLingItem
