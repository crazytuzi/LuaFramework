local CGetCrossBattleSelectionFightReq = class("CGetCrossBattleSelectionFightReq")
CGetCrossBattleSelectionFightReq.TYPEID = 12616989
function CGetCrossBattleSelectionFightReq:ctor(activity_cfg_id)
  self.id = 12616989
  self.activity_cfg_id = activity_cfg_id or nil
end
function CGetCrossBattleSelectionFightReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CGetCrossBattleSelectionFightReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CGetCrossBattleSelectionFightReq:sizepolicy(size)
  return size <= 65535
end
return CGetCrossBattleSelectionFightReq
