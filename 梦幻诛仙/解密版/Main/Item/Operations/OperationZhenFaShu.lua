local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local OperationZhenFaShu = Lplus.Extend(OperationBase, "OperationZhenFaShu")
local def = OperationZhenFaShu.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.ZHENFA_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local zhenfashu = require("Main.Item.ItemUtils").GetZhenFaShuItemCfg(item.id)
  local TeamData = require("Main.Team.TeamData")
  local FormationModule = require("Main.Formation.FormationModule")
  FormationModule.Instance():ShowFormationDlg(0, zhenfashu.formationId, function(id)
    if id <= 0 then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CReqCloseZhenfa").new())
    else
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CReqOpenZhenfa").new(id))
    end
  end)
  return true
end
OperationZhenFaShu.Commit()
return OperationZhenFaShu
