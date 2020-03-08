local CShareSuc = class("CShareSuc")
CShareSuc.TYPEID = 12592153
function CShareSuc:ctor(shareId, shareCount)
  self.id = 12592153
  self.shareId = shareId or nil
  self.shareCount = shareCount or nil
end
function CShareSuc:marshal(os)
  os:marshalInt32(self.shareId)
  os:marshalInt32(self.shareCount)
end
function CShareSuc:unmarshal(os)
  self.shareId = os:unmarshalInt32()
  self.shareCount = os:unmarshalInt32()
end
function CShareSuc:sizepolicy(size)
  return size <= 65535
end
return CShareSuc
