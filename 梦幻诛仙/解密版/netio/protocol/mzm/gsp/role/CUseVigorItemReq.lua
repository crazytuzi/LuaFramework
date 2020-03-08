local CUseVigorItemReq = class("CUseVigorItemReq")
CUseVigorItemReq.TYPEID = 12585993
function CUseVigorItemReq:ctor(itemKey, allUse)
  self.id = 12585993
  self.itemKey = itemKey or nil
  self.allUse = allUse or nil
end
function CUseVigorItemReq:marshal(os)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.allUse)
end
function CUseVigorItemReq:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
  self.allUse = os:unmarshalInt32()
end
function CUseVigorItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseVigorItemReq
