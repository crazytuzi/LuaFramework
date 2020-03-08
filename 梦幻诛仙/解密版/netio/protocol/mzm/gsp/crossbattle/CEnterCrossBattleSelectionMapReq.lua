local CEnterCrossBattleSelectionMapReq = class("CEnterCrossBattleSelectionMapReq")
CEnterCrossBattleSelectionMapReq.TYPEID = 12616991
function CEnterCrossBattleSelectionMapReq:ctor(activity_cfg_id)
  self.id = 12616991
  self.activity_cfg_id = activity_cfg_id or nil
end
function CEnterCrossBattleSelectionMapReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CEnterCrossBattleSelectionMapReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CEnterCrossBattleSelectionMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterCrossBattleSelectionMapReq
