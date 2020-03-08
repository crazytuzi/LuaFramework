local CEnterWorldGoalActivityMapReq = class("CEnterWorldGoalActivityMapReq")
CEnterWorldGoalActivityMapReq.TYPEID = 12594444
function CEnterWorldGoalActivityMapReq:ctor(activity_cfg_id, enter_activity_map_npc_id)
  self.id = 12594444
  self.activity_cfg_id = activity_cfg_id or nil
  self.enter_activity_map_npc_id = enter_activity_map_npc_id or nil
end
function CEnterWorldGoalActivityMapReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.enter_activity_map_npc_id)
end
function CEnterWorldGoalActivityMapReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.enter_activity_map_npc_id = os:unmarshalInt32()
end
function CEnterWorldGoalActivityMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterWorldGoalActivityMapReq
