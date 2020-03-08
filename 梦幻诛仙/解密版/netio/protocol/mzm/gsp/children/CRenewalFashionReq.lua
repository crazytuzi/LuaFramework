local CRenewalFashionReq = class("CRenewalFashionReq")
CRenewalFashionReq.TYPEID = 12609436
function CRenewalFashionReq:ctor(bagId, grid, fashionCfgId)
  self.id = 12609436
  self.bagId = bagId or nil
  self.grid = grid or nil
  self.fashionCfgId = fashionCfgId or nil
end
function CRenewalFashionReq:marshal(os)
  os:marshalInt32(self.bagId)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.fashionCfgId)
end
function CRenewalFashionReq:unmarshal(os)
  self.bagId = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.fashionCfgId = os:unmarshalInt32()
end
function CRenewalFashionReq:sizepolicy(size)
  return size <= 65535
end
return CRenewalFashionReq
