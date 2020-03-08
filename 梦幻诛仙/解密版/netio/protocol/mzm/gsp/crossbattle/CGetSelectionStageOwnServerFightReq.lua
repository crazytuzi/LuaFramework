local CGetSelectionStageOwnServerFightReq = class("CGetSelectionStageOwnServerFightReq")
CGetSelectionStageOwnServerFightReq.TYPEID = 12617080
function CGetSelectionStageOwnServerFightReq:ctor(activity_cfg_id, selection_stage)
  self.id = 12617080
  self.activity_cfg_id = activity_cfg_id or nil
  self.selection_stage = selection_stage or nil
end
function CGetSelectionStageOwnServerFightReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.selection_stage)
end
function CGetSelectionStageOwnServerFightReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.selection_stage = os:unmarshalInt32()
end
function CGetSelectionStageOwnServerFightReq:sizepolicy(size)
  return size <= 65535
end
return CGetSelectionStageOwnServerFightReq
