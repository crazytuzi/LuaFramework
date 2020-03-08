local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local OperationImprovePartnerYuanShen = Lplus.Extend(OperationBase, "OperationImprovePartnerYuanShen")
local def = OperationImprovePartnerYuanShen.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.YUANSHEN_IMPROVE_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local closeTips = true
  local PartnerMain = require("Main.partner.ui.PartnerMain")
  if not PartnerMain.IsYuanShenOpen() then
    Toast(textRes.Partner.YuanShen[10])
    return closeTips
  end
  PartnerMain.Instance():ShowDlgByTabType(PartnerMain.TabType.Tab_YS)
  return closeTips
end
OperationImprovePartnerYuanShen.Commit()
return OperationImprovePartnerYuanShen
