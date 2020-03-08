local SNoMoreAwardNotice = class("SNoMoreAwardNotice")
SNoMoreAwardNotice.TYPEID = 12590342
function SNoMoreAwardNotice:ctor(outPostType)
  self.id = 12590342
  self.outPostType = outPostType or nil
end
function SNoMoreAwardNotice:marshal(os)
  os:marshalInt32(self.outPostType)
end
function SNoMoreAwardNotice:unmarshal(os)
  self.outPostType = os:unmarshalInt32()
end
function SNoMoreAwardNotice:sizepolicy(size)
  return size <= 65535
end
return SNoMoreAwardNotice
