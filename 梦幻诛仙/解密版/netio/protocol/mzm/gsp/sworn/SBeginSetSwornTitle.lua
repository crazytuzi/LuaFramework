local SBeginSetSwornTitle = class("SBeginSetSwornTitle")
SBeginSetSwornTitle.TYPEID = 12597764
function SBeginSetSwornTitle:ctor(swornid)
  self.id = 12597764
  self.swornid = swornid or nil
end
function SBeginSetSwornTitle:marshal(os)
  os:marshalInt64(self.swornid)
end
function SBeginSetSwornTitle:unmarshal(os)
  self.swornid = os:unmarshalInt64()
end
function SBeginSetSwornTitle:sizepolicy(size)
  return size <= 65535
end
return SBeginSetSwornTitle
