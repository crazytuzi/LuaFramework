local Lplus = require("Lplus")
local ZhuXianJianZhenData = Lplus.Class("ZhuXianJianZhenData")
local def = ZhuXianJianZhenData.define
local instance
def.field("table")._cfgData = nil
def.static("=>", ZhuXianJianZhenData).Instance = function()
  if instance == nil then
    instance = ZhuXianJianZhenData()
  end
  return instance
end
def.method("number").InitData = function(self, actCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ZHUXIANJIANZHEN, actCfgId)
  if record == nil then
    warn(">>>>Load ZhuXianJianZhen data error, actCfgId = " .. actCfgId .. "<<<<")
    return
  end
  self._cfgData = {}
  local retData = self._cfgData
  retData.activity_cfg_id = record:GetIntValue("activity_cfg_id")
  retData.moduleid = record:GetIntValue("moduleid")
  retData.npc_id = record:GetIntValue("npc_id")
  retData.npc_service_id = record:GetIntValue("npc_service_id")
  retData.activity_map_cfg_id = record:GetIntValue("activity_map_cfg_id")
  retData.collect_item_duration_in_second = record:GetIntValue("collect_item_duration_in_second")
  retData.collect_item_tips_duration_in_second = record:GetIntValue("collect_item_tips_duration_in_second")
  retData.collect_item_tips_id = record:GetIntValue("collect_item_tips_id")
  retData.commit_item_cfg_id = record:GetIntValue("commit_item_cfg_id")
  retData.commit_item_npc_id = record:GetIntValue("commit_item_npc_id")
  retData.commit_item_npc_service_id = record:GetIntValue("commit_item_npc_service_id")
  retData.commit_item_num = record:GetIntValue("commit_item_num")
  retData.kill_monster_duration_in_second = record:GetIntValue("kill_monster_duration_in_second")
  retData.kill_monster_num = record:GetIntValue("kill_monster_num")
  retData.kill_monster_tips_duration_in_second = record:GetIntValue("kill_monster_tips_duration_in_second")
  retData.kill_monster_tips_id = record:GetIntValue("kill_monster_tips_id")
  retData.daily_try_max_times = record:GetIntValue("daily_try_max_times")
  retData.effect_id = record:GetIntValue("effect_id")
  retData.effect_coord_x = record:GetIntValue("effect_coord_x")
  retData.effect_coord_y = record:GetIntValue("effect_coord_y")
  retData.collect_item_success_effect_id = record:GetIntValue("collect_item_success_effect_id")
  retData.desc = record:GetStringValue("desc")
end
def.method("=>", "number").GetNPCId = function(self)
  if self._cfgData == nil then
    return 0
  end
  return self._cfgData.npc_id
end
def.method("=>", "number").GetNPCServiceId = function(self)
  return self._cfgData.npc_service_id
end
def.method("=>", "number").GetCommitNPCServiceId = function(self)
  return self._cfgData.commit_item_npc_service_id
end
def.method("=>").GetCommitNPCId = function(self)
  return self._cfgData.commit_item_npc_id
end
def.method("=>", "table").GetFirstRoundTipsInfo = function(self)
  return {
    duration = self._cfgData.collect_item_tips_duration_in_second,
    tipsId = self._cfgData.collect_item_tips_id
  }
end
def.method("=>", "number").GetFirstRoundLimitTime = function(self)
  return self._cfgData.collect_item_duration_in_second
end
def.method("=>", "number").GetFirstRoundDstItemsNum = function(self)
  return self._cfgData.commit_item_num
end
def.method("=>", "table").GetSecondRoundTipsInfo = function(self)
  return {
    duration = self._cfgData.kill_monster_tips_duration_in_second,
    tipsId = self._cfgData.kill_monster_tips_id
  }
end
def.method("=>", "number").GetSecondRoundLimitTime = function(self)
  return self._cfgData.kill_monster_duration_in_second
end
def.method("=>", "number").GetSecondRoundDstNum = function(self)
  return self._cfgData.kill_monster_num
end
def.method("=>", "number").GetMapId = function(self)
  return self._cfgData.activity_map_cfg_id
end
def.method("=>", "number").GetMaxTryTimes = function(self)
  return self._cfgData.daily_try_max_times
end
def.method("=>", "table").GetEffectInfo = function(self)
  return {
    effectId = self._cfgData.effect_id,
    x = self._cfgData.effect_coord_x,
    y = self._cfgData.effect_coord_y
  }
end
def.method("=>", "number").GetUIEffectId = function(self)
  return self._cfgData.collect_item_success_effect_id
end
def.method("=>", "string").GetTalkContent = function(self)
  return self._cfgData.desc or ""
end
def.method().Release = function(self)
  self._cfgData = nil
end
def.method("=>", "boolean").IsNil = function(self)
  return self._cfgData == nil
end
return ZhuXianJianZhenData.Commit()
