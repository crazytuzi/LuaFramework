local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local FoolsDayMgr = require("Main.Festival.FoolsDay.FoolsDayMgr")
local OperationGivingFoolsDayChest = Lplus.Extend(OperationBase, "OperationGivingFoolsDayChest")
local def = OperationGivingFoolsDayChest.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ItemUtils = require("Main.Item.ItemUtils")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.FOOLS_DAY_ACTIVITY_ITEM and not ItemUtils.IsItemBind(item) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8136]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local bFeatureOpen = FoolsDayMgr.Instance():GetFeatureOpen()
  if not bFeatureOpen then
    local moduleName = textRes.IDIP.PlayTypeName[FoolsDayMgr.GetFeatureType()]
    if moduleName then
      local tip = string.format(textRes.IDIP[7], moduleName)
      Toast(tip)
    end
    return true
  end
  local PresentPanel = require("Main.Present.ui.PresentPanel")
  local FriendData = require("Main.friend.FriendData")
  local objPresentPanel = PresentPanel.Instance()
  local friendsList = FriendData.Instance():GetFriendList()
  if friendsList == nil or #friendsList < 1 then
    Toast(textRes.Festival.FoolsDay[17])
    return true
  end
  objPresentPanel:ShowPanel(PresentPanel.StateConst.Item, nil)
  return true
end
return OperationGivingFoolsDayChest.Commit()
