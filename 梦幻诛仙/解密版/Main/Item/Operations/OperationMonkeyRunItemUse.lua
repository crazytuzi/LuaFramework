local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemData = require("Main.Item.ItemData")
local MonkeyRunUtils = require("Main.activity.MonkeyRun.MonkeyRunUtils")
local MonkeyRunMgr = require("Main.activity.MonkeyRun.MonkeyRunMgr")
local OperationMonkeyRunItemUse = Lplus.Extend(OperationBase, "OperationMonkeyRunItemUse")
local def = OperationMonkeyRunItemUse.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  warn("OperationMonkeyRunItemUse")
  if source == ItemTipsMgr.Source.Bag then
    local itemId = item.id
    local activityId = MonkeyRunUtils.GetMonkeyRunItemRelatedActivityId(itemId)
    if activityId == 0 then
      return false
    else
      return true
    end
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  MonkeyRunMgr.Instance():RequireToShowOutAwardPanel()
  return true
end
OperationMonkeyRunItemUse.Commit()
return OperationMonkeyRunItemUse
