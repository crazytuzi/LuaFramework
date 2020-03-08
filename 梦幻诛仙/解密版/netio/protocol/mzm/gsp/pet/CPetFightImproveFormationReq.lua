local CPetFightImproveFormationReq = class("CPetFightImproveFormationReq")
CPetFightImproveFormationReq.TYPEID = 12590685
function CPetFightImproveFormationReq:ctor(formation_id, item_uuid, use_all)
  self.id = 12590685
  self.formation_id = formation_id or nil
  self.item_uuid = item_uuid or nil
  self.use_all = use_all or nil
end
function CPetFightImproveFormationReq:marshal(os)
  os:marshalInt32(self.formation_id)
  os:marshalInt64(self.item_uuid)
  os:marshalInt32(self.use_all)
end
function CPetFightImproveFormationReq:unmarshal(os)
  self.formation_id = os:unmarshalInt32()
  self.item_uuid = os:unmarshalInt64()
  self.use_all = os:unmarshalInt32()
end
function CPetFightImproveFormationReq:sizepolicy(size)
  return size <= 65535
end
return CPetFightImproveFormationReq
