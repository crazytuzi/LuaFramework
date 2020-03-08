local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationLongJingUse = Lplus.Extend(OperationBase, "OperationLongJingUse")
local def = OperationLongJingUse.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.FABAO_LONGJING_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self:CannotUseInFight() then
    return false
  end
  local HeroProp = require("Main.Hero.Interface").GetHeroProp()
  local FabaoUtils = require("Main.Fabao.FabaoUtils")
  local roleLv = HeroProp.level
  local minLevel = FabaoUtils.GetFabaoConstValue("FABAO_OPEN_LEVEL") or 60
  if roleLv < minLevel then
    Toast(textRes.Fabao[35]:format(minLevel))
    return false
  end
  local FabaoModule = require("Main.Fabao.FabaoModule")
  local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
  local hasFabaoTask, taskId = FabaoModule.HasFabaoTask()
  if false == hasFabaoTask and 0 == taskId then
    FabaoSocialPanel.Instance():ShowPanel(FabaoSocialPanel.NodeId.FabaoXQ)
    return true
  else
    Toast(textRes.Fabao[131] or textRes.Fabao[59])
    return false
  end
end
OperationLongJingUse.Commit()
return OperationLongJingUse
