local CChangeFloortieReq = class("CChangeFloortieReq")
CChangeFloortieReq.TYPEID = 12605499
function CChangeFloortieReq:ctor(furnitureId, furnitureUuId)
  self.id = 12605499
  self.furnitureId = furnitureId or nil
  self.furnitureUuId = furnitureUuId or nil
end
function CChangeFloortieReq:marshal(os)
  os:marshalInt32(self.furnitureId)
  os:marshalInt64(self.furnitureUuId)
end
function CChangeFloortieReq:unmarshal(os)
  self.furnitureId = os:unmarshalInt32()
  self.furnitureUuId = os:unmarshalInt64()
end
function CChangeFloortieReq:sizepolicy(size)
  return size <= 65535
end
return CChangeFloortieReq
