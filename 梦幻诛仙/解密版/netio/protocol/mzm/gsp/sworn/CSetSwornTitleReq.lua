local CSetSwornTitleReq = class("CSetSwornTitleReq")
CSetSwornTitleReq.TYPEID = 12597762
function CSetSwornTitleReq:ctor(swornid, title)
  self.id = 12597762
  self.swornid = swornid or nil
  self.title = title or nil
end
function CSetSwornTitleReq:marshal(os)
  os:marshalInt64(self.swornid)
  os:marshalString(self.title)
end
function CSetSwornTitleReq:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.title = os:unmarshalString()
end
function CSetSwornTitleReq:sizepolicy(size)
  return size <= 65535
end
return CSetSwornTitleReq
