local SAllSwornTitleOK = class("SAllSwornTitleOK")
SAllSwornTitleOK.TYPEID = 12597780
function SAllSwornTitleOK:ctor(swornid)
  self.id = 12597780
  self.swornid = swornid or nil
end
function SAllSwornTitleOK:marshal(os)
  os:marshalInt64(self.swornid)
end
function SAllSwornTitleOK:unmarshal(os)
  self.swornid = os:unmarshalInt64()
end
function SAllSwornTitleOK:sizepolicy(size)
  return size <= 65535
end
return SAllSwornTitleOK
