local CGetPlantTreeDetailInfoReq = class("CGetPlantTreeDetailInfoReq")
CGetPlantTreeDetailInfoReq.TYPEID = 12611602
function CGetPlantTreeDetailInfoReq:ctor(owner_id, activity_cfg_id)
  self.id = 12611602
  self.owner_id = owner_id or nil
  self.activity_cfg_id = activity_cfg_id or nil
end
function CGetPlantTreeDetailInfoReq:marshal(os)
  os:marshalInt64(self.owner_id)
  os:marshalInt32(self.activity_cfg_id)
end
function CGetPlantTreeDetailInfoReq:unmarshal(os)
  self.owner_id = os:unmarshalInt64()
  self.activity_cfg_id = os:unmarshalInt32()
end
function CGetPlantTreeDetailInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetPlantTreeDetailInfoReq
