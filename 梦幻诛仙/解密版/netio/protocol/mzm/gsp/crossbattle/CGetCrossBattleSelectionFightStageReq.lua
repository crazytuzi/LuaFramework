local CGetCrossBattleSelectionFightStageReq = class("CGetCrossBattleSelectionFightStageReq")
CGetCrossBattleSelectionFightStageReq.TYPEID = 12617013
function CGetCrossBattleSelectionFightStageReq:ctor(activity_cfg_id, fight_zone_id, selection_stage)
  self.id = 12617013
  self.activity_cfg_id = activity_cfg_id or nil
  self.fight_zone_id = fight_zone_id or nil
  self.selection_stage = selection_stage or nil
end
function CGetCrossBattleSelectionFightStageReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.fight_zone_id)
  os:marshalInt32(self.selection_stage)
end
function CGetCrossBattleSelectionFightStageReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.fight_zone_id = os:unmarshalInt32()
  self.selection_stage = os:unmarshalInt32()
end
function CGetCrossBattleSelectionFightStageReq:sizepolicy(size)
  return size <= 65535
end
return CGetCrossBattleSelectionFightStageReq
