local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationImproveLQ = Lplus.Extend(OperationBase, "OperationImproveLQ")
local def = OperationImproveLQ.define
local FabaoSpiritModule = require("Main.FabaoSpirit.FabaoSpiritModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if FabaoSpiritModule.IsFeatureOpen() and source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.FABAO_ARTIFACT_IMPROVE_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if not FabaoSpiritModule.CheckFeatureOpen() then
    Toast(textRes.FabaoSpirit[28])
    return true
  end
  local FabaoSpiritNode = require("Main.FabaoSpirit.ui.FabaoSpiritNode")
  FabaoSpiritNode.SetFirstSelectType(1)
  local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
  FabaoSocialPanel.Instance():ShowPanel(FabaoSocialPanel.NodeId.FabaoSpirit)
  return true
end
return OperationImproveLQ.Commit()
