local CGetCrossBattleFinalFightStageReq = class("CGetCrossBattleFinalFightStageReq")
CGetCrossBattleFinalFightStageReq.TYPEID = 12617064
function CGetCrossBattleFinalFightStageReq:ctor(activity_cfg_id, fight_zone_id, Final_stage)
  self.id = 12617064
  self.activity_cfg_id = activity_cfg_id or nil
  self.fight_zone_id = fight_zone_id or nil
  self.Final_stage = Final_stage or nil
end
function CGetCrossBattleFinalFightStageReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.fight_zone_id)
  os:marshalInt32(self.Final_stage)
end
function CGetCrossBattleFinalFightStageReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.fight_zone_id = os:unmarshalInt32()
  self.Final_stage = os:unmarshalInt32()
end
function CGetCrossBattleFinalFightStageReq:sizepolicy(size)
  return size <= 65535
end
return CGetCrossBattleFinalFightStageReq
