local CSetSwornNameReq = class("CSetSwornNameReq")
CSetSwornNameReq.TYPEID = 12597763
function CSetSwornNameReq:ctor(swornid, name1, name2)
  self.id = 12597763
  self.swornid = swornid or nil
  self.name1 = name1 or nil
  self.name2 = name2 or nil
end
function CSetSwornNameReq:marshal(os)
  os:marshalInt64(self.swornid)
  os:marshalString(self.name1)
  os:marshalString(self.name2)
end
function CSetSwornNameReq:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.name1 = os:unmarshalString()
  self.name2 = os:unmarshalString()
end
function CSetSwornNameReq:sizepolicy(size)
  return size <= 65535
end
return CSetSwornNameReq
