local CAutoBreedBabyReq = class("CAutoBreedBabyReq")
CAutoBreedBabyReq.TYPEID = 12609437
function CAutoBreedBabyReq:ctor(childid, client_yuanbao)
  self.id = 12609437
  self.childid = childid or nil
  self.client_yuanbao = client_yuanbao or nil
end
function CAutoBreedBabyReq:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt64(self.client_yuanbao)
end
function CAutoBreedBabyReq:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.client_yuanbao = os:unmarshalInt64()
end
function CAutoBreedBabyReq:sizepolicy(size)
  return size <= 65535
end
return CAutoBreedBabyReq
