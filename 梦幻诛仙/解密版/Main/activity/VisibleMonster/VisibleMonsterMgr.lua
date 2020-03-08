local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local VisibleMonster = Lplus.Class(CUR_CLASS_NAME)
local def = VisibleMonster.define
local ActivityInterface = require("Main.activity.ActivityInterface")
local ChatModule = require("Main.Chat.ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local instance
def.static("=>", VisibleMonster).Instance = function()
  if instance == nil then
    instance = VisibleMonster()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncCommonVisibleMonsterFightTip", VisibleMonster.OnSSyncCommonVisibleMonsterFightTip)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, VisibleMonster.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, VisibleMonster.OnFunctionOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, VisibleMonster.OnFunctionOpenChange)
end
def.method("number", "=>", "number").GetActivityIdByFeatureType = function(self, featureType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_VISIBLE_MONSTER_ACTIVITY_FEATURE_CFG, featureType)
  if record == nil then
    return 0
  end
  local activityId = record:GetIntValue("activity_cfg_id")
  return activityId
end
def.method("number").ShowActivity = function(self, activityId)
  ActivityInterface.Instance():removeCustomCloseActivity(activityId)
end
def.method("number").HideActivity = function(self, activityId)
  ActivityInterface.Instance():addCustomCloseActivity(activityId)
end
def.method().HideAllFeatureClosedActivities = function(self)
  local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
  local entries = DynamicData.GetTable(CFG_PATH.DATA_VISIBLE_MONSTER_ACTIVITY_FEATURE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local hidedActivities = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local featureType = entry:GetIntValue("idip_module_switch_id")
    local activityId = entry:GetIntValue("activity_cfg_id")
    if not FeatureOpenListModule.Instance():CheckFeatureOpen(featureType) then
      hidedActivities[#hidedActivities + 1] = activityId
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  for i, activityId in ipairs(hidedActivities) do
    self:HideActivity(activityId)
  end
end
def.method().Release = function(self)
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  instance:Release()
end
def.static("table", "table").OnFunctionOpenInit = function(params, context)
  instance:HideAllFeatureClosedActivities()
end
def.static("table", "table").OnFunctionOpenChange = function(params, context)
  local feature = params.feature or 0
  local activityId = instance:GetActivityIdByFeatureType(feature)
  if activityId == 0 then
    return
  end
  if params.open then
    instance:ShowActivity(activityId)
  else
    instance:HideActivity(activityId)
  end
end
def.static("table").OnSSyncCommonVisibleMonsterFightTip = function(p)
  local monsterNameCfg = VisibleMonster.GetVisibleMonsterNameCfg(p.monster_category_id)
  if monsterNameCfg then
    local str
    if p.today_kill_times >= p.today_max_kill_times then
      str = string.format(textRes.activity[609], monsterNameCfg.monster_name)
    else
      str = string.format(textRes.activity[608], monsterNameCfg.monster_name, p.today_kill_times, p.today_max_kill_times - p.today_kill_times)
    end
    Toast(str)
  end
end
def.static("number", "=>", "table").GetVisibleMonsterNameCfg = function(mosterId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_VISIBLE_MONSTER_NAME_CFG, mosterId)
  if record == nil then
    warn("!!!!!GetVisibleMonsterNameCfg is nil:", mosterId)
    return nil
  end
  local cfg = {}
  cfg.monster_category_id = mosterId
  cfg.monster_name = record:GetStringValue("monster_name")
  return cfg
end
return VisibleMonster.Commit()
