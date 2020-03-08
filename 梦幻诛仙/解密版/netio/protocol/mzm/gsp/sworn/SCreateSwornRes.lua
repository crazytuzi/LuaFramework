local SCreateSwornRes = class("SCreateSwornRes")
SCreateSwornRes.TYPEID = 12597774
function SCreateSwornRes:ctor(swornid)
  self.id = 12597774
  self.swornid = swornid or nil
end
function SCreateSwornRes:marshal(os)
  os:marshalInt64(self.swornid)
end
function SCreateSwornRes:unmarshal(os)
  self.swornid = os:unmarshalInt64()
end
function SCreateSwornRes:sizepolicy(size)
  return size <= 65535
end
return SCreateSwornRes
