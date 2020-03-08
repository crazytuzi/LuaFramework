local CGetSelectionStageBetInfoReq = class("CGetSelectionStageBetInfoReq")
CGetSelectionStageBetInfoReq.TYPEID = 12617045
function CGetSelectionStageBetInfoReq:ctor(activity_cfg_id, fight_zone_id, selection_stage)
  self.id = 12617045
  self.activity_cfg_id = activity_cfg_id or nil
  self.fight_zone_id = fight_zone_id or nil
  self.selection_stage = selection_stage or nil
end
function CGetSelectionStageBetInfoReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.fight_zone_id)
  os:marshalInt32(self.selection_stage)
end
function CGetSelectionStageBetInfoReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.fight_zone_id = os:unmarshalInt32()
  self.selection_stage = os:unmarshalInt32()
end
function CGetSelectionStageBetInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetSelectionStageBetInfoReq
