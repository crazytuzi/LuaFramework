local CLeaveCrossBattleSelectionMapReq = class("CLeaveCrossBattleSelectionMapReq")
CLeaveCrossBattleSelectionMapReq.TYPEID = 12616990
function CLeaveCrossBattleSelectionMapReq:ctor(activity_cfg_id)
  self.id = 12616990
  self.activity_cfg_id = activity_cfg_id or nil
end
function CLeaveCrossBattleSelectionMapReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CLeaveCrossBattleSelectionMapReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CLeaveCrossBattleSelectionMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveCrossBattleSelectionMapReq
