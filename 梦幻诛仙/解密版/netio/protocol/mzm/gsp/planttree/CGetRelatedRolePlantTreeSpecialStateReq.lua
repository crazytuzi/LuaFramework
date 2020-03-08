local CGetRelatedRolePlantTreeSpecialStateReq = class("CGetRelatedRolePlantTreeSpecialStateReq")
CGetRelatedRolePlantTreeSpecialStateReq.TYPEID = 12611603
function CGetRelatedRolePlantTreeSpecialStateReq:ctor(activity_cfg_id)
  self.id = 12611603
  self.activity_cfg_id = activity_cfg_id or nil
end
function CGetRelatedRolePlantTreeSpecialStateReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CGetRelatedRolePlantTreeSpecialStateReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CGetRelatedRolePlantTreeSpecialStateReq:sizepolicy(size)
  return size <= 65535
end
return CGetRelatedRolePlantTreeSpecialStateReq
