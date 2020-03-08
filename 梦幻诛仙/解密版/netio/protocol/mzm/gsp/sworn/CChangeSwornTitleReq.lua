local CChangeSwornTitleReq = class("CChangeSwornTitleReq")
CChangeSwornTitleReq.TYPEID = 12597784
function CChangeSwornTitleReq:ctor(title)
  self.id = 12597784
  self.title = title or nil
end
function CChangeSwornTitleReq:marshal(os)
  os:marshalString(self.title)
end
function CChangeSwornTitleReq:unmarshal(os)
  self.title = os:unmarshalString()
end
function CChangeSwornTitleReq:sizepolicy(size)
  return size <= 65535
end
return CChangeSwornTitleReq
