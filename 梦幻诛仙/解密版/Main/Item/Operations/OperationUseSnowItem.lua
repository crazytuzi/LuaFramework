local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationUseSnowItem = Lplus.Extend(OperationBase, "OperationUseSnowItem")
local def = OperationUseSnowItem.define
local ITEM_ID = 210130100
local ACTIVITY_ID = 350000105
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Bag and item.id == ITEM_ID and ActivityInterface.Instance():isActivityOpend(ACTIVITY_ID) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local WorldGoalUtils = require("Main.activity.WorldGoal.WorldGoalUtils")
  local mainNpcId = WorldGoalUtils.GetNpcIdByActivityId(ACTIVITY_ID)
  if 0 == mainNpcId then
    return false
  end
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_World_Goal_Item, nil)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {mainNpcId})
  return true
end
OperationUseSnowItem.Commit()
return OperationUseSnowItem
