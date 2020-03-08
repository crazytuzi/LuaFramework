local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local WingFabaoDetailDlg = require("Main.Equip.ui.WingFabaoDetailDlg")
local ItemModule = require("Main.Item.ItemModule")
local OperationWingFabaoDetail = Lplus.Extend(OperationBase, "OperationWingFabaoDetail")
local def = OperationWingFabaoDetail.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.FABAO_ITEM and (source == ItemTipsMgr.Source.FabaoBag or source == ItemTipsMgr.Source.Equip) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8108]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local FabaoModule = require("Main.Fabao.FabaoModule")
  local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
  local hasFabaoTask, taskId = FabaoModule.HasFabaoTask()
  if false == hasFabaoTask and 0 == taskId then
    FabaoSocialPanel.Instance():ShowPanelWithParams(FabaoSocialPanel.NodeId.FabaoBasic, {
      basicSubNode = FabaoSocialPanel.BasicSubNode.FabaoTuJian
    })
    return true
  else
    Toast(textRes.Fabao[131] or textRes.Fabao[59])
    return false
  end
end
OperationWingFabaoDetail.Commit()
return OperationWingFabaoDetail
