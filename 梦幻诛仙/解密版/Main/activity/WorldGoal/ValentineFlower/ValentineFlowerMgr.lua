local Lplus = require("Lplus")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ValentineFlowerModel = require("Main.activity.WorldGoal.ValentineFlower.ValentineFlowerModel")
local ValentineFlowerMgr = Lplus.Class("ValentineFlowerMgr")
local def = ValentineFlowerMgr.define
def.field("table").flowersInMap = nil
local instance
def.static("=>", ValentineFlowerMgr).Instance = function()
  if nil == instance then
    instance = ValentineFlowerMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ValentineFlowerMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, ValentineFlowerMgr.OnChangeMap)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_WorldGoal_Entity_Change, ValentineFlowerMgr.OnWorldGoalEntityChange)
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance:ClearFlowers()
end
def.static("table", "table").OnChangeMap = function(p1, p2)
  local mapId = p1[1]
  if not instance:IsValentineActivityMap(mapId) then
    instance:ClearFlowers()
  end
end
def.static("table", "table").OnWorldGoalEntityChange = function(p1, p2)
  if instance == nil then
    return
  end
  local cfgId = p1[1]
  local score = p1[2]
  local cfgInfo = require("Main.activity.WorldGoal.WorldGoalUtils").GetActivityInfoByCfgId(cfgId)
  if cfgInfo == nil then
    return
  end
  if cfgInfo.activityId == constant.CWorldGoalConsts.FLOWER_ACTIVITY_CFG_ID then
    instance:UpdateFlowersStatus(score)
  end
end
def.method("number", "=>", "boolean").IsValentineActivityMap = function(self, mapId)
  local WorldGoalUtils = require("Main.activity.WorldGoal.WorldGoalUtils")
  local activityInfo = WorldGoalUtils.GetSectionMapInfo(constant.CWorldGoalConsts.FLOWER_ACTIVITY_CFG_ID, 1)
  if activityInfo == nil then
    return false
  end
  if activityInfo.mapId == mapId then
    return true
  end
  return false
end
def.method("number").UpdateFlowersStatus = function(self, score)
  if self.flowersInMap == nil then
    self.flowersInMap = {}
  end
  local flowersCfg = ValentineFlowerMgr.GetValentineFlowersCfg()
  for i = 1, #flowersCfg do
    local modelId = 0
    if score < flowersCfg[i].trigger_point then
      modelId = flowersCfg[i].init_modle_id
    else
      modelId = flowersCfg[i].change_modle_id
    end
    if self.flowersInMap[i] == nil then
      self.flowersInMap[i] = ValentineFlowerModel.new()
    end
    self.flowersInMap[i] = self.flowersInMap[i]:ReplaceFlowerModel(modelId, flowersCfg[i].x, flowersCfg[i].y)
  end
end
def.method().ClearFlowers = function(self)
  if self.flowersInMap == nil then
    return
  end
  for i = 1, #self.flowersInMap do
    local flower = self.flowersInMap[i]
    flower:DestroyFlower()
  end
  self.flowersInMap = nil
end
def.method().ExitFlowersActivity = function(self)
  require("Main.activity.WorldGoal.WorldGoalMgr").Instance():CLeaveWorldGoalActivityMapReq(constant.CWorldGoalConsts.FLOWER_ACTIVITY_CFG_ID)
end
local cachedFlowersCfg
def.static("=>", "table").GetValentineFlowersCfg = function()
  if cachedFlowersCfg ~= nil then
    return cachedFlowersCfg
  end
  cachedFlowersCfg = {}
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_VALENTINE_FLOWER_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local flower = {}
    flower.id = record:GetIntValue("id")
    flower.sort_id = record:GetIntValue("sort_id")
    flower.x = record:GetIntValue("x")
    flower.y = record:GetIntValue("y")
    flower.trigger_point = record:GetIntValue("trigger_point")
    flower.init_modle_id = record:GetIntValue("init_modle_id")
    flower.change_modle_id = record:GetIntValue("change_modle_id")
    table.insert(cachedFlowersCfg, flower)
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return cachedFlowersCfg
end
ValentineFlowerMgr.Commit()
return ValentineFlowerMgr
