local SSynZhuXianJianZhenActivityStageInfo = class("SSynZhuXianJianZhenActivityStageInfo")
SSynZhuXianJianZhenActivityStageInfo.TYPEID = 12614178
SSynZhuXianJianZhenActivityStageInfo.STAGE_OVER = 0
SSynZhuXianJianZhenActivityStageInfo.STAGE_COLLECT_ITEM = 1
SSynZhuXianJianZhenActivityStageInfo.STAGE_KILL_MONSTER = 2
SSynZhuXianJianZhenActivityStageInfo.STATE_BEGIN = 1
SSynZhuXianJianZhenActivityStageInfo.STATE_RUNNING = 2
SSynZhuXianJianZhenActivityStageInfo.STATE_END = 3
SSynZhuXianJianZhenActivityStageInfo.RESULT_NULL = 0
SSynZhuXianJianZhenActivityStageInfo.RESULT_SUCCESS = 1
SSynZhuXianJianZhenActivityStageInfo.RESULT_FAIL = 2
function SSynZhuXianJianZhenActivityStageInfo:ctor(activity_cfg_id, stage, state, result, commit_item_num, kill_monster_num, stage_collect_item_start_timestamp, stage_kill_monster_start_timestamp, daily_try_times)
  self.id = 12614178
  self.activity_cfg_id = activity_cfg_id or nil
  self.stage = stage or nil
  self.state = state or nil
  self.result = result or nil
  self.commit_item_num = commit_item_num or nil
  self.kill_monster_num = kill_monster_num or nil
  self.stage_collect_item_start_timestamp = stage_collect_item_start_timestamp or nil
  self.stage_kill_monster_start_timestamp = stage_kill_monster_start_timestamp or nil
  self.daily_try_times = daily_try_times or nil
end
function SSynZhuXianJianZhenActivityStageInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.state)
  os:marshalInt32(self.result)
  os:marshalInt32(self.commit_item_num)
  os:marshalInt32(self.kill_monster_num)
  os:marshalInt32(self.stage_collect_item_start_timestamp)
  os:marshalInt32(self.stage_kill_monster_start_timestamp)
  os:marshalInt32(self.daily_try_times)
end
function SSynZhuXianJianZhenActivityStageInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
  self.result = os:unmarshalInt32()
  self.commit_item_num = os:unmarshalInt32()
  self.kill_monster_num = os:unmarshalInt32()
  self.stage_collect_item_start_timestamp = os:unmarshalInt32()
  self.stage_kill_monster_start_timestamp = os:unmarshalInt32()
  self.daily_try_times = os:unmarshalInt32()
end
function SSynZhuXianJianZhenActivityStageInfo:sizepolicy(size)
  return size <= 65535
end
return SSynZhuXianJianZhenActivityStageInfo
