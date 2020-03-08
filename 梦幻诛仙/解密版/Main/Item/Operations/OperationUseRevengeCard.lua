local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationUseRevengeCard = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationUseRevengeCard.define
local PKMgr = require("Main.PlayerPK.PKMgr")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local timer = 0
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if PKMgr.IsFeatureOpen() and source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.PK_REVENGE_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if timer ~= 0 and math.abs(os.clock() - timer) < 3 then
    Toast(textRes.PlayerPK.PK[75])
    return true
  end
  timer = os.clock()
  if _G.CheckCrossServerAndToast() then
    return true
  end
  local ItemModule = require("Main.Item.ItemModule")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local iCanUseTimes = item.extraMap[ItemXStoreType.PK_REVENGE_ITEM_AVAILABLE_TIMES]
  if iCanUseTimes == nil then
    require("Main.PlayerPK.PK.ui.UIBindPKPlayer").Instance():ShowPanel(bagId, itemKey)
  else
    if _G.PlayerIsInState(_G.RoleState.BATTLE) then
      Toast(textRes.PlayerPK.PK[74])
      return true
    end
    if PKMgr.IsInTeamAndNotLeader() then
      Toast(textRes.PlayerPK.PK[65])
      return true
    end
    PKMgr.GetProtocols().SendCUseRevengeItemReq(bagId, itemKey)
  end
  return true
end
return OperationUseRevengeCard.Commit()
