local CBetInFinalReq = class("CBetInFinalReq")
CBetInFinalReq.TYPEID = 12617072
function CBetInFinalReq:ctor(activity_cfg_id, stage, fight_index, target_corps_id, sortid)
  self.id = 12617072
  self.activity_cfg_id = activity_cfg_id or nil
  self.stage = stage or nil
  self.fight_index = fight_index or nil
  self.target_corps_id = target_corps_id or nil
  self.sortid = sortid or nil
end
function CBetInFinalReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.fight_index)
  os:marshalInt64(self.target_corps_id)
  os:marshalInt32(self.sortid)
end
function CBetInFinalReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  self.fight_index = os:unmarshalInt32()
  self.target_corps_id = os:unmarshalInt64()
  self.sortid = os:unmarshalInt32()
end
function CBetInFinalReq:sizepolicy(size)
  return size <= 65535
end
return CBetInFinalReq
